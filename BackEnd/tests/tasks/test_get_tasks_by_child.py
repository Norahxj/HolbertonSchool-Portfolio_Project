import pytest
from flask_jwt_extended import decode_token

from app.routes import task_routes


REGISTER_URL = "/api/auth/register"
CHILD_LOGIN_URL = "/api/auth/child-login"
CHILDREN_URL = "/api/children/"
TASKS_BY_CHILD_URL = "/api/tasks/child/{}"


def authorization_header(token):
    return {"Authorization": token}


def register_parent(
    client,
    email="tasks.by.child.parent@gmail.com",
    phone="0551234567",
):
    response = client.post(
        REGISTER_URL,
        json={
            "first_name": "Manar",
            "last_name": "Zaid",
            "phone": phone,
            "email": email,
            "password": "Password123!",
            "guardian_type": "mother",
        },
    )
    assert response.status_code == 201, response.get_json()
    return response.get_json()


def create_child(
    client,
    access_token,
    name="Sara",
    phone="0559876543",
):
    response = client.post(
        CHILDREN_URL,
        headers=authorization_header(access_token),
        json={
            "name": name,
            "birth_date": "2015-05-10",
            "phone": phone,
        },
    )
    assert response.status_code == 201, response.get_json()

    data = response.get_json()
    return data.get("child", data)


def get_tasks_by_child_request(client, token, child_id):
    return client.get(
        TASKS_BY_CHILD_URL.format(child_id),
        headers=authorization_header(token),
    )


# ---------------------------------------------------------------------------
# Authentication and authorization
# ---------------------------------------------------------------------------

def test_get_tasks_by_child_requires_access_token(client):
    response = client.get(
        TASKS_BY_CHILD_URL.format("child-id")
    )

    assert response.status_code == 401


@pytest.mark.parametrize(
    "token",
    [
        "invalid-token",
        "abc.def",
        "abc.def.ghi",
    ],
)
def test_get_tasks_by_child_rejects_invalid_token(
    client,
    token,
):
    response = client.get(
        TASKS_BY_CHILD_URL.format("child-id"),
        headers=authorization_header(token),
    )

    assert response.status_code in (401, 422)


def test_child_token_cannot_get_tasks_by_child(client):
    parent = register_parent(client)
    child = create_child(
        client,
        parent["access_token"],
    )

    login_response = client.post(
        CHILD_LOGIN_URL,
        json={"access_code": child["access_code"]},
    )
    assert login_response.status_code == 200

    child_token = login_response.get_json()["access_token"]

    response = get_tasks_by_child_request(
        client,
        child_token,
        child["id"],
    )

    assert response.status_code == 403
    assert response.get_json() == {
        "error": "Parent access required"
    }


# ---------------------------------------------------------------------------
# Route behavior
# ---------------------------------------------------------------------------

def test_route_passes_child_id_and_parent_id_to_service(
    client,
    app,
    monkeypatch,
):
    parent = register_parent(client)
    captured = {}

    with app.app_context():
        expected_parent_id = decode_token(
            parent["access_token"]
        )["sub"]

    def fake_get_tasks_by_child_for_parent(
        child_id,
        parent_id,
    ):
        captured["child_id"] = child_id
        captured["parent_id"] = parent_id
        return []

    monkeypatch.setattr(
        task_routes.task_service,
        "get_tasks_by_child_for_parent",
        fake_get_tasks_by_child_for_parent,
    )

    response = get_tasks_by_child_request(
        client,
        parent["access_token"],
        "requested-child-id",
    )

    assert response.status_code == 200
    assert response.get_json() == []
    assert captured == {
        "child_id": "requested-child-id",
        "parent_id": expected_parent_id,
    }


def test_route_returns_404_when_service_returns_none(
    client,
    monkeypatch,
):
    parent = register_parent(client)

    monkeypatch.setattr(
        task_routes.task_service,
        "get_tasks_by_child_for_parent",
        lambda child_id, parent_id: None,
    )

    response = get_tasks_by_child_request(
        client,
        parent["access_token"],
        "missing-child",
    )

    assert response.status_code == 404
    assert response.get_json() == {
        "error": "Child not found"
    }


def test_route_returns_empty_list_when_child_has_no_tasks(
    client,
    monkeypatch,
):
    parent = register_parent(client)

    monkeypatch.setattr(
        task_routes.task_service,
        "get_tasks_by_child_for_parent",
        lambda child_id, parent_id: [],
    )

    response = get_tasks_by_child_request(
        client,
        parent["access_token"],
        "child-id",
    )

    assert response.status_code == 200
    assert response.get_json() == []


def test_route_serializes_tasks_list(
    client,
    monkeypatch,
):
    parent = register_parent(client)

    class FakeTaskOne:
        id = "task-1"
        title = "Task one"
        description = "Description one"
        points = 10
        task_frequency = "ONCE"
        recurrence_day = None
        category = "MORAL"
        is_auto_verified = False
        created_by = "parent-id"
        created_at = None

    class FakeTaskTwo:
        id = "task-2"
        title = "Task two"
        description = "Description two"
        points = 20
        task_frequency = "WEEKLY"
        recurrence_day = 3
        category = "FINANCIAL"
        is_auto_verified = True
        created_by = "parent-id"
        created_at = None

    monkeypatch.setattr(
        task_routes.task_service,
        "get_tasks_by_child_for_parent",
        lambda child_id, parent_id: [
            FakeTaskOne(),
            FakeTaskTwo(),
        ],
    )

    response = get_tasks_by_child_request(
        client,
        parent["access_token"],
        "child-id",
    )

    assert response.status_code == 200
    assert response.get_json() == [
        {
            "id": "task-1",
            "title": "Task one",
            "description": "Description one",
            "points": 10,
            "task_frequency": "ONCE",
            "recurrence_day": None,
            "category": "MORAL",
            "is_auto_verified": False,
            "created_by": "parent-id",
            "created_at": None,
        },
        {
            "id": "task-2",
            "title": "Task two",
            "description": "Description two",
            "points": 20,
            "task_frequency": "WEEKLY",
            "recurrence_day": 3,
            "category": "FINANCIAL",
            "is_auto_verified": True,
            "created_by": "parent-id",
            "created_at": None,
        },
    ]


def test_route_preserves_service_task_order(
    client,
    monkeypatch,
):
    parent = register_parent(client)

    class FakeTask:
        description = None
        points = 10
        task_frequency = "ONCE"
        recurrence_day = None
        category = "MORAL"
        is_auto_verified = False
        created_by = "parent-id"
        created_at = None

        def __init__(self, task_id, title):
            self.id = task_id
            self.title = title

    monkeypatch.setattr(
        task_routes.task_service,
        "get_tasks_by_child_for_parent",
        lambda child_id, parent_id: [
            FakeTask("task-2", "Second"),
            FakeTask("task-1", "First"),
        ],
    )

    response = get_tasks_by_child_request(
        client,
        parent["access_token"],
        "child-id",
    )

    assert response.status_code == 200
    assert [
        task["id"] for task in response.get_json()
    ] == ["task-2", "task-1"]


# ---------------------------------------------------------------------------
# Service behavior
# ---------------------------------------------------------------------------

def test_service_passes_child_id_and_parent_id_to_repository(
    monkeypatch,
):
    service = task_routes.task_service
    captured = {}

    class FakeChild:
        task_children = []

    fake_child = FakeChild()

    def fake_get_child_for_guardian(
        child_id,
        parent_id,
    ):
        captured["child_id"] = child_id
        captured["parent_id"] = parent_id
        return fake_child

    monkeypatch.setattr(
        service.child_repository,
        "get_child_for_guardian",
        fake_get_child_for_guardian,
    )

    result = service.get_tasks_by_child_for_parent(
        "child-id",
        "parent-id",
    )

    assert result == []
    assert captured == {
        "child_id": "child-id",
        "parent_id": "parent-id",
    }


def test_service_returns_none_when_child_is_not_accessible(
    monkeypatch,
):
    service = task_routes.task_service

    monkeypatch.setattr(
        service.child_repository,
        "get_child_for_guardian",
        lambda child_id, parent_id: None,
    )

    result = service.get_tasks_by_child_for_parent(
        "missing-child",
        "parent-id",
    )

    assert result is None


def test_service_returns_empty_list_when_child_has_no_task_children(
    monkeypatch,
):
    service = task_routes.task_service

    class FakeChild:
        task_children = []

    monkeypatch.setattr(
        service.child_repository,
        "get_child_for_guardian",
        lambda child_id, parent_id: FakeChild(),
    )

    result = service.get_tasks_by_child_for_parent(
        "child-id",
        "parent-id",
    )

    assert result == []


def test_service_extracts_task_from_each_task_child(
    monkeypatch,
):
    service = task_routes.task_service

    task_one = object()
    task_two = object()

    class FakeTaskChild:
        def __init__(self, task):
            self.task = task

    class FakeChild:
        task_children = [
            FakeTaskChild(task_one),
            FakeTaskChild(task_two),
        ]

    monkeypatch.setattr(
        service.child_repository,
        "get_child_for_guardian",
        lambda child_id, parent_id: FakeChild(),
    )

    result = service.get_tasks_by_child_for_parent(
        "child-id",
        "parent-id",
    )

    assert result == [task_one, task_two]


def test_service_preserves_task_children_order(
    monkeypatch,
):
    service = task_routes.task_service

    class FakeTask:
        def __init__(self, task_id):
            self.id = task_id

    class FakeTaskChild:
        def __init__(self, task):
            self.task = task

    class FakeChild:
        task_children = [
            FakeTaskChild(FakeTask("task-3")),
            FakeTaskChild(FakeTask("task-1")),
            FakeTaskChild(FakeTask("task-2")),
        ]

    monkeypatch.setattr(
        service.child_repository,
        "get_child_for_guardian",
        lambda child_id, parent_id: FakeChild(),
    )

    result = service.get_tasks_by_child_for_parent(
        "child-id",
        "parent-id",
    )

    assert [task.id for task in result] == [
        "task-3",
        "task-1",
        "task-2",
    ]