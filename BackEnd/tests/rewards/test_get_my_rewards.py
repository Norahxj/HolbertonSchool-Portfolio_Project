import pytest
from flask_jwt_extended import decode_token

from app.routes import reward_routes


REGISTER_URL = "/api/auth/register"
CHILDREN_URL = "/api/children/"
CHILD_LOGIN_URL = "/api/auth/child-login"
MY_REWARDS_URL = "/api/rewards/my"


def auth_header(token):
    return {"Authorization": token}


def register_parent(
    client,
    email="my.rewards.parent@gmail.com",
    phone="0557500001",
    guardian_type="mother",
):
    response = client.post(
        REGISTER_URL,
        json={
            "first_name": "Manar",
            "last_name": "Zaid",
            "phone": phone,
            "email": email,
            "password": "Password123!",
            "guardian_type": guardian_type,
        },
    )
    assert response.status_code == 201, response.get_json()
    return response.get_json()


def create_child(
    client,
    parent_token,
    phone="0557500099",
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


def get_my_rewards(client, token):
    return client.get(
        MY_REWARDS_URL,
        headers=auth_header(token),
    )


# ===========================================================================
# Route tests
# ===========================================================================

def test_get_my_rewards_requires_access_token(client):
    response = client.get(MY_REWARDS_URL)

    assert response.status_code == 401


@pytest.mark.parametrize(
    "token",
    ["invalid-token", "abc.def", "abc.def.ghi"],
)
def test_get_my_rewards_rejects_invalid_token(
    client,
    token,
):
    response = client.get(
        MY_REWARDS_URL,
        headers=auth_header(token),
    )

    assert response.status_code in (401, 422)


def test_parent_cannot_get_child_my_rewards(client):
    parent = register_parent(client)

    response = get_my_rewards(
        client,
        parent["access_token"],
    )

    assert response.status_code == 403
    assert response.get_json() == {
        "error": "Child access required"
    }


def test_route_passes_child_identity_to_service(
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

    def fake_get_my_rewards(child_id):
        captured["child_id"] = child_id
        return [], None

    monkeypatch.setattr(
        reward_routes.reward_service,
        "get_my_rewards",
        fake_get_my_rewards,
    )
    monkeypatch.setattr(
        reward_routes.rewards_response_schema,
        "dump",
        lambda rewards: [],
    )

    response = get_my_rewards(
        client,
        child_login["access_token"],
    )

    assert response.status_code == 200
    assert response.get_json() == []
    assert captured["child_id"] == expected_child_id


def test_route_maps_child_not_found_to_404(
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

    monkeypatch.setattr(
        reward_routes.reward_service,
        "get_my_rewards",
        lambda child_id: (
            None,
            "child_not_found",
        ),
    )

    response = get_my_rewards(
        client,
        child_login["access_token"],
    )

    assert response.status_code == 404
    assert response.get_json() == {
        "error": "Child not found"
    }


@pytest.mark.parametrize(
    "service_error",
    ["repository_error", "unexpected_error"],
)
def test_route_maps_other_errors_to_500(
    client,
    monkeypatch,
    service_error,
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
        reward_routes.reward_service,
        "get_my_rewards",
        lambda child_id: (
            None,
            service_error,
        ),
    )

    response = get_my_rewards(
        client,
        child_login["access_token"],
    )

    assert response.status_code == 500
    assert response.get_json() == {
        "error": "Failed to retrieve rewards"
    }


def test_route_does_not_serialize_when_service_fails(
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
        reward_routes.reward_service,
        "get_my_rewards",
        lambda child_id: (
            None,
            "repository_error",
        ),
    )

    def fake_dump(rewards):
        dump_called["value"] = True
        return []

    monkeypatch.setattr(
        reward_routes.rewards_response_schema,
        "dump",
        fake_dump,
    )

    response = get_my_rewards(
        client,
        child_login["access_token"],
    )

    assert response.status_code == 500
    assert dump_called["value"] is False


def test_route_serializes_rewards_list(
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

    rewards = [object(), object()]
    serialized = [
        {
            "id": "reward-1",
            "child_id": child["id"],
            "reward_name": "رحلة",
            "description": None,
            "status": "LOCKED",
            "unlock_day": 3,
            "assigned_by": "parent-id",
            "created_at": "2026-07-21T12:00:00",
        },
        {
            "id": "reward-2",
            "child_id": child["id"],
            "reward_name": "هدية",
            "description": "مكافأة جميلة",
            "status": "UNLOCKED",
            "unlock_day": 2,
            "assigned_by": "parent-id",
            "created_at": "2026-07-21T13:00:00",
        },
    ]
    captured = {}

    monkeypatch.setattr(
        reward_routes.reward_service,
        "get_my_rewards",
        lambda child_id: (
            rewards,
            None,
        ),
    )

    def fake_dump(value):
        captured["value"] = value
        return serialized

    monkeypatch.setattr(
        reward_routes.rewards_response_schema,
        "dump",
        fake_dump,
    )

    response = get_my_rewards(
        client,
        child_login["access_token"],
    )

    assert response.status_code == 200
    assert response.get_json() == serialized
    assert captured["value"] is rewards


def test_route_returns_empty_list_when_child_has_no_rewards(
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

    monkeypatch.setattr(
        reward_routes.reward_service,
        "get_my_rewards",
        lambda child_id: (
            [],
            None,
        ),
    )
    monkeypatch.setattr(
        reward_routes.rewards_response_schema,
        "dump",
        lambda rewards: [],
    )

    response = get_my_rewards(
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


def test_service_queries_child_by_identity(
    monkeypatch,
):
    service = reward_routes.reward_service
    captured = {}

    def fake_get_child(child_id):
        captured["child_id"] = child_id
        return None

    monkeypatch.setattr(
        service.child_repository,
        "get_child_by_id",
        fake_get_child,
    )

    result = service.get_my_rewards(
        "child-123"
    )

    assert result == (None, "child_not_found")
    assert captured["child_id"] == "child-123"


def test_service_returns_child_not_found(
    monkeypatch,
):
    service = reward_routes.reward_service

    monkeypatch.setattr(
        service.child_repository,
        "get_child_by_id",
        lambda child_id: None,
    )

    result = service.get_my_rewards(
        "missing-child"
    )

    assert result == (
        None,
        "child_not_found",
    )


def test_service_does_not_query_rewards_when_child_missing(
    monkeypatch,
):
    service = reward_routes.reward_service
    calls = {"count": 0}

    monkeypatch.setattr(
        service.child_repository,
        "get_child_by_id",
        lambda child_id: None,
    )

    def fake_get_rewards(child_id):
        calls["count"] += 1
        return []

    monkeypatch.setattr(
        service.reward_repository,
        "get_rewards_by_child_id",
        fake_get_rewards,
    )

    result = service.get_my_rewards(
        "missing-child"
    )

    assert result == (
        None,
        "child_not_found",
    )
    assert calls["count"] == 0


def test_service_queries_rewards_for_authenticated_child(
    monkeypatch,
):
    service = reward_routes.reward_service
    child = FakeChild("child-123")
    rewards = [object(), object()]
    captured = {}

    monkeypatch.setattr(
        service.child_repository,
        "get_child_by_id",
        lambda child_id: child,
    )

    def fake_get_rewards(child_id):
        captured["child_id"] = child_id
        return rewards

    monkeypatch.setattr(
        service.reward_repository,
        "get_rewards_by_child_id",
        fake_get_rewards,
    )

    result = service.get_my_rewards(
        "child-123"
    )

    assert result == (rewards, None)
    assert captured["child_id"] == "child-123"


def test_service_returns_empty_list_when_repository_returns_empty(
    monkeypatch,
):
    service = reward_routes.reward_service
    child = FakeChild()

    monkeypatch.setattr(
        service.child_repository,
        "get_child_by_id",
        lambda child_id: child,
    )
    monkeypatch.setattr(
        service.reward_repository,
        "get_rewards_by_child_id",
        lambda child_id: [],
    )

    result = service.get_my_rewards(
        child.id
    )

    assert result == ([], None)


def test_service_returns_repository_rewards_unchanged(
    monkeypatch,
):
    service = reward_routes.reward_service
    child = FakeChild()
    rewards = [object(), object()]

    monkeypatch.setattr(
        service.child_repository,
        "get_child_by_id",
        lambda child_id: child,
    )
    monkeypatch.setattr(
        service.reward_repository,
        "get_rewards_by_child_id",
        lambda child_id: rewards,
    )

    returned_rewards, error = (
        service.get_my_rewards(child.id)
    )

    assert error is None
    assert returned_rewards is rewards