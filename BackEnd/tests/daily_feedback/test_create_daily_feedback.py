import pytest
from flask_jwt_extended import decode_token

from app.routes import daily_feedback_routes
import app.repositories.daily_feedback_repository as repository_module
import app.services.daily_feedback_service as service_module


REGISTER_URL = "/api/auth/register"
CHILDREN_URL = "/api/children/"
CHILD_LOGIN_URL = "/api/auth/child-login"
DAILY_FEEDBACK_URL = "/api/daily-feedback/"


def auth_header(token):
    return {"Authorization": token}


def register_parent(
    client,
    email="daily.feedback.parent@gmail.com",
    phone="0557940001",
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
    phone="0557940099",
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


def create_feedback_request(
    client,
    token,
    payload,
):
    return client.post(
        DAILY_FEEDBACK_URL,
        headers=auth_header(token),
        json=payload,
    )


# ===========================================================================
# Route tests
# ===========================================================================

def test_route_requires_access_token(client):
    response = client.post(
        DAILY_FEEDBACK_URL,
        json={
            "child_id": "child-id",
            "mood": "HAPPY",
        },
    )

    assert response.status_code == 401


def test_child_cannot_create_feedback(client):
    parent = register_parent(client)
    child = create_child(
        client,
        parent["access_token"],
    )
    child_login = login_child(
        client,
        child["access_code"],
    )

    response = create_feedback_request(
        client,
        child_login["access_token"],
        {
            "child_id": child["id"],
            "mood": "HAPPY",
        },
    )

    assert response.status_code == 403
    assert response.get_json() == {
        "error": "Parent access required"
    }


@pytest.mark.parametrize(
    "payload",
    [
        {},
        {"child_id": "child-id"},
        {"mood": "HAPPY"},
        {
            "child_id": "child-id",
            "mood": "INVALID_MOOD",
        },
    ],
)
def test_route_rejects_invalid_payload(
    client,
    payload,
):
    parent = register_parent(client)

    response = create_feedback_request(
        client,
        parent["access_token"],
        payload,
    )

    assert response.status_code == 400


def test_route_passes_parent_id_and_validated_data_to_service(
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

    expected_feedback_data = {
        "child_id": child["id"],
        "mood": "HAPPY",
    }
    captured = {}
    fake_feedback = object()

    def fake_schema_load(payload):
        captured["payload"] = payload
        return expected_feedback_data

    def fake_create_feedback(
        parent_id,
        feedback_data,
    ):
        captured["parent_id"] = parent_id
        captured["feedback_data"] = feedback_data
        return fake_feedback, None

    monkeypatch.setattr(
        daily_feedback_routes.daily_feedback_create_schema,
        "load",
        fake_schema_load,
    )
    monkeypatch.setattr(
        daily_feedback_routes.daily_feedback_service,
        "create_feedback",
        fake_create_feedback,
    )
    monkeypatch.setattr(
        daily_feedback_routes.daily_feedback_response_schema,
        "dump",
        lambda feedback: {"id": "feedback-id"},
    )

    response = create_feedback_request(
        client,
        parent["access_token"],
        {
            "child_id": child["id"],
            "mood": "HAPPY",
        },
    )

    assert response.status_code == 201
    assert captured["parent_id"] == expected_parent_id
    assert (
        captured["feedback_data"]
        is expected_feedback_data
    )
    assert captured["payload"] == {
        "child_id": child["id"],
        "mood": "HAPPY",
    }


def test_route_maps_child_not_found_to_404(
    client,
    monkeypatch,
):
    parent = register_parent(client)

    monkeypatch.setattr(
        daily_feedback_routes.daily_feedback_create_schema,
        "load",
        lambda payload: {
            "child_id": "missing-child",
            "mood": "HAPPY",
        },
    )
    monkeypatch.setattr(
        daily_feedback_routes.daily_feedback_service,
        "create_feedback",
        lambda parent_id, feedback_data: (
            None,
            "child_not_found",
        ),
    )

    response = create_feedback_request(
        client,
        parent["access_token"],
        {
            "child_id": "missing-child",
            "mood": "HAPPY",
        },
    )

    assert response.status_code == 404
    assert response.get_json() == {
        "error": "Child not found"
    }


def test_route_maps_duplicate_feedback_to_400(
    client,
    monkeypatch,
):
    parent = register_parent(
        client,
        email="daily.feedback.duplicate@gmail.com",
        phone="0557940002",
    )

    monkeypatch.setattr(
        daily_feedback_routes.daily_feedback_create_schema,
        "load",
        lambda payload: {
            "child_id": "child-id",
            "mood": "HAPPY",
        },
    )
    monkeypatch.setattr(
        daily_feedback_routes.daily_feedback_service,
        "create_feedback",
        lambda parent_id, feedback_data: (
            None,
            "feedback_already_exists_today",
        ),
    )

    response = create_feedback_request(
        client,
        parent["access_token"],
        {
            "child_id": "child-id",
            "mood": "HAPPY",
        },
    )

    assert response.status_code == 400
    assert response.get_json() == {
        "error": (
            "You already created feedback "
            "for this child today"
        )
    }


@pytest.mark.parametrize(
    "service_error",
    [
        "create_failed",
        "database_error",
        "unexpected_error",
    ],
)
def test_route_maps_other_service_errors_to_500(
    client,
    monkeypatch,
    service_error,
):
    parent = register_parent(
        client,
        email=(
            f"daily.feedback.{service_error}"
            "@gmail.com"
        ),
        phone="0557940003",
    )

    monkeypatch.setattr(
        daily_feedback_routes.daily_feedback_create_schema,
        "load",
        lambda payload: {
            "child_id": "child-id",
            "mood": "HAPPY",
        },
    )
    monkeypatch.setattr(
        daily_feedback_routes.daily_feedback_service,
        "create_feedback",
        lambda parent_id, feedback_data: (
            None,
            service_error,
        ),
    )

    response = create_feedback_request(
        client,
        parent["access_token"],
        {
            "child_id": "child-id",
            "mood": "HAPPY",
        },
    )

    assert response.status_code == 500
    assert response.get_json() == {
        "error": "Failed to create feedback"
    }


def test_route_does_not_serialize_when_service_fails(
    client,
    monkeypatch,
):
    parent = register_parent(
        client,
        email="daily.feedback.no.serialize@gmail.com",
        phone="0557940004",
    )
    dump_calls = {"count": 0}

    monkeypatch.setattr(
        daily_feedback_routes.daily_feedback_create_schema,
        "load",
        lambda payload: {
            "child_id": "child-id",
            "mood": "HAPPY",
        },
    )
    monkeypatch.setattr(
        daily_feedback_routes.daily_feedback_service,
        "create_feedback",
        lambda parent_id, feedback_data: (
            None,
            "create_failed",
        ),
    )

    def fake_dump(feedback):
        dump_calls["count"] += 1
        return {}

    monkeypatch.setattr(
        daily_feedback_routes.daily_feedback_response_schema,
        "dump",
        fake_dump,
    )

    response = create_feedback_request(
        client,
        parent["access_token"],
        {
            "child_id": "child-id",
            "mood": "HAPPY",
        },
    )

    assert response.status_code == 500
    assert dump_calls["count"] == 0


def test_route_serializes_created_feedback(
    client,
    monkeypatch,
):
    parent = register_parent(
        client,
        email="daily.feedback.success@gmail.com",
        phone="0557940005",
    )

    feedback = object()
    serialized_feedback = {
        "id": "feedback-id",
        "child_id": "child-id",
        "created_by": "parent-id",
        "mood": "HAPPY",
        "feedback_date": "2026-07-21",
        "created_at": "2026-07-21T12:00:00",
    }
    captured = {}

    monkeypatch.setattr(
        daily_feedback_routes.daily_feedback_create_schema,
        "load",
        lambda payload: {
            "child_id": "child-id",
            "mood": "HAPPY",
        },
    )
    monkeypatch.setattr(
        daily_feedback_routes.daily_feedback_service,
        "create_feedback",
        lambda parent_id, feedback_data: (
            feedback,
            None,
        ),
    )

    def fake_dump(value):
        captured["feedback"] = value
        return serialized_feedback

    monkeypatch.setattr(
        daily_feedback_routes.daily_feedback_response_schema,
        "dump",
        fake_dump,
    )

    response = create_feedback_request(
        client,
        parent["access_token"],
        {
            "child_id": "child-id",
            "mood": "HAPPY",
        },
    )

    assert response.status_code == 201
    assert response.get_json() == serialized_feedback
    assert captured["feedback"] is feedback


# ===========================================================================
# Service tests
# ===========================================================================

class FakeChild:
    def __init__(self, child_id="child-id"):
        self.id = child_id


class FakeFeedback:
    pass


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

    result = service.create_feedback(
        "parent-123",
        {
            "child_id": "child-123",
            "mood": "HAPPY",
        },
    )

    assert result == (
        None,
        "child_not_found",
    )
    assert captured == {
        "child_id": "child-123",
        "parent_id": "parent-123",
    }


def test_service_does_not_query_existing_feedback_when_child_missing(
    monkeypatch,
):
    service = (
        daily_feedback_routes
        .daily_feedback_service
    )
    calls = {"count": 0}

    monkeypatch.setattr(
        service.child_repository,
        "get_child_for_guardian",
        lambda child_id, parent_id: None,
    )

    def fake_get_existing(
        child_id,
        parent_id,
    ):
        calls["count"] += 1
        return None

    monkeypatch.setattr(
        service.daily_feedback_repository,
        "get_feedback_for_child_today_by_parent",
        fake_get_existing,
    )

    result = service.create_feedback(
        "parent-id",
        {
            "child_id": "child-id",
            "mood": "HAPPY",
        },
    )

    assert result == (
        None,
        "child_not_found",
    )
    assert calls["count"] == 0


def test_service_returns_duplicate_when_feedback_exists(
    monkeypatch,
):
    service = (
        daily_feedback_routes
        .daily_feedback_service
    )
    child = FakeChild("child-123")
    existing_feedback = FakeFeedback()

    monkeypatch.setattr(
        service.child_repository,
        "get_child_for_guardian",
        lambda child_id, parent_id: child,
    )
    monkeypatch.setattr(
        service.daily_feedback_repository,
        "get_feedback_for_child_today_by_parent",
        lambda child_id, parent_id: (
            existing_feedback
        ),
    )

    result = service.create_feedback(
        "parent-123",
        {
            "child_id": "child-123",
            "mood": "HAPPY",
        },
    )

    assert result == (
        None,
        "feedback_already_exists_today",
    )


def test_service_does_not_create_when_feedback_exists(
    monkeypatch,
):
    service = (
        daily_feedback_routes
        .daily_feedback_service
    )
    child = FakeChild("child-123")
    create_calls = {"count": 0}

    monkeypatch.setattr(
        service.child_repository,
        "get_child_for_guardian",
        lambda child_id, parent_id: child,
    )
    monkeypatch.setattr(
        service.daily_feedback_repository,
        "get_feedback_for_child_today_by_parent",
        lambda child_id, parent_id: FakeFeedback(),
    )

    def fake_create_feedback(feedback):
        create_calls["count"] += 1
        return feedback, None

    monkeypatch.setattr(
        service.daily_feedback_repository,
        "create_feedback",
        fake_create_feedback,
    )

    result = service.create_feedback(
        "parent-123",
        {
            "child_id": "child-123",
            "mood": "HAPPY",
        },
    )

    assert result == (
        None,
        "feedback_already_exists_today",
    )
    assert create_calls["count"] == 0


def test_service_builds_feedback_with_expected_fields(
    monkeypatch,
):
    service = (
        daily_feedback_routes
        .daily_feedback_service
    )
    child = FakeChild("child-123")
    expected_date = object()
    captured = {}

    monkeypatch.setattr(
        service.child_repository,
        "get_child_for_guardian",
        lambda child_id, parent_id: child,
    )
    monkeypatch.setattr(
        service.daily_feedback_repository,
        "get_feedback_for_child_today_by_parent",
        lambda child_id, parent_id: None,
    )
    monkeypatch.setattr(
        service_module,
        "riyadh_today",
        lambda: expected_date,
    )

    class FakeDailyFeedback:
        def __init__(self, **kwargs):
            captured.update(kwargs)

    monkeypatch.setattr(
        service_module,
        "DailyFeedback",
        FakeDailyFeedback,
    )
    monkeypatch.setattr(
        service.daily_feedback_repository,
        "create_feedback",
        lambda feedback: (
            feedback,
            None,
        ),
    )

    feedback, error = service.create_feedback(
        "parent-123",
        {
            "child_id": "child-123",
            "mood": "HAPPY",
        },
    )

    assert error is None
    assert isinstance(
        feedback,
        FakeDailyFeedback,
    )
    assert captured == {
        "child_id": "child-123",
        "created_by": "parent-123",
        "mood": "HAPPY",
        "feedback_date": expected_date,
    }


def test_service_maps_repository_error_to_create_failed(
    monkeypatch,
):
    service = (
        daily_feedback_routes
        .daily_feedback_service
    )
    child = FakeChild("child-123")

    monkeypatch.setattr(
        service.child_repository,
        "get_child_for_guardian",
        lambda child_id, parent_id: child,
    )
    monkeypatch.setattr(
        service.daily_feedback_repository,
        "get_feedback_for_child_today_by_parent",
        lambda child_id, parent_id: None,
    )
    monkeypatch.setattr(
        service.daily_feedback_repository,
        "create_feedback",
        lambda feedback: (
            None,
            "integrity_error",
        ),
    )

    result = service.create_feedback(
        "parent-123",
        {
            "child_id": "child-123",
            "mood": "HAPPY",
        },
    )

    assert result == (
        None,
        "create_failed",
    )


def test_service_returns_created_feedback(
    monkeypatch,
):
    service = (
        daily_feedback_routes
        .daily_feedback_service
    )
    child = FakeChild("child-123")
    created_feedback = FakeFeedback()

    monkeypatch.setattr(
        service.child_repository,
        "get_child_for_guardian",
        lambda child_id, parent_id: child,
    )
    monkeypatch.setattr(
        service.daily_feedback_repository,
        "get_feedback_for_child_today_by_parent",
        lambda child_id, parent_id: None,
    )
    monkeypatch.setattr(
        service.daily_feedback_repository,
        "create_feedback",
        lambda feedback: (
            created_feedback,
            None,
        ),
    )

    feedback, error = service.create_feedback(
        "parent-123",
        {
            "child_id": "child-123",
            "mood": "HAPPY",
        },
    )

    assert error is None
    assert feedback is created_feedback


# ===========================================================================
# Repository tests
#
# These tests assume the repository implements:
#   create_feedback(feedback)
# using db.session.add() and db.session.commit().
# ===========================================================================

class FakeSession:
    def __init__(self):
        self.added = None
        self.commit_called = False
        self.rollback_called = False
        self.error = None

    def add(self, value):
        self.added = value

    def commit(self):
        self.commit_called = True
        if self.error:
            raise self.error

    def rollback(self):
        self.rollback_called = True


def test_repository_create_feedback_adds_and_commits(
    monkeypatch,
):
    repository = (
        daily_feedback_routes
        .daily_feedback_service
        .daily_feedback_repository
    )
    session = FakeSession()
    feedback = FakeFeedback()

    monkeypatch.setattr(
        repository_module.db,
        "session",
        session,
    )

    created_feedback, error = (
        repository.create_feedback(feedback)
    )

    assert error is None
    assert created_feedback is feedback
    assert session.added is feedback
    assert session.commit_called is True
    assert session.rollback_called is False


def test_repository_create_feedback_propagates_exception(
    monkeypatch,
):
    repository = (
        daily_feedback_routes
        .daily_feedback_service
        .daily_feedback_repository
    )
    session = FakeSession()
    session.error = Exception("database failure")
    feedback = FakeFeedback()

    monkeypatch.setattr(
        repository_module.db,
        "session",
        session,
    )

    with pytest.raises(
        Exception,
        match="database failure",
    ):
        repository.create_feedback(feedback)

    assert session.added is feedback
    assert session.commit_called is True
    assert session.rollback_called is False