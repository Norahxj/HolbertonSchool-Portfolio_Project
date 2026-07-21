from datetime import datetime, timezone

import pytest
from flask_jwt_extended import decode_token

from app.routes import task_assignment_routes
import app.services.task_assignment_service as service_module


REGISTER_URL = "/api/auth/register"
CHILDREN_URL = "/api/children/"
CHILD_LOGIN_URL = "/api/auth/child-login"
URL = "/api/task-assignments/{}/approve"


def h(token):
    return {"Authorization": token}


def reg(
    client,
    email="approve.parent@gmail.com",
    phone="0551111111",
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


def child(client, token):
    response = client.post(
        CHILDREN_URL,
        headers=h(token),
        json={
            "name": "Sara",
            "birth_date": "2015-05-10",
            "phone": "0559999999",
        },
    )

    assert response.status_code == 201, response.get_json()
    data = response.get_json()
    return data.get("child", data)


def login_child(client, code):
    response = client.post(
        CHILD_LOGIN_URL,
        json={"access_code": code},
    )

    assert response.status_code == 200, response.get_json()
    return response.get_json()


def req(client, token, assignment_id):
    return client.put(
        URL.format(assignment_id),
        headers=h(token),
    )


def test_requires_token(client):
    response = client.put(URL.format("x"))

    assert response.status_code == 401


@pytest.mark.parametrize(
    "token",
    ["bad", "a.b", "a.b.c"],
)
def test_invalid_token(client, token):
    response = client.put(
        URL.format("x"),
        headers=h(token),
    )

    assert response.status_code in (401, 422)


def test_child_forbidden(client):
    parent = reg(client)
    created_child = child(
        client,
        parent["access_token"],
    )
    child_token = login_child(
        client,
        created_child["access_code"],
    )["access_token"]

    response = req(
        client,
        child_token,
        "id",
    )

    assert response.status_code == 403
    assert response.get_json() == {
        "error": "Parent access required"
    }


def test_route_passes_ids(client, app, monkeypatch):
    parent = reg(client)

    with app.app_context():
        parent_id = decode_token(
            parent["access_token"]
        )["sub"]

    captured = {}

    class Assignment:
        id = "1"

    def fake_approve_assignment(
        assignment_id,
        requested_parent_id,
    ):
        captured["assignment_id"] = assignment_id
        captured["parent_id"] = requested_parent_id
        return Assignment(), None

    monkeypatch.setattr(
        task_assignment_routes.assignment_service,
        "approve_assignment",
        fake_approve_assignment,
    )
    monkeypatch.setattr(
        task_assignment_routes.parent_assignment_response_schema,
        "dump",
        lambda assignment: {"id": "1"},
    )

    response = req(
        client,
        parent["access_token"],
        "assign",
    )

    assert response.status_code == 200
    assert response.get_json() == {"id": "1"}
    assert captured == {
        "assignment_id": "assign",
        "parent_id": parent_id,
    }


@pytest.mark.parametrize(
    (
        "error",
        "expected_status",
        "expected_message",
        "email",
        "phone",
    ),
    [
        (
            "assignment_not_found",
            404,
            "Assignment not found",
            "assignment.not.found@gmail.com",
            "0553000001",
        ),
        (
            "assignment_not_pending_review",
            400,
            "Assignment is not waiting for review",
            "assignment.not.pending@gmail.com",
            "0553000002",
        ),
        (
            "update_failed",
            500,
            "Failed to approve assignment",
            "assignment.update.failed@gmail.com",
            "0553000003",
        ),
        (
            "points_failed",
            500,
            "Failed to approve assignment",
            "assignment.points.failed@gmail.com",
            "0553000004",
        ),
        (
            "unexpected_error",
            500,
            "Failed to approve assignment",
            "assignment.unexpected.error@gmail.com",
            "0553000005",
        ),
    ],
)
def test_route_errors(
    client,
    monkeypatch,
    error,
    expected_status,
    expected_message,
    email,
    phone,
):
    parent = reg(
        client,
        email=email,
        phone=phone,
    )

    monkeypatch.setattr(
        task_assignment_routes.assignment_service,
        "approve_assignment",
        lambda assignment_id, parent_id: (
            None,
            error,
        ),
    )

    response = req(
        client,
        parent["access_token"],
        "id",
    )

    assert response.status_code == expected_status
    assert response.get_json() == {
        "error": expected_message
    }


class Task:
    def __init__(self):
        self.points = 20


class Assign:
    def __init__(self, status="PENDING_REVIEW"):
        self.id = "aid"
        self.child_id = "cid"
        self.status = status
        self.task = Task()
        self.approved_at = None


def test_service_not_found(monkeypatch):
    service = task_assignment_routes.assignment_service

    monkeypatch.setattr(
        service.task_assignment_repository,
        "get_assignment_for_parent",
        lambda assignment_id, parent_id: None,
    )

    result = service.approve_assignment("a", "p")

    assert result == (
        None,
        "assignment_not_found",
    )


@pytest.mark.parametrize(
    "status",
    ["PENDING", "APPROVED", "REJECTED"],
)
def test_service_requires_pending(
    monkeypatch,
    status,
):
    service = task_assignment_routes.assignment_service

    monkeypatch.setattr(
        service.task_assignment_repository,
        "get_assignment_for_parent",
        lambda assignment_id, parent_id: Assign(status),
    )

    result = service.approve_assignment("a", "p")

    assert result == (
        None,
        "assignment_not_pending_review",
    )


def test_service_success(monkeypatch):
    service = task_assignment_routes.assignment_service
    assignment = Assign()
    now = datetime(
        2026,
        1,
        1,
        tzinfo=timezone.utc,
    )

    monkeypatch.setattr(
        service.task_assignment_repository,
        "get_assignment_for_parent",
        lambda assignment_id, parent_id: assignment,
    )
    monkeypatch.setattr(
        service.task_assignment_repository,
        "update_assignment",
        lambda commit=False: (True, None),
    )
    monkeypatch.setattr(
        service.points_service,
        "add_points",
        lambda **kwargs: (object(), None),
    )
    monkeypatch.setattr(
        service_module,
        "utc_now",
        lambda: now,
    )
    monkeypatch.setattr(
        service_module.db.session,
        "commit",
        lambda: None,
    )

    result, error = service.approve_assignment(
        "a",
        "p",
    )

    assert error is None
    assert result is assignment
    assert result.status == "APPROVED"
    assert result.approved_at == now


def test_update_fail(monkeypatch):
    service = task_assignment_routes.assignment_service
    assignment = Assign()
    rollback_calls = {"count": 0}

    monkeypatch.setattr(
        service.task_assignment_repository,
        "get_assignment_for_parent",
        lambda assignment_id, parent_id: assignment,
    )
    monkeypatch.setattr(
        service.task_assignment_repository,
        "update_assignment",
        lambda commit=False: (
            False,
            "integrity_error",
        ),
    )
    monkeypatch.setattr(
        service_module.db.session,
        "rollback",
        lambda: rollback_calls.__setitem__(
            "count",
            rollback_calls["count"] + 1,
        ),
    )

    result = service.approve_assignment("a", "p")

    assert result == (None, "update_failed")
    assert rollback_calls["count"] == 1


def test_points_fail(monkeypatch):
    service = task_assignment_routes.assignment_service
    assignment = Assign()
    rollback_calls = {"count": 0}

    monkeypatch.setattr(
        service.task_assignment_repository,
        "get_assignment_for_parent",
        lambda assignment_id, parent_id: assignment,
    )
    monkeypatch.setattr(
        service.task_assignment_repository,
        "update_assignment",
        lambda commit=False: (True, None),
    )
    monkeypatch.setattr(
        service.points_service,
        "add_points",
        lambda **kwargs: (
            None,
            "history_failed",
        ),
    )
    monkeypatch.setattr(
        service_module,
        "utc_now",
        lambda: datetime.now(timezone.utc),
    )
    monkeypatch.setattr(
        service_module.db.session,
        "rollback",
        lambda: rollback_calls.__setitem__(
            "count",
            rollback_calls["count"] + 1,
        ),
    )

    result = service.approve_assignment("a", "p")

    assert result == (None, "points_failed")
    assert rollback_calls["count"] == 1


def test_add_points_args(monkeypatch):
    service = task_assignment_routes.assignment_service
    assignment = Assign()
    captured = {}

    monkeypatch.setattr(
        service.task_assignment_repository,
        "get_assignment_for_parent",
        lambda assignment_id, parent_id: assignment,
    )
    monkeypatch.setattr(
        service.task_assignment_repository,
        "update_assignment",
        lambda commit=False: (True, None),
    )
    monkeypatch.setattr(
        service_module,
        "utc_now",
        lambda: datetime.now(timezone.utc),
    )
    monkeypatch.setattr(
        service_module.db.session,
        "commit",
        lambda: None,
    )

    def fake_add_points(**kwargs):
        captured.update(kwargs)
        return object(), None

    monkeypatch.setattr(
        service.points_service,
        "add_points",
        fake_add_points,
    )

    service.approve_assignment("a", "p")

    assert captured == {
        "child_id": "cid",
        "amount": 20,
        "task_assignment_id": "aid",
        "commit": False,
    }