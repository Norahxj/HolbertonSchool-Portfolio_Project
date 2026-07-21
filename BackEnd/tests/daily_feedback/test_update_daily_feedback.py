import pytest
from flask_jwt_extended import decode_token

from app.routes import daily_feedback_routes


REGISTER_URL = "/api/auth/register"
CHILDREN_URL = "/api/children/"
CHILD_LOGIN_URL = "/api/auth/child-login"
UPDATE_FEEDBACK_URL = "/api/daily-feedback/{feedback_id}"


def auth_header(token):
    return {"Authorization": token}


def register_parent(
    client,
    email="update.daily.feedback.parent@gmail.com",
    phone="0557970001",
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
    phone="0557970099",
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


def update_feedback_request(
    client,
    token,
    feedback_id,
    payload,
):
    return client.put(
        UPDATE_FEEDBACK_URL.format(
            feedback_id=feedback_id
        ),
        headers=auth_header(token),
        json=payload,
    )


# ===========================================================================
# Route tests
# ===========================================================================

def test_route_requires_access_token(client):
    response = client.put(
        UPDATE_FEEDBACK_URL.format(
            feedback_id="feedback-id"
        ),
        json={"mood": "HAPPY"},
    )

    assert response.status_code == 401


def test_child_cannot_update_feedback(client):
    parent = register_parent(client)
    child = create_child(
        client,
        parent["access_token"],
    )
    child_login = login_child(
        client,
        child["access_code"],
    )

    response = update_feedback_request(
        client,
        child_login["access_token"],
        "feedback-id",
        {"mood": "HAPPY"},
    )

    assert response.status_code == 403
    assert response.get_json() == {
        "error": "Parent access required"
    }


@pytest.mark.parametrize(
    "payload",
    [
        {},
        {"mood": "SAD"},
        {"mood": ""},
        {"mood": None},
    ],
)
def test_route_rejects_invalid_payload(
    client,
    payload,
):
    parent = register_parent(client)

    response = update_feedback_request(
        client,
        parent["access_token"],
        "feedback-id",
        payload,
    )

    assert response.status_code == 400


@pytest.mark.parametrize(
    "mood",
    [
        "HAPPY",
        "PROUD",
        "GREAT",
        "LOVE",
        "STRONG",
        "STAR",
    ],
)
def test_route_accepts_all_valid_mood_values(
    client,
    monkeypatch,
    mood,
):
    parent = register_parent(client)
    feedback = object()

    monkeypatch.setattr(
        daily_feedback_routes.daily_feedback_service,
        "update_feedback",
        lambda feedback_id, parent_id, feedback_data: (
            feedback,
            None,
        ),
    )
    monkeypatch.setattr(
        daily_feedback_routes.daily_feedback_response_schema,
        "dump",
        lambda value: {
            "id": "feedback-id",
            "mood": mood,
        },
    )

    response = update_feedback_request(
        client,
        parent["access_token"],
        "feedback-id",
        {"mood": mood},
    )

    assert response.status_code == 200
    assert response.get_json()["mood"] == mood


def test_route_passes_ids_and_validated_data_to_service(
    client,
    app,
    monkeypatch,
):
    parent = register_parent(client)

    with app.app_context():
        expected_parent_id = decode_token(
            parent["access_token"]
        )["sub"]

    expected_data = {"mood": "PROUD"}
    feedback = object()
    captured = {}

    def fake_load(payload):
        captured["payload"] = payload
        return expected_data

    def fake_update_feedback(
        feedback_id,
        parent_id,
        feedback_data,
    ):
        captured["feedback_id"] = feedback_id
        captured["parent_id"] = parent_id
        captured["feedback_data"] = feedback_data
        return feedback, None

    monkeypatch.setattr(
        daily_feedback_routes.daily_feedback_update_schema,
        "load",
        fake_load,
    )
    monkeypatch.setattr(
        daily_feedback_routes.daily_feedback_service,
        "update_feedback",
        fake_update_feedback,
    )
    monkeypatch.setattr(
        daily_feedback_routes.daily_feedback_response_schema,
        "dump",
        lambda value: {
            "id": "feedback-123",
            "mood": "PROUD",
        },
    )

    response = update_feedback_request(
        client,
        parent["access_token"],
        "feedback-123",
        {"mood": "PROUD"},
    )

    assert response.status_code == 200
    assert captured["feedback_id"] == "feedback-123"
    assert captured["parent_id"] == expected_parent_id
    assert captured["feedback_data"] is expected_data
    assert captured["payload"] == {
        "mood": "PROUD"
    }


def test_route_maps_feedback_not_found_to_404(
    client,
    monkeypatch,
):
    parent = register_parent(
        client,
        email="update.daily.feedback.missing@gmail.com",
        phone="0557970002",
    )

    monkeypatch.setattr(
        daily_feedback_routes.daily_feedback_service,
        "update_feedback",
        lambda feedback_id, parent_id, feedback_data: (
            None,
            "feedback_not_found",
        ),
    )

    response = update_feedback_request(
        client,
        parent["access_token"],
        "missing-feedback",
        {"mood": "HAPPY"},
    )

    assert response.status_code == 404
    assert response.get_json() == {
        "error": "Feedback not found"
    }


def test_route_maps_no_data_provided_to_400(
    client,
    monkeypatch,
):
    parent = register_parent(
        client,
        email="update.daily.feedback.no.data@gmail.com",
        phone="0557970003",
    )

    monkeypatch.setattr(
        daily_feedback_routes.daily_feedback_update_schema,
        "load",
        lambda payload: {},
    )
    monkeypatch.setattr(
        daily_feedback_routes.daily_feedback_service,
        "update_feedback",
        lambda feedback_id, parent_id, feedback_data: (
            None,
            "no_data_provided",
        ),
    )

    response = update_feedback_request(
        client,
        parent["access_token"],
        "feedback-id",
        {"mood": "HAPPY"},
    )

    assert response.status_code == 400
    assert response.get_json() == {
        "error": "No fields provided for update"
    }


@pytest.mark.parametrize(
    "service_error",
    [
        "update_failed",
        "database_error",
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
            f"update.daily.feedback.{service_error}"
            "@gmail.com"
        ),
        phone="0557970004",
    )

    monkeypatch.setattr(
        daily_feedback_routes.daily_feedback_service,
        "update_feedback",
        lambda feedback_id, parent_id, feedback_data: (
            None,
            service_error,
        ),
    )

    response = update_feedback_request(
        client,
        parent["access_token"],
        "feedback-id",
        {"mood": "HAPPY"},
    )

    assert response.status_code == 500
    assert response.get_json() == {
        "error": "Failed to update feedback"
    }


def test_route_does_not_serialize_when_service_fails(
    client,
    monkeypatch,
):
    parent = register_parent(
        client,
        email="update.daily.feedback.no.serialize@gmail.com",
        phone="0557970005",
    )
    dump_calls = {"count": 0}

    monkeypatch.setattr(
        daily_feedback_routes.daily_feedback_service,
        "update_feedback",
        lambda feedback_id, parent_id, feedback_data: (
            None,
            "update_failed",
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

    response = update_feedback_request(
        client,
        parent["access_token"],
        "feedback-id",
        {"mood": "HAPPY"},
    )

    assert response.status_code == 500
    assert dump_calls["count"] == 0


def test_route_serializes_updated_feedback(
    client,
    monkeypatch,
):
    parent = register_parent(
        client,
        email="update.daily.feedback.success@gmail.com",
        phone="0557970006",
    )

    feedback = object()
    serialized_feedback = {
        "id": "feedback-123",
        "child_id": "child-123",
        "created_by": "parent-123",
        "mood": "STAR",
        "feedback_date": "2026-07-21",
        "created_at": "2026-07-21T10:00:00",
    }
    captured = {}

    monkeypatch.setattr(
        daily_feedback_routes.daily_feedback_service,
        "update_feedback",
        lambda feedback_id, parent_id, feedback_data: (
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

    response = update_feedback_request(
        client,
        parent["access_token"],
        "feedback-123",
        {"mood": "STAR"},
    )

    assert response.status_code == 200
    assert response.get_json() == serialized_feedback
    assert captured["feedback"] is feedback


# ===========================================================================
# Service tests
# ===========================================================================

class FakeFeedback:
    def __init__(self, mood="HAPPY"):
        self.mood = mood


def test_service_gets_feedback_for_creator(
    monkeypatch,
):
    service = (
        daily_feedback_routes
        .daily_feedback_service
    )
    captured = {}

    def fake_get_feedback_for_creator(
        feedback_id,
        parent_id,
    ):
        captured["feedback_id"] = feedback_id
        captured["parent_id"] = parent_id
        return None

    monkeypatch.setattr(
        service.daily_feedback_repository,
        "get_feedback_for_creator",
        fake_get_feedback_for_creator,
    )

    result = service.update_feedback(
        "feedback-123",
        "parent-123",
        {"mood": "HAPPY"},
    )

    assert result == (
        None,
        "feedback_not_found",
    )
    assert captured == {
        "feedback_id": "feedback-123",
        "parent_id": "parent-123",
    }


def test_service_returns_feedback_not_found(
    monkeypatch,
):
    service = (
        daily_feedback_routes
        .daily_feedback_service
    )

    monkeypatch.setattr(
        service.daily_feedback_repository,
        "get_feedback_for_creator",
        lambda feedback_id, parent_id: None,
    )

    result = service.update_feedback(
        "missing-feedback",
        "parent-123",
        {"mood": "HAPPY"},
    )

    assert result == (
        None,
        "feedback_not_found",
    )


def test_service_does_not_update_when_feedback_missing(
    monkeypatch,
):
    service = (
        daily_feedback_routes
        .daily_feedback_service
    )
    update_calls = {"count": 0}

    monkeypatch.setattr(
        service.daily_feedback_repository,
        "get_feedback_for_creator",
        lambda feedback_id, parent_id: None,
    )

    def fake_update_feedback():
        update_calls["count"] += 1
        return True, None

    monkeypatch.setattr(
        service.daily_feedback_repository,
        "update_feedback",
        fake_update_feedback,
    )

    result = service.update_feedback(
        "missing-feedback",
        "parent-123",
        {"mood": "HAPPY"},
    )

    assert result == (
        None,
        "feedback_not_found",
    )
    assert update_calls["count"] == 0


def test_service_returns_no_data_provided(
    monkeypatch,
):
    service = (
        daily_feedback_routes
        .daily_feedback_service
    )
    feedback = FakeFeedback()

    monkeypatch.setattr(
        service.daily_feedback_repository,
        "get_feedback_for_creator",
        lambda feedback_id, parent_id: feedback,
    )

    result = service.update_feedback(
        "feedback-123",
        "parent-123",
        {},
    )

    assert result == (
        None,
        "no_data_provided",
    )


def test_service_does_not_update_repository_when_mood_missing(
    monkeypatch,
):
    service = (
        daily_feedback_routes
        .daily_feedback_service
    )
    feedback = FakeFeedback()
    update_calls = {"count": 0}

    monkeypatch.setattr(
        service.daily_feedback_repository,
        "get_feedback_for_creator",
        lambda feedback_id, parent_id: feedback,
    )

    def fake_update_feedback():
        update_calls["count"] += 1
        return True, None

    monkeypatch.setattr(
        service.daily_feedback_repository,
        "update_feedback",
        fake_update_feedback,
    )

    result = service.update_feedback(
        "feedback-123",
        "parent-123",
        {},
    )

    assert result == (
        None,
        "no_data_provided",
    )
    assert update_calls["count"] == 0


@pytest.mark.parametrize(
    "new_mood",
    [
        "HAPPY",
        "PROUD",
        "GREAT",
        "LOVE",
        "STRONG",
        "STAR",
    ],
)
def test_service_changes_feedback_mood(
    monkeypatch,
    new_mood,
):
    service = (
        daily_feedback_routes
        .daily_feedback_service
    )
    feedback = FakeFeedback("HAPPY")

    monkeypatch.setattr(
        service.daily_feedback_repository,
        "get_feedback_for_creator",
        lambda feedback_id, parent_id: feedback,
    )
    monkeypatch.setattr(
        service.daily_feedback_repository,
        "update_feedback",
        lambda: (
            True,
            None,
        ),
    )

    returned_feedback, error = (
        service.update_feedback(
            "feedback-123",
            "parent-123",
            {"mood": new_mood},
        )
    )

    assert error is None
    assert returned_feedback is feedback
    assert feedback.mood == new_mood


def test_service_calls_repository_update_without_arguments(
    monkeypatch,
):
    service = (
        daily_feedback_routes
        .daily_feedback_service
    )
    feedback = FakeFeedback()
    captured = {
        "args": None,
        "kwargs": None,
    }

    monkeypatch.setattr(
        service.daily_feedback_repository,
        "get_feedback_for_creator",
        lambda feedback_id, parent_id: feedback,
    )

    def fake_update_feedback(*args, **kwargs):
        captured["args"] = args
        captured["kwargs"] = kwargs
        return True, None

    monkeypatch.setattr(
        service.daily_feedback_repository,
        "update_feedback",
        fake_update_feedback,
    )

    returned_feedback, error = (
        service.update_feedback(
            "feedback-123",
            "parent-123",
            {"mood": "PROUD"},
        )
    )

    assert error is None
    assert returned_feedback is feedback
    assert captured["args"] == ()
    assert captured["kwargs"] == {}


def test_service_maps_repository_failure_to_update_failed(
    monkeypatch,
):
    service = (
        daily_feedback_routes
        .daily_feedback_service
    )
    feedback = FakeFeedback("HAPPY")

    monkeypatch.setattr(
        service.daily_feedback_repository,
        "get_feedback_for_creator",
        lambda feedback_id, parent_id: feedback,
    )
    monkeypatch.setattr(
        service.daily_feedback_repository,
        "update_feedback",
        lambda: (
            False,
            "database_error",
        ),
    )

    result = service.update_feedback(
        "feedback-123",
        "parent-123",
        {"mood": "STAR"},
    )

    assert result == (
        None,
        "update_failed",
    )
    assert feedback.mood == "STAR"


def test_service_treats_false_success_without_error_as_failure(
    monkeypatch,
):
    service = (
        daily_feedback_routes
        .daily_feedback_service
    )
    feedback = FakeFeedback()

    monkeypatch.setattr(
        service.daily_feedback_repository,
        "get_feedback_for_creator",
        lambda feedback_id, parent_id: feedback,
    )
    monkeypatch.setattr(
        service.daily_feedback_repository,
        "update_feedback",
        lambda: (
            False,
            None,
        ),
    )

    result = service.update_feedback(
        "feedback-123",
        "parent-123",
        {"mood": "LOVE"},
    )

    assert result == (
        None,
        "update_failed",
    )


def test_service_returns_feedback_after_successful_update(
    monkeypatch,
):
    service = (
        daily_feedback_routes
        .daily_feedback_service
    )
    feedback = FakeFeedback("HAPPY")

    monkeypatch.setattr(
        service.daily_feedback_repository,
        "get_feedback_for_creator",
        lambda feedback_id, parent_id: feedback,
    )
    monkeypatch.setattr(
        service.daily_feedback_repository,
        "update_feedback",
        lambda: (
            True,
            None,
        ),
    )

    returned_feedback, error = (
        service.update_feedback(
            "feedback-123",
            "parent-123",
            {"mood": "STRONG"},
        )
    )

    assert error is None
    assert returned_feedback is feedback
    assert feedback.mood == "STRONG"