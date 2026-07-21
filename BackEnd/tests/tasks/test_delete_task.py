import pytest
from flask_jwt_extended import decode_token

from app.routes import task_routes


REGISTER_URL = "/api/auth/register"
CHILD_LOGIN_URL = "/api/auth/child-login"
CHILDREN_URL = "/api/children/"
TASK_URL = "/api/tasks/{}"


def authorization_header(token):
    return {"Authorization": token}


def register_parent(
    client,
    email="delete.task.parent@gmail.com",
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


def delete_task_request(client, token, task_id):
    return client.delete(
        TASK_URL.format(task_id),
        headers=authorization_header(token),
    )


# ---------------------------------------------------------------------------
# Authentication and authorization
# ---------------------------------------------------------------------------

def test_delete_task_requires_access_token(client):
    response = client.delete(TASK_URL.format("task-id"))

    assert response.status_code == 401


@pytest.mark.parametrize(
    "token",
    [
        "invalid-token",
        "abc.def",
        "abc.def.ghi",
    ],
)
def test_delete_task_rejects_invalid_token(client, token):
    response = client.delete(
        TASK_URL.format("task-id"),
        headers=authorization_header(token),
    )

    assert response.status_code in (401, 422)


def test_child_cannot_delete_task(client):
    parent = register_parent(client)
    child = create_child(client, parent["access_token"])

    login_response = client.post(
        CHILD_LOGIN_URL,
        json={"access_code": child["access_code"]},
    )
    assert login_response.status_code == 200

    child_token = login_response.get_json()["access_token"]

    response = delete_task_request(
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

    def fake_delete_task_for_parent(task_id, parent_id):
        captured["task_id"] = task_id
        captured["parent_id"] = parent_id
        return True, None

    monkeypatch.setattr(
        task_routes.task_service,
        "delete_task_for_parent",
        fake_delete_task_for_parent,
    )

    response = delete_task_request(
        client,
        parent["access_token"],
        "requested-task-id",
    )

    assert response.status_code == 200
    assert response.get_json() == {
        "message": "Task deleted successfully"
    }
    assert captured == {
        "task_id": "requested-task-id",
        "parent_id": expected_parent_id,
    }


def test_route_returns_404_when_task_not_found(
    client,
    monkeypatch,
):
    parent = register_parent(client)

    monkeypatch.setattr(
        task_routes.task_service,
        "delete_task_for_parent",
        lambda task_id, parent_id: (
            False,
            "task_not_found",
        ),
    )

    response = delete_task_request(
        client,
        parent["access_token"],
        "missing-task",
    )

    assert response.status_code == 404
    assert response.get_json() == {
        "error": "Task not found"
    }


def test_route_returns_500_when_delete_fails(
    client,
    monkeypatch,
):
    parent = register_parent(client)

    monkeypatch.setattr(
        task_routes.task_service,
        "delete_task_for_parent",
        lambda task_id, parent_id: (
            False,
            "delete_error",
        ),
    )

    response = delete_task_request(
        client,
        parent["access_token"],
        "task-id",
    )

    assert response.status_code == 500
    assert response.get_json() == {
        "error": "Failed to delete task"
    }


def test_route_returns_success_for_no_error(
    client,
    monkeypatch,
):
    parent = register_parent(client)

    monkeypatch.setattr(
        task_routes.task_service,
        "delete_task_for_parent",
        lambda task_id, parent_id: (
            True,
            None,
        ),
    )

    response = delete_task_request(
        client,
        parent["access_token"],
        "task-id",
    )

    assert response.status_code == 200
    assert response.get_json() == {
        "message": "Task deleted successfully"
    }


def test_route_ignores_service_success_value_when_error_is_none(
    client,
    monkeypatch,
):
    parent = register_parent(client)

    monkeypatch.setattr(
        task_routes.task_service,
        "delete_task_for_parent",
        lambda task_id, parent_id: (
            False,
            None,
        ),
    )

    response = delete_task_request(
        client,
        parent["access_token"],
        "task-id",
    )

    assert response.status_code == 200
    assert response.get_json() == {
        "message": "Task deleted successfully"
    }


# ---------------------------------------------------------------------------
# Service behavior
# ---------------------------------------------------------------------------

def test_service_passes_task_id_and_parent_id_to_repository(
    monkeypatch,
):
    service = task_routes.task_service
    captured = {}

    class FakeTask:
        id = "task-id"

    fake_task = FakeTask()

    def fake_get_task_for_creator(task_id, parent_id):
        captured["task_id"] = task_id
        captured["parent_id"] = parent_id
        return fake_task

    monkeypatch.setattr(
        service.task_repository,
        "get_task_for_creator",
        fake_get_task_for_creator,
    )
    monkeypatch.setattr(
        service.task_repository,
        "delete_task",
        lambda task: (True, None),
    )

    result = service.delete_task_for_parent(
        "task-id",
        "parent-id",
    )

    assert result == (True, None)
    assert captured == {
        "task_id": "task-id",
        "parent_id": "parent-id",
    }


def test_service_returns_task_not_found_when_repository_returns_none(
    monkeypatch,
):
    service = task_routes.task_service
    delete_called = {"value": False}

    monkeypatch.setattr(
        service.task_repository,
        "get_task_for_creator",
        lambda task_id, parent_id: None,
    )

    def fake_delete_task(task):
        delete_called["value"] = True
        return True, None

    monkeypatch.setattr(
        service.task_repository,
        "delete_task",
        fake_delete_task,
    )

    result = service.delete_task_for_parent(
        "missing-task",
        "parent-id",
    )

    assert result == (False, "task_not_found")
    assert delete_called["value"] is False


def test_service_passes_found_task_to_delete_repository(
    monkeypatch,
):
    service = task_routes.task_service
    captured = {}

    class FakeTask:
        id = "task-id"

    fake_task = FakeTask()

    monkeypatch.setattr(
        service.task_repository,
        "get_task_for_creator",
        lambda task_id, parent_id: fake_task,
    )

    def fake_delete_task(task):
        captured["task"] = task
        return True, None

    monkeypatch.setattr(
        service.task_repository,
        "delete_task",
        fake_delete_task,
    )

    result = service.delete_task_for_parent(
        "task-id",
        "parent-id",
    )

    assert result == (True, None)
    assert captured["task"] is fake_task


def test_service_returns_delete_error_when_repository_delete_fails(
    monkeypatch,
):
    service = task_routes.task_service

    class FakeTask:
        id = "task-id"

    fake_task = FakeTask()

    monkeypatch.setattr(
        service.task_repository,
        "get_task_for_creator",
        lambda task_id, parent_id: fake_task,
    )
    monkeypatch.setattr(
        service.task_repository,
        "delete_task",
        lambda task: (
            False,
            "integrity_error",
        ),
    )

    result = service.delete_task_for_parent(
        "task-id",
        "parent-id",
    )

    assert result == (False, "delete_error")


def test_service_returns_success_when_repository_delete_succeeds(
    monkeypatch,
):
    service = task_routes.task_service

    class FakeTask:
        id = "task-id"

    fake_task = FakeTask()

    monkeypatch.setattr(
        service.task_repository,
        "get_task_for_creator",
        lambda task_id, parent_id: fake_task,
    )
    monkeypatch.setattr(
        service.task_repository,
        "delete_task",
        lambda task: (
            True,
            None,
        ),
    )

    result = service.delete_task_for_parent(
        "task-id",
        "parent-id",
    )

    assert result == (True, None)


def test_service_treats_false_success_as_delete_error_even_without_error(
    monkeypatch,
):
    service = task_routes.task_service

    class FakeTask:
        id = "task-id"

    fake_task = FakeTask()

    monkeypatch.setattr(
        service.task_repository,
        "get_task_for_creator",
        lambda task_id, parent_id: fake_task,
    )
    monkeypatch.setattr(
        service.task_repository,
        "delete_task",
        lambda task: (
            False,
            None,
        ),
    )

    result = service.delete_task_for_parent(
        "task-id",
        "parent-id",
    )

    assert result == (False, "delete_error")