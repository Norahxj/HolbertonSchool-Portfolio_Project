from datetime import date

import pytest
from flask_jwt_extended import decode_token

from app.routes import task_routes
import app.services.task_service as task_service_module


REGISTER_URL = "/api/auth/register"
CHILD_LOGIN_URL = "/api/auth/child-login"
CHILDREN_URL = "/api/children/"
TASK_URL = "/api/tasks/{}"


def authorization_header(token):
    return {"Authorization": token}


def register_parent(
    client,
    email="update.task.parent@gmail.com",
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


def update_task_request(client, token, task_id, payload):
    return client.put(
        TASK_URL.format(task_id),
        headers=authorization_header(token),
        json=payload,
    )


# ---------------------------------------------------------------------------
# Authentication and authorization
# ---------------------------------------------------------------------------

def test_update_task_requires_access_token(client):
    response = client.put(
        TASK_URL.format("task-id"),
        json={"title": "Updated task"},
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
def test_update_task_rejects_invalid_token(client, token):
    response = client.put(
        TASK_URL.format("task-id"),
        headers=authorization_header(token),
        json={"title": "Updated task"},
    )

    assert response.status_code in (401, 422)


def test_child_cannot_update_task(client):
    parent = register_parent(client)
    child = create_child(client, parent["access_token"])

    login_response = client.post(
        CHILD_LOGIN_URL,
        json={"access_code": child["access_code"]},
    )
    assert login_response.status_code == 200

    child_token = login_response.get_json()["access_token"]

    response = update_task_request(
        client,
        child_token,
        "task-id",
        {"title": "Updated task"},
    )

    assert response.status_code == 403
    assert response.get_json() == {
        "error": "Parent access required"
    }


# ---------------------------------------------------------------------------
# Schema validation through the route
# ---------------------------------------------------------------------------

def test_update_task_rejects_empty_payload(client):
    parent = register_parent(client)

    response = update_task_request(
        client,
        parent["access_token"],
        "task-id",
        {},
    )

    assert response.status_code == 400
    assert "errors" in response.get_json()


@pytest.mark.parametrize("points", [0, 101])
def test_update_task_rejects_points_outside_allowed_range(
    client,
    points,
):
    parent = register_parent(client)

    response = update_task_request(
        client,
        parent["access_token"],
        "task-id",
        {"points": points},
    )

    assert response.status_code == 400
    assert "errors" in response.get_json()


def test_update_task_rejects_invalid_frequency_at_schema_level(client):
    parent = register_parent(client)

    response = update_task_request(
        client,
        parent["access_token"],
        "task-id",
        {"task_frequency": "YEARLY"},
    )

    assert response.status_code == 400
    assert "errors" in response.get_json()


def test_update_task_rejects_invalid_category(client):
    parent = register_parent(client)

    response = update_task_request(
        client,
        parent["access_token"],
        "task-id",
        {"category": "INVALID_CATEGORY"},
    )

    assert response.status_code == 400
    assert "errors" in response.get_json()


def test_update_task_rejects_non_integer_recurrence_day(client):
    parent = register_parent(client)

    response = update_task_request(
        client,
        parent["access_token"],
        "task-id",
        {"recurrence_day": "Monday"},
    )

    assert response.status_code == 400
    assert "errors" in response.get_json()


# ---------------------------------------------------------------------------
# Route behavior and error mapping
# ---------------------------------------------------------------------------

def test_route_passes_task_id_parent_id_and_loaded_data_to_service(
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

    class FakeTask:
        id = "task-id"
        title = "Updated title"
        description = "Updated description"
        points = 20
        task_frequency = "WEEKLY"
        recurrence_day = 2
        category = "MORAL"
        is_auto_verified = True
        created_by = expected_parent_id
        created_at = None

    def fake_update_task_for_parent(
        task_id,
        parent_id,
        task_data,
    ):
        captured["task_id"] = task_id
        captured["parent_id"] = parent_id
        captured["task_data"] = task_data
        return FakeTask(), None

    monkeypatch.setattr(
        task_routes.task_service,
        "update_task_for_parent",
        fake_update_task_for_parent,
    )

    payload = {
        "title": "Updated title",
        "description": "Updated description",
        "points": 20,
        "task_frequency": "WEEKLY",
        "recurrence_day": 2,
        "category": "MORAL",
        "is_auto_verified": True,
    }

    response = update_task_request(
        client,
        parent["access_token"],
        "requested-task-id",
        payload,
    )

    assert response.status_code == 200
    assert captured == {
        "task_id": "requested-task-id",
        "parent_id": expected_parent_id,
        "task_data": payload,
    }


@pytest.mark.parametrize(
    ("service_error", "expected_status", "expected_body"),
    [
        (
            "not_found",
            404,
            {"error": "Task not found"},
        ),
        (
            "invalid_recurrence_day",
            400,
            {
                "error": (
                    "Invalid recurrence_day for selected "
                    "task_frequency"
                )
            },
        ),
        (
            "invalid_frequency",
            400,
            {"error": "Invalid task frequency"},
        ),
        (
            "update_failed",
            500,
            {"error": "Failed to update task"},
        ),
        (
            "assignment_failed",
            500,
            {"error": "Failed to update task"},
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

    monkeypatch.setattr(
        task_routes.task_service,
        "update_task_for_parent",
        lambda task_id, parent_id, task_data: (
            None,
            service_error,
        ),
    )

    response = update_task_request(
        client,
        parent["access_token"],
        "task-id",
        {"title": "Updated"},
    )

    assert response.status_code == expected_status
    assert response.get_json() == expected_body


def test_route_serializes_updated_task(client, monkeypatch):
    parent = register_parent(client)

    class FakeTask:
        id = "task-id"
        title = "Updated"
        description = "Description"
        points = 15
        task_frequency = "MONTHLY"
        recurrence_day = 31
        category = "FINANCIAL"
        is_auto_verified = False
        created_by = "parent-id"
        created_at = None

    monkeypatch.setattr(
        task_routes.task_service,
        "update_task_for_parent",
        lambda task_id, parent_id, task_data: (
            FakeTask(),
            None,
        ),
    )

    response = update_task_request(
        client,
        parent["access_token"],
        "task-id",
        {"title": "Updated"},
    )

    assert response.status_code == 200
    assert response.get_json() == {
        "id": "task-id",
        "title": "Updated",
        "description": "Description",
        "points": 15,
        "task_frequency": "MONTHLY",
        "recurrence_day": 31,
        "category": "FINANCIAL",
        "is_auto_verified": False,
        "created_by": "parent-id",
        "created_at": None,
    }


# ---------------------------------------------------------------------------
# _validate_recurrence_for_update
# ---------------------------------------------------------------------------

class RecurrenceTask:
    def __init__(
        self,
        task_frequency="ONCE",
        recurrence_day=None,
    ):
        self.task_frequency = task_frequency
        self.recurrence_day = recurrence_day


@pytest.mark.parametrize("frequency", ["ONCE", "DAILY"])
def test_validate_recurrence_clears_day_for_once_and_daily(
    frequency,
):
    service = task_routes.task_service
    task = RecurrenceTask("WEEKLY", 4)

    result = service._validate_recurrence_for_update(
        task,
        {"task_frequency": frequency},
    )

    assert result == (frequency, None, None)


@pytest.mark.parametrize("frequency", ["ONCE", "DAILY"])
def test_validate_recurrence_rejects_day_for_once_and_daily(
    frequency,
):
    service = task_routes.task_service
    task = RecurrenceTask()

    result = service._validate_recurrence_for_update(
        task,
        {
            "task_frequency": frequency,
            "recurrence_day": 1,
        },
    )

    assert result == (
        None,
        None,
        "invalid_recurrence_day",
    )


@pytest.mark.parametrize("day", [0, 3, 6])
def test_validate_recurrence_accepts_valid_weekly_days(day):
    service = task_routes.task_service
    task = RecurrenceTask()

    result = service._validate_recurrence_for_update(
        task,
        {
            "task_frequency": "WEEKLY",
            "recurrence_day": day,
        },
    )

    assert result == ("WEEKLY", day, None)


@pytest.mark.parametrize("day", [None, -1, 7])
def test_validate_recurrence_rejects_invalid_weekly_days(day):
    service = task_routes.task_service
    task = RecurrenceTask()

    result = service._validate_recurrence_for_update(
        task,
        {
            "task_frequency": "WEEKLY",
            "recurrence_day": day,
        },
    )

    assert result == (
        None,
        None,
        "invalid_recurrence_day",
    )


@pytest.mark.parametrize("day", [1, 15, 31])
def test_validate_recurrence_accepts_valid_monthly_days(day):
    service = task_routes.task_service
    task = RecurrenceTask()

    result = service._validate_recurrence_for_update(
        task,
        {
            "task_frequency": "MONTHLY",
            "recurrence_day": day,
        },
    )

    assert result == ("MONTHLY", day, None)


@pytest.mark.parametrize("day", [None, 0, 32])
def test_validate_recurrence_rejects_invalid_monthly_days(day):
    service = task_routes.task_service
    task = RecurrenceTask()

    result = service._validate_recurrence_for_update(
        task,
        {
            "task_frequency": "MONTHLY",
            "recurrence_day": day,
        },
    )

    assert result == (
        None,
        None,
        "invalid_recurrence_day",
    )


def test_validate_recurrence_uses_existing_values_when_omitted():
    service = task_routes.task_service
    task = RecurrenceTask("WEEKLY", 5)

    result = service._validate_recurrence_for_update(
        task,
        {"title": "Updated"},
    )

    assert result == ("WEEKLY", 5, None)


def test_validate_recurrence_rejects_invalid_existing_frequency():
    service = task_routes.task_service
    task = RecurrenceTask("INVALID", None)

    result = service._validate_recurrence_for_update(
        task,
        {"title": "Updated"},
    )

    assert result == (
        None,
        None,
        "invalid_frequency",
    )


# ---------------------------------------------------------------------------
# Service behavior
# ---------------------------------------------------------------------------

class FakeTaskChild:
    def __init__(self, child_id):
        self.child_id = child_id


class FakeTask:
    def __init__(
        self,
        task_frequency="ONCE",
        recurrence_day=None,
        task_children=None,
    ):
        self.id = "task-id"
        self.title = "Old title"
        self.description = "Old description"
        self.points = 10
        self.category = "MORAL"
        self.is_auto_verified = False
        self.task_frequency = task_frequency
        self.recurrence_day = recurrence_day
        self.task_children = task_children or []


def prepare_found_task(monkeypatch, task):
    service = task_routes.task_service

    monkeypatch.setattr(
        service.task_repository,
        "get_task_for_creator",
        lambda task_id, parent_id: task,
    )
    monkeypatch.setattr(
        service.task_repository,
        "update_task",
        lambda commit=False: (True, None),
    )

    return service


def test_service_returns_not_found_when_creator_task_is_missing(
    monkeypatch,
):
    service = task_routes.task_service
    captured = {}

    def fake_get_task(task_id, parent_id):
        captured["task_id"] = task_id
        captured["parent_id"] = parent_id
        return None

    monkeypatch.setattr(
        service.task_repository,
        "get_task_for_creator",
        fake_get_task,
    )

    result = service.update_task_for_parent(
        "task-id",
        "parent-id",
        {"title": "Updated"},
    )

    assert result == (None, "not_found")
    assert captured == {
        "task_id": "task-id",
        "parent_id": "parent-id",
    }


def test_service_returns_recurrence_validation_error_before_update(
    monkeypatch,
):
    task = FakeTask("WEEKLY", 2)
    service = task_routes.task_service
    update_called = {"value": False}

    monkeypatch.setattr(
        service.task_repository,
        "get_task_for_creator",
        lambda task_id, parent_id: task,
    )

    monkeypatch.setattr(
        service,
        "_validate_recurrence_for_update",
        lambda task, task_data: (
            None,
            None,
            "invalid_recurrence_day",
        ),
    )

    def fake_update_task(commit=False):
        update_called["value"] = True
        return True, None

    monkeypatch.setattr(
        service.task_repository,
        "update_task",
        fake_update_task,
    )

    result = service.update_task_for_parent(
        "task-id",
        "parent-id",
        {"recurrence_day": 9},
    )

    assert result == (
        None,
        "invalid_recurrence_day",
    )
    assert update_called["value"] is False


def test_service_updates_provided_fields_and_strips_strings(
    monkeypatch,
):
    task = FakeTask("WEEKLY", 1)
    service = prepare_found_task(monkeypatch, task)

    monkeypatch.setattr(
        task_service_module,
        "riyadh_today",
        lambda: date(2026, 7, 21),
    )
    monkeypatch.setattr(
        task_service_module,
        "is_task_due_on_date",
        lambda frequency, recurrence_day, today: False,
    )

    commit_calls = {"count": 0}
    monkeypatch.setattr(
        task_service_module.db.session,
        "commit",
        lambda: commit_calls.__setitem__(
            "count",
            commit_calls["count"] + 1,
        ),
    )

    result, error = service.update_task_for_parent(
        "task-id",
        "parent-id",
        {
            "title": "  New title  ",
            "description": "  New description  ",
            "points": 30,
            "category": "FINANCIAL",
            "is_auto_verified": True,
            "task_frequency": "WEEKLY",
            "recurrence_day": 4,
        },
    )

    assert error is None
    assert result is task
    assert task.title == "New title"
    assert task.description == "New description"
    assert task.points == 30
    assert task.category == "FINANCIAL"
    assert task.is_auto_verified is True
    assert task.task_frequency == "WEEKLY"
    assert task.recurrence_day == 4
    assert commit_calls["count"] == 1


def test_service_preserves_fields_not_in_payload(monkeypatch):
    task = FakeTask("WEEKLY", 1)
    service = prepare_found_task(monkeypatch, task)

    monkeypatch.setattr(
        task_service_module,
        "riyadh_today",
        lambda: date(2026, 7, 21),
    )
    monkeypatch.setattr(
        task_service_module,
        "is_task_due_on_date",
        lambda frequency, recurrence_day, today: False,
    )
    monkeypatch.setattr(
        task_service_module.db.session,
        "commit",
        lambda: None,
    )

    result, error = service.update_task_for_parent(
        "task-id",
        "parent-id",
        {"points": 50},
    )

    assert error is None
    assert result is task
    assert task.title == "Old title"
    assert task.description == "Old description"
    assert task.points == 50
    assert task.category == "MORAL"
    assert task.is_auto_verified is False
    assert task.task_frequency == "WEEKLY"
    assert task.recurrence_day == 1


def test_service_calls_repository_update_with_commit_false(
    monkeypatch,
):
    task = FakeTask("WEEKLY", 1)
    service = task_routes.task_service
    captured = {}

    monkeypatch.setattr(
        service.task_repository,
        "get_task_for_creator",
        lambda task_id, parent_id: task,
    )

    def fake_update_task(commit=False):
        captured["commit"] = commit
        return True, None

    monkeypatch.setattr(
        service.task_repository,
        "update_task",
        fake_update_task,
    )
    monkeypatch.setattr(
        task_service_module,
        "riyadh_today",
        lambda: date(2026, 7, 21),
    )
    monkeypatch.setattr(
        task_service_module,
        "is_task_due_on_date",
        lambda frequency, recurrence_day, today: False,
    )
    monkeypatch.setattr(
        task_service_module.db.session,
        "commit",
        lambda: None,
    )

    service.update_task_for_parent(
        "task-id",
        "parent-id",
        {"title": "Updated"},
    )

    assert captured["commit"] is False


def test_service_rolls_back_when_repository_update_fails(
    monkeypatch,
):
    task = FakeTask()
    service = task_routes.task_service
    rollback_calls = {"count": 0}

    monkeypatch.setattr(
        service.task_repository,
        "get_task_for_creator",
        lambda task_id, parent_id: task,
    )
    monkeypatch.setattr(
        service.task_repository,
        "update_task",
        lambda commit=False: (
            False,
            "integrity_error",
        ),
    )
    monkeypatch.setattr(
        task_service_module.db.session,
        "rollback",
        lambda: rollback_calls.__setitem__(
            "count",
            rollback_calls["count"] + 1,
        ),
    )

    result = service.update_task_for_parent(
        "task-id",
        "parent-id",
        {"title": "Updated"},
    )

    assert result == (None, "update_failed")
    assert rollback_calls["count"] == 1


def test_service_creates_assignment_for_once_task(
    monkeypatch,
):
    task = FakeTask(
        "ONCE",
        None,
        [
            FakeTaskChild("child-1"),
            FakeTaskChild("child-2"),
        ],
    )
    service = prepare_found_task(monkeypatch, task)
    today = date(2026, 7, 21)
    created_assignments = []

    monkeypatch.setattr(
        task_service_module,
        "riyadh_today",
        lambda: today,
    )
    monkeypatch.setattr(
        service.task_assignment_repository,
        "get_assignment_for_date",
        lambda task_id, child_id, assigned_date: None,
    )

    def fake_create_assignment(assignment, commit=False):
        created_assignments.append(
            {
                "task_id": assignment.task_id,
                "child_id": assignment.child_id,
                "status": assignment.status,
                "assigned_date": assignment.assigned_date,
                "commit": commit,
            }
        )
        return assignment, None

    monkeypatch.setattr(
        service.task_assignment_repository,
        "create_assignment",
        fake_create_assignment,
    )
    monkeypatch.setattr(
        task_service_module.db.session,
        "commit",
        lambda: None,
    )

    result, error = service.update_task_for_parent(
        "task-id",
        "parent-id",
        {"title": "Updated"},
    )

    assert error is None
    assert result is task
    assert created_assignments == [
        {
            "task_id": "task-id",
            "child_id": "child-1",
            "status": "PENDING",
            "assigned_date": today,
            "commit": False,
        },
        {
            "task_id": "task-id",
            "child_id": "child-2",
            "status": "PENDING",
            "assigned_date": today,
            "commit": False,
        },
    ]


def test_service_creates_assignment_when_recurring_task_is_due(
    monkeypatch,
):
    task = FakeTask(
        "WEEKLY",
        1,
        [FakeTaskChild("child-1")],
    )
    service = prepare_found_task(monkeypatch, task)
    today = date(2026, 7, 21)
    created = {"count": 0}

    monkeypatch.setattr(
        task_service_module,
        "riyadh_today",
        lambda: today,
    )
    monkeypatch.setattr(
        task_service_module,
        "is_task_due_on_date",
        lambda frequency, recurrence_day, target_date: True,
    )
    monkeypatch.setattr(
        service.task_assignment_repository,
        "get_assignment_for_date",
        lambda task_id, child_id, assigned_date: None,
    )

    def fake_create_assignment(assignment, commit=False):
        created["count"] += 1
        return assignment, None

    monkeypatch.setattr(
        service.task_assignment_repository,
        "create_assignment",
        fake_create_assignment,
    )
    monkeypatch.setattr(
        task_service_module.db.session,
        "commit",
        lambda: None,
    )

    result, error = service.update_task_for_parent(
        "task-id",
        "parent-id",
        {"title": "Updated"},
    )

    assert error is None
    assert result is task
    assert created["count"] == 1


def test_service_does_not_create_assignment_when_not_due(
    monkeypatch,
):
    task = FakeTask(
        "WEEKLY",
        1,
        [FakeTaskChild("child-1")],
    )
    service = prepare_found_task(monkeypatch, task)
    created = {"count": 0}

    monkeypatch.setattr(
        task_service_module,
        "riyadh_today",
        lambda: date(2026, 7, 21),
    )
    monkeypatch.setattr(
        task_service_module,
        "is_task_due_on_date",
        lambda frequency, recurrence_day, today: False,
    )

    def fake_create_assignment(assignment, commit=False):
        created["count"] += 1
        return assignment, None

    monkeypatch.setattr(
        service.task_assignment_repository,
        "create_assignment",
        fake_create_assignment,
    )
    monkeypatch.setattr(
        task_service_module.db.session,
        "commit",
        lambda: None,
    )

    result, error = service.update_task_for_parent(
        "task-id",
        "parent-id",
        {"title": "Updated"},
    )

    assert error is None
    assert result is task
    assert created["count"] == 0


def test_service_skips_child_with_existing_assignment(
    monkeypatch,
):
    task = FakeTask(
        "ONCE",
        None,
        [
            FakeTaskChild("child-1"),
            FakeTaskChild("child-2"),
        ],
    )
    service = prepare_found_task(monkeypatch, task)
    created_child_ids = []

    monkeypatch.setattr(
        task_service_module,
        "riyadh_today",
        lambda: date(2026, 7, 21),
    )

    def fake_get_existing(task_id, child_id, assigned_date):
        if child_id == "child-1":
            return object()
        return None

    monkeypatch.setattr(
        service.task_assignment_repository,
        "get_assignment_for_date",
        fake_get_existing,
    )

    def fake_create_assignment(assignment, commit=False):
        created_child_ids.append(assignment.child_id)
        return assignment, None

    monkeypatch.setattr(
        service.task_assignment_repository,
        "create_assignment",
        fake_create_assignment,
    )
    monkeypatch.setattr(
        task_service_module.db.session,
        "commit",
        lambda: None,
    )

    result, error = service.update_task_for_parent(
        "task-id",
        "parent-id",
        {"title": "Updated"},
    )

    assert error is None
    assert result is task
    assert created_child_ids == ["child-2"]


def test_service_rolls_back_when_assignment_creation_fails(
    monkeypatch,
):
    task = FakeTask(
        "ONCE",
        None,
        [FakeTaskChild("child-1")],
    )
    service = prepare_found_task(monkeypatch, task)
    rollback_calls = {"count": 0}
    commit_calls = {"count": 0}

    monkeypatch.setattr(
        task_service_module,
        "riyadh_today",
        lambda: date(2026, 7, 21),
    )
    monkeypatch.setattr(
        service.task_assignment_repository,
        "get_assignment_for_date",
        lambda task_id, child_id, assigned_date: None,
    )
    monkeypatch.setattr(
        service.task_assignment_repository,
        "create_assignment",
        lambda assignment, commit=False: (
            None,
            "integrity_error",
        ),
    )
    monkeypatch.setattr(
        task_service_module.db.session,
        "rollback",
        lambda: rollback_calls.__setitem__(
            "count",
            rollback_calls["count"] + 1,
        ),
    )
    monkeypatch.setattr(
        task_service_module.db.session,
        "commit",
        lambda: commit_calls.__setitem__(
            "count",
            commit_calls["count"] + 1,
        ),
    )

    result = service.update_task_for_parent(
        "task-id",
        "parent-id",
        {"title": "Updated"},
    )

    assert result == (None, "assignment_failed")
    assert rollback_calls["count"] == 1
    assert commit_calls["count"] == 0


def test_service_rolls_back_on_unexpected_exception(
    monkeypatch,
):
    task = FakeTask()
    service = task_routes.task_service
    rollback_calls = {"count": 0}

    monkeypatch.setattr(
        service.task_repository,
        "get_task_for_creator",
        lambda task_id, parent_id: task,
    )
    monkeypatch.setattr(
        service.task_repository,
        "update_task",
        lambda commit=False: (_ for _ in ()).throw(
            RuntimeError("database error")
        ),
    )
    monkeypatch.setattr(
        task_service_module.db.session,
        "rollback",
        lambda: rollback_calls.__setitem__(
            "count",
            rollback_calls["count"] + 1,
        ),
    )

    result = service.update_task_for_parent(
        "task-id",
        "parent-id",
        {"title": "Updated"},
    )

    assert result == (None, "update_failed")
    assert rollback_calls["count"] == 1


# ---------------------------------------------------------------------------
# Pure helper: is_task_due_on_date
# ---------------------------------------------------------------------------

def test_daily_task_is_always_due():
    assert task_service_module.is_task_due_on_date(
        "DAILY",
        None,
        date(2026, 7, 21),
    ) is True


def test_weekly_task_is_due_on_matching_weekday():
    target = date(2026, 7, 21)

    assert task_service_module.is_task_due_on_date(
        "WEEKLY",
        target.weekday(),
        target,
    ) is True


def test_weekly_task_is_not_due_on_different_weekday():
    target = date(2026, 7, 21)

    assert task_service_module.is_task_due_on_date(
        "WEEKLY",
        (target.weekday() + 1) % 7,
        target,
    ) is False


def test_monthly_task_is_due_on_selected_day():
    assert task_service_module.is_task_due_on_date(
        "MONTHLY",
        21,
        date(2026, 7, 21),
    ) is True


def test_monthly_day_31_uses_last_day_of_short_month():
    assert task_service_module.is_task_due_on_date(
        "MONTHLY",
        31,
        date(2026, 2, 28),
    ) is True


def test_once_frequency_is_not_handled_as_due_by_helper():
    assert task_service_module.is_task_due_on_date(
        "ONCE",
        None,
        date(2026, 7, 21),
    ) is False