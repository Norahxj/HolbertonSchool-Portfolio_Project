import pytest
from flask_jwt_extended import decode_token
from sqlalchemy.exc import IntegrityError

from app.routes import reward_routes
import app.services.reward_service as reward_service_module
import app.repositories.reward_repository as reward_repository_module


REGISTER_URL = "/api/auth/register"
CHILDREN_URL = "/api/children/"
CHILD_LOGIN_URL = "/api/auth/child-login"
UPDATE_REWARD_URL = "/api/rewards/{reward_id}"


def auth_header(token):
    return {"Authorization": token}


def register_parent(
    client,
    email="update.reward.parent@gmail.com",
    phone="0557600001",
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
    phone="0557600099",
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


def update_reward_request(
    client,
    token,
    reward_id,
    payload,
):
    return client.put(
        UPDATE_REWARD_URL.format(
            reward_id=reward_id
        ),
        headers=auth_header(token),
        json=payload,
    )


# ===========================================================================
# Route tests
# ===========================================================================

def test_update_reward_requires_access_token(client):
    response = client.put(
        UPDATE_REWARD_URL.format(
            reward_id="reward-id"
        ),
        json={"reward_name": "هدية جديدة"},
    )

    assert response.status_code == 401


@pytest.mark.parametrize(
    "token",
    ["invalid-token", "abc.def", "abc.def.ghi"],
)
def test_update_reward_rejects_invalid_token(
    client,
    token,
):
    response = client.put(
        UPDATE_REWARD_URL.format(
            reward_id="reward-id"
        ),
        headers=auth_header(token),
        json={"reward_name": "هدية جديدة"},
    )

    assert response.status_code in (401, 422)


def test_child_cannot_update_reward(client):
    parent = register_parent(client)
    child = create_child(
        client,
        parent["access_token"],
    )
    child_login = login_child(
        client,
        child["access_code"],
    )

    response = update_reward_request(
        client,
        child_login["access_token"],
        "reward-id",
        {"reward_name": "هدية جديدة"},
    )

    assert response.status_code == 403
    assert response.get_json() == {
        "error": "Parent access required"
    }


def test_route_rejects_empty_payload(client):
    parent = register_parent(client)

    response = update_reward_request(
        client,
        parent["access_token"],
        "reward-id",
        {},
    )

    assert response.status_code == 400


def test_route_rejects_missing_json_body(client):
    parent = register_parent(client)

    response = client.put(
        UPDATE_REWARD_URL.format(
            reward_id="reward-id"
        ),
        headers=auth_header(
            parent["access_token"]
        ),
    )

    assert response.status_code == 415

@pytest.mark.parametrize(
    "reward_name",
    ["", " ", "A"],
)
def test_route_rejects_too_short_reward_name(
    client,
    reward_name,
):
    parent = register_parent(client)

    response = update_reward_request(
        client,
        parent["access_token"],
        "reward-id",
        {"reward_name": reward_name},
    )

    assert response.status_code == 400


def test_route_rejects_reward_name_longer_than_100(
    client,
):
    parent = register_parent(client)

    response = update_reward_request(
        client,
        parent["access_token"],
        "reward-id",
        {"reward_name": "A" * 101},
    )

    assert response.status_code == 400


@pytest.mark.parametrize(
    "unlock_day",
    [-1, 7, 100],
)
def test_route_rejects_unlock_day_outside_range(
    client,
    unlock_day,
):
    parent = register_parent(client)

    response = update_reward_request(
        client,
        parent["access_token"],
        "reward-id",
        {"unlock_day": unlock_day},
    )

    assert response.status_code == 400


def test_route_rejects_description_longer_than_500(
    client,
):
    parent = register_parent(client)

    response = update_reward_request(
        client,
        parent["access_token"],
        "reward-id",
        {"description": "A" * 501},
    )

    assert response.status_code == 400


def test_route_accepts_single_reward_name_field(
    client,
    monkeypatch,
):
    parent = register_parent(client)
    captured = {}

    class FakeReward:
        id = "reward-id"
        child_id = "child-id"
        reward_name = "هدية جديدة"
        description = None
        status = "LOCKED"
        unlock_day = 3
        assigned_by = "parent-id"
        created_at = None

    def fake_update_reward(
        reward_id,
        parent_id,
        reward_data,
    ):
        captured["reward_id"] = reward_id
        captured["parent_id"] = parent_id
        captured["reward_data"] = reward_data
        return FakeReward(), None

    monkeypatch.setattr(
        reward_routes.reward_service,
        "update_reward",
        fake_update_reward,
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

    response = update_reward_request(
        client,
        parent["access_token"],
        "reward-id",
        {"reward_name": "هدية جديدة"},
    )

    assert response.status_code == 200
    assert captured["reward_data"] == {
        "reward_name": "هدية جديدة"
    }


def test_route_accepts_single_description_field(
    client,
    monkeypatch,
):
    parent = register_parent(client)
    captured = {}

    class FakeReward:
        id = "reward-id"
        child_id = "child-id"
        reward_name = "هدية"
        description = "وصف جديد"
        status = "LOCKED"
        unlock_day = 3
        assigned_by = "parent-id"
        created_at = None

    def fake_update_reward(
        reward_id,
        parent_id,
        reward_data,
    ):
        captured["reward_data"] = reward_data
        return FakeReward(), None

    monkeypatch.setattr(
        reward_routes.reward_service,
        "update_reward",
        fake_update_reward,
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

    response = update_reward_request(
        client,
        parent["access_token"],
        "reward-id",
        {"description": "وصف جديد"},
    )

    assert response.status_code == 200
    assert captured["reward_data"] == {
        "description": "وصف جديد"
    }


def test_route_accepts_single_unlock_day_field(
    client,
    monkeypatch,
):
    parent = register_parent(client)
    captured = {}

    class FakeReward:
        id = "reward-id"
        child_id = "child-id"
        reward_name = "هدية"
        description = None
        status = "LOCKED"
        unlock_day = 5
        assigned_by = "parent-id"
        created_at = None

    def fake_update_reward(
        reward_id,
        parent_id,
        reward_data,
    ):
        captured["reward_data"] = reward_data
        return FakeReward(), None

    monkeypatch.setattr(
        reward_routes.reward_service,
        "update_reward",
        fake_update_reward,
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

    response = update_reward_request(
        client,
        parent["access_token"],
        "reward-id",
        {"unlock_day": 5},
    )

    assert response.status_code == 200
    assert captured["reward_data"] == {
        "unlock_day": 5
    }


def test_route_passes_reward_id_parent_id_and_data(
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
        id = "reward-123"
        child_id = "child-id"
        reward_name = "هدية جديدة"
        description = "وصف جديد"
        status = "UNLOCKED"
        unlock_day = 4
        assigned_by = expected_parent_id
        created_at = None

    def fake_update_reward(
        reward_id,
        parent_id,
        reward_data,
    ):
        captured["reward_id"] = reward_id
        captured["parent_id"] = parent_id
        captured["reward_data"] = reward_data
        return FakeReward(), None

    monkeypatch.setattr(
        reward_routes.reward_service,
        "update_reward",
        fake_update_reward,
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

    payload = {
        "reward_name": "هدية جديدة",
        "description": "وصف جديد",
        "unlock_day": 4,
    }

    response = update_reward_request(
        client,
        parent["access_token"],
        "reward-123",
        payload,
    )

    assert response.status_code == 200
    assert captured == {
        "reward_id": "reward-123",
        "parent_id": expected_parent_id,
        "reward_data": payload,
    }


def test_route_maps_reward_not_found_to_404(
    client,
    monkeypatch,
):
    parent = register_parent(client)

    monkeypatch.setattr(
        reward_routes.reward_service,
        "update_reward",
        lambda reward_id, parent_id, reward_data: (
            None,
            "reward_not_found",
        ),
    )

    response = update_reward_request(
        client,
        parent["access_token"],
        "missing-reward",
        {"reward_name": "هدية جديدة"},
    )

    assert response.status_code == 404
    assert response.get_json() == {
        "error": "Reward not found"
    }


@pytest.mark.parametrize(
    "service_error",
    ["update_failed", "unexpected_error"],
)
def test_route_maps_other_errors_to_500(
    client,
    monkeypatch,
    service_error,
):
    parent = register_parent(client)

    monkeypatch.setattr(
        reward_routes.reward_service,
        "update_reward",
        lambda reward_id, parent_id, reward_data: (
            None,
            service_error,
        ),
    )

    response = update_reward_request(
        client,
        parent["access_token"],
        "reward-id",
        {"reward_name": "هدية جديدة"},
    )

    assert response.status_code == 500
    assert response.get_json() == {
        "error": "Failed to update reward"
    }


def test_route_does_not_serialize_when_service_fails(
    client,
    monkeypatch,
):
    parent = register_parent(client)
    dump_called = {"value": False}

    monkeypatch.setattr(
        reward_routes.reward_service,
        "update_reward",
        lambda reward_id, parent_id, reward_data: (
            None,
            "update_failed",
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

    response = update_reward_request(
        client,
        parent["access_token"],
        "reward-id",
        {"reward_name": "هدية جديدة"},
    )

    assert response.status_code == 500
    assert dump_called["value"] is False


def test_route_serializes_updated_reward(
    client,
    monkeypatch,
):
    parent = register_parent(client)
    reward = object()
    serialized = {
        "id": "reward-id",
        "child_id": "child-id",
        "reward_name": "هدية جديدة",
        "description": None,
        "status": "LOCKED",
        "unlock_day": 5,
        "assigned_by": "parent-id",
        "created_at": "2026-07-21T12:00:00",
    }
    captured = {}

    monkeypatch.setattr(
        reward_routes.reward_service,
        "update_reward",
        lambda reward_id, parent_id, reward_data: (
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

    response = update_reward_request(
        client,
        parent["access_token"],
        "reward-id",
        {"unlock_day": 5},
    )

    assert response.status_code == 200
    assert response.get_json() == serialized
    assert captured["value"] is reward


# ===========================================================================
# Service tests
# ===========================================================================

class FakeReward:
    def __init__(
        self,
        reward_id="reward-id",
        reward_name="هدية",
        description="وصف",
        status="LOCKED",
        unlock_day=3,
    ):
        self.id = reward_id
        self.reward_name = reward_name
        self.description = description
        self.status = status
        self.unlock_day = unlock_day


def prepare_valid_update(
    monkeypatch,
    *,
    reward=None,
    update_result=(True, None),
    weekday=2,
):
    service = reward_routes.reward_service
    reward = reward or FakeReward()

    monkeypatch.setattr(
        service.reward_repository,
        "get_reward_for_parent",
        lambda reward_id, parent_id: reward,
    )
    monkeypatch.setattr(
        service.reward_repository,
        "update_reward",
        lambda: update_result,
    )
    monkeypatch.setattr(
        reward_service_module,
        "riyadh_weekday",
        lambda: weekday,
    )

    return service, reward


def test_service_queries_reward_for_correct_parent(
    monkeypatch,
):
    service = reward_routes.reward_service
    captured = {}

    def fake_get_reward(reward_id, parent_id):
        captured["reward_id"] = reward_id
        captured["parent_id"] = parent_id
        return None

    monkeypatch.setattr(
        service.reward_repository,
        "get_reward_for_parent",
        fake_get_reward,
    )

    result = service.update_reward(
        "reward-123",
        "parent-456",
        {"reward_name": "هدية جديدة"},
    )

    assert result == (
        None,
        "reward_not_found",
    )
    assert captured == {
        "reward_id": "reward-123",
        "parent_id": "parent-456",
    }


def test_service_returns_reward_not_found(
    monkeypatch,
):
    service = reward_routes.reward_service

    monkeypatch.setattr(
        service.reward_repository,
        "get_reward_for_parent",
        lambda reward_id, parent_id: None,
    )

    result = service.update_reward(
        "missing-reward",
        "parent-id",
        {"reward_name": "هدية جديدة"},
    )

    assert result == (
        None,
        "reward_not_found",
    )


def test_service_strips_reward_name(
    monkeypatch,
):
    service, reward = prepare_valid_update(
        monkeypatch
    )

    result, error = service.update_reward(
        reward.id,
        "parent-id",
        {"reward_name": "  هدية جديدة  "},
    )

    assert error is None
    assert result is reward
    assert reward.reward_name == "هدية جديدة"


def test_service_does_not_change_reward_name_when_absent(
    monkeypatch,
):
    reward = FakeReward(
        reward_name="الاسم القديم"
    )
    service, reward = prepare_valid_update(
        monkeypatch,
        reward=reward,
    )

    service.update_reward(
        reward.id,
        "parent-id",
        {"description": "وصف جديد"},
    )

    assert reward.reward_name == "الاسم القديم"


def test_service_strips_description(
    monkeypatch,
):
    service, reward = prepare_valid_update(
        monkeypatch
    )

    result, error = service.update_reward(
        reward.id,
        "parent-id",
        {"description": "  وصف جديد  "},
    )

    assert error is None
    assert result is reward
    assert reward.description == "وصف جديد"


def test_service_allows_none_description(
    monkeypatch,
):
    service, reward = prepare_valid_update(
        monkeypatch
    )

    result, error = service.update_reward(
        reward.id,
        "parent-id",
        {"description": None},
    )

    assert error is None
    assert result is reward
    assert reward.description is None


def test_service_does_not_change_description_when_absent(
    monkeypatch,
):
    reward = FakeReward(
        description="الوصف القديم"
    )
    service, reward = prepare_valid_update(
        monkeypatch,
        reward=reward,
    )

    service.update_reward(
        reward.id,
        "parent-id",
        {"reward_name": "اسم جديد"},
    )

    assert reward.description == "الوصف القديم"


def test_service_sets_unlock_day(
    monkeypatch,
):
    service, reward = prepare_valid_update(
        monkeypatch,
        weekday=1,
    )

    result, error = service.update_reward(
        reward.id,
        "parent-id",
        {"unlock_day": 5},
    )

    assert error is None
    assert result is reward
    assert reward.unlock_day == 5


def test_service_sets_unlocked_when_day_matches_today(
    monkeypatch,
):
    reward = FakeReward(
        status="LOCKED",
        unlock_day=2,
    )
    service, reward = prepare_valid_update(
        monkeypatch,
        reward=reward,
        weekday=4,
    )

    service.update_reward(
        reward.id,
        "parent-id",
        {"unlock_day": 4},
    )

    assert reward.unlock_day == 4
    assert reward.status == "UNLOCKED"


def test_service_sets_locked_when_day_differs_from_today(
    monkeypatch,
):
    reward = FakeReward(
        status="UNLOCKED",
        unlock_day=2,
    )
    service, reward = prepare_valid_update(
        monkeypatch,
        reward=reward,
        weekday=1,
    )

    service.update_reward(
        reward.id,
        "parent-id",
        {"unlock_day": 4},
    )

    assert reward.unlock_day == 4
    assert reward.status == "LOCKED"


def test_service_keeps_claimed_status_when_unlock_day_changes(
    monkeypatch,
):
    reward = FakeReward(
        status="CLAIMED",
        unlock_day=2,
    )
    service, reward = prepare_valid_update(
        monkeypatch,
        reward=reward,
        weekday=4,
    )

    service.update_reward(
        reward.id,
        "parent-id",
        {"unlock_day": 4},
    )

    assert reward.unlock_day == 4
    assert reward.status == "CLAIMED"


def test_service_does_not_call_weekday_without_unlock_day(
    monkeypatch,
):
    service = reward_routes.reward_service
    reward = FakeReward()
    calls = {"weekday": 0}

    monkeypatch.setattr(
        service.reward_repository,
        "get_reward_for_parent",
        lambda reward_id, parent_id: reward,
    )
    monkeypatch.setattr(
        service.reward_repository,
        "update_reward",
        lambda: (True, None),
    )

    def fake_weekday():
        calls["weekday"] += 1
        return 2

    monkeypatch.setattr(
        reward_service_module,
        "riyadh_weekday",
        fake_weekday,
    )

    result, error = service.update_reward(
        reward.id,
        "parent-id",
        {"reward_name": "اسم جديد"},
    )

    assert error is None
    assert result is reward
    assert calls["weekday"] == 0


def test_service_updates_multiple_fields_together(
    monkeypatch,
):
    reward = FakeReward(
        reward_name="قديم",
        description="قديم",
        status="LOCKED",
        unlock_day=1,
    )
    service, reward = prepare_valid_update(
        monkeypatch,
        reward=reward,
        weekday=5,
    )

    result, error = service.update_reward(
        reward.id,
        "parent-id",
        {
            "reward_name": "  جديد  ",
            "description": "  وصف جديد  ",
            "unlock_day": 5,
        },
    )

    assert error is None
    assert result is reward
    assert reward.reward_name == "جديد"
    assert reward.description == "وصف جديد"
    assert reward.unlock_day == 5
    assert reward.status == "UNLOCKED"


def test_service_calls_repository_update_once(
    monkeypatch,
):
    service = reward_routes.reward_service
    reward = FakeReward()
    calls = {"count": 0}

    monkeypatch.setattr(
        service.reward_repository,
        "get_reward_for_parent",
        lambda reward_id, parent_id: reward,
    )

    def fake_update():
        calls["count"] += 1
        return True, None

    monkeypatch.setattr(
        service.reward_repository,
        "update_reward",
        fake_update,
    )

    result, error = service.update_reward(
        reward.id,
        "parent-id",
        {"reward_name": "اسم جديد"},
    )

    assert error is None
    assert result is reward
    assert calls["count"] == 1


def test_service_does_not_update_repository_when_reward_missing(
    monkeypatch,
):
    service = reward_routes.reward_service
    calls = {"count": 0}

    monkeypatch.setattr(
        service.reward_repository,
        "get_reward_for_parent",
        lambda reward_id, parent_id: None,
    )

    def fake_update():
        calls["count"] += 1
        return True, None

    monkeypatch.setattr(
        service.reward_repository,
        "update_reward",
        fake_update,
    )

    result = service.update_reward(
        "missing-reward",
        "parent-id",
        {"reward_name": "اسم جديد"},
    )

    assert result == (
        None,
        "reward_not_found",
    )
    assert calls["count"] == 0


def test_service_returns_update_failed_when_repository_fails(
    monkeypatch,
):
    service, reward = prepare_valid_update(
        monkeypatch,
        update_result=(
            False,
            "integrity_error",
        ),
    )

    result = service.update_reward(
        reward.id,
        "parent-id",
        {"reward_name": "اسم جديد"},
    )

    assert result == (
        None,
        "update_failed",
    )
    assert reward.reward_name == "اسم جديد"


# ===========================================================================
# Repository tests
# ===========================================================================

def test_repository_update_reward_commits(
    app,
    monkeypatch,
):
    repository = (
        reward_routes.reward_service
        .reward_repository
    )
    calls = {
        "commit": 0,
        "rollback": 0,
    }

    with app.app_context():
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

        result = repository.update_reward()

    assert result == (True, None)
    assert calls == {
        "commit": 1,
        "rollback": 0,
    }


def test_repository_update_reward_rolls_back_on_integrity_error(
    app,
    monkeypatch,
):
    repository = (
        reward_routes.reward_service
        .reward_repository
    )
    calls = {
        "commit": 0,
        "rollback": 0,
    }

    error = IntegrityError(
        "statement",
        {},
        Exception("database integrity error"),
    )

    def fake_commit():
        calls["commit"] += 1
        raise error

    with app.app_context():
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

        result = repository.update_reward()

    assert result == (
        False,
        "integrity_error",
    )
    assert calls == {
        "commit": 1,
        "rollback": 1,
    }