import pytest
from flask_jwt_extended import decode_token

from app.routes import daily_feedback_routes
import app.repositories.daily_feedback_repository as repository_module


REGISTER_URL = "/api/auth/register"
CHILDREN_URL = "/api/children/"
CHILD_LOGIN_URL = "/api/auth/child-login"
FEEDBACK_URL = "/api/daily-feedback/child/{child_id}"


def auth_header(token):
    return {"Authorization": token}


def register_parent(
    client,
    email="daily.feedback.list.parent@gmail.com",
    phone="0557950001",
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
    phone="0557950099",
):
    response = client.post(
        CHILDREN_URL,
        headers=auth_header(parent_token),
        json={
            "name": "Sara",
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


def get_child_feedback(
    client,
    token,
    child_id,
):
    return client.get(
        FEEDBACK_URL.format(child_id=child_id),
        headers=auth_header(token),
    )


# ===========================================================================
# Route tests
# ===========================================================================

def test_route_requires_access_token(client):
    response = client.get(
        FEEDBACK_URL.format(child_id="child-id")
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
def test_route_rejects_invalid_access_token(
    client,
    token,
):
    response = client.get(
        FEEDBACK_URL.format(child_id="child-id"),
        headers=auth_header(token),
    )

    assert response.status_code in (401, 422)


def test_child_cannot_get_feedback(client):
    parent = register_parent(client)
    child = create_child(
        client,
        parent["access_token"],
    )
    child_login = login_child(
        client,
        child["access_code"],
    )

    response = get_child_feedback(
        client,
        child_login["access_token"],
        child["id"],
    )

    assert response.status_code == 403
    assert response.get_json() == {
        "error": "Parent access required"
    }


def test_route_passes_child_id_and_parent_id_to_service(
    client,
    app,
    monkeypatch,
):
    parent = register_parent(client)
    child = create_child(
        client,
        parent["access_token"],
    )

    with app.app_context():
        expected_parent_id = decode_token(
            parent["access_token"]
        )["sub"]

    feedback = []
    captured = {}

    def fake_get_feedback_for_child_as_parent(
        child_id,
        parent_id,
    ):
        captured["child_id"] = child_id
        captured["parent_id"] = parent_id
        return feedback, None

    monkeypatch.setattr(
        daily_feedback_routes.daily_feedback_service,
        "get_feedback_for_child_as_parent",
        fake_get_feedback_for_child_as_parent,
    )
    monkeypatch.setattr(
        daily_feedback_routes.daily_feedback_list_schema,
        "dump",
        lambda value: [],
    )

    response = get_child_feedback(
        client,
        parent["access_token"],
        child["id"],
    )

    assert response.status_code == 200
    assert captured == {
        "child_id": child["id"],
        "parent_id": expected_parent_id,
    }


def test_route_maps_child_not_found_to_404(
    client,
    monkeypatch,
):
    parent = register_parent(
        client,
        email="daily.feedback.list.missing@gmail.com",
        phone="0557950002",
    )

    monkeypatch.setattr(
        daily_feedback_routes.daily_feedback_service,
        "get_feedback_for_child_as_parent",
        lambda child_id, parent_id: (
            None,
            "child_not_found",
        ),
    )

    response = get_child_feedback(
        client,
        parent["access_token"],
        "missing-child",
    )

    assert response.status_code == 404
    assert response.get_json() == {
        "error": "Child not found"
    }


@pytest.mark.parametrize(
    "service_error",
    [
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
        email=(
            f"daily.feedback.list.{service_error}"
            "@gmail.com"
        ),
        phone="0557950003",
    )

    monkeypatch.setattr(
        daily_feedback_routes.daily_feedback_service,
        "get_feedback_for_child_as_parent",
        lambda child_id, parent_id: (
            None,
            service_error,
        ),
    )

    response = get_child_feedback(
        client,
        parent["access_token"],
        "child-id",
    )

    assert response.status_code == 500
    assert response.get_json() == {
        "error": "Failed to retrieve feedback"
    }


def test_route_does_not_serialize_when_service_fails(
    client,
    monkeypatch,
):
    parent = register_parent(
        client,
        email="daily.feedback.list.no.serialize@gmail.com",
        phone="0557950004",
    )
    dump_calls = {"count": 0}

    monkeypatch.setattr(
        daily_feedback_routes.daily_feedback_service,
        "get_feedback_for_child_as_parent",
        lambda child_id, parent_id: (
            None,
            "repository_error",
        ),
    )

    def fake_dump(feedback):
        dump_calls["count"] += 1
        return []

    monkeypatch.setattr(
        daily_feedback_routes.daily_feedback_list_schema,
        "dump",
        fake_dump,
    )

    response = get_child_feedback(
        client,
        parent["access_token"],
        "child-id",
    )

    assert response.status_code == 500
    assert dump_calls["count"] == 0


def test_route_serializes_feedback_list(
    client,
    monkeypatch,
):
    parent = register_parent(
        client,
        email="daily.feedback.list.success@gmail.com",
        phone="0557950005",
    )

    feedback = [object(), object()]
    serialized_feedback = [
        {
            "id": "feedback-1",
            "child_id": "child-id",
            "created_by": "parent-id",
            "mood": "HAPPY",
            "feedback_date": "2026-07-21",
            "created_at": "2026-07-21T10:00:00",
        },
        {
            "id": "feedback-2",
            "child_id": "child-id",
            "created_by": "parent-id",
            "mood": "NEUTRAL",
            "feedback_date": "2026-07-20",
            "created_at": "2026-07-20T10:00:00",
        },
    ]
    captured = {}

    monkeypatch.setattr(
        daily_feedback_routes.daily_feedback_service,
        "get_feedback_for_child_as_parent",
        lambda child_id, parent_id: (
            feedback,
            None,
        ),
    )

    def fake_dump(value):
        captured["feedback"] = value
        return serialized_feedback

    monkeypatch.setattr(
        daily_feedback_routes.daily_feedback_list_schema,
        "dump",
        fake_dump,
    )

    response = get_child_feedback(
        client,
        parent["access_token"],
        "child-id",
    )

    assert response.status_code == 200
    assert response.get_json() == serialized_feedback
    assert captured["feedback"] is feedback


def test_route_returns_empty_list_when_no_feedback(
    client,
    monkeypatch,
):
    parent = register_parent(
        client,
        email="daily.feedback.list.empty@gmail.com",
        phone="0557950006",
    )

    monkeypatch.setattr(
        daily_feedback_routes.daily_feedback_service,
        "get_feedback_for_child_as_parent",
        lambda child_id, parent_id: (
            [],
            None,
        ),
    )
    monkeypatch.setattr(
        daily_feedback_routes.daily_feedback_list_schema,
        "dump",
        lambda feedback: [],
    )

    response = get_child_feedback(
        client,
        parent["access_token"],
        "child-id",
    )

    assert response.status_code == 200
    assert response.get_json() == []


# ===========================================================================
# Service tests
# ===========================================================================

class FakeChild:
    def __init__(self, child_id="child-id"):
        self.id = child_id


def test_service_checks_guardian_access(
    monkeypatch,
):
    service = (
        daily_feedback_routes
        .daily_feedback_service
    )
    captured = {}

    def fake_get_child_for_guardian(
        child_id,
        parent_id,
    ):
        captured["child_id"] = child_id
        captured["parent_id"] = parent_id
        return None

    monkeypatch.setattr(
        service.child_repository,
        "get_child_for_guardian",
        fake_get_child_for_guardian,
    )

    result = (
        service
        .get_feedback_for_child_as_parent(
            "child-123",
            "parent-123",
        )
    )

    assert result == (
        None,
        "child_not_found",
    )
    assert captured == {
        "child_id": "child-123",
        "parent_id": "parent-123",
    }


def test_service_does_not_query_feedback_when_child_missing(
    monkeypatch,
):
    service = (
        daily_feedback_routes
        .daily_feedback_service
    )
    repository_calls = {"count": 0}

    monkeypatch.setattr(
        service.child_repository,
        "get_child_for_guardian",
        lambda child_id, parent_id: None,
    )

    def fake_get_feedback_by_child_id(child_id):
        repository_calls["count"] += 1
        return []

    monkeypatch.setattr(
        service.daily_feedback_repository,
        "get_feedback_by_child_id",
        fake_get_feedback_by_child_id,
    )

    result = (
        service
        .get_feedback_for_child_as_parent(
            "missing-child",
            "parent-123",
        )
    )

    assert result == (
        None,
        "child_not_found",
    )
    assert repository_calls["count"] == 0


def test_service_passes_child_id_to_repository(
    monkeypatch,
):
    service = (
        daily_feedback_routes
        .daily_feedback_service
    )
    child = FakeChild("child-123")
    feedback = [object()]
    captured = {}

    monkeypatch.setattr(
        service.child_repository,
        "get_child_for_guardian",
        lambda child_id, parent_id: child,
    )

    def fake_get_feedback_by_child_id(child_id):
        captured["child_id"] = child_id
        return feedback

    monkeypatch.setattr(
        service.daily_feedback_repository,
        "get_feedback_by_child_id",
        fake_get_feedback_by_child_id,
    )

    returned_feedback, error = (
        service
        .get_feedback_for_child_as_parent(
            "child-123",
            "parent-123",
        )
    )

    assert error is None
    assert returned_feedback is feedback
    assert captured["child_id"] == "child-123"


def test_service_returns_empty_feedback_list(
    monkeypatch,
):
    service = (
        daily_feedback_routes
        .daily_feedback_service
    )

    monkeypatch.setattr(
        service.child_repository,
        "get_child_for_guardian",
        lambda child_id, parent_id: (
            FakeChild(child_id)
        ),
    )
    monkeypatch.setattr(
        service.daily_feedback_repository,
        "get_feedback_by_child_id",
        lambda child_id: [],
    )

    feedback, error = (
        service
        .get_feedback_for_child_as_parent(
            "child-123",
            "parent-123",
        )
    )

    assert error is None
    assert feedback == []


# ===========================================================================
# Repository tests
# ===========================================================================

class FakeQuery:
    def __init__(self, results):
        self.results = results
        self.filtered_child_id = None
        self.order_argument = None
        self.filter_called = 0
        self.order_called = 0
        self.all_called = 0

    def filter_by(self, **kwargs):
        self.filter_called += 1
        self.filtered_child_id = kwargs["child_id"]
        return self

    def order_by(self, argument):
        self.order_called += 1
        self.order_argument = argument
        return self

    def all(self):
        self.all_called += 1
        return self.results


class FakeCreatedAt:
    descending_expression = object()

    @classmethod
    def desc(cls):
        return cls.descending_expression


def test_repository_filters_orders_and_returns_all(
    app,
    monkeypatch,
):
    repository = (
        daily_feedback_routes
        .daily_feedback_service
        .daily_feedback_repository
    )
    expected_feedback = [
        object(),
        object(),
    ]
    fake_query = FakeQuery(expected_feedback)

    with app.app_context():
        monkeypatch.setattr(
            repository_module.DailyFeedback,
            "query",
            fake_query,
        )
        monkeypatch.setattr(
            repository_module.DailyFeedback,
            "created_at",
            FakeCreatedAt,
        )

        result = (
            repository
            .get_feedback_by_child_id(
                "child-123"
            )
        )

    assert result is expected_feedback
    assert fake_query.filter_called == 1
    assert (
        fake_query.filtered_child_id
        == "child-123"
    )
    assert fake_query.order_called == 1
    assert (
        fake_query.order_argument
        is FakeCreatedAt.descending_expression
    )
    assert fake_query.all_called == 1