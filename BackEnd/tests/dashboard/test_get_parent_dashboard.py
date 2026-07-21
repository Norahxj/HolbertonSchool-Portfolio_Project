from datetime import date

import pytest
from flask_jwt_extended import decode_token

from app.routes import dashboard_routes
import app.services.dashboard_service as service_module


REGISTER_URL = "/api/auth/register"
CHILDREN_URL = "/api/children/"
CHILD_LOGIN_URL = "/api/auth/child-login"
DASHBOARD_URL = "/api/dashboard/"


def auth_header(token):
    return {"Authorization": token}


def register_parent(
    client,
    email="dashboard.parent@gmail.com",
    phone="0557901001",
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
    parent_token,
    name="Sara",
    birth_date="2015-05-10",
    phone="0557901099",
):
    response = client.post(
        CHILDREN_URL,
        headers=auth_header(parent_token),
        json={
            "name": name,
            "birth_date": birth_date,
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


def get_dashboard(client, token):
    return client.get(
        DASHBOARD_URL,
        headers=auth_header(token),
    )


# ===========================================================================
# Route tests
# ===========================================================================

def test_route_requires_access_token(client):
    response = client.get(DASHBOARD_URL)

    assert response.status_code == 401


def test_route_rejects_invalid_access_token(client):
    response = client.get(
        DASHBOARD_URL,
        headers=auth_header("invalid-token"),
    )

    assert response.status_code in (401, 422)


def test_child_cannot_get_parent_dashboard(client):
    parent = register_parent(client)
    child = create_child(
        client,
        parent["access_token"],
    )
    child_login = login_child(
        client,
        child["access_code"],
    )

    response = get_dashboard(
        client,
        child_login["access_token"],
    )

    assert response.status_code == 403
    assert response.get_json() == {
        "error": "Parent access required"
    }


def test_route_passes_parent_identity_and_role_to_service(
    client,
    app,
    monkeypatch,
):
    parent = register_parent(client)

    with app.app_context():
        expected_parent_id = decode_token(
            parent["access_token"]
        )["sub"]

    expected_dashboard = []
    captured = {}

    def fake_get_dashboard(user_id, role):
        captured["user_id"] = user_id
        captured["role"] = role
        return expected_dashboard, None

    monkeypatch.setattr(
        dashboard_routes.dashboard_service,
        "get_dashboard",
        fake_get_dashboard,
    )
    monkeypatch.setattr(
        dashboard_routes.dashboard_response_schema,
        "dump",
        lambda value: [],
    )

    response = get_dashboard(
        client,
        parent["access_token"],
    )

    assert response.status_code == 200
    assert captured == {
        "user_id": expected_parent_id,
        "role": "parent",
    }


def test_route_maps_parent_not_found_to_404(
    client,
    monkeypatch,
):
    parent = register_parent(
        client,
        email="dashboard.missing.parent@gmail.com",
        phone="0557901002",
    )

    monkeypatch.setattr(
        dashboard_routes.dashboard_service,
        "get_dashboard",
        lambda user_id, role: (
            None,
            "parent_not_found",
        ),
    )

    response = get_dashboard(
        client,
        parent["access_token"],
    )

    assert response.status_code == 404
    assert response.get_json() == {
        "error": "Parent not found"
    }


@pytest.mark.parametrize(
    "service_error",
    [
        "invalid_role",
        "child_not_found",
        "repository_error",
        "unexpected_error",
    ],
)
def test_route_maps_other_errors_to_500(
    client,
    monkeypatch,
    service_error,
):
    parent = register_parent(
        client,
        email=f"dashboard.{service_error}@gmail.com",
        phone="0557901003",
    )

    monkeypatch.setattr(
        dashboard_routes.dashboard_service,
        "get_dashboard",
        lambda user_id, role: (
            None,
            service_error,
        ),
    )

    response = get_dashboard(
        client,
        parent["access_token"],
    )

    assert response.status_code == 500
    assert response.get_json() == {
        "error": "Failed to retrieve dashboard"
    }


def test_route_does_not_serialize_when_service_fails(
    client,
    monkeypatch,
):
    parent = register_parent(
        client,
        email="dashboard.no.serialize@gmail.com",
        phone="0557901004",
    )
    dump_calls = {"count": 0}

    monkeypatch.setattr(
        dashboard_routes.dashboard_service,
        "get_dashboard",
        lambda user_id, role: (
            None,
            "repository_error",
        ),
    )

    def fake_dump(value):
        dump_calls["count"] += 1
        return []

    monkeypatch.setattr(
        dashboard_routes.dashboard_response_schema,
        "dump",
        fake_dump,
    )

    response = get_dashboard(
        client,
        parent["access_token"],
    )

    assert response.status_code == 500
    assert dump_calls["count"] == 0


def test_route_serializes_dashboard_list(
    client,
    monkeypatch,
):
    parent = register_parent(
        client,
        email="dashboard.success@gmail.com",
        phone="0557901005",
    )

    dashboard = [object(), object()]
    serialized_dashboard = [
        {
            "child_id": "child-1",
            "child_name": "Sara",
            "child_age": 11,
            "week_start": "2026-07-17",
            "week_end": "2026-07-23",
            "progress_percentage": 50.0,
            "completed_tasks": 2,
            "approved_tasks": 2,
            "pending_review_tasks": 1,
            "pending_tasks": 1,
            "rejected_tasks": 0,
            "remaining_tasks": 2,
            "total_tasks": 4,
        },
        {
            "child_id": "child-2",
            "child_name": "Omar",
            "child_age": 9,
            "week_start": "2026-07-17",
            "week_end": "2026-07-23",
            "progress_percentage": 0.0,
            "completed_tasks": 0,
            "approved_tasks": 0,
            "pending_review_tasks": 0,
            "pending_tasks": 0,
            "rejected_tasks": 0,
            "remaining_tasks": 0,
            "total_tasks": 0,
        },
    ]
    captured = {}

    monkeypatch.setattr(
        dashboard_routes.dashboard_service,
        "get_dashboard",
        lambda user_id, role: (
            dashboard,
            None,
        ),
    )

    def fake_dump(value):
        captured["dashboard"] = value
        return serialized_dashboard

    monkeypatch.setattr(
        dashboard_routes.dashboard_response_schema,
        "dump",
        fake_dump,
    )

    response = get_dashboard(
        client,
        parent["access_token"],
    )

    assert response.status_code == 200
    assert response.get_json() == serialized_dashboard
    assert captured["dashboard"] is dashboard


def test_route_returns_empty_list_when_parent_has_no_children(
    client,
    monkeypatch,
):
    parent = register_parent(
        client,
        email="dashboard.empty@gmail.com",
        phone="0557901006",
    )

    monkeypatch.setattr(
        dashboard_routes.dashboard_service,
        "get_dashboard",
        lambda user_id, role: (
            [],
            None,
        ),
    )
    monkeypatch.setattr(
        dashboard_routes.dashboard_response_schema,
        "dump",
        lambda value: [],
    )

    response = get_dashboard(
        client,
        parent["access_token"],
    )

    assert response.status_code == 200
    assert response.get_json() == []


# ===========================================================================
# Service tests
# ===========================================================================

class FakeParent:
    def __init__(self, user_id="parent-id"):
        self.id = user_id


class FakeChild:
    def __init__(
        self,
        child_id="child-id",
        name="Sara",
        age=11,
    ):
        self.id = child_id
        self.name = name
        self.age = age


class FakeAssignment:
    def __init__(self, status):
        self.status = status


def test_service_returns_parent_not_found(
    monkeypatch,
):
    service = dashboard_routes.dashboard_service

    monkeypatch.setattr(
        service.user_repository,
        "get_user_by_id",
        lambda user_id: None,
    )

    result = service.get_dashboard(
        "missing-parent",
        "parent",
    )

    assert result == (
        None,
        "parent_not_found",
    )


def test_service_does_not_query_children_when_parent_missing(
    monkeypatch,
):
    service = dashboard_routes.dashboard_service
    calls = {"children": 0}

    monkeypatch.setattr(
        service.user_repository,
        "get_user_by_id",
        lambda user_id: None,
    )

    def fake_get_children_by_guardian(parent):
        calls["children"] += 1
        return []

    monkeypatch.setattr(
        service.child_repository,
        "get_children_by_guardian",
        fake_get_children_by_guardian,
    )

    result = service.get_dashboard(
        "missing-parent",
        "parent",
    )

    assert result == (
        None,
        "parent_not_found",
    )
    assert calls["children"] == 0


def test_service_gets_children_for_parent(
    monkeypatch,
):
    service = dashboard_routes.dashboard_service
    parent = FakeParent()
    children = []
    captured = {}

    monkeypatch.setattr(
        service.user_repository,
        "get_user_by_id",
        lambda user_id: parent,
    )

    def fake_get_children_by_guardian(value):
        captured["parent"] = value
        return children

    monkeypatch.setattr(
        service.child_repository,
        "get_children_by_guardian",
        fake_get_children_by_guardian,
    )
    monkeypatch.setattr(
        service_module,
        "riyadh_today",
        lambda: date(2026, 7, 21),
    )

    dashboard, error = service.get_dashboard(
        "parent-id",
        "parent",
    )

    assert error is None
    assert dashboard == []
    assert captured["parent"] is parent


def test_service_returns_child_not_found_for_child_role(
    monkeypatch,
):
    service = dashboard_routes.dashboard_service

    monkeypatch.setattr(
        service.child_repository,
        "get_child_by_id",
        lambda child_id: None,
    )

    result = service.get_dashboard(
        "missing-child",
        "child",
    )

    assert result == (
        None,
        "child_not_found",
    )


def test_service_uses_single_child_for_child_role(
    monkeypatch,
):
    service = dashboard_routes.dashboard_service
    child = FakeChild()
    captured = {}

    monkeypatch.setattr(
        service.child_repository,
        "get_child_by_id",
        lambda child_id: child,
    )
    monkeypatch.setattr(
        service.assignment_repository,
        "get_child_assignments_between_dates",
        lambda child_id, week_start, week_end: (
            captured.setdefault(
                "call",
                (child_id, week_start, week_end),
            )
            and []
        ),
    )
    monkeypatch.setattr(
        service_module,
        "riyadh_today",
        lambda: date(2026, 7, 21),
    )

    dashboard, error = service.get_dashboard(
        "child-id",
        "child",
    )

    assert error is None
    assert len(dashboard) == 1
    assert dashboard[0]["child_id"] == "child-id"


def test_service_returns_invalid_role(
    monkeypatch,
):
    service = dashboard_routes.dashboard_service

    result = service.get_dashboard(
        "user-id",
        "admin",
    )

    assert result == (
        None,
        "invalid_role",
    )


@pytest.mark.parametrize(
    ("today", "expected_start", "expected_end"),
    [
        (
            date(2026, 7, 17),
            date(2026, 7, 17),
            date(2026, 7, 23),
        ),
        (
            date(2026, 7, 18),
            date(2026, 7, 17),
            date(2026, 7, 23),
        ),
        (
            date(2026, 7, 21),
            date(2026, 7, 17),
            date(2026, 7, 23),
        ),
        (
            date(2026, 7, 23),
            date(2026, 7, 17),
            date(2026, 7, 23),
        ),
    ],
)
def test_service_calculates_week_from_friday_to_thursday(
    monkeypatch,
    today,
    expected_start,
    expected_end,
):
    service = dashboard_routes.dashboard_service
    parent = FakeParent()
    child = FakeChild()
    captured = {}

    monkeypatch.setattr(
        service.user_repository,
        "get_user_by_id",
        lambda user_id: parent,
    )
    monkeypatch.setattr(
        service.child_repository,
        "get_children_by_guardian",
        lambda value: [child],
    )
    monkeypatch.setattr(
        service_module,
        "riyadh_today",
        lambda: today,
    )

    def fake_get_assignments(
        child_id,
        week_start,
        week_end,
    ):
        captured["child_id"] = child_id
        captured["week_start"] = week_start
        captured["week_end"] = week_end
        return []

    monkeypatch.setattr(
        service.assignment_repository,
        "get_child_assignments_between_dates",
        fake_get_assignments,
    )

    dashboard, error = service.get_dashboard(
        "parent-id",
        "parent",
    )

    assert error is None
    assert captured == {
        "child_id": "child-id",
        "week_start": expected_start,
        "week_end": expected_end,
    }
    assert dashboard[0]["week_start"] == expected_start
    assert dashboard[0]["week_end"] == expected_end


def test_service_counts_all_assignment_statuses(
    monkeypatch,
):
    service = dashboard_routes.dashboard_service
    child = FakeChild(
        child_id="child-123",
        name="Sara",
        age=11,
    )
    assignments = [
        FakeAssignment("APPROVED"),
        FakeAssignment("APPROVED"),
        FakeAssignment("PENDING_REVIEW"),
        FakeAssignment("PENDING"),
        FakeAssignment("PENDING"),
        FakeAssignment("REJECTED"),
    ]

    monkeypatch.setattr(
        service.user_repository,
        "get_user_by_id",
        lambda user_id: FakeParent(),
    )
    monkeypatch.setattr(
        service.child_repository,
        "get_children_by_guardian",
        lambda parent: [child],
    )
    monkeypatch.setattr(
        service.assignment_repository,
        "get_child_assignments_between_dates",
        lambda child_id, week_start, week_end: assignments,
    )
    monkeypatch.setattr(
        service_module,
        "riyadh_today",
        lambda: date(2026, 7, 21),
    )

    dashboard, error = service.get_dashboard(
        "parent-id",
        "parent",
    )

    assert error is None
    assert dashboard == [
        {
            "child_id": "child-123",
            "child_name": "Sara",
            "child_age": 11,
            "week_start": date(2026, 7, 17),
            "week_end": date(2026, 7, 23),
            "progress_percentage": 33.3,
            "completed_tasks": 2,
            "approved_tasks": 2,
            "pending_review_tasks": 1,
            "pending_tasks": 2,
            "rejected_tasks": 1,
            "remaining_tasks": 4,
            "total_tasks": 6,
        }
    ]


def test_service_completed_tasks_equals_approved_tasks(
    monkeypatch,
):
    service = dashboard_routes.dashboard_service
    assignments = [
        FakeAssignment("APPROVED"),
        FakeAssignment("PENDING_REVIEW"),
        FakeAssignment("REJECTED"),
    ]

    monkeypatch.setattr(
        service.user_repository,
        "get_user_by_id",
        lambda user_id: FakeParent(),
    )
    monkeypatch.setattr(
        service.child_repository,
        "get_children_by_guardian",
        lambda parent: [FakeChild()],
    )
    monkeypatch.setattr(
        service.assignment_repository,
        "get_child_assignments_between_dates",
        lambda child_id, week_start, week_end: assignments,
    )
    monkeypatch.setattr(
        service_module,
        "riyadh_today",
        lambda: date(2026, 7, 21),
    )

    dashboard, error = service.get_dashboard(
        "parent-id",
        "parent",
    )

    assert error is None
    assert dashboard[0]["approved_tasks"] == 1
    assert dashboard[0]["completed_tasks"] == 1


def test_service_remaining_tasks_are_all_non_approved_tasks(
    monkeypatch,
):
    service = dashboard_routes.dashboard_service
    assignments = [
        FakeAssignment("APPROVED"),
        FakeAssignment("PENDING"),
        FakeAssignment("PENDING_REVIEW"),
        FakeAssignment("REJECTED"),
    ]

    monkeypatch.setattr(
        service.user_repository,
        "get_user_by_id",
        lambda user_id: FakeParent(),
    )
    monkeypatch.setattr(
        service.child_repository,
        "get_children_by_guardian",
        lambda parent: [FakeChild()],
    )
    monkeypatch.setattr(
        service.assignment_repository,
        "get_child_assignments_between_dates",
        lambda child_id, week_start, week_end: assignments,
    )
    monkeypatch.setattr(
        service_module,
        "riyadh_today",
        lambda: date(2026, 7, 21),
    )

    dashboard, error = service.get_dashboard(
        "parent-id",
        "parent",
    )

    assert error is None
    assert dashboard[0]["total_tasks"] == 4
    assert dashboard[0]["approved_tasks"] == 1
    assert dashboard[0]["remaining_tasks"] == 3


def test_service_progress_is_zero_when_no_tasks(
    monkeypatch,
):
    service = dashboard_routes.dashboard_service

    monkeypatch.setattr(
        service.user_repository,
        "get_user_by_id",
        lambda user_id: FakeParent(),
    )
    monkeypatch.setattr(
        service.child_repository,
        "get_children_by_guardian",
        lambda parent: [FakeChild()],
    )
    monkeypatch.setattr(
        service.assignment_repository,
        "get_child_assignments_between_dates",
        lambda child_id, week_start, week_end: [],
    )
    monkeypatch.setattr(
        service_module,
        "riyadh_today",
        lambda: date(2026, 7, 21),
    )

    dashboard, error = service.get_dashboard(
        "parent-id",
        "parent",
    )

    assert error is None
    assert dashboard[0]["progress_percentage"] == 0
    assert dashboard[0]["total_tasks"] == 0
    assert dashboard[0]["remaining_tasks"] == 0


@pytest.mark.parametrize(
    ("statuses", "expected_progress"),
    [
        (
            ["APPROVED"],
            100.0,
        ),
        (
            ["APPROVED", "PENDING"],
            50.0,
        ),
        (
            [
                "APPROVED",
                "PENDING",
                "REJECTED",
            ],
            33.3,
        ),
        (
            [
                "APPROVED",
                "APPROVED",
                "PENDING",
            ],
            66.7,
        ),
    ],
)
def test_service_calculates_and_rounds_progress_percentage(
    monkeypatch,
    statuses,
    expected_progress,
):
    service = dashboard_routes.dashboard_service
    assignments = [
        FakeAssignment(status)
        for status in statuses
    ]

    monkeypatch.setattr(
        service.user_repository,
        "get_user_by_id",
        lambda user_id: FakeParent(),
    )
    monkeypatch.setattr(
        service.child_repository,
        "get_children_by_guardian",
        lambda parent: [FakeChild()],
    )
    monkeypatch.setattr(
        service.assignment_repository,
        "get_child_assignments_between_dates",
        lambda child_id, week_start, week_end: assignments,
    )
    monkeypatch.setattr(
        service_module,
        "riyadh_today",
        lambda: date(2026, 7, 21),
    )

    dashboard, error = service.get_dashboard(
        "parent-id",
        "parent",
    )

    assert error is None
    assert (
        dashboard[0]["progress_percentage"]
        == expected_progress
    )


def test_service_builds_dashboard_for_each_child(
    monkeypatch,
):
    service = dashboard_routes.dashboard_service
    children = [
        FakeChild(
            child_id="child-1",
            name="Sara",
            age=11,
        ),
        FakeChild(
            child_id="child-2",
            name="Omar",
            age=9,
        ),
    ]

    assignments = {
        "child-1": [
            FakeAssignment("APPROVED"),
        ],
        "child-2": [
            FakeAssignment("PENDING"),
            FakeAssignment("REJECTED"),
        ],
    }
    calls = []

    monkeypatch.setattr(
        service.user_repository,
        "get_user_by_id",
        lambda user_id: FakeParent(),
    )
    monkeypatch.setattr(
        service.child_repository,
        "get_children_by_guardian",
        lambda parent: children,
    )

    def fake_get_assignments(
        child_id,
        week_start,
        week_end,
    ):
        calls.append(child_id)
        return assignments[child_id]

    monkeypatch.setattr(
        service.assignment_repository,
        "get_child_assignments_between_dates",
        fake_get_assignments,
    )
    monkeypatch.setattr(
        service_module,
        "riyadh_today",
        lambda: date(2026, 7, 21),
    )

    dashboard, error = service.get_dashboard(
        "parent-id",
        "parent",
    )

    assert error is None
    assert calls == [
        "child-1",
        "child-2",
    ]
    assert len(dashboard) == 2

    assert dashboard[0]["child_id"] == "child-1"
    assert dashboard[0]["child_name"] == "Sara"
    assert dashboard[0]["progress_percentage"] == 100.0

    assert dashboard[1]["child_id"] == "child-2"
    assert dashboard[1]["child_name"] == "Omar"
    assert dashboard[1]["progress_percentage"] == 0.0


def test_service_converts_child_id_to_string(
    monkeypatch,
):
    service = dashboard_routes.dashboard_service

    class StringableId:
        def __str__(self):
            return "converted-child-id"

    child = FakeChild()
    child.id = StringableId()

    monkeypatch.setattr(
        service.user_repository,
        "get_user_by_id",
        lambda user_id: FakeParent(),
    )
    monkeypatch.setattr(
        service.child_repository,
        "get_children_by_guardian",
        lambda parent: [child],
    )
    monkeypatch.setattr(
        service.assignment_repository,
        "get_child_assignments_between_dates",
        lambda child_id, week_start, week_end: [],
    )
    monkeypatch.setattr(
        service_module,
        "riyadh_today",
        lambda: date(2026, 7, 21),
    )

    dashboard, error = service.get_dashboard(
        "parent-id",
        "parent",
    )

    assert error is None
    assert (
        dashboard[0]["child_id"]
        == "converted-child-id"
    )


def test_service_ignores_unknown_status_in_specific_counts(
    monkeypatch,
):
    service = dashboard_routes.dashboard_service
    assignments = [
        FakeAssignment("APPROVED"),
        FakeAssignment("UNKNOWN"),
    ]

    monkeypatch.setattr(
        service.user_repository,
        "get_user_by_id",
        lambda user_id: FakeParent(),
    )
    monkeypatch.setattr(
        service.child_repository,
        "get_children_by_guardian",
        lambda parent: [FakeChild()],
    )
    monkeypatch.setattr(
        service.assignment_repository,
        "get_child_assignments_between_dates",
        lambda child_id, week_start, week_end: assignments,
    )
    monkeypatch.setattr(
        service_module,
        "riyadh_today",
        lambda: date(2026, 7, 21),
    )

    dashboard, error = service.get_dashboard(
        "parent-id",
        "parent",
    )

    assert error is None
    assert dashboard[0]["total_tasks"] == 2
    assert dashboard[0]["approved_tasks"] == 1
    assert dashboard[0]["pending_review_tasks"] == 0
    assert dashboard[0]["pending_tasks"] == 0
    assert dashboard[0]["rejected_tasks"] == 0
    assert dashboard[0]["remaining_tasks"] == 1
    assert dashboard[0]["progress_percentage"] == 50.0