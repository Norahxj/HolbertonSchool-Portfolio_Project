from datetime import datetime, timezone

import pytest
from flask_jwt_extended import decode_token

from app.routes import task_assignment_routes


REGISTER_URL = "/api/auth/register"
CHILDREN_URL = "/api/children/"
CHILD_LOGIN_URL = "/api/auth/child-login"
REJECT_ASSIGNMENT_URL = "/api/task-assignments/{}/reject"


def authorization_header(token):
    return {"Authorization": token}


def register_parent(
    client,
    email="reject.assignment.parent@gmail.com",
    phone="0554100001",
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
    phone="0554100099",
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


def reject_assignment_request(
    client,
    token,
    assignment_id,
):
    return client.put(
        REJECT_ASSIGNMENT_URL.format(assignment_id),
        headers=authorization_header(token),
    )


# ---------------------------------------------------------------------------
# Authentication and authorization
# ---------------------------------------------------------------------------

def test_reject_assignment_requires_access_token(client):
    response = client.put(
        REJECT_ASSIGNMENT_URL.format("assignment-id")
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
def test_reject_assignment_rejects_invalid_token(
    client,
    token,
):
    response = client.put(
        REJECT_ASSIGNMENT_URL.format("assignment-id"),
        headers=authorization_header(token),
    )

    assert response.status_code in (401, 422)


def test_child_cannot_reject_assignment(client):
    parent = register_parent(client)
    child = create_child(
        client,
        parent["access_token"],
    )
    child_login = login_child(
        client,
        child["access_code"],
    )

    response = reject_assignment_request(
        client,
        child_login["access_token"],
        "assignment-id",
    )

    assert response.status_code == 403
    assert response.get_json() == {
        "error": "Parent access required"
    }


# ---------------------------------------------------------------------------
# Route behavior
# ---------------------------------------------------------------------------

def test_route_passes_assignment_id_and_parent_id_to_service(
    client,
    app,
    monkeypatch,
):
    parent = register_parent(client)

    with app.app_context():
        expected_parent_id = decode_token(
            parent["access_token"]
        )["sub"]

    captured = {}

    class FakeAssignment:
        id = "assignment-id"

    def fake_reject_assignment(
        assignment_id,
        parent_id,
    ):
        captured["assignment_id"] = assignment_id
        captured["parent_id"] = parent_id
        return FakeAssignment(), None

    monkeypatch.setattr(
        task_assignment_routes.assignment_service,
        "reject_assignment",
        fake_reject_assignment,
    )
    monkeypatch.setattr(
        task_assignment_routes.parent_assignment_response_schema,
        "dump",
        lambda assignment: {"id": assignment.id},
    )

    response = reject_assignment_request(
        client,
        parent["access_token"],
        "requested-assignment-id",
    )

    assert response.status_code == 200
    assert response.get_json() == {
        "id": "assignment-id"
    }
    assert captured == {
        "assignment_id": "requested-assignment-id",
        "parent_id": expected_parent_id,
    }


@pytest.mark.parametrize(
    (
        "service_error",
        "expected_status",
        "expected_body",
        "email",
        "phone",
    ),
    [
        (
            "assignment_not_found",
            404,
            {"error": "Assignment not found"},
            "reject.not.found@gmail.com",
            "0554100002",
        ),
        (
            "assignment_not_pending_review",
            400,
            {
                "error": (
                    "Assignment is not waiting for review"
                )
            },
            "reject.not.pending@gmail.com",
            "0554100003",
        ),
        (
            "update_failed",
            500,
            {
                "error": "Failed to reject assignment"
            },
            "reject.update.failed@gmail.com",
            "0554100004",
        ),
        (
            "unexpected_error",
            500,
            {
                "error": "Failed to reject assignment"
            },
            "reject.unexpected.error@gmail.com",
            "0554100005",
        ),
    ],
)
def test_route_maps_service_errors(
    client,
    monkeypatch,
    service_error,
    expected_status,
    expected_body,
    email,
    phone,
):
    parent = register_parent(
        client,
        email=email,
        phone=phone,
    )

    monkeypatch.setattr(
        task_assignment_routes.assignment_service,
        "reject_assignment",
        lambda assignment_id, parent_id: (
            None,
            service_error,
        ),
    )

    response = reject_assignment_request(
        client,
        parent["access_token"],
        "assignment-id",
    )

    assert response.status_code == expected_status
    assert response.get_json() == expected_body


def test_route_serializes_rejected_assignment(
    client,
    monkeypatch,
):
    parent = register_parent(client)
    assignment = object()
    serialized = {
        "id": "assignment-id",
        "status": "REJECTED",
    }
    captured = {}

    monkeypatch.setattr(
        task_assignment_routes.assignment_service,
        "reject_assignment",
        lambda assignment_id, parent_id: (
            assignment,
            None,
        ),
    )

    def fake_dump(value):
        captured["value"] = value
        return serialized

    monkeypatch.setattr(
        task_assignment_routes.parent_assignment_response_schema,
        "dump",
        fake_dump,
    )

    response = reject_assignment_request(
        client,
        parent["access_token"],
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
    dump_called = {"value": False}

    monkeypatch.setattr(
        task_assignment_routes.assignment_service,
        "reject_assignment",
        lambda assignment_id, parent_id: (
            None,
            "assignment_not_found",
        ),
    )

    def fake_dump(value):
        dump_called["value"] = True
        return {}

    monkeypatch.setattr(
        task_assignment_routes.parent_assignment_response_schema,
        "dump",
        fake_dump,
    )

    response = reject_assignment_request(
        client,
        parent["access_token"],
        "missing-assignment",
    )

    assert response.status_code == 404
    assert dump_called["value"] is False


def test_route_serializes_assignment_fields(
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
        status = "REJECTED"
        completed_at = datetime(
            2026,
            7,
            21,
            10,
            30,
            tzinfo=timezone.utc,
        )
        approved_at = None
        task = FakeTask()
        child = FakeChild()
        assigned_date = None

    monkeypatch.setattr(
        task_assignment_routes.assignment_service,
        "reject_assignment",
        lambda assignment_id, parent_id: (
            FakeAssignment(),
            None,
        ),
    )

    response = reject_assignment_request(
        client,
        parent["access_token"],
        "assignment-id",
    )

    data = response.get_json()

    assert response.status_code == 200
    assert data["id"] == "assignment-id"
    assert data["status"] == "REJECTED"
    assert data["approved_at"] is None
    assert data["task"]["id"] == "task-id"
    assert data["task"]["title"] == "Clean room"
    assert data["child"]["id"] == "child-id"
    assert data["child"]["name"] == "Sara"


# ---------------------------------------------------------------------------
# Service behavior
# ---------------------------------------------------------------------------

class FakeTask:
    def __init__(self, points=20):
        self.points = points


class FakeAssignment:
    def __init__(self, status="PENDING_REVIEW"):
        self.id = "assignment-id"
        self.child_id = "child-id"
        self.status = status
        self.task = FakeTask()
        self.completed_at = datetime(
            2026,
            7,
            21,
            10,
            30,
            tzinfo=timezone.utc,
        )
        self.approved_at = datetime(
            2026,
            7,
            21,
            11,
            0,
            tzinfo=timezone.utc,
        )


def test_service_passes_assignment_id_and_parent_id_to_repository(
    monkeypatch,
):
    service = task_assignment_routes.assignment_service
    captured = {}

    def fake_get_assignment_for_parent(
        assignment_id,
        parent_id,
    ):
        captured["assignment_id"] = assignment_id
        captured["parent_id"] = parent_id
        return None

    monkeypatch.setattr(
        service.task_assignment_repository,
        "get_assignment_for_parent",
        fake_get_assignment_for_parent,
    )

    result = service.reject_assignment(
        "assignment-id",
        "parent-id",
    )

    assert result == (
        None,
        "assignment_not_found",
    )
    assert captured == {
        "assignment_id": "assignment-id",
        "parent_id": "parent-id",
    }


def test_service_returns_not_found_when_assignment_missing(
    monkeypatch,
):
    service = task_assignment_routes.assignment_service
    update_called = {"value": False}

    monkeypatch.setattr(
        service.task_assignment_repository,
        "get_assignment_for_parent",
        lambda assignment_id, parent_id: None,
    )

    def fake_update_assignment():
        update_called["value"] = True
        return True, None

    monkeypatch.setattr(
        service.task_assignment_repository,
        "update_assignment",
        fake_update_assignment,
    )

    result = service.reject_assignment(
        "missing-assignment",
        "parent-id",
    )

    assert result == (
        None,
        "assignment_not_found",
    )
    assert update_called["value"] is False


@pytest.mark.parametrize(
    "status",
    [
        "PENDING",
        "APPROVED",
        "REJECTED",
    ],
)
def test_service_rejects_assignment_not_pending_review(
    monkeypatch,
    status,
):
    service = task_assignment_routes.assignment_service
    assignment = FakeAssignment(status=status)
    update_called = {"value": False}

    monkeypatch.setattr(
        service.task_assignment_repository,
        "get_assignment_for_parent",
        lambda assignment_id, parent_id: assignment,
    )

    def fake_update_assignment():
        update_called["value"] = True
        return True, None

    monkeypatch.setattr(
        service.task_assignment_repository,
        "update_assignment",
        fake_update_assignment,
    )

    result = service.reject_assignment(
        "assignment-id",
        "parent-id",
    )

    assert result == (
        None,
        "assignment_not_pending_review",
    )
    assert update_called["value"] is False


def test_service_changes_status_to_rejected(
    monkeypatch,
):
    service = task_assignment_routes.assignment_service
    assignment = FakeAssignment()

    monkeypatch.setattr(
        service.task_assignment_repository,
        "get_assignment_for_parent",
        lambda assignment_id, parent_id: assignment,
    )
    monkeypatch.setattr(
        service.task_assignment_repository,
        "update_assignment",
        lambda: (True, None),
    )

    result, error = service.reject_assignment(
        "assignment-id",
        "parent-id",
    )

    assert error is None
    assert result is assignment
    assert assignment.status == "REJECTED"


def test_service_clears_approved_at(
    monkeypatch,
):
    service = task_assignment_routes.assignment_service
    assignment = FakeAssignment()

    assert assignment.approved_at is not None

    monkeypatch.setattr(
        service.task_assignment_repository,
        "get_assignment_for_parent",
        lambda assignment_id, parent_id: assignment,
    )
    monkeypatch.setattr(
        service.task_assignment_repository,
        "update_assignment",
        lambda: (True, None),
    )

    result, error = service.reject_assignment(
        "assignment-id",
        "parent-id",
    )

    assert error is None
    assert result is assignment
    assert assignment.approved_at is None


def test_service_keeps_completed_at_unchanged(
    monkeypatch,
):
    service = task_assignment_routes.assignment_service
    assignment = FakeAssignment()
    original_completed_at = assignment.completed_at

    monkeypatch.setattr(
        service.task_assignment_repository,
        "get_assignment_for_parent",
        lambda assignment_id, parent_id: assignment,
    )
    monkeypatch.setattr(
        service.task_assignment_repository,
        "update_assignment",
        lambda: (True, None),
    )

    result, error = service.reject_assignment(
        "assignment-id",
        "parent-id",
    )

    assert error is None
    assert result is assignment
    assert assignment.completed_at == original_completed_at


def test_service_calls_update_assignment_with_default_commit(
    monkeypatch,
):
    service = task_assignment_routes.assignment_service
    assignment = FakeAssignment()
    captured = {}

    monkeypatch.setattr(
        service.task_assignment_repository,
        "get_assignment_for_parent",
        lambda assignment_id, parent_id: assignment,
    )

    def fake_update_assignment(*args, **kwargs):
        captured["args"] = args
        captured["kwargs"] = kwargs
        return True, None

    monkeypatch.setattr(
        service.task_assignment_repository,
        "update_assignment",
        fake_update_assignment,
    )

    result, error = service.reject_assignment(
        "assignment-id",
        "parent-id",
    )

    assert error is None
    assert result is assignment
    assert captured["args"] == ()
    assert captured["kwargs"] == {}


def test_service_returns_update_failed_when_repository_update_fails(
    monkeypatch,
):
    service = task_assignment_routes.assignment_service
    assignment = FakeAssignment()

    monkeypatch.setattr(
        service.task_assignment_repository,
        "get_assignment_for_parent",
        lambda assignment_id, parent_id: assignment,
    )
    monkeypatch.setattr(
        service.task_assignment_repository,
        "update_assignment",
        lambda: (
            False,
            "integrity_error",
        ),
    )

    result = service.reject_assignment(
        "assignment-id",
        "parent-id",
    )

    assert result == (
        None,
        "update_failed",
    )


def test_service_returns_assignment_without_modifying_task_points(
    monkeypatch,
):
    service = task_assignment_routes.assignment_service
    assignment = FakeAssignment()
    original_points = assignment.task.points

    monkeypatch.setattr(
        service.task_assignment_repository,
        "get_assignment_for_parent",
        lambda assignment_id, parent_id: assignment,
    )
    monkeypatch.setattr(
        service.task_assignment_repository,
        "update_assignment",
        lambda: (True, None),
    )

    result, error = service.reject_assignment(
        "assignment-id",
        "parent-id",
    )

    assert error is None
    assert result is assignment
    assert assignment.task.points == original_points