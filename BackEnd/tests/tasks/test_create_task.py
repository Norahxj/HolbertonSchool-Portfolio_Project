import pytest
from flask_jwt_extended import decode_token
import app.services.task_service as task_service_module
from app.extensions import db
from app.routes import task_routes


REGISTER_URL = "/api/auth/register"
CHILDREN_URL = "/api/children/"
TASKS_URL = "/api/tasks/"
CHILD_LOGIN_URL = "/api/auth/child-login"


def valid_parent_data(
    *,
    first_name="Manar",
    last_name="Zaid",
    phone="0551234567",
    email="create.task.parent@gmail.com",
    guardian_type="mother",
):
    return {
        "first_name": first_name,
        "last_name": last_name,
        "phone": phone,
        "email": email,
        "password": "Password123!",
        "guardian_type": guardian_type,
    }


def valid_child_data(
    *,
    name="Sara",
    birth_date="2015-05-10",
    phone="0559876543",
):
    return {
        "name": name,
        "birth_date": birth_date,
        "phone": phone,
    }


def valid_task_data(
    child_ids,
    *,
    title="Arrange your room",
    description="Arrange and clean your room",
    points=10,
    task_frequency="ONCE",
    recurrence_day=None,
    category="MORAL",
    is_auto_verified=False,
):
    return {
        "child_ids": child_ids,
        "title": title,
        "description": description,
        "points": points,
        "task_frequency": task_frequency,
        "recurrence_day": recurrence_day,
        "category": category,
        "is_auto_verified": is_auto_verified,
    }


def authorization_header(access_token):
    return {
        "Authorization": access_token,
    }


def register_parent(client, parent_data=None):
    response = client.post(
        REGISTER_URL,
        json=parent_data or valid_parent_data(),
    )
    response_data = response.get_json()

    assert response.status_code == 201, response_data
    assert "access_token" in response_data

    return response_data


def create_child(client, access_token, child_data=None):
    response = client.post(
        CHILDREN_URL,
        headers=authorization_header(access_token),
        json=child_data or valid_child_data(),
    )
    response_data = response.get_json()

    assert response.status_code == 201, response_data

    if isinstance(response_data, dict) and "child" in response_data:
        return response_data["child"]

    return response_data


def create_task_request(client, access_token, payload):
    return client.post(
        TASKS_URL,
        headers=authorization_header(access_token),
        json=payload,
    )


# =========================================================
# Successful requests
# =========================================================


def test_create_task_success_for_one_child(client):
    parent = register_parent(client)
    child = create_child(client, parent["access_token"])

    response = create_task_request(
        client,
        parent["access_token"],
        valid_task_data([child["id"]]),
    )
    response_data = response.get_json()

    assert response.status_code == 201, response_data
    assert response_data["title"] == "Arrange your room"
    assert response_data["description"] == "Arrange and clean your room"
    assert response_data["points"] == 10
    assert response_data["task_frequency"] == "ONCE"
    assert response_data["recurrence_day"] is None
    assert response_data["category"] == "MORAL"
    assert response_data["is_auto_verified"] is False


def test_create_task_response_contains_schema_fields(client):
    parent = register_parent(client)
    child = create_child(client, parent["access_token"])

    response = create_task_request(
        client,
        parent["access_token"],
        valid_task_data([child["id"]]),
    )
    response_data = response.get_json()

    expected_fields = {
        "id",
        "title",
        "description",
        "points",
        "task_frequency",
        "recurrence_day",
        "category",
        "is_auto_verified",
        "created_by",
        "created_at",
    }

    assert response.status_code == 201, response_data
    assert expected_fields.issubset(response_data.keys())


def test_create_task_for_multiple_children(client):
    parent = register_parent(client)

    first_child = create_child(
        client,
        parent["access_token"],
        valid_child_data(
            name="Sara",
            phone="0551111111",
        ),
    )

    second_child = create_child(
        client,
        parent["access_token"],
        valid_child_data(
            name="Noura",
            birth_date="2014-06-15",
            phone="0552222222",
        ),
    )

    response = create_task_request(
        client,
        parent["access_token"],
        valid_task_data(
            [first_child["id"], second_child["id"]]
        ),
    )

    assert response.status_code == 201, response.get_json()


def test_create_task_uses_default_frequency_and_verification(client):
    parent = register_parent(client)
    child = create_child(client, parent["access_token"])

    payload = {
        "child_ids": [child["id"]],
        "title": "Read a book",
        "description": "Read ten pages",
        "points": 15,
        "category": "MORAL",
    }

    response = create_task_request(
        client,
        parent["access_token"],
        payload,
    )
    response_data = response.get_json()

    assert response.status_code == 201, response_data
    assert response_data["task_frequency"] == "ONCE"
    assert response_data["is_auto_verified"] is False


@pytest.mark.parametrize(
    "task_frequency, recurrence_day",
    [
        ("DAILY", None),
        ("WEEKLY", 2),
        ("MONTHLY", 15),
    ],
)
def test_create_task_accepts_supported_frequencies(
    client,
    task_frequency,
    recurrence_day,
):
    parent = register_parent(client)
    child = create_child(client, parent["access_token"])

    response = create_task_request(
        client,
        parent["access_token"],
        valid_task_data(
            [child["id"]],
            task_frequency=task_frequency,
            recurrence_day=recurrence_day,
        ),
    )
    response_data = response.get_json()

    assert response.status_code == 201, response_data
    assert response_data["task_frequency"] == task_frequency
    assert response_data["recurrence_day"] == recurrence_day


# =========================================================
# Child IDs validation and access
# =========================================================


def test_create_task_rejects_empty_child_ids(client):
    parent = register_parent(client)

    response = create_task_request(
        client,
        parent["access_token"],
        valid_task_data([]),
    )

    assert response.status_code == 400


def test_create_task_rejects_duplicate_child_ids(client):
    parent = register_parent(client)
    child = create_child(client, parent["access_token"])

    response = create_task_request(
        client,
        parent["access_token"],
        valid_task_data([child["id"], child["id"]]),
    )
    response_data = response.get_json()

    assert response.status_code == 400, response_data
    assert response_data == {
        "error": "Duplicate child IDs are not allowed"
    }


def test_create_task_returns_404_for_unknown_child(client):
    parent = register_parent(client)

    response = create_task_request(
        client,
        parent["access_token"],
        valid_task_data(
            ["00000000-0000-0000-0000-000000000000"]
        ),
    )
    response_data = response.get_json()

    assert response.status_code == 404, response_data
    assert response_data == {"error": "Child not found"}


def test_parent_cannot_create_task_for_another_family_child(client):
    first_parent = register_parent(
        client,
        valid_parent_data(
            phone="0553333333",
            email="first.create.task.parent@gmail.com",
        ),
    )

    second_parent = register_parent(
        client,
        valid_parent_data(
            first_name="Noura",
            phone="0554444444",
            email="second.create.task.parent@gmail.com",
        ),
    )

    second_child = create_child(
        client,
        second_parent["access_token"],
        valid_child_data(
            name="Khalid",
            phone="0555555555",
        ),
    )

    response = create_task_request(
        client,
        first_parent["access_token"],
        valid_task_data([second_child["id"]]),
    )

    assert response.status_code == 404
    assert response.get_json() == {"error": "Child not found"}


# =========================================================
# Schema validation
# =========================================================


@pytest.mark.parametrize(
    "missing_field",
    [
        "child_ids",
        "title",
        "description",
        "points",
        "category",
    ],
)
def test_create_task_rejects_missing_required_field(
    client,
    missing_field,
):
    parent = register_parent(client)
    child = create_child(client, parent["access_token"])

    payload = valid_task_data([child["id"]])
    payload.pop(missing_field)

    response = create_task_request(
        client,
        parent["access_token"],
        payload,
    )

    assert response.status_code == 400


@pytest.mark.parametrize(
    "invalid_points",
    [
        0,
        -1,
        101,
        1000,
    ],
)
def test_create_task_rejects_points_outside_range(
    client,
    invalid_points,
):
    parent = register_parent(client)
    child = create_child(client, parent["access_token"])

    response = create_task_request(
        client,
        parent["access_token"],
        valid_task_data(
            [child["id"]],
            points=invalid_points,
        ),
    )

    assert response.status_code == 400


@pytest.mark.parametrize(
    "invalid_frequency",
    [
        "",
        "YEARLY",
        "WEEK",
        "daily",
    ],
)
def test_create_task_rejects_invalid_frequency(
    client,
    invalid_frequency,
):
    parent = register_parent(client)
    child = create_child(client, parent["access_token"])

    response = create_task_request(
        client,
        parent["access_token"],
        valid_task_data(
            [child["id"]],
            task_frequency=invalid_frequency,
        ),
    )

    assert response.status_code == 400


@pytest.mark.parametrize(
    "invalid_category",
    [
        "",
        "UNKNOWN",
        "DAILY",
        "moral",
    ],
)
def test_create_task_rejects_invalid_category(
    client,
    invalid_category,
):
    parent = register_parent(client)
    child = create_child(client, parent["access_token"])

    response = create_task_request(
        client,
        parent["access_token"],
        valid_task_data(
            [child["id"]],
            category=invalid_category,
        ),
    )

    assert response.status_code == 400


@pytest.mark.parametrize(
    "field, invalid_value",
    [
        ("child_ids", "not-a-list"),
        ("title", 123),
        ("description", 123),
        ("points", "ten"),
        ("task_frequency", 123),
        ("recurrence_day", "monday"),
        ("category", 123),
        ("is_auto_verified", {"value": True}),
    ],
)
def test_create_task_rejects_invalid_field_types(
    client,
    field,
    invalid_value,
):
    parent = register_parent(client)
    child = create_child(client, parent["access_token"])

    payload = valid_task_data([child["id"]])
    payload[field] = invalid_value

    response = create_task_request(
        client,
        parent["access_token"],
        payload,
    )

    assert response.status_code == 400


# =========================================================
# Authentication and authorization
# =========================================================


def test_create_task_requires_access_token(client):
    response = client.post(
        TASKS_URL,
        json=valid_task_data(
            ["00000000-0000-0000-0000-000000000000"]
        ),
    )

    assert response.status_code == 401


@pytest.mark.parametrize(
    "invalid_token",
    [
        "invalid-token",
        "abc.def",
        "abc.def.ghi",
    ],
)
def test_create_task_rejects_invalid_token(
    client,
    invalid_token,
):
    response = create_task_request(
        client,
        invalid_token,
        valid_task_data(
            ["00000000-0000-0000-0000-000000000000"]
        ),
    )

    assert response.status_code in (401, 422)


def test_child_token_cannot_create_task(client):
    parent = register_parent(client)
    child = create_child(client, parent["access_token"])

    login_response = client.post(
        CHILD_LOGIN_URL,
        json={"access_code": child["access_code"]},
    )
    login_data = login_response.get_json()

    assert login_response.status_code == 200, login_data

    response = create_task_request(
        client,
        login_data["access_token"],
        valid_task_data([child["id"]]),
    )

    assert response.status_code == 403
    assert response.get_json() == {
        "error": "Parent access required"
    }


# =========================================================
# Route behavior
# =========================================================


def test_route_passes_parent_id_and_loaded_data_to_service(
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
        id = "task-id-123"
        title = "Test task"
        description = "Test description"
        points = 10
        task_frequency = "ONCE"
        recurrence_day = None
        category = "MORAL"
        is_auto_verified = False
        created_by = expected_parent_id
        created_at = None

    def fake_create_task(parent_id, task_data):
        captured["parent_id"] = parent_id
        captured["task_data"] = task_data
        return FakeTask(), None

    monkeypatch.setattr(
        task_routes.task_service,
        "create_task",
        fake_create_task,
    )

    payload = {
        "child_ids": ["child-id-123"],
        "title": "Test task",
        "description": "Test description",
        "points": 10,
        "category": "MORAL",
    }

    response = create_task_request(
        client,
        parent["access_token"],
        payload,
    )

    assert response.status_code == 201
    assert captured["parent_id"] == expected_parent_id
    assert captured["task_data"] == {
        "child_ids": ["child-id-123"],
        "title": "Test task",
        "description": "Test description",
        "points": 10,
        "task_frequency": "ONCE",
        "category": "MORAL",
        "is_auto_verified": False,
    }


@pytest.mark.parametrize(
    "service_error, expected_status, expected_body",
    [
        (
            "duplicate_child_ids",
            400,
            {"error": "Duplicate child IDs are not allowed"},
        ),
        (
            "child_ids_required",
            400,
            {"error": "At least one child ID is required"},
        ),
        (
            "child_not_found",
            404,
            {"error": "Child not found"},
        ),
        (
            "create_failed",
            500,
            {"error": "Failed to create task"},
        ),
        (
            "task_child_failed",
            500,
            {"error": "Failed to create task"},
        ),
        (
            "assignment_failed",
            500,
            {"error": "Failed to create task"},
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
        "create_task",
        lambda parent_id, task_data: (
            None,
            service_error,
        ),
    )

    response = create_task_request(
        client,
        parent["access_token"],
        valid_task_data(["child-id-123"]),
    )

    assert response.status_code == expected_status
    assert response.get_json() == expected_body


def test_route_serializes_service_task(
    client,
    monkeypatch,
):
    parent = register_parent(client)

    class FakeTask:
        id = "fake-task-id"
        title = "Fake task"
        description = "Fake description"
        points = 25
        task_frequency = "WEEKLY"
        recurrence_day = 3
        category = "RELIGIOUS"
        is_auto_verified = True
        created_by = "parent-id"
        created_at = None

    monkeypatch.setattr(
        task_routes.task_service,
        "create_task",
        lambda parent_id, task_data: (
            FakeTask(),
            None,
        ),
    )

    response = create_task_request(
        client,
        parent["access_token"],
        valid_task_data(["child-id-123"]),
    )

    assert response.status_code == 201
    assert response.get_json() == {
        "id": "fake-task-id",
        "title": "Fake task",
        "description": "Fake description",
        "points": 25,
        "task_frequency": "WEEKLY",
        "recurrence_day": 3,
        "category": "RELIGIOUS",
        "is_auto_verified": True,
        "created_by": "parent-id",
        "created_at": None,
    }


# =========================================================
# Service behavior
# =========================================================


def test_service_rejects_empty_child_ids():
    service = task_routes.task_service

    task, error = service.create_task(
        "parent-id",
        {"child_ids": []},
    )

    assert task is None
    assert error == "child_ids_required"


def test_service_rejects_duplicate_child_ids():
    service = task_routes.task_service

    task, error = service.create_task(
        "parent-id",
        {
            "child_ids": [
                "child-id",
                "child-id",
            ]
        },
    )

    assert task is None
    assert error == "duplicate_child_ids"


def test_service_returns_child_not_found(
    monkeypatch,
):
    service = task_routes.task_service
    captured = []

    def fake_get_child_for_guardian(child_id, parent_id):
        captured.append((child_id, parent_id))
        if child_id == "missing-child":
            return None
        return object()

    monkeypatch.setattr(
        service.child_repository,
        "get_child_for_guardian",
        fake_get_child_for_guardian,
    )

    task, error = service.create_task(
        "parent-id",
        {
            "child_ids": [
                "existing-child",
                "missing-child",
            ]
        },
    )

    assert task is None
    assert error == "child_not_found"
    assert captured == [
        ("existing-child", "parent-id"),
        ("missing-child", "parent-id"),
    ]


def test_service_rolls_back_when_task_creation_fails(
    monkeypatch,
):
    service = task_routes.task_service
    fake_child = object()
    rollback_called = {"value": False}

    monkeypatch.setattr(
        service.child_repository,
        "get_child_for_guardian",
        lambda child_id, parent_id: fake_child,
    )

    monkeypatch.setattr(
        service,
        "_build_task",
        lambda parent_id, task_data: object(),
    )

    monkeypatch.setattr(
        service.task_repository,
        "create_task",
        lambda task, commit=False: (
            None,
            "create_error",
        ),
    )

    monkeypatch.setattr(
        db.session,
        "rollback",
        lambda: rollback_called.update(value=True),
    )

    task, error = service.create_task(
        "parent-id",
        {"child_ids": ["child-id"]},
    )

    assert task is None
    assert error == "create_failed"
    assert rollback_called["value"] is True


def test_service_creates_task_child_for_each_child(
    monkeypatch,
):
    service = task_routes.task_service

    class FakeChild:
        def __init__(self, child_id):
            self.id = child_id

    children = {
        "child-1": FakeChild("child-1"),
        "child-2": FakeChild("child-2"),
    }

    class FakeTask:
        id = "task-id"
        task_frequency = "WEEKLY"
        recurrence_day = 0

    created_task_children = []

    monkeypatch.setattr(
        service.child_repository,
        "get_child_for_guardian",
        lambda child_id, parent_id: children[child_id],
    )

    monkeypatch.setattr(
        service,
        "_build_task",
        lambda parent_id, task_data: FakeTask(),
    )

    monkeypatch.setattr(
        service.task_repository,
        "create_task",
        lambda task, commit=False: (task, None),
    )

    def fake_create_task_child(task_child, commit=False):
        created_task_children.append(task_child)
        return task_child, None

    monkeypatch.setattr(
        service.task_child_repository,
        "create_task_child",
        fake_create_task_child,
    )

    monkeypatch.setattr(
       task_service_module,
        "is_task_due_on_date",
        lambda frequency, recurrence_day, today: False,
    )

    monkeypatch.setattr(
        db.session,
        "commit",
        lambda: None,
    )

    task, error = service.create_task(
        "parent-id",
        {
            "child_ids": ["child-1", "child-2"],
        },
    )

    assert error is None
    assert task.id == "task-id"
    assert len(created_task_children) == 2

    assert {
        task_child.child_id
        for task_child in created_task_children
    } == {"child-1", "child-2"}

    assert {
        task_child.task_id
        for task_child in created_task_children
    } == {"task-id"}


def test_service_creates_assignment_for_once_task(
    monkeypatch,
):
    service = task_routes.task_service

    class FakeChild:
        id = "child-id"

    class FakeTask:
        id = "task-id"
        task_frequency = "ONCE"
        recurrence_day = None

    created_assignments = []

    monkeypatch.setattr(
        service.child_repository,
        "get_child_for_guardian",
        lambda child_id, parent_id: FakeChild(),
    )

    monkeypatch.setattr(
        service,
        "_build_task",
        lambda parent_id, task_data: FakeTask(),
    )

    monkeypatch.setattr(
        service.task_repository,
        "create_task",
        lambda task, commit=False: (task, None),
    )

    monkeypatch.setattr(
        service.task_child_repository,
        "create_task_child",
        lambda task_child, commit=False: (
            task_child,
            None,
        ),
    )

    def fake_create_assignment(assignment, commit=False):
        created_assignments.append(assignment)
        return assignment, None

    monkeypatch.setattr(
        service.task_assignment_repository,
        "create_assignment",
        fake_create_assignment,
    )

    monkeypatch.setattr(
        db.session,
        "commit",
        lambda: None,
    )

    task, error = service.create_task(
        "parent-id",
        {"child_ids": ["child-id"]},
    )

    assert error is None
    assert task.id == "task-id"
    assert len(created_assignments) == 1
    assert created_assignments[0].task_id == "task-id"
    assert created_assignments[0].child_id == "child-id"
    assert created_assignments[0].status == "PENDING"


def test_service_does_not_create_assignment_when_not_due(
    monkeypatch,
):
    service = task_routes.task_service

    class FakeChild:
        id = "child-id"

    class FakeTask:
        id = "task-id"
        task_frequency = "WEEKLY"
        recurrence_day = 4

    assignment_called = {"value": False}

    monkeypatch.setattr(
        service.child_repository,
        "get_child_for_guardian",
        lambda child_id, parent_id: FakeChild(),
    )

    monkeypatch.setattr(
        service,
        "_build_task",
        lambda parent_id, task_data: FakeTask(),
    )

    monkeypatch.setattr(
        service.task_repository,
        "create_task",
        lambda task, commit=False: (task, None),
    )

    monkeypatch.setattr(
        service.task_child_repository,
        "create_task_child",
        lambda task_child, commit=False: (
            task_child,
            None,
        ),
    )

    monkeypatch.setattr(
        task_service_module,
        "is_task_due_on_date",
        lambda frequency, recurrence_day, today: False,
    )

    def fake_create_assignment(assignment, commit=False):
        assignment_called["value"] = True
        return assignment, None

    monkeypatch.setattr(
        service.task_assignment_repository,
        "create_assignment",
        fake_create_assignment,
    )

    monkeypatch.setattr(
        db.session,
        "commit",
        lambda: None,
    )

    task, error = service.create_task(
        "parent-id",
        {"child_ids": ["child-id"]},
    )

    assert error is None
    assert task.id == "task-id"
    assert assignment_called["value"] is False


def test_service_rolls_back_when_task_child_creation_fails(
    monkeypatch,
):
    service = task_routes.task_service

    class FakeChild:
        id = "child-id"

    class FakeTask:
        id = "task-id"
        task_frequency = "ONCE"
        recurrence_day = None

    rollback_called = {"value": False}

    monkeypatch.setattr(
        service.child_repository,
        "get_child_for_guardian",
        lambda child_id, parent_id: FakeChild(),
    )

    monkeypatch.setattr(
        service,
        "_build_task",
        lambda parent_id, task_data: FakeTask(),
    )

    monkeypatch.setattr(
        service.task_repository,
        "create_task",
        lambda task, commit=False: (task, None),
    )

    monkeypatch.setattr(
        service.task_child_repository,
        "create_task_child",
        lambda task_child, commit=False: (
            None,
            "task_child_error",
        ),
    )

    monkeypatch.setattr(
        db.session,
        "rollback",
        lambda: rollback_called.update(value=True),
    )

    task, error = service.create_task(
        "parent-id",
        {"child_ids": ["child-id"]},
    )

    assert task is None
    assert error == "task_child_failed"
    assert rollback_called["value"] is True


def test_service_rolls_back_when_assignment_creation_fails(
    monkeypatch,
):
    service = task_routes.task_service

    class FakeChild:
        id = "child-id"

    class FakeTask:
        id = "task-id"
        task_frequency = "ONCE"
        recurrence_day = None

    rollback_called = {"value": False}

    monkeypatch.setattr(
        service.child_repository,
        "get_child_for_guardian",
        lambda child_id, parent_id: FakeChild(),
    )

    monkeypatch.setattr(
        service,
        "_build_task",
        lambda parent_id, task_data: FakeTask(),
    )

    monkeypatch.setattr(
        service.task_repository,
        "create_task",
        lambda task, commit=False: (task, None),
    )

    monkeypatch.setattr(
        service.task_child_repository,
        "create_task_child",
        lambda task_child, commit=False: (
            task_child,
            None,
        ),
    )

    monkeypatch.setattr(
        service.task_assignment_repository,
        "create_assignment",
        lambda assignment, commit=False: (
            None,
            "assignment_error",
        ),
    )

    monkeypatch.setattr(
        db.session,
        "rollback",
        lambda: rollback_called.update(value=True),
    )

    task, error = service.create_task(
        "parent-id",
        {"child_ids": ["child-id"]},
    )

    assert task is None
    assert error == "assignment_failed"
    assert rollback_called["value"] is True


def test_service_commits_once_after_success(
    monkeypatch,
):
    service = task_routes.task_service

    class FakeChild:
        id = "child-id"

    class FakeTask:
        id = "task-id"
        task_frequency = "ONCE"
        recurrence_day = None

    commit_count = {"value": 0}

    monkeypatch.setattr(
        service.child_repository,
        "get_child_for_guardian",
        lambda child_id, parent_id: FakeChild(),
    )

    monkeypatch.setattr(
        service,
        "_build_task",
        lambda parent_id, task_data: FakeTask(),
    )

    monkeypatch.setattr(
        service.task_repository,
        "create_task",
        lambda task, commit=False: (task, None),
    )

    monkeypatch.setattr(
        service.task_child_repository,
        "create_task_child",
        lambda task_child, commit=False: (
            task_child,
            None,
        ),
    )

    monkeypatch.setattr(
        service.task_assignment_repository,
        "create_assignment",
        lambda assignment, commit=False: (
            assignment,
            None,
        ),
    )

    def fake_commit():
        commit_count["value"] += 1

    monkeypatch.setattr(
        db.session,
        "commit",
        fake_commit,
    )

    task, error = service.create_task(
        "parent-id",
        {"child_ids": ["child-id"]},
    )

    assert error is None
    assert task.id == "task-id"
    assert commit_count["value"] == 1