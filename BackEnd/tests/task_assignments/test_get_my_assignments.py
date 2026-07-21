import pytest
from flask_jwt_extended import decode_token

from app.routes import task_assignment_routes


REGISTER_URL = "/api/auth/register"
CHILD_LOGIN_URL = "/api/auth/child-login"
CHILDREN_URL = "/api/children/"
MY_ASSIGNMENTS_URL = "/api/task-assignments/my"


def authorization_header(token):
    return {"Authorization": token}


def register_parent(
    client,
    email="my.assignments.parent@gmail.com",
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


def login_child(client, access_code):
    response = client.post(
        CHILD_LOGIN_URL,
        json={"access_code": access_code},
    )

    assert response.status_code == 200, response.get_json()
    return response.get_json()


def get_my_assignments(client, token):
    return client.get(
        MY_ASSIGNMENTS_URL,
        headers=authorization_header(token),
    )


# ---------------------------------------------------------------------------
# Authentication and authorization
# ---------------------------------------------------------------------------

def test_get_my_assignments_requires_access_token(client):
    response = client.get(MY_ASSIGNMENTS_URL)

    assert response.status_code == 401


@pytest.mark.parametrize(
    "token",
    [
        "invalid-token",
        "abc.def",
        "abc.def.ghi",
    ],
)
def test_get_my_assignments_rejects_invalid_token(
    client,
    token,
):
    response = client.get(
        MY_ASSIGNMENTS_URL,
        headers=authorization_header(token),
    )

    assert response.status_code in (401, 422)


def test_parent_cannot_get_child_my_assignments(client):
    parent = register_parent(client)

    response = get_my_assignments(
        client,
        parent["access_token"],
    )

    assert response.status_code == 403
    assert response.get_json() == {
        "error": "Child access required"
    }


# ---------------------------------------------------------------------------
# Route behavior
# ---------------------------------------------------------------------------

def test_route_passes_child_identity_to_service(
    client,
    app,
    monkeypatch,
):
    parent = register_parent(client)
    child = create_child(
        client,
        parent["access_token"],
    )
    child_login = login_child(
        client,
        child["access_code"],
    )

    with app.app_context():
        expected_child_id = decode_token(
            child_login["access_token"]
        )["sub"]

    captured = {}

    def fake_get_assignments_for_child(child_id):
        captured["child_id"] = child_id
        return []

    monkeypatch.setattr(
        task_assignment_routes.assignment_service,
        "get_assignments_for_child",
        fake_get_assignments_for_child,
    )

    response = get_my_assignments(
        client,
        child_login["access_token"],
    )

    assert response.status_code == 200
    assert response.get_json() == []
    assert captured == {
        "child_id": expected_child_id
    }


def test_route_returns_empty_list_when_child_has_no_assignments(
    client,
    monkeypatch,
):
    parent = register_parent(client)
    child = create_child(
        client,
        parent["access_token"],
    )
    child_login = login_child(
        client,
        child["access_code"],
    )

    monkeypatch.setattr(
        task_assignment_routes.assignment_service,
        "get_assignments_for_child",
        lambda child_id: [],
    )

    response = get_my_assignments(
        client,
        child_login["access_token"],
    )

    assert response.status_code == 200
    assert response.get_json() == []


def test_route_uses_child_assignments_schema_to_serialize(
    client,
    monkeypatch,
):
    parent = register_parent(client)
    child = create_child(
        client,
        parent["access_token"],
    )
    child_login = login_child(
        client,
        child["access_code"],
    )

    assignments = [object(), object()]
    serialized = [
        {"id": "assignment-1"},
        {"id": "assignment-2"},
    ]
    captured = {}

    monkeypatch.setattr(
        task_assignment_routes.assignment_service,
        "get_assignments_for_child",
        lambda child_id: assignments,
    )

    def fake_dump(value):
        captured["value"] = value
        return serialized

    monkeypatch.setattr(
        task_assignment_routes.child_assignments_response_schema,
        "dump",
        fake_dump,
    )

    response = get_my_assignments(
        client,
        child_login["access_token"],
    )

    assert response.status_code == 200
    assert response.get_json() == serialized
    assert captured["value"] is assignments


def test_route_serializes_child_assignment_fields(
    client,
    monkeypatch,
):
    parent = register_parent(client)
    child = create_child(
        client,
        parent["access_token"],
    )
    child_login = login_child(
        client,
        child["access_code"],
    )

    class FakeTask:
        id = "task-id"
        title = "Clean room"
        description = "Clean your room"
        points = 10
        task_frequency = "DAILY"
        recurrence_day = None
        category = "MORAL"
        is_auto_verified = False

    class FakeAssignment:
        id = "assignment-id"
        status = "PENDING"
        completed_at = None
        approved_at = None
        task = FakeTask()
        assigned_date = None

    monkeypatch.setattr(
        task_assignment_routes.assignment_service,
        "get_assignments_for_child",
        lambda child_id: [FakeAssignment()],
    )

    response = get_my_assignments(
        client,
        child_login["access_token"],
    )

    data = response.get_json()

    assert response.status_code == 200
    assert len(data) == 1
    assert data[0]["id"] == "assignment-id"
    assert data[0]["status"] == "PENDING"
    assert data[0]["completed_at"] is None
    assert data[0]["approved_at"] is None
    assert data[0]["task"]["id"] == "task-id"
    assert data[0]["task"]["title"] == "Clean room"


def test_route_preserves_assignment_order(
    client,
    monkeypatch,
):
    parent = register_parent(client)
    child = create_child(
        client,
        parent["access_token"],
    )
    child_login = login_child(
        client,
        child["access_code"],
    )

    class FakeTask:
        id = "task-id"
        title = "Task"
        description = None
        points = 10
        task_frequency = "ONCE"
        recurrence_day = None
        category = "MORAL"
        is_auto_verified = False

    class FakeAssignment:
        completed_at = None
        approved_at = None
        status = "PENDING"
        task = FakeTask()
        assigned_date = None

        def __init__(self, assignment_id):
            self.id = assignment_id

    monkeypatch.setattr(
        task_assignment_routes.assignment_service,
        "get_assignments_for_child",
        lambda child_id: [
            FakeAssignment("assignment-3"),
            FakeAssignment("assignment-1"),
            FakeAssignment("assignment-2"),
        ],
    )

    response = get_my_assignments(
        client,
        child_login["access_token"],
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

def test_service_passes_child_id_to_repository(
    monkeypatch,
):
    service = task_assignment_routes.assignment_service
    captured = {}

    def fake_get_assignments_by_child_id(child_id):
        captured["child_id"] = child_id
        return []

    monkeypatch.setattr(
        service.task_assignment_repository,
        "get_assignments_by_child_id",
        fake_get_assignments_by_child_id,
    )

    result = service.get_assignments_for_child(
        "child-id"
    )

    assert result == []
    assert captured == {
        "child_id": "child-id"
    }


def test_service_returns_empty_repository_list(
    monkeypatch,
):
    service = task_assignment_routes.assignment_service

    monkeypatch.setattr(
        service.task_assignment_repository,
        "get_assignments_by_child_id",
        lambda child_id: [],
    )

    result = service.get_assignments_for_child(
        "child-id"
    )

    assert result == []


def test_service_returns_repository_result_without_change(
    monkeypatch,
):
    service = task_assignment_routes.assignment_service
    expected_assignments = [object(), object()]

    monkeypatch.setattr(
        service.task_assignment_repository,
        "get_assignments_by_child_id",
        lambda child_id: expected_assignments,
    )

    result = service.get_assignments_for_child(
        "child-id"
    )

    assert result is expected_assignments