import pytest
from flask_jwt_extended import decode_token

from app.routes import daily_feedback_routes
import app.repositories.daily_feedback_repository as repository_module


REGISTER_URL = "/api/auth/register"
CHILDREN_URL = "/api/children/"
CHILD_LOGIN_URL = "/api/auth/child-login"
MY_FEEDBACK_URL = "/api/daily-feedback/my"


def auth_header(token):
    return {"Authorization": token}


def register_parent(
    client,
    email="my.daily.feedback.parent@gmail.com",
    phone="0557960001",
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
    phone="0557960099",
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


def get_my_feedback(client, token):
    return client.get(
        MY_FEEDBACK_URL,
        headers=auth_header(token),
    )


# ===========================================================================
# Route tests
# ===========================================================================

def test_route_requires_access_token(client):
    response = client.get(MY_FEEDBACK_URL)

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
        MY_FEEDBACK_URL,
        headers=auth_header(token),
    )

    assert response.status_code in (401, 422)


def test_parent_cannot_get_my_feedback(client):
    parent = register_parent(client)

    response = get_my_feedback(
        client,
        parent["access_token"],
    )

    assert response.status_code == 403
    assert response.get_json() == {
        "error": "Child access required"
    }


def test_route_passes_authenticated_child_id_to_service(
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

    feedback = []
    captured = {}

    def fake_get_my_feedback(child_id):
        captured["child_id"] = child_id
        return feedback, None

    monkeypatch.setattr(
        daily_feedback_routes.daily_feedback_service,
        "get_my_feedback",
        fake_get_my_feedback,
    )
    monkeypatch.setattr(
        daily_feedback_routes.daily_feedback_list_schema,
        "dump",
        lambda value: [],
    )

    response = get_my_feedback(
        client,
        child_login["access_token"],
    )

    assert response.status_code == 200
    assert captured["child_id"] == expected_child_id


def test_route_maps_child_not_found_to_404(
    client,
    monkeypatch,
):
    parent = register_parent(
        client,
        email="my.daily.feedback.missing@gmail.com",
        phone="0557960002",
    )
    child = create_child(
        client,
        parent["access_token"],
        phone="0557960098",
    )
    child_login = login_child(
        client,
        child["access_code"],
    )

    monkeypatch.setattr(
        daily_feedback_routes.daily_feedback_service,
        "get_my_feedback",
        lambda child_id: (
            None,
            "child_not_found",
        ),
    )

    response = get_my_feedback(
        client,
        child_login["access_token"],
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
            f"my.daily.feedback.{service_error}"
            "@gmail.com"
        ),
        phone="0557960003",
    )
    child = create_child(
        client,
        parent["access_token"],
        phone="0557960097",
    )
    child_login = login_child(
        client,
        child["access_code"],
    )

    monkeypatch.setattr(
        daily_feedback_routes.daily_feedback_service,
        "get_my_feedback",
        lambda child_id: (
            None,
            service_error,
        ),
    )

    response = get_my_feedback(
        client,
        child_login["access_token"],
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
        email="my.daily.feedback.no.serialize@gmail.com",
        phone="0557960004",
    )
    child = create_child(
        client,
        parent["access_token"],
        phone="0557960096",
    )
    child_login = login_child(
        client,
        child["access_code"],
    )
    dump_calls = {"count": 0}

    monkeypatch.setattr(
        daily_feedback_routes.daily_feedback_service,
        "get_my_feedback",
        lambda child_id: (
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

    response = get_my_feedback(
        client,
        child_login["access_token"],
    )

    assert response.status_code == 500
    assert dump_calls["count"] == 0


def test_route_serializes_feedback_list(
    client,
    monkeypatch,
):
    parent = register_parent(
        client,
        email="my.daily.feedback.success@gmail.com",
        phone="0557960005",
    )
    child = create_child(
        client,
        parent["access_token"],
        phone="0557960095",
    )
    child_login = login_child(
        client,
        child["access_code"],
    )

    feedback = [object(), object()]
    serialized_feedback = [
        {
            "id": "feedback-1",
            "child_id": child["id"],
            "created_by": "parent-id",
            "mood": "HAPPY",
            "feedback_date": "2026-07-21",
            "created_at": "2026-07-21T10:00:00",
        },
        {
            "id": "feedback-2",
            "child_id": child["id"],
            "created_by": "parent-id",
            "mood": "NEUTRAL",
            "feedback_date": "2026-07-20",
            "created_at": "2026-07-20T10:00:00",
        },
    ]
    captured = {}

    monkeypatch.setattr(
        daily_feedback_routes.daily_feedback_service,
        "get_my_feedback",
        lambda child_id: (
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

    response = get_my_feedback(
        client,
        child_login["access_token"],
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
        email="my.daily.feedback.empty@gmail.com",
        phone="0557960006",
    )
    child = create_child(
        client,
        parent["access_token"],
        phone="0557960094",
    )
    child_login = login_child(
        client,
        child["access_code"],
    )

    monkeypatch.setattr(
        daily_feedback_routes.daily_feedback_service,
        "get_my_feedback",
        lambda child_id: (
            [],
            None,
        ),
    )
    monkeypatch.setattr(
        daily_feedback_routes.daily_feedback_list_schema,
        "dump",
        lambda feedback: [],
    )

    response = get_my_feedback(
        client,
        child_login["access_token"],
    )

    assert response.status_code == 200
    assert response.get_json() == []


# ===========================================================================
# Service tests
# ===========================================================================

class FakeChild:
    def __init__(self, child_id="child-id"):
        self.id = child_id


def test_service_queries_child_by_id(
    monkeypatch,
):
    service = (
        daily_feedback_routes
        .daily_feedback_service
    )
    captured = {}

    def fake_get_child_by_id(child_id):
        captured["child_id"] = child_id
        return None

    monkeypatch.setattr(
        service.child_repository,
        "get_child_by_id",
        fake_get_child_by_id,
    )

    result = service.get_my_feedback(
        "child-123"
    )

    assert result == (
        None,
        "child_not_found",
    )
    assert captured["child_id"] == "child-123"


def test_service_returns_child_not_found(
    monkeypatch,
):
    service = (
        daily_feedback_routes
        .daily_feedback_service
    )

    monkeypatch.setattr(
        service.child_repository,
        "get_child_by_id",
        lambda child_id: None,
    )

    result = service.get_my_feedback(
        "missing-child"
    )

    assert result == (
        None,
        "child_not_found",
    )


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
        "get_child_by_id",
        lambda child_id: None,
    )

    def fake_get_feedback_by_child_id(child_id):
        repository_calls["count"] += 1
        return []

    monkeypatch.setattr(
        service.daily_feedback_repository,
        "get_feedback_by_child_id",
        fake_get_feedback_by_child_id,
    )

    result = service.get_my_feedback(
        "missing-child"
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
    feedback = [object()]
    captured = {}

    monkeypatch.setattr(
        service.child_repository,
        "get_child_by_id",
        lambda child_id: FakeChild(child_id),
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
        service.get_my_feedback(
            "child-123"
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
        "get_child_by_id",
        lambda child_id: FakeChild(child_id),
    )
    monkeypatch.setattr(
        service.daily_feedback_repository,
        "get_feedback_by_child_id",
        lambda child_id: [],
    )

    feedback, error = (
        service.get_my_feedback(
            "child-123"
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