import pytest

from app.routes import reward_bank_routes
import app.services.reward_bank_service as service_module


REGISTER_URL = "/api/auth/register"
CHILDREN_URL = "/api/children/"
CHILD_LOGIN_URL = "/api/auth/child-login"
SUGGESTIONS_URL = "/api/reward-bank/suggestions"


def auth_header(token):
    return {"Authorization": token}


def register_parent(
    client,
    email="reward.bank.parent@gmail.com",
    phone="0557910001",
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
    phone="0557910099",
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


def get_reward_suggestions(
    client,
    token,
    payload,
):
    return client.post(
        SUGGESTIONS_URL,
        headers=auth_header(token),
        json=payload,
    )


# ===========================================================================
# require_parent tests
# ===========================================================================

def test_require_parent_returns_none_for_parent(
    app,
    monkeypatch,
):
    with app.test_request_context():
        monkeypatch.setattr(
            reward_bank_routes,
            "get_jwt",
            lambda: {"role": "parent"},
        )

        result = reward_bank_routes.require_parent()

    assert result is None


def test_require_parent_returns_403_for_child(
    app,
    monkeypatch,
):
    with app.test_request_context():
        monkeypatch.setattr(
            reward_bank_routes,
            "get_jwt",
            lambda: {"role": "child"},
        )

        result = reward_bank_routes.require_parent()

    assert result == (
        {"error": "Parent access required"},
        403,
    )


def test_require_parent_returns_403_when_role_missing(
    app,
    monkeypatch,
):
    with app.test_request_context():
        monkeypatch.setattr(
            reward_bank_routes,
            "get_jwt",
            lambda: {},
        )

        result = reward_bank_routes.require_parent()

    assert result == (
        {"error": "Parent access required"},
        403,
    )


# ===========================================================================
# Route tests
# ===========================================================================

def test_route_requires_access_token(client):
    response = client.post(
        SUGGESTIONS_URL,
        json={"lang": "en"},
    )

    assert response.status_code == 401


def test_route_rejects_invalid_access_token(client):
    response = client.post(
        SUGGESTIONS_URL,
        headers=auth_header("invalid-token"),
        json={"lang": "en"},
    )

    assert response.status_code in (401, 422)


def test_child_cannot_get_reward_suggestions(client):
    parent = register_parent(client)
    child = create_child(
        client,
        parent["access_token"],
    )
    child_login = login_child(
        client,
        child["access_code"],
    )

    response = get_reward_suggestions(
        client,
        child_login["access_token"],
        {"lang": "en"},
    )

    assert response.status_code == 403
    assert response.get_json() == {
        "error": "Parent access required"
    }


@pytest.mark.parametrize(
    "payload",
    [
        {"lang": "fr"},
        {"lang": ""},
        {"lang": None},
    ],
)
def test_route_rejects_invalid_request_model(
    client,
    payload,
):
    parent = register_parent(client)

    response = get_reward_suggestions(
        client,
        parent["access_token"],
        payload,
    )

    assert response.status_code == 400


def test_route_uses_default_language_and_count(
    client,
    monkeypatch,
):
    parent = register_parent(client)
    captured = {}

    def fake_get_random_suggestions(
        lang,
        count,
    ):
        captured["lang"] = lang
        captured["count"] = count
        return [], None

    monkeypatch.setattr(
        reward_bank_routes.reward_bank_service,
        "get_random_suggestions",
        fake_get_random_suggestions,
    )

    response = get_reward_suggestions(
        client,
        parent["access_token"],
        {},
    )

    assert response.status_code == 200
    assert captured == {
        "lang": "en",
        "count": 5,
    }


def test_route_passes_language_to_service(
    client,
    monkeypatch,
):
    parent = register_parent(
        client,
        email="reward.bank.arabic@gmail.com",
        phone="0557910002",
    )
    captured = {}

    def fake_get_random_suggestions(
        lang,
        count,
    ):
        captured["lang"] = lang
        captured["count"] = count
        return [], None

    monkeypatch.setattr(
        reward_bank_routes.reward_bank_service,
        "get_random_suggestions",
        fake_get_random_suggestions,
    )

    response = get_reward_suggestions(
        client,
        parent["access_token"],
        {"lang": "ar"},
    )

    assert response.status_code == 200
    assert captured == {
        "lang": "ar",
        "count": 5,
    }


def test_route_passes_count_when_present(
    client,
    monkeypatch,
):
    parent = register_parent(
        client,
        email="reward.bank.count@gmail.com",
        phone="0557910003",
    )
    captured = {}

    def fake_get_random_suggestions(
        lang,
        count,
    ):
        captured["lang"] = lang
        captured["count"] = count
        return [], None

    monkeypatch.setattr(
        reward_bank_routes.reward_bank_service,
        "get_random_suggestions",
        fake_get_random_suggestions,
    )

    response = get_reward_suggestions(
        client,
        parent["access_token"],
        {
            "lang": "en",
            "count": 3,
        },
    )

    assert response.status_code == 200
    assert captured == {
        "lang": "en",
        "count": 3,
    }


def test_route_maps_invalid_language_to_400(
    client,
    monkeypatch,
):
    parent = register_parent(
        client,
        email="reward.bank.invalid.language@gmail.com",
        phone="0557910004",
    )

    monkeypatch.setattr(
        reward_bank_routes.reward_bank_service,
        "get_random_suggestions",
        lambda lang, count: (
            None,
            "invalid_language",
        ),
    )

    response = get_reward_suggestions(
        client,
        parent["access_token"],
        {"lang": "en"},
    )

    assert response.status_code == 400
    assert response.get_json() == {
        "error": "Invalid language"
    }


def test_route_maps_invalid_count_to_400(
    client,
    monkeypatch,
):
    parent = register_parent(
        client,
        email="reward.bank.invalid.count@gmail.com",
        phone="0557910005",
    )

    monkeypatch.setattr(
        reward_bank_routes.reward_bank_service,
        "get_random_suggestions",
        lambda lang, count: (
            None,
            "invalid_count",
        ),
    )

    response = get_reward_suggestions(
        client,
        parent["access_token"],
        {"lang": "en"},
    )

    assert response.status_code == 400
    assert response.get_json() == {
        "error": "Count must be greater than zero"
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
        email=f"reward.bank.{service_error}@gmail.com",
        phone="0557910006",
    )

    monkeypatch.setattr(
        reward_bank_routes.reward_bank_service,
        "get_random_suggestions",
        lambda lang, count: (
            None,
            service_error,
        ),
    )

    response = get_reward_suggestions(
        client,
        parent["access_token"],
        {"lang": "en"},
    )

    assert response.status_code == 500
    assert response.get_json() == {
        "error": (
            "Failed to retrieve reward suggestions"
        )
    }


def test_route_returns_suggestions_wrapped_in_object(
    client,
    monkeypatch,
):
    parent = register_parent(
        client,
        email="reward.bank.success@gmail.com",
        phone="0557910007",
    )

    suggestions = [
        {
            "reward_name": "Movie night",
            "description": "Choose a family movie",
            "unlock_day": 4,
        }
    ]

    monkeypatch.setattr(
        reward_bank_routes.reward_bank_service,
        "get_random_suggestions",
        lambda lang, count: (
            suggestions,
            None,
        ),
    )

    response = get_reward_suggestions(
        client,
        parent["access_token"],
        {"lang": "en"},
    )

    assert response.status_code == 200
    assert response.get_json() == {
        "suggestions": suggestions
    }


def test_route_does_not_call_service_for_child(
    client,
    monkeypatch,
):
    parent = register_parent(
        client,
        email="reward.bank.child.blocked@gmail.com",
        phone="0557910008",
    )
    child = create_child(
        client,
        parent["access_token"],
        phone="0557910098",
    )
    child_login = login_child(
        client,
        child["access_code"],
    )
    calls = {"count": 0}

    def fake_get_random_suggestions(
        lang,
        count,
    ):
        calls["count"] += 1
        return [], None

    monkeypatch.setattr(
        reward_bank_routes.reward_bank_service,
        "get_random_suggestions",
        fake_get_random_suggestions,
    )

    response = get_reward_suggestions(
        client,
        child_login["access_token"],
        {"lang": "en"},
    )

    assert response.status_code == 403
    assert calls["count"] == 0


# ===========================================================================
# Service tests
# ===========================================================================

def make_reward(
    *,
    reward_name_en="Movie night",
    reward_name_ar="ليلة فيلم",
    description_en="Choose a family movie",
    description_ar="اختر فيلمًا عائليًا",
    default_unlock_day=4,
):
    return {
        "reward_name_en": reward_name_en,
        "reward_name_ar": reward_name_ar,
        "description_en": description_en,
        "description_ar": description_ar,
        "default_unlock_day": default_unlock_day,
    }


@pytest.mark.parametrize(
    "language",
    [
        "fr",
        "es",
        "",
        "arabic",
    ],
)
def test_service_rejects_invalid_language(
    monkeypatch,
    language,
):
    service = reward_bank_routes.reward_bank_service

    monkeypatch.setattr(
        service_module,
        "REWARD_SUGGESTIONS",
        [],
    )

    result = service.get_random_suggestions(
        lang=language,
        count=5,
    )

    assert result == (
        None,
        "invalid_language",
    )


@pytest.mark.parametrize(
    "language",
    [
        "EN",
        "En",
        "AR",
        "Ar",
    ],
)
def test_service_language_is_case_insensitive(
    monkeypatch,
    language,
):
    service = reward_bank_routes.reward_bank_service
    reward = make_reward()

    monkeypatch.setattr(
        service_module,
        "REWARD_SUGGESTIONS",
        [reward],
    )
    monkeypatch.setattr(
        service_module.random,
        "sample",
        lambda population, count: population[:count],
    )

    suggestions, error = (
        service.get_random_suggestions(
            lang=language,
            count=1,
        )
    )

    assert error is None
    assert len(suggestions) == 1


@pytest.mark.parametrize(
    "count",
    [0, -1, -10],
)
def test_service_rejects_non_positive_count(
    monkeypatch,
    count,
):
    service = reward_bank_routes.reward_bank_service

    monkeypatch.setattr(
        service_module,
        "REWARD_SUGGESTIONS",
        [],
    )

    result = service.get_random_suggestions(
        lang="en",
        count=count,
    )

    assert result == (
        None,
        "invalid_count",
    )


def test_service_samples_requested_count(
    monkeypatch,
):
    service = reward_bank_routes.reward_bank_service
    rewards = [
        make_reward(reward_name_en="Reward 1"),
        make_reward(reward_name_en="Reward 2"),
        make_reward(reward_name_en="Reward 3"),
    ]
    captured = {}

    monkeypatch.setattr(
        service_module,
        "REWARD_SUGGESTIONS",
        rewards,
    )

    def fake_sample(population, count):
        captured["population"] = population
        captured["count"] = count
        return population[:count]

    monkeypatch.setattr(
        service_module.random,
        "sample",
        fake_sample,
    )

    suggestions, error = (
        service.get_random_suggestions(
            lang="en",
            count=2,
        )
    )

    assert error is None
    assert captured["population"] is rewards
    assert captured["count"] == 2
    assert len(suggestions) == 2


def test_service_samples_at_most_available_rewards(
    monkeypatch,
):
    service = reward_bank_routes.reward_bank_service
    rewards = [
        make_reward(reward_name_en="Reward 1"),
        make_reward(reward_name_en="Reward 2"),
    ]
    captured = {}

    monkeypatch.setattr(
        service_module,
        "REWARD_SUGGESTIONS",
        rewards,
    )

    def fake_sample(population, count):
        captured["count"] = count
        return population[:count]

    monkeypatch.setattr(
        service_module.random,
        "sample",
        fake_sample,
    )

    suggestions, error = (
        service.get_random_suggestions(
            lang="en",
            count=5,
        )
    )

    assert error is None
    assert captured["count"] == 2
    assert len(suggestions) == 2


def test_service_builds_english_reward_suggestion(
    monkeypatch,
):
    service = reward_bank_routes.reward_bank_service
    reward = make_reward(
        reward_name_en="Movie night",
        reward_name_ar="ليلة فيلم",
        description_en="Choose a family movie",
        description_ar="اختر فيلمًا عائليًا",
        default_unlock_day=4,
    )

    monkeypatch.setattr(
        service_module,
        "REWARD_SUGGESTIONS",
        [reward],
    )
    monkeypatch.setattr(
        service_module.random,
        "sample",
        lambda population, count: population[:count],
    )

    suggestions, error = (
        service.get_random_suggestions(
            lang="en",
            count=1,
        )
    )

    assert error is None
    assert suggestions == [
        {
            "reward_name": "Movie night",
            "description": "Choose a family movie",
            "unlock_day": 4,
        }
    ]


def test_service_builds_arabic_reward_suggestion(
    monkeypatch,
):
    service = reward_bank_routes.reward_bank_service
    reward = make_reward(
        reward_name_en="Movie night",
        reward_name_ar="ليلة فيلم",
        description_en="Choose a family movie",
        description_ar="اختر فيلمًا عائليًا",
        default_unlock_day=6,
    )

    monkeypatch.setattr(
        service_module,
        "REWARD_SUGGESTIONS",
        [reward],
    )
    monkeypatch.setattr(
        service_module.random,
        "sample",
        lambda population, count: population[:count],
    )

    suggestions, error = (
        service.get_random_suggestions(
            lang="ar",
            count=1,
        )
    )

    assert error is None
    assert suggestions == [
        {
            "reward_name": "ليلة فيلم",
            "description": "اختر فيلمًا عائليًا",
            "unlock_day": 6,
        }
    ]


def test_service_returns_empty_list_when_bank_is_empty(
    monkeypatch,
):
    service = reward_bank_routes.reward_bank_service
    captured = {}

    monkeypatch.setattr(
        service_module,
        "REWARD_SUGGESTIONS",
        [],
    )

    def fake_sample(population, count):
        captured["population"] = population
        captured["count"] = count
        return []

    monkeypatch.setattr(
        service_module.random,
        "sample",
        fake_sample,
    )

    suggestions, error = (
        service.get_random_suggestions(
            lang="en",
            count=5,
        )
    )

    assert error is None
    assert suggestions == []
    assert captured["population"] == []
    assert captured["count"] == 0