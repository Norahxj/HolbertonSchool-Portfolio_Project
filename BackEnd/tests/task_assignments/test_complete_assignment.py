from datetime import datetime, timezone

import pytest
from flask_jwt_extended import decode_token

from app.routes import task_assignment_routes
import app.services.task_assignment_service as task_assignment_service_module


REGISTER_URL = "/api/auth/register"
CHILD_LOGIN_URL = "/api/auth/child-login"
CHILDREN_URL = "/api/children/"
COMPLETE_ASSIGNMENT_URL = "/api/task-assignments/{}/complete"


def authorization_header(token):
    return {"Authorization": token}


def register_parent(
    client,
    email="complete.assignment.parent@gmail.com",
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


def complete_assignment_request(
    client,
    token,
    assignment_id,
):
    return client.put(
        COMPLETE_ASSIGNMENT_URL.format(assignment_id),
        headers=authorization_header(token),
    )


# ---------------------------------------------------------------------------
# Authentication and authorization
# ---------------------------------------------------------------------------

def test_complete_assignment_requires_access_token(client):
    response = client.put(
        COMPLETE_ASSIGNMENT_URL.format("assignment-id")
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
def test_complete_assignment_rejects_invalid_token(
    client,
    token,
):
    response = client.put(
        COMPLETE_ASSIGNMENT_URL.format("assignment-id"),
        headers=authorization_header(token),
    )

    assert response.status_code in (401, 422)


def test_parent_cannot_complete_assignment(client):
    parent = register_parent(client)

    response = complete_assignment_request(
        client,
        parent["access_token"],
        "assignment-id",
    )

    assert response.status_code == 403
    assert response.get_json() == {
        "error": "Child access required"
    }


# ---------------------------------------------------------------------------
# Route behavior
# ---------------------------------------------------------------------------

def test_route_passes_assignment_id_and_child_id_to_service(
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

    class FakeAssignment:
        id = "assignment-id"

    fake_assignment = FakeAssignment()

    def fake_complete_assignment(
        assignment_id,
        child_id,
    ):
        captured["assignment_id"] = assignment_id
        captured["child_id"] = child_id
        return fake_assignment, None

    monkeypatch.setattr(
        task_assignment_routes.assignment_service,
        "complete_assignment",
        fake_complete_assignment,
    )
    monkeypatch.setattr(
        task_assignment_routes.child_assignment_response_schema,
        "dump",
        lambda assignment: {"id": assignment.id},
    )

    response = complete_assignment_request(
        client,
        child_login["access_token"],
        "requested-assignment-id",
    )

    assert response.status_code == 200
    assert response.get_json() == {
        "id": "assignment-id"
    }
    assert captured == {
        "assignment_id": "requested-assignment-id",
        "child_id": expected_child_id,
    }


@pytest.mark.parametrize(
    ("service_error", "expected_status", "expected_body"),
    [
        (
            "assignment_not_found",
            404,
            {"error": "Assignment not found"},
        ),
        (
            "assignment_already_completed",
            400,
            {
                "error": (
                    "Assignment already completed "
                    "or waiting for review"
                )
            },
        ),
        (
            "update_failed",
            500,
            {"error": "Failed to complete assignment"},
        ),
        (
            "points_failed",
            500,
            {"error": "Failed to complete assignment"},
        ),
        (
            "unexpected_error",
            500,
            {"error": "Failed to complete assignment"},
        ),
    ],
)
def test_route_maps_service_errors(
    client,
    monkeypatch,
    service_error,
    expected_status,
    expected_body,
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
        "complete_assignment",
        lambda assignment_id, child_id: (
            None,
            service_error,
        ),
    )

    response = complete_assignment_request(
        client,
        child_login["access_token"],
        "assignment-id",
    )

    assert response.status_code == expected_status
    assert response.get_json() == expected_body


def test_route_serializes_completed_assignment(
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

    assignment = object()
    serialized = {
        "id": "assignment-id",
        "status": "PENDING_REVIEW",
    }
    captured = {}

    monkeypatch.setattr(
        task_assignment_routes.assignment_service,
        "complete_assignment",
        lambda assignment_id, child_id: (
            assignment,
            None,
        ),
    )

    def fake_dump(value):
        captured["value"] = value
        return serialized

    monkeypatch.setattr(
        task_assignment_routes.child_assignment_response_schema,
        "dump",
        fake_dump,
    )

    response = complete_assignment_request(
        client,
        child_login["access_token"],
        "assignment-id",
    )

    assert response.status_code == 200
    assert response.get_json() == serialized
    assert captured["value"] is assignment


def test_route_does_not_serialize_when_service_returns_error(
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
    dump_called = {"value": False}

    monkeypatch.setattr(
        task_assignment_routes.assignment_service,
        "complete_assignment",
        lambda assignment_id, child_id: (
            None,
            "assignment_not_found",
        ),
    )

    def fake_dump(value):
        dump_called["value"] = True
        return {}

    monkeypatch.setattr(
        task_assignment_routes.child_assignment_response_schema,
        "dump",
        fake_dump,
    )

    response = complete_assignment_request(
        client,
        child_login["access_token"],
        "missing-assignment",
    )

    assert response.status_code == 404
    assert dump_called["value"] is False


# ---------------------------------------------------------------------------
# Service behavior
# ---------------------------------------------------------------------------

class FakeTask:
    def __init__(
        self,
        is_auto_verified=False,
        points=10,
    ):
        self.is_auto_verified = is_auto_verified
        self.points = points


class FakeAssignment:
    def __init__(
        self,
        status="PENDING",
        is_auto_verified=False,
        points=10,
    ):
        self.id = "assignment-id"
        self.child_id = "child-id"
        self.status = status
        self.completed_at = None
        self.approved_at = None
        self.task = FakeTask(
            is_auto_verified=is_auto_verified,
            points=points,
        )


def prepare_assignment_service(
    monkeypatch,
    assignment,
):
    service = task_assignment_routes.assignment_service

    monkeypatch.setattr(
        service.task_assignment_repository,
        "get_assignment_for_child",
        lambda assignment_id, child_id: assignment,
    )
    monkeypatch.setattr(
        service.task_assignment_repository,
        "update_assignment",
        lambda commit=False: (True, None),
    )

    return service


def test_service_passes_assignment_id_and_child_id_to_repository(
    monkeypatch,
):
    service = task_assignment_routes.assignment_service
    captured = {}

    def fake_get_assignment_for_child(
        assignment_id,
        child_id,
    ):
        captured["assignment_id"] = assignment_id
        captured["child_id"] = child_id
        return None

    monkeypatch.setattr(
        service.task_assignment_repository,
        "get_assignment_for_child",
        fake_get_assignment_for_child,
    )

    result = service.complete_assignment(
        "assignment-id",
        "child-id",
    )

    assert result == (
        None,
        "assignment_not_found",
    )
    assert captured == {
        "assignment_id": "assignment-id",
        "child_id": "child-id",
    }


def test_service_returns_not_found_when_assignment_missing(
    monkeypatch,
):
    service = task_assignment_routes.assignment_service
    update_called = {"value": False}

    monkeypatch.setattr(
        service.task_assignment_repository,
        "get_assignment_for_child",
        lambda assignment_id, child_id: None,
    )

    def fake_update_assignment(commit=False):
        update_called["value"] = True
        return True, None

    monkeypatch.setattr(
        service.task_assignment_repository,
        "update_assignment",
        fake_update_assignment,
    )

    result = service.complete_assignment(
        "missing-assignment",
        "child-id",
    )

    assert result == (
        None,
        "assignment_not_found",
    )
    assert update_called["value"] is False


@pytest.mark.parametrize(
    "status",
    ["PENDING_REVIEW", "APPROVED"],
)
def test_service_rejects_already_completed_statuses(
    monkeypatch,
    status,
):
    assignment = FakeAssignment(status=status)
    service = task_assignment_routes.assignment_service
    update_called = {"value": False}

    monkeypatch.setattr(
        service.task_assignment_repository,
        "get_assignment_for_child",
        lambda assignment_id, child_id: assignment,
    )

    def fake_update_assignment(commit=False):
        update_called["value"] = True
        return True, None

    monkeypatch.setattr(
        service.task_assignment_repository,
        "update_assignment",
        fake_update_assignment,
    )

    result = service.complete_assignment(
        "assignment-id",
        "child-id",
    )

    assert result == (
        None,
        "assignment_already_completed",
    )
    assert update_called["value"] is False


def test_manual_verification_sets_pending_review(
    monkeypatch,
):
    assignment = FakeAssignment(
        status="PENDING",
        is_auto_verified=False,
    )
    service = prepare_assignment_service(
        monkeypatch,
        assignment,
    )
    now = datetime(
        2026,
        7,
        21,
        10,
        30,
        tzinfo=timezone.utc,
    )

    monkeypatch.setattr(
        task_assignment_service_module,
        "utc_now",
        lambda: now,
    )
    monkeypatch.setattr(
        task_assignment_service_module.db.session,
        "commit",
        lambda: None,
    )

    points_called = {"value": False}

    def fake_add_points(**kwargs):
        points_called["value"] = True
        return object(), None

    monkeypatch.setattr(
        service.points_service,
        "add_points",
        fake_add_points,
    )

    result, error = service.complete_assignment(
        "assignment-id",
        "child-id",
    )

    assert error is None
    assert result is assignment
    assert assignment.status == "PENDING_REVIEW"
    assert assignment.completed_at == now
    assert assignment.approved_at is None
    assert points_called["value"] is False


def test_auto_verified_assignment_is_approved_immediately(
    monkeypatch,
):
    assignment = FakeAssignment(
        status="PENDING",
        is_auto_verified=True,
        points=25,
    )
    service = prepare_assignment_service(
        monkeypatch,
        assignment,
    )
    now = datetime(
        2026,
        7,
        21,
        10,
        30,
        tzinfo=timezone.utc,
    )

    monkeypatch.setattr(
        task_assignment_service_module,
        "utc_now",
        lambda: now,
    )
    monkeypatch.setattr(
        task_assignment_service_module.db.session,
        "commit",
        lambda: None,
    )
    monkeypatch.setattr(
        service.points_service,
        "add_points",
        lambda **kwargs: (object(), None),
    )

    result, error = service.complete_assignment(
        "assignment-id",
        "child-id",
    )

    assert error is None
    assert result is assignment
    assert assignment.status == "APPROVED"
    assert assignment.completed_at == now
    assert assignment.approved_at == now


def test_service_calls_update_assignment_with_commit_false(
    monkeypatch,
):
    assignment = FakeAssignment(
        is_auto_verified=False,
    )
    service = task_assignment_routes.assignment_service
    captured = {}

    monkeypatch.setattr(
        service.task_assignment_repository,
        "get_assignment_for_child",
        lambda assignment_id, child_id: assignment,
    )

    def fake_update_assignment(commit=False):
        captured["commit"] = commit
        return True, None

    monkeypatch.setattr(
        service.task_assignment_repository,
        "update_assignment",
        fake_update_assignment,
    )
    monkeypatch.setattr(
        task_assignment_service_module,
        "utc_now",
        lambda: datetime.now(timezone.utc),
    )
    monkeypatch.setattr(
        task_assignment_service_module.db.session,
        "commit",
        lambda: None,
    )

    service.complete_assignment(
        "assignment-id",
        "child-id",
    )

    assert captured["commit"] is False


def test_auto_verified_assignment_adds_points_with_expected_arguments(
    monkeypatch,
):
    assignment = FakeAssignment(
        is_auto_verified=True,
        points=30,
    )
    service = prepare_assignment_service(
        monkeypatch,
        assignment,
    )
    captured = {}

    monkeypatch.setattr(
        task_assignment_service_module,
        "utc_now",
        lambda: datetime.now(timezone.utc),
    )
    monkeypatch.setattr(
        task_assignment_service_module.db.session,
        "commit",
        lambda: None,
    )

    def fake_add_points(
        child_id,
        amount,
        task_assignment_id,
        commit,
    ):
        captured["child_id"] = child_id
        captured["amount"] = amount
        captured["task_assignment_id"] = (
            task_assignment_id
        )
        captured["commit"] = commit
        return object(), None

    monkeypatch.setattr(
        service.points_service,
        "add_points",
        fake_add_points,
    )

    result, error = service.complete_assignment(
        "assignment-id",
        "token-child-id",
    )

    assert error is None
    assert result is assignment
    assert captured == {
        "child_id": "child-id",
        "amount": 30,
        "task_assignment_id": "assignment-id",
        "commit": False,
    }


def test_service_rolls_back_when_assignment_update_fails(
    monkeypatch,
):
    assignment = FakeAssignment(
        is_auto_verified=False,
    )
    service = task_assignment_routes.assignment_service
    rollback_calls = {"count": 0}
    commit_calls = {"count": 0}

    monkeypatch.setattr(
        service.task_assignment_repository,
        "get_assignment_for_child",
        lambda assignment_id, child_id: assignment,
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
        task_assignment_service_module,
        "utc_now",
        lambda: datetime.now(timezone.utc),
    )
    monkeypatch.setattr(
        task_assignment_service_module.db.session,
        "rollback",
        lambda: rollback_calls.__setitem__(
            "count",
            rollback_calls["count"] + 1,
        ),
    )
    monkeypatch.setattr(
        task_assignment_service_module.db.session,
        "commit",
        lambda: commit_calls.__setitem__(
            "count",
            commit_calls["count"] + 1,
        ),
    )

    result = service.complete_assignment(
        "assignment-id",
        "child-id",
    )

    assert result == (None, "update_failed")
    assert rollback_calls["count"] == 1
    assert commit_calls["count"] == 0


def test_service_rolls_back_when_adding_points_fails(
    monkeypatch,
):
    assignment = FakeAssignment(
        is_auto_verified=True,
        points=15,
    )
    service = prepare_assignment_service(
        monkeypatch,
        assignment,
    )
    rollback_calls = {"count": 0}
    commit_calls = {"count": 0}

    monkeypatch.setattr(
        task_assignment_service_module,
        "utc_now",
        lambda: datetime.now(timezone.utc),
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
        task_assignment_service_module.db.session,
        "rollback",
        lambda: rollback_calls.__setitem__(
            "count",
            rollback_calls["count"] + 1,
        ),
    )
    monkeypatch.setattr(
        task_assignment_service_module.db.session,
        "commit",
        lambda: commit_calls.__setitem__(
            "count",
            commit_calls["count"] + 1,
        ),
    )

    result = service.complete_assignment(
        "assignment-id",
        "child-id",
    )

    assert result == (None, "points_failed")
    assert rollback_calls["count"] == 1
    assert commit_calls["count"] == 0


def test_service_commits_once_after_success(
    monkeypatch,
):
    assignment = FakeAssignment(
        is_auto_verified=False,
    )
    service = prepare_assignment_service(
        monkeypatch,
        assignment,
    )
    commit_calls = {"count": 0}

    monkeypatch.setattr(
        task_assignment_service_module,
        "utc_now",
        lambda: datetime.now(timezone.utc),
    )
    monkeypatch.setattr(
        task_assignment_service_module.db.session,
        "commit",
        lambda: commit_calls.__setitem__(
            "count",
            commit_calls["count"] + 1,
        ),
    )

    result, error = service.complete_assignment(
        "assignment-id",
        "child-id",
    )

    assert error is None
    assert result is assignment
    assert commit_calls["count"] == 1


def test_service_rolls_back_on_unexpected_exception(
    monkeypatch,
):
    assignment = FakeAssignment(
        is_auto_verified=False,
    )
    service = task_assignment_routes.assignment_service
    rollback_calls = {"count": 0}

    monkeypatch.setattr(
        service.task_assignment_repository,
        "get_assignment_for_child",
        lambda assignment_id, child_id: assignment,
    )
    monkeypatch.setattr(
        service.task_assignment_repository,
        "update_assignment",
        lambda commit=False: (_ for _ in ()).throw(
            RuntimeError("database error")
        ),
    )
    monkeypatch.setattr(
        task_assignment_service_module,
        "utc_now",
        lambda: datetime.now(timezone.utc),
    )
    monkeypatch.setattr(
        task_assignment_service_module.db.session,
        "rollback",
        lambda: rollback_calls.__setitem__(
            "count",
            rollback_calls["count"] + 1,
        ),
    )

    result = service.complete_assignment(
        "assignment-id",
        "child-id",
    )

    assert result == (None, "update_failed")
    assert rollback_calls["count"] == 1