import pytest
from flask_jwt_extended import decode_token

from app.routes import task_assignment_routes


REGISTER_URL = "/api/auth/register"
CHILD_LOGIN_URL = "/api/auth/child-login"
CHILDREN_URL = "/api/children/"
ASSIGNMENTS_BY_TASK_URL = "/api/task-assignments/task/{}"


def authorization_header(token):
    return {"Authorization": token}


def register_parent(
    client,
    email="assignments.by.task.parent@gmail.com",
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


def create_child(client, access_token):
    response = client.post(
        CHILDREN_URL,
        headers=authorization_header(access_token),
        json={
            "name": "Sara",
            "birth_date": "2015-05-10",
            "phone": "0559876543",
        },
    )

    assert response.status_code == 201, response.get_json()

    data = response.get_json()
    return data.get("child", data)


def get_assignments_by_task_request(client, token, task_id):
    return client.get(
        ASSIGNMENTS_BY_TASK_URL.format(task_id),
        headers=authorization_header(token),
    )


# ---------------------------------------------------------------------------
# Authentication and authorization
# ---------------------------------------------------------------------------

def test_get_assignments_by_task_requires_access_token(client):
    response = client.get(
        ASSIGNMENTS_BY_TASK_URL.format("task-id")
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
def test_get_assignments_by_task_rejects_invalid_token(
    client,
    token,
):
    response = client.get(
        ASSIGNMENTS_BY_TASK_URL.format("task-id"),
        headers=authorization_header(token),
    )

    assert response.status_code in (401, 422)


def test_child_token_cannot_get_assignments_by_task(client):
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

    response = get_assignments_by_task_request(
        client,
        child_token,
        "task-id",
    )

    assert response.status_code == 403
    assert response.get_json() == {
        "error": "Parent access required"
    }


# ---------------------------------------------------------------------------
# Route behavior
# ---------------------------------------------------------------------------

def test_route_passes_task_id_and_parent_id_to_service(
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

    def fake_get_assignments_for_task(
        task_id,
        parent_id,
    ):
        captured["task_id"] = task_id
        captured["parent_id"] = parent_id
        return []

    monkeypatch.setattr(
        task_assignment_routes.assignment_service,
        "get_assignments_for_task",
        fake_get_assignments_for_task,
    )

    response = get_assignments_by_task_request(
        client,
        parent["access_token"],
        "requested-task-id",
    )

    assert response.status_code == 200
    assert response.get_json() == []
    assert captured == {
        "task_id": "requested-task-id",
        "parent_id": expected_parent_id,
    }


def test_route_returns_404_when_service_returns_none(
    client,
    monkeypatch,
):
    parent = register_parent(client)

    monkeypatch.setattr(
        task_assignment_routes.assignment_service,
        "get_assignments_for_task",
        lambda task_id, parent_id: None,
    )

    response = get_assignments_by_task_request(
        client,
        parent["access_token"],
        "missing-task",
    )

    assert response.status_code == 404
    assert response.get_json() == {
        "error": "Task not found"
    }


def test_route_returns_empty_list_when_task_has_no_assignments(
    client,
    monkeypatch,
):
    parent = register_parent(client)

    monkeypatch.setattr(
        task_assignment_routes.assignment_service,
        "get_assignments_for_task",
        lambda task_id, parent_id: [],
    )

    response = get_assignments_by_task_request(
        client,
        parent["access_token"],
        "task-id",
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
        "get_assignments_for_task",
        lambda task_id, parent_id: assignments,
    )

    def fake_dump(value):
        captured["value"] = value
        return serialized

    monkeypatch.setattr(
        task_assignment_routes.parent_assignments_response_schema,
        "dump",
        fake_dump,
    )

    response = get_assignments_by_task_request(
        client,
        parent["access_token"],
        "task-id",
    )

    assert response.status_code == 200
    assert response.get_json() == serialized
    assert captured["value"] is assignments


def test_route_does_not_serialize_when_task_is_not_found(
    client,
    monkeypatch,
):
    parent = register_parent(client)
    dump_called = {"value": False}

    monkeypatch.setattr(
        task_assignment_routes.assignment_service,
        "get_assignments_for_task",
        lambda task_id, parent_id: None,
    )

    def fake_dump(value):
        dump_called["value"] = True
        return []

    monkeypatch.setattr(
        task_assignment_routes.parent_assignments_response_schema,
        "dump",
        fake_dump,
    )

    response = get_assignments_by_task_request(
        client,
        parent["access_token"],
        "missing-task",
    )

    assert response.status_code == 404
    assert dump_called["value"] is False


# ---------------------------------------------------------------------------
# Service behavior
# ---------------------------------------------------------------------------

def test_service_passes_task_id_and_parent_id_to_task_repository(
    monkeypatch,
):
    service = task_assignment_routes.assignment_service
    captured = {}

    class FakeTask:
        id = "task-id"

    fake_task = FakeTask()

    def fake_get_task_for_guardian_children(
        task_id,
        parent_id,
    ):
        captured["task_id"] = task_id
        captured["parent_id"] = parent_id
        return fake_task

    monkeypatch.setattr(
        service.task_repository,
        "get_task_for_guardian_children",
        fake_get_task_for_guardian_children,
    )
    monkeypatch.setattr(
        service.task_assignment_repository,
        "get_assignments_by_task_id",
        lambda task_id: [],
    )

    result = service.get_assignments_for_task(
        "task-id",
        "parent-id",
    )

    assert result == []
    assert captured == {
        "task_id": "task-id",
        "parent_id": "parent-id",
    }


def test_service_returns_none_when_task_is_not_accessible(
    monkeypatch,
):
    service = task_assignment_routes.assignment_service
    assignments_repository_called = {"value": False}

    monkeypatch.setattr(
        service.task_repository,
        "get_task_for_guardian_children",
        lambda task_id, parent_id: None,
    )

    def fake_get_assignments(task_id):
        assignments_repository_called["value"] = True
        return []

    monkeypatch.setattr(
        service.task_assignment_repository,
        "get_assignments_by_task_id",
        fake_get_assignments,
    )

    result = service.get_assignments_for_task(
        "missing-task",
        "parent-id",
    )

    assert result is None
    assert assignments_repository_called["value"] is False


def test_service_passes_task_id_to_assignment_repository(
    monkeypatch,
):
    service = task_assignment_routes.assignment_service
    captured = {}
    expected_assignments = [object(), object()]

    class FakeTask:
        id = "task-id"

    monkeypatch.setattr(
        service.task_repository,
        "get_task_for_guardian_children",
        lambda task_id, parent_id: FakeTask(),
    )

    def fake_get_assignments_by_task_id(task_id):
        captured["task_id"] = task_id
        return expected_assignments

    monkeypatch.setattr(
        service.task_assignment_repository,
        "get_assignments_by_task_id",
        fake_get_assignments_by_task_id,
    )

    result = service.get_assignments_for_task(
        "requested-task-id",
        "parent-id",
    )

    assert result is expected_assignments
    assert captured["task_id"] == "requested-task-id"


def test_service_returns_empty_list_from_assignment_repository(
    monkeypatch,
):
    service = task_assignment_routes.assignment_service

    class FakeTask:
        id = "task-id"

    monkeypatch.setattr(
        service.task_repository,
        "get_task_for_guardian_children",
        lambda task_id, parent_id: FakeTask(),
    )
    monkeypatch.setattr(
        service.task_assignment_repository,
        "get_assignments_by_task_id",
        lambda task_id: [],
    )

    result = service.get_assignments_for_task(
        "task-id",
        "parent-id",
    )

    assert result == []


def test_service_returns_assignment_repository_result_without_change(
    monkeypatch,
):
    service = task_assignment_routes.assignment_service
    expected_assignments = [object(), object()]

    class FakeTask:
        id = "task-id"

    monkeypatch.setattr(
        service.task_repository,
        "get_task_for_guardian_children",
        lambda task_id, parent_id: FakeTask(),
    )
    monkeypatch.setattr(
        service.task_assignment_repository,
        "get_assignments_by_task_id",
        lambda task_id: expected_assignments,
    )

    result = service.get_assignments_for_task(
        "task-id",
        "parent-id",
    )

    assert result is expected_assignments