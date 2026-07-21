import pytest
from flask_jwt_extended import decode_token
from sqlalchemy.exc import IntegrityError

from app.routes import reward_routes
import app.services.reward_service as reward_service_module
import app.repositories.reward_repository as reward_repository_module


REGISTER_URL = "/api/auth/register"
CHILDREN_URL = "/api/children/"
CHILD_LOGIN_URL = "/api/auth/child-login"
CREATE_REWARD_URL = "/api/rewards/"


def auth_header(token):
    return {"Authorization": token}


def register_parent(
    client,
    email="reward.parent@gmail.com",
    phone="0557300001",
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
    phone="0557300099",
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


def create_reward_request(client, token, payload):
    return client.post(
        CREATE_REWARD_URL,
        headers=auth_header(token),
        json=payload,
    )


def valid_reward_payload(
    child_id="child-id",
    reward_name="رحلة جميلة",
    description="مكافأة على الإنجاز",
    unlock_day=3,
):
    return {
        "child_id": child_id,
        "reward_name": reward_name,
        "description": description,
        "unlock_day": unlock_day,
    }


# ===========================================================================
# Route tests
# ===========================================================================

def test_create_reward_requires_access_token(client):
    response = client.post(
        CREATE_REWARD_URL,
        json=valid_reward_payload(),
    )

    assert response.status_code == 401


@pytest.mark.parametrize(
    "token",
    ["invalid-token", "abc.def", "abc.def.ghi"],
)
def test_create_reward_rejects_invalid_token(
    client,
    token,
):
    response = client.post(
        CREATE_REWARD_URL,
        headers=auth_header(token),
        json=valid_reward_payload(),
    )

    assert response.status_code in (401, 422)


def test_child_cannot_create_reward(client):
    parent = register_parent(client)
    child = create_child(
        client,
        parent["access_token"],
    )
    child_login = login_child(
        client,
        child["access_code"],
    )

    response = create_reward_request(
        client,
        child_login["access_token"],
        valid_reward_payload(
            child_id=child["id"]
        ),
    )

    assert response.status_code == 403
    assert response.get_json() == {
        "error": "Parent access required"
    }


def test_route_returns_400_when_child_id_missing(
    client,
):
    parent = register_parent(client)

    payload = valid_reward_payload()
    payload.pop("child_id")

    response = create_reward_request(
        client,
        parent["access_token"],
        payload,
    )

    assert response.status_code == 400


def test_route_returns_400_when_reward_name_missing(
    client,
):
    parent = register_parent(client)

    payload = valid_reward_payload()
    payload.pop("reward_name")

    response = create_reward_request(
        client,
        parent["access_token"],
        payload,
    )

    assert response.status_code == 400


@pytest.mark.parametrize(
    "reward_name",
    ["", " ", "A"],
)
def test_route_rejects_too_short_reward_name(
    client,
    reward_name,
):
    parent = register_parent(client)

    response = create_reward_request(
        client,
        parent["access_token"],
        valid_reward_payload(
            reward_name=reward_name
        ),
    )

    assert response.status_code == 400


def test_route_rejects_reward_name_longer_than_100(
    client,
):
    parent = register_parent(client)

    response = create_reward_request(
        client,
        parent["access_token"],
        valid_reward_payload(
            reward_name="A" * 101
        ),
    )

    assert response.status_code == 400


def test_route_accepts_reward_name_with_surrounding_spaces(
    client,
    monkeypatch,
):
    parent = register_parent(client)
    captured = {}

    class FakeReward:
        id = "reward-id"
        child_id = "child-id"
        reward_name = "رحلة جميلة"
        description = None
        status = "LOCKED"
        unlock_day = 3
        assigned_by = "parent-id"
        created_at = None

    def fake_create_reward(parent_id, reward_data):
        captured["parent_id"] = parent_id
        captured["reward_data"] = reward_data
        return FakeReward(), None

    monkeypatch.setattr(
        reward_routes.reward_service,
        "create_reward",
        fake_create_reward,
    )
    monkeypatch.setattr(
        reward_routes.reward_response_schema,
        "dump",
        lambda reward: {
            "id": reward.id,
            "child_id": reward.child_id,
            "reward_name": reward.reward_name,
            "description": reward.description,
            "status": reward.status,
            "unlock_day": reward.unlock_day,
            "assigned_by": reward.assigned_by,
            "created_at": reward.created_at,
        },
    )

    response = create_reward_request(
        client,
        parent["access_token"],
        valid_reward_payload(
            reward_name="  رحلة جميلة  "
        ),
    )

    assert response.status_code == 201
    assert (
        captured["reward_data"]["reward_name"]
        == "  رحلة جميلة  "
    )


@pytest.mark.parametrize(
    "unlock_day",
    [-1, 7, 100],
)
def test_route_rejects_unlock_day_outside_range(
    client,
    unlock_day,
):
    parent = register_parent(client)

    response = create_reward_request(
        client,
        parent["access_token"],
        valid_reward_payload(
            unlock_day=unlock_day
        ),
    )

    assert response.status_code == 400


def test_route_rejects_description_longer_than_500(
    client,
):
    parent = register_parent(client)

    response = create_reward_request(
        client,
        parent["access_token"],
        valid_reward_payload(
            description="A" * 501
        ),
    )

    assert response.status_code == 400


def test_route_accepts_null_description(
    client,
    monkeypatch,
):
    parent = register_parent(client)
    captured = {}

    class FakeReward:
        id = "reward-id"
        child_id = "child-id"
        reward_name = "رحلة جميلة"
        description = None
        status = "LOCKED"
        unlock_day = 3
        assigned_by = "parent-id"
        created_at = None

    def fake_create_reward(parent_id, reward_data):
        captured["reward_data"] = reward_data
        return FakeReward(), None

    monkeypatch.setattr(
        reward_routes.reward_service,
        "create_reward",
        fake_create_reward,
    )
    monkeypatch.setattr(
        reward_routes.reward_response_schema,
        "dump",
        lambda reward: {
            "id": reward.id,
            "child_id": reward.child_id,
            "reward_name": reward.reward_name,
            "description": reward.description,
            "status": reward.status,
            "unlock_day": reward.unlock_day,
            "assigned_by": reward.assigned_by,
            "created_at": reward.created_at,
        },
    )

    response = create_reward_request(
        client,
        parent["access_token"],
        valid_reward_payload(
            description=None
        ),
    )

    assert response.status_code == 201
    assert captured["reward_data"]["description"] is None


def test_route_uses_default_unlock_day_when_missing(
    client,
    monkeypatch,
):
    parent = register_parent(client)
    captured = {}

    class FakeReward:
        id = "reward-id"
        child_id = "child-id"
        reward_name = "رحلة جميلة"
        description = None
        status = "LOCKED"
        unlock_day = 3
        assigned_by = "parent-id"
        created_at = None

    def fake_create_reward(parent_id, reward_data):
        captured["reward_data"] = reward_data
        return FakeReward(), None

    monkeypatch.setattr(
        reward_routes.reward_service,
        "create_reward",
        fake_create_reward,
    )
    monkeypatch.setattr(
        reward_routes.reward_response_schema,
        "dump",
        lambda reward: {
            "id": reward.id,
            "child_id": reward.child_id,
            "reward_name": reward.reward_name,
            "description": reward.description,
            "status": reward.status,
            "unlock_day": reward.unlock_day,
            "assigned_by": reward.assigned_by,
            "created_at": reward.created_at,
        },
    )

    payload = valid_reward_payload()
    payload.pop("unlock_day")

    response = create_reward_request(
        client,
        parent["access_token"],
        payload,
    )

    assert response.status_code == 201
    assert captured["reward_data"]["unlock_day"] == 3


def test_route_passes_parent_identity_and_loaded_data(
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

    class FakeReward:
        id = "reward-id"
        child_id = "child-id"
        reward_name = "رحلة جميلة"
        description = "مكافأة"
        status = "LOCKED"
        unlock_day = 4
        assigned_by = expected_parent_id
        created_at = None

    def fake_create_reward(parent_id, reward_data):
        captured["parent_id"] = parent_id
        captured["reward_data"] = reward_data
        return FakeReward(), None

    monkeypatch.setattr(
        reward_routes.reward_service,
        "create_reward",
        fake_create_reward,
    )
    monkeypatch.setattr(
        reward_routes.reward_response_schema,
        "dump",
        lambda reward: {
            "id": reward.id,
            "child_id": reward.child_id,
            "reward_name": reward.reward_name,
            "description": reward.description,
            "status": reward.status,
            "unlock_day": reward.unlock_day,
            "assigned_by": reward.assigned_by,
            "created_at": reward.created_at,
        },
    )

    payload = valid_reward_payload(
        child_id="child-id",
        reward_name="رحلة جميلة",
        description="مكافأة",
        unlock_day=4,
    )

    response = create_reward_request(
        client,
        parent["access_token"],
        payload,
    )

    assert response.status_code == 201
    assert captured["parent_id"] == expected_parent_id
    assert captured["reward_data"] == payload


def test_route_maps_child_not_found_to_404(
    client,
    monkeypatch,
):
    parent = register_parent(client)

    monkeypatch.setattr(
        reward_routes.reward_service,
        "create_reward",
        lambda parent_id, reward_data: (
            None,
            "child_not_found",
        ),
    )

    response = create_reward_request(
        client,
        parent["access_token"],
        valid_reward_payload(),
    )

    assert response.status_code == 404
    assert response.get_json() == {
        "error": "Child not found"
    }


@pytest.mark.parametrize(
    "service_error",
    ["create_failed", "unexpected_error"],
)
def test_route_maps_other_service_errors_to_500(
    client,
    monkeypatch,
    service_error,
):
    parent = register_parent(client)

    monkeypatch.setattr(
        reward_routes.reward_service,
        "create_reward",
        lambda parent_id, reward_data: (
            None,
            service_error,
        ),
    )

    response = create_reward_request(
        client,
        parent["access_token"],
        valid_reward_payload(),
    )

    assert response.status_code == 500
    assert response.get_json() == {
        "error": "Failed to create reward"
    }


def test_route_does_not_serialize_when_service_fails(
    client,
    monkeypatch,
):
    parent = register_parent(client)
    dump_called = {"value": False}

    monkeypatch.setattr(
        reward_routes.reward_service,
        "create_reward",
        lambda parent_id, reward_data: (
            None,
            "create_failed",
        ),
    )

    def fake_dump(reward):
        dump_called["value"] = True
        return {}

    monkeypatch.setattr(
        reward_routes.reward_response_schema,
        "dump",
        fake_dump,
    )

    response = create_reward_request(
        client,
        parent["access_token"],
        valid_reward_payload(),
    )

    assert response.status_code == 500
    assert dump_called["value"] is False


def test_route_serializes_created_reward(
    client,
    monkeypatch,
):
    parent = register_parent(client)
    reward = object()
    serialized = {
        "id": "reward-id",
        "child_id": "child-id",
        "reward_name": "رحلة جميلة",
        "description": "مكافأة",
        "status": "LOCKED",
        "unlock_day": 4,
        "assigned_by": "parent-id",
        "created_at": "2026-07-21T12:00:00",
    }
    captured = {}

    monkeypatch.setattr(
        reward_routes.reward_service,
        "create_reward",
        lambda parent_id, reward_data: (
            reward,
            None,
        ),
    )

    def fake_dump(value):
        captured["value"] = value
        return serialized

    monkeypatch.setattr(
        reward_routes.reward_response_schema,
        "dump",
        fake_dump,
    )

    response = create_reward_request(
        client,
        parent["access_token"],
        valid_reward_payload(),
    )

    assert response.status_code == 201
    assert response.get_json() == serialized
    assert captured["value"] is reward


# ===========================================================================
# Service tests
# ===========================================================================

class FakeChild:
    def __init__(self, child_id="child-id"):
        self.id = child_id


def prepare_valid_creation(
    monkeypatch,
    *,
    child=None,
    repository_result=None,
    weekday=2,
):
    service = reward_routes.reward_service
    child = child or FakeChild()

    monkeypatch.setattr(
        service.child_repository,
        "get_child_for_guardian",
        lambda child_id, parent_id: child,
    )

    monkeypatch.setattr(
        reward_service_module,
        "riyadh_weekday",
        lambda: weekday,
    )

    captured = {}

    def fake_create_reward(reward):
        captured["reward"] = reward
        if repository_result is not None:
            return repository_result
        return reward, None

    monkeypatch.setattr(
        service.reward_repository,
        "create_reward",
        fake_create_reward,
    )

    return service, child, captured


def test_service_queries_child_for_correct_guardian(
    monkeypatch,
):
    service = reward_routes.reward_service
    captured = {}

    def fake_get_child(child_id, parent_id):
        captured["child_id"] = child_id
        captured["parent_id"] = parent_id
        return None

    monkeypatch.setattr(
        service.child_repository,
        "get_child_for_guardian",
        fake_get_child,
    )

    result = service.create_reward(
        "parent-123",
        valid_reward_payload(
            child_id="child-456"
        ),
    )

    assert result == (None, "child_not_found")
    assert captured == {
        "child_id": "child-456",
        "parent_id": "parent-123",
    }


def test_service_returns_child_not_found(
    monkeypatch,
):
    service = reward_routes.reward_service

    monkeypatch.setattr(
        service.child_repository,
        "get_child_for_guardian",
        lambda child_id, parent_id: None,
    )

    result = service.create_reward(
        "parent-id",
        valid_reward_payload(),
    )

    assert result == (None, "child_not_found")


def test_service_uses_default_unlock_day_three(
    monkeypatch,
):
    service, child, captured = (
        prepare_valid_creation(
            monkeypatch,
            weekday=1,
        )
    )

    reward_data = valid_reward_payload(
        child_id=child.id
    )
    reward_data.pop("unlock_day")

    result, error = service.create_reward(
        "parent-id",
        reward_data,
    )

    assert error is None
    assert result is captured["reward"]
    assert captured["reward"].unlock_day == 3


def test_service_sets_status_unlocked_on_matching_weekday(
    monkeypatch,
):
    service, child, captured = (
        prepare_valid_creation(
            monkeypatch,
            weekday=4,
        )
    )

    result, error = service.create_reward(
        "parent-id",
        valid_reward_payload(
            child_id=child.id,
            unlock_day=4,
        ),
    )

    assert error is None
    assert result is captured["reward"]
    assert captured["reward"].status == "UNLOCKED"


def test_service_sets_status_locked_on_different_weekday(
    monkeypatch,
):
    service, child, captured = (
        prepare_valid_creation(
            monkeypatch,
            weekday=2,
        )
    )

    result, error = service.create_reward(
        "parent-id",
        valid_reward_payload(
            child_id=child.id,
            unlock_day=4,
        ),
    )

    assert error is None
    assert result is captured["reward"]
    assert captured["reward"].status == "LOCKED"


def test_service_strips_reward_name(
    monkeypatch,
):
    service, child, captured = (
        prepare_valid_creation(monkeypatch)
    )

    result, error = service.create_reward(
        "parent-id",
        valid_reward_payload(
            child_id=child.id,
            reward_name="  رحلة جميلة  ",
        ),
    )

    assert error is None
    assert result is captured["reward"]
    assert (
        captured["reward"].reward_name
        == "رحلة جميلة"
    )


def test_service_strips_description(
    monkeypatch,
):
    service, child, captured = (
        prepare_valid_creation(monkeypatch)
    )

    result, error = service.create_reward(
        "parent-id",
        valid_reward_payload(
            child_id=child.id,
            description="  مكافأة جميلة  ",
        ),
    )

    assert error is None
    assert result is captured["reward"]
    assert (
        captured["reward"].description
        == "مكافأة جميلة"
    )


def test_service_preserves_none_description(
    monkeypatch,
):
    service, child, captured = (
        prepare_valid_creation(monkeypatch)
    )

    result, error = service.create_reward(
        "parent-id",
        valid_reward_payload(
            child_id=child.id,
            description=None,
        ),
    )

    assert error is None
    assert result is captured["reward"]
    assert captured["reward"].description is None


def test_service_builds_reward_with_correct_fields(
    monkeypatch,
):
    service, child, captured = (
        prepare_valid_creation(
            monkeypatch,
            weekday=0,
        )
    )

    result, error = service.create_reward(
        "parent-123",
        valid_reward_payload(
            child_id=child.id,
            reward_name="  رحلة  ",
            description="  نهاية الأسبوع  ",
            unlock_day=5,
        ),
    )

    reward = captured["reward"]

    assert error is None
    assert result is reward
    assert reward.child_id == child.id
    assert reward.reward_name == "رحلة"
    assert reward.description == "نهاية الأسبوع"
    assert reward.status == "LOCKED"
    assert reward.unlock_day == 5
    assert reward.assigned_by == "parent-123"


def test_service_passes_reward_to_repository(
    monkeypatch,
):
    service, child, captured = (
        prepare_valid_creation(monkeypatch)
    )

    result, error = service.create_reward(
        "parent-id",
        valid_reward_payload(
            child_id=child.id
        ),
    )

    assert error is None
    assert result is captured["reward"]
    assert captured["reward"] is not None


def test_service_returns_create_failed_on_repository_error(
    monkeypatch,
):
    service, child, captured = (
        prepare_valid_creation(
            monkeypatch,
            repository_result=(
                None,
                "integrity_error",
            ),
        )
    )

    result = service.create_reward(
        "parent-id",
        valid_reward_payload(
            child_id=child.id
        ),
    )

    assert result == (None, "create_failed")
    assert captured["reward"] is not None


# ===========================================================================
# Repository tests
# ===========================================================================

def test_repository_adds_and_commits_reward(
    app,
    monkeypatch,
):
    repository = (
        reward_routes.reward_service
        .reward_repository
    )
    reward = object()
    calls = {
        "added": None,
        "commit": 0,
        "rollback": 0,
    }

    with app.app_context():
        monkeypatch.setattr(
            reward_repository_module.db.session,
            "add",
            lambda value: calls.__setitem__(
                "added",
                value,
            ),
        )
        monkeypatch.setattr(
            reward_repository_module.db.session,
            "commit",
            lambda: calls.__setitem__(
                "commit",
                calls["commit"] + 1,
            ),
        )
        monkeypatch.setattr(
            reward_repository_module.db.session,
            "rollback",
            lambda: calls.__setitem__(
                "rollback",
                calls["rollback"] + 1,
            ),
        )

        result = repository.create_reward(reward)

    assert result == (reward, None)
    assert calls == {
        "added": reward,
        "commit": 1,
        "rollback": 0,
    }


def test_repository_rolls_back_on_integrity_error(
    app,
    monkeypatch,
):
    repository = (
        reward_routes.reward_service
        .reward_repository
    )
    reward = object()
    calls = {
        "add": 0,
        "commit": 0,
        "rollback": 0,
    }

    error = IntegrityError(
        "statement",
        {},
        Exception("database integrity error"),
    )

    def fake_add(value):
        calls["add"] += 1

    def fake_commit():
        calls["commit"] += 1
        raise error

    with app.app_context():
        monkeypatch.setattr(
            reward_repository_module.db.session,
            "add",
            fake_add,
        )
        monkeypatch.setattr(
            reward_repository_module.db.session,
            "commit",
            fake_commit,
        )
        monkeypatch.setattr(
            reward_repository_module.db.session,
            "rollback",
            lambda: calls.__setitem__(
                "rollback",
                calls["rollback"] + 1,
            ),
        )

        result = repository.create_reward(reward)

    assert result == (
        None,
        "integrity_error",
    )
    assert calls == {
        "add": 1,
        "commit": 1,
        "rollback": 1,
    }