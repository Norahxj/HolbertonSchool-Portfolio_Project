import pytest
from flask_jwt_extended import decode_token

from app.routes import task_assignment_routes


REGISTER_URL = "/api/auth/register"
CHILD_LOGIN_URL = "/api/auth/child-login"
CHILDREN_URL = "/api/children/"
ASSIGNMENTS_BY_CHILD_URL = "/api/task-assignments/child/{}"


def authorization_header(token):
    return {"Authorization": token}


def register_parent(
    client,
    email="assignments.by.child.parent@gmail.com",
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


def get_assignments_by_child_request(
    client,
    token,
    child_id,
):
    return client.get(
        ASSIGNMENTS_BY_CHILD_URL.format(child_id),
        headers=authorization_header(token),
    )


# ---------------------------------------------------------------------------
# Authentication and authorization
# ---------------------------------------------------------------------------

def test_get_assignments_by_child_requires_access_token(client):
    response = client.get(
        ASSIGNMENTS_BY_CHILD_URL.format("child-id")
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
def test_get_assignments_by_child_rejects_invalid_token(
    client,
    token,
):
    response = client.get(
        ASSIGNMENTS_BY_CHILD_URL.format("child-id"),
        headers=authorization_header(token),
    )

    assert response.status_code in (401, 422)


def test_child_token_cannot_get_assignments_by_child(client):
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

    response = get_assignments_by_child_request(
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

    def fake_get_assignments_for_child_by_parent(
        child_id,
        parent_id,
    ):
        captured["child_id"] = child_id
        captured["parent_id"] = parent_id
        return []

    monkeypatch.setattr(
        task_assignment_routes.assignment_service,
        "get_assignments_for_child_by_parent",
        fake_get_assignments_for_child_by_parent,
    )

    response = get_assignments_by_child_request(
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
        task_assignment_routes.assignment_service,
        "get_assignments_for_child_by_parent",
        lambda child_id, parent_id: None,
    )

    response = get_assignments_by_child_request(
        client,
        parent["access_token"],
        "missing-child",
    )

    assert response.status_code == 404
    assert response.get_json() == {
        "error": "Child not found or access denied"
    }


def test_route_returns_empty_list_when_child_has_no_assignments(
    client,
    monkeypatch,
):
    parent = register_parent(client)

    monkeypatch.setattr(
        task_assignment_routes.assignment_service,
        "get_assignments_for_child_by_parent",
        lambda child_id, parent_id: [],
    )

    response = get_assignments_by_child_request(
        client,
        parent["access_token"],
        "child-id",
    )

    assert response.status_code == 200
    assert response.get_json() == []


def test_route_uses_parent_assignments_schema_to_serialize(
    client,
    monkeypatch,
):
    parent = register_parent(client)
    assignments = [object(), object()]
    serialized = [
        {"id": "assignment-1"},
        {"id": "assignment-2"},
    ]
    captured = {}

    monkeypatch.setattr(
        task_assignment_routes.assignment_service,
        "get_assignments_for_child_by_parent",
        lambda child_id, parent_id: assignments,
    )

    def fake_dump(value):
        captured["value"] = value
        return serialized

    monkeypatch.setattr(
        task_assignment_routes.parent_assignments_response_schema,
        "dump",
        fake_dump,
    )

    response = get_assignments_by_child_request(
        client,
        parent["access_token"],
        "child-id",
    )

    assert response.status_code == 200
    assert response.get_json() == serialized
    assert captured["value"] is assignments


def test_route_does_not_serialize_when_child_is_not_found(
    client,
    monkeypatch,
):
    parent = register_parent(client)
    dump_called = {"value": False}

    monkeypatch.setattr(
        task_assignment_routes.assignment_service,
        "get_assignments_for_child_by_parent",
        lambda child_id, parent_id: None,
    )

    def fake_dump(value):
        dump_called["value"] = True
        return []

    monkeypatch.setattr(
        task_assignment_routes.parent_assignments_response_schema,
        "dump",
        fake_dump,
    )

    response = get_assignments_by_child_request(
        client,
        parent["access_token"],
        "missing-child",
    )

    assert response.status_code == 404
    assert dump_called["value"] is False


def test_route_serializes_assignment_task_and_child_fields(
    client,
    monkeypatch,
):
    parent = register_parent(client)

    class FakeTask:
        id = "task-id"
        title = "Clean room"
        description = "Clean your room"
        points = 10
        task_frequency = "DAILY"
        recurrence_day = None
        category = "MORAL"
        is_auto_verified = False

    class FakeChild:
        id = "child-id"
        name = "Sara"

    class FakeAssignment:
        id = "assignment-id"
        status = "PENDING_REVIEW"
        completed_at = None
        approved_at = None
        task = FakeTask()
        child = FakeChild()
        assigned_date = None

    monkeypatch.setattr(
        task_assignment_routes.assignment_service,
        "get_assignments_for_child_by_parent",
        lambda child_id, parent_id: [FakeAssignment()],
    )

    response = get_assignments_by_child_request(
        client,
        parent["access_token"],
        "child-id",
    )

    data = response.get_json()

    assert response.status_code == 200
    assert len(data) == 1
    assert data[0]["id"] == "assignment-id"
    assert data[0]["status"] == "PENDING_REVIEW"
    assert data[0]["completed_at"] is None
    assert data[0]["approved_at"] is None
    assert data[0]["task"]["id"] == "task-id"
    assert data[0]["task"]["title"] == "Clean room"
    assert data[0]["child"]["id"] == "child-id"
    assert data[0]["child"]["name"] == "Sara"


def test_route_preserves_assignment_order(
    client,
    monkeypatch,
):
    parent = register_parent(client)

    class FakeTask:
        id = "task-id"
        title = "Task"
        description = None
        points = 10
        task_frequency = "ONCE"
        recurrence_day = None
        category = "MORAL"
        is_auto_verified = False

    class FakeChild:
        id = "child-id"
        name = "Sara"

    class FakeAssignment:
        completed_at = None
        approved_at = None
        status = "PENDING"
        task = FakeTask()
        child = FakeChild()
        assigned_date = None

        def __init__(self, assignment_id):
            self.id = assignment_id

    monkeypatch.setattr(
        task_assignment_routes.assignment_service,
        "get_assignments_for_child_by_parent",
        lambda child_id, parent_id: [
            FakeAssignment("assignment-3"),
            FakeAssignment("assignment-1"),
            FakeAssignment("assignment-2"),
        ],
    )

    response = get_assignments_by_child_request(
        client,
        parent["access_token"],
        "child-id",
    )

    assert response.status_code == 200
    assert [
        assignment["id"]
        for assignment in response.get_json()
    ] == [
        "assignment-3",
        "assignment-1",
        "assignment-2",
    ]


# ---------------------------------------------------------------------------
# Service behavior
# ---------------------------------------------------------------------------

def test_service_passes_child_id_and_parent_id_to_child_repository(
    monkeypatch,
):
    service = task_assignment_routes.assignment_service
    captured = {}

    class FakeChild:
        id = "child-id"

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
    monkeypatch.setattr(
        service.task_assignment_repository,
        "get_assignments_by_child_id",
        lambda child_id: [],
    )

    result = service.get_assignments_for_child_by_parent(
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
    service = task_assignment_routes.assignment_service
    assignment_repository_called = {"value": False}

    monkeypatch.setattr(
        service.child_repository,
        "get_child_for_guardian",
        lambda child_id, parent_id: None,
    )

    def fake_get_assignments_by_child_id(child_id):
        assignment_repository_called["value"] = True
        return []

    monkeypatch.setattr(
        service.task_assignment_repository,
        "get_assignments_by_child_id",
        fake_get_assignments_by_child_id,
    )

    result = service.get_assignments_for_child_by_parent(
        "missing-child",
        "parent-id",
    )

    assert result is None
    assert assignment_repository_called["value"] is False


def test_service_passes_child_id_to_assignment_repository(
    monkeypatch,
):
    service = task_assignment_routes.assignment_service
    captured = {}
    expected_assignments = [object(), object()]

    class FakeChild:
        id = "child-id"

    monkeypatch.setattr(
        service.child_repository,
        "get_child_for_guardian",
        lambda child_id, parent_id: FakeChild(),
    )

    def fake_get_assignments_by_child_id(child_id):
        captured["child_id"] = child_id
        return expected_assignments

    monkeypatch.setattr(
        service.task_assignment_repository,
        "get_assignments_by_child_id",
        fake_get_assignments_by_child_id,
    )

    result = service.get_assignments_for_child_by_parent(
        "requested-child-id",
        "parent-id",
    )

    assert result is expected_assignments
    assert captured["child_id"] == "requested-child-id"


def test_service_returns_empty_repository_list(
    monkeypatch,
):
    service = task_assignment_routes.assignment_service

    class FakeChild:
        id = "child-id"

    monkeypatch.setattr(
        service.child_repository,
        "get_child_for_guardian",
        lambda child_id, parent_id: FakeChild(),
    )
    monkeypatch.setattr(
        service.task_assignment_repository,
        "get_assignments_by_child_id",
        lambda child_id: [],
    )

    result = service.get_assignments_for_child_by_parent(
        "child-id",
        "parent-id",
    )

    assert result == []


def test_service_returns_repository_result_without_change(
    monkeypatch,
):
    service = task_assignment_routes.assignment_service
    expected_assignments = [object(), object()]

    class FakeChild:
        id = "child-id"

    monkeypatch.setattr(
        service.child_repository,
        "get_child_for_guardian",
        lambda child_id, parent_id: FakeChild(),
    )
    monkeypatch.setattr(
        service.task_assignment_repository,
        "get_assignments_by_child_id",
        lambda child_id: expected_assignments,
    )

    result = service.get_assignments_for_child_by_parent(
        "child-id",
        "parent-id",
    )

    assert result is expected_assignments