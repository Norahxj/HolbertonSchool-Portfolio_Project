import pytest
from flask_jwt_extended import decode_token

from app.routes import task_bank_routes
import app.services.task_bank_service as service_module


REGISTER_URL = "/api/auth/register"
CHILDREN_URL = "/api/children/"
CHILD_LOGIN_URL = "/api/auth/child-login"
SUGGESTIONS_URL = "/api/task-bank/suggestions"


def auth_header(token):
    return {"Authorization": token}


def register_parent(
    client,
    email="task.bank.suggestions.parent@gmail.com",
    phone="0557990001",
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
    phone="0557990099",
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


def get_suggestions(
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
# Route tests
# ===========================================================================

def test_route_requires_access_token(client):
    response = client.post(
        SUGGESTIONS_URL,
        json={
            "child_ids": ["child-id"],
            "category": "FINANCIAL",
            "lang": "en",
        },
    )

    assert response.status_code == 401


def test_child_cannot_get_suggestions(client):
    parent = register_parent(client)
    child = create_child(
        client,
        parent["access_token"],
    )
    child_login = login_child(
        client,
        child["access_code"],
    )

    response = get_suggestions(
        client,
        child_login["access_token"],
        {
            "child_ids": [child["id"]],
            "category": "FINANCIAL",
            "lang": "en",
        },
    )

    assert response.status_code == 403
    assert response.get_json() == {
        "error": "Parent access required"
    }


def test_route_requires_child_ids(
    client,
):
    parent = register_parent(client)

    response = get_suggestions(
        client,
        parent["access_token"],
        {
            "child_ids": [],
            "category": "FINANCIAL",
            "lang": "en",
        },
    )

    assert response.status_code == 400
    assert response.get_json() == {
        "error": "child_ids is required"
    }


def test_route_rejects_duplicate_child_ids(
    client,
):
    parent = register_parent(client)

    response = get_suggestions(
        client,
        parent["access_token"],
        {
            "child_ids": [
                "child-123",
                "child-123",
            ],
            "category": "FINANCIAL",
            "lang": "en",
        },
    )

    assert response.status_code == 400
    assert response.get_json() == {
        "error": (
            "Duplicate child IDs are not allowed"
        )
    }


@pytest.mark.parametrize(
    "payload",
    [
        {},
        {"category": "FINANCIAL"},
        {"child_ids": ["child-id"]},
        {
            "child_ids": ["child-id"],
            "category": "INVALID",
        },
        {
            "child_ids": ["child-id"],
            "category": "FINANCIAL",
            "lang": "fr",
        },
    ],
)
def test_route_rejects_invalid_request_model(
    client,
    payload,
):
    parent = register_parent(client)

    response = get_suggestions(
        client,
        parent["access_token"],
        payload,
    )

    assert response.status_code == 400


def test_route_passes_expected_values_to_service(
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

    captured = {}

    def fake_get_random_suggestions(
        parent_id,
        child_ids,
        category,
        lang,
        count,
    ):
        captured["parent_id"] = parent_id
        captured["child_ids"] = child_ids
        captured["category"] = category
        captured["lang"] = lang
        captured["count"] = count
        return [], None

    monkeypatch.setattr(
        task_bank_routes.task_bank_service,
        "get_random_suggestions",
        fake_get_random_suggestions,
    )

    response = get_suggestions(
        client,
        parent["access_token"],
        {
            "child_ids": [child["id"]],
            "category": "MORAL",
            "lang": "ar",
        },
    )

    assert response.status_code == 200
    assert captured == {
        "parent_id": expected_parent_id,
        "child_ids": [child["id"]],
        "category": "MORAL",
        "lang": "ar",
        "count": 5,
    }


def test_route_uses_english_as_default_language(
    client,
    monkeypatch,
):
    parent = register_parent(
        client,
        email="task.bank.default.lang@gmail.com",
        phone="0557990002",
    )
    captured = {}

    def fake_get_random_suggestions(
        parent_id,
        child_ids,
        category,
        lang,
        count,
    ):
        captured["lang"] = lang
        return [], None

    monkeypatch.setattr(
        task_bank_routes.task_bank_service,
        "get_random_suggestions",
        fake_get_random_suggestions,
    )

    response = get_suggestions(
        client,
        parent["access_token"],
        {
            "child_ids": ["child-id"],
            "category": "SOCIAL",
        },
    )

    assert response.status_code == 200
    assert captured["lang"] == "en"


@pytest.mark.parametrize(
    ("service_error", "expected_message"),
    [
        ("invalid_category", "Invalid category"),
        ("invalid_language", "Invalid language"),
    ],
)
def test_route_maps_validation_service_errors_to_400(
    client,
    monkeypatch,
    service_error,
    expected_message,
):
    parent = register_parent(
        client,
        email=(
            f"task.bank.{service_error}"
            "@gmail.com"
        ),
        phone="0557990003",
    )

    monkeypatch.setattr(
        task_bank_routes.task_bank_service,
        "get_random_suggestions",
        lambda **kwargs: (
            None,
            service_error,
        ),
    )

    response = get_suggestions(
        client,
        parent["access_token"],
        {
            "child_ids": ["child-id"],
            "category": "FINANCIAL",
            "lang": "en",
        },
    )

    assert response.status_code == 400
    assert response.get_json() == {
        "error": expected_message
    }


def test_route_maps_child_not_found_to_404(
    client,
    monkeypatch,
):
    parent = register_parent(
        client,
        email="task.bank.child.missing@gmail.com",
        phone="0557990004",
    )

    monkeypatch.setattr(
        task_bank_routes.task_bank_service,
        "get_random_suggestions",
        lambda **kwargs: (
            None,
            "child_not_found",
        ),
    )

    response = get_suggestions(
        client,
        parent["access_token"],
        {
            "child_ids": ["missing-child"],
            "category": "FINANCIAL",
            "lang": "en",
        },
    )

    assert response.status_code == 404
    assert response.get_json() == {
        "error": "Child not found"
    }


@pytest.mark.parametrize(
    "service_error",
    [
        "child_ids_required",
        "duplicate_child_ids",
        "invalid_count",
        "unexpected_error",
    ],
)
def test_route_maps_unhandled_service_errors_to_500(
    client,
    monkeypatch,
    service_error,
):
    parent = register_parent(
        client,
        email=(
            f"task.bank.unhandled.{service_error}"
            "@gmail.com"
        ),
        phone="0557990005",
    )

    monkeypatch.setattr(
        task_bank_routes.task_bank_service,
        "get_random_suggestions",
        lambda **kwargs: (
            None,
            service_error,
        ),
    )

    response = get_suggestions(
        client,
        parent["access_token"],
        {
            "child_ids": ["child-id"],
            "category": "FINANCIAL",
            "lang": "en",
        },
    )

    assert response.status_code == 500
    assert response.get_json() == {
        "error": (
            "Failed to retrieve task suggestions"
        )
    }


def test_route_returns_suggestions_wrapped_in_object(
    client,
    monkeypatch,
):
    parent = register_parent(
        client,
        email="task.bank.suggestions.success@gmail.com",
        phone="0557990006",
    )

    suggestions = [
        {
            "title": "Save money",
            "description": "Save part of your allowance",
            "points": 10,
            "category": "FINANCIAL",
            "task_frequency": "WEEKLY",
            "recurrence_day": 4,
            "is_auto_verified": False,
        }
    ]

    monkeypatch.setattr(
        task_bank_routes.task_bank_service,
        "get_random_suggestions",
        lambda **kwargs: (
            suggestions,
            None,
        ),
    )

    response = get_suggestions(
        client,
        parent["access_token"],
        {
            "child_ids": ["child-id"],
            "category": "FINANCIAL",
            "lang": "en",
        },
    )

    assert response.status_code == 200
    assert response.get_json() == {
        "suggestions": suggestions
    }


def test_route_does_not_call_service_when_child_ids_duplicate(
    client,
    monkeypatch,
):
    parent = register_parent(
        client,
        email="task.bank.no.service.duplicate@gmail.com",
        phone="0557990007",
    )
    calls = {"count": 0}

    def fake_get_random_suggestions(**kwargs):
        calls["count"] += 1
        return [], None

    monkeypatch.setattr(
        task_bank_routes.task_bank_service,
        "get_random_suggestions",
        fake_get_random_suggestions,
    )

    response = get_suggestions(
        client,
        parent["access_token"],
        {
            "child_ids": ["same-id", "same-id"],
            "category": "MORAL",
            "lang": "ar",
        },
    )

    assert response.status_code == 400
    assert calls["count"] == 0


# ===========================================================================
# Service tests
# ===========================================================================

class FakeChild:
    def __init__(self, age):
        self.age = age


def make_task(
    *,
    title_en="English title",
    title_ar="عنوان عربي",
    description_en="English description",
    description_ar="وصف عربي",
    default_points=10,
    age_min=6,
    age_max=18,
    suggested_frequency=None,
):
    task = {
        "title_en": title_en,
        "title_ar": title_ar,
        "description_en": description_en,
        "description_ar": description_ar,
        "default_points": default_points,
        "age_min": age_min,
        "age_max": age_max,
    }

    if suggested_frequency is not None:
        task["suggested_frequency"] = (
            suggested_frequency
        )

    return task


def test_service_rejects_invalid_category(
    monkeypatch,
):
    service = task_bank_routes.task_bank_service

    monkeypatch.setattr(
        service_module,
        "TASK_BANK",
        {"FINANCIAL": []},
    )

    result = service.get_random_suggestions(
        parent_id="parent-id",
        child_ids=["child-id"],
        category="INVALID",
        lang="en",
        count=5,
    )

    assert result == (
        None,
        "invalid_category",
    )


def test_service_category_is_case_insensitive(
    monkeypatch,
):
    service = task_bank_routes.task_bank_service

    monkeypatch.setattr(
        service_module,
        "TASK_BANK",
        {"FINANCIAL": []},
    )
    monkeypatch.setattr(
        service.child_repository,
        "get_child_for_guardian",
        lambda child_id, parent_id: FakeChild(10),
    )

    suggestions, error = (
        service.get_random_suggestions(
            parent_id="parent-id",
            child_ids=["child-id"],
            category="financial",
            lang="en",
            count=5,
        )
    )

    assert error is None
    assert suggestions == []


def test_service_rejects_missing_child_ids(
    monkeypatch,
):
    service = task_bank_routes.task_bank_service

    monkeypatch.setattr(
        service_module,
        "TASK_BANK",
        {"FINANCIAL": []},
    )

    result = service.get_random_suggestions(
        parent_id="parent-id",
        child_ids=[],
        category="FINANCIAL",
        lang="en",
        count=5,
    )

    assert result == (
        None,
        "child_ids_required",
    )


def test_service_rejects_duplicate_child_ids(
    monkeypatch,
):
    service = task_bank_routes.task_bank_service

    monkeypatch.setattr(
        service_module,
        "TASK_BANK",
        {"FINANCIAL": []},
    )

    result = service.get_random_suggestions(
        parent_id="parent-id",
        child_ids=["child-id", "child-id"],
        category="FINANCIAL",
        lang="en",
        count=5,
    )

    assert result == (
        None,
        "duplicate_child_ids",
    )


@pytest.mark.parametrize("count", [0, -1, -10])
def test_service_rejects_non_positive_count(
    monkeypatch,
    count,
):
    service = task_bank_routes.task_bank_service

    monkeypatch.setattr(
        service_module,
        "TASK_BANK",
        {"FINANCIAL": []},
    )

    result = service.get_random_suggestions(
        parent_id="parent-id",
        child_ids=["child-id"],
        category="FINANCIAL",
        lang="en",
        count=count,
    )

    assert result == (
        None,
        "invalid_count",
    )


@pytest.mark.parametrize(
    "language",
    ["fr", "es", "", "arabic"],
)
def test_service_rejects_invalid_language(
    monkeypatch,
    language,
):
    service = task_bank_routes.task_bank_service

    monkeypatch.setattr(
        service_module,
        "TASK_BANK",
        {"FINANCIAL": []},
    )

    result = service.get_random_suggestions(
        parent_id="parent-id",
        child_ids=["child-id"],
        category="FINANCIAL",
        lang=language,
        count=5,
    )

    assert result == (
        None,
        "invalid_language",
    )


def test_service_language_is_case_insensitive(
    monkeypatch,
):
    service = task_bank_routes.task_bank_service
    task = make_task()

    monkeypatch.setattr(
        service_module,
        "TASK_BANK",
        {"FINANCIAL": [task]},
    )
    monkeypatch.setattr(
        service.child_repository,
        "get_child_for_guardian",
        lambda child_id, parent_id: FakeChild(10),
    )
    monkeypatch.setattr(
        service_module.random,
        "sample",
        lambda population, count: population[:count],
    )
    monkeypatch.setattr(
        service,
        "_default_recurrence_day",
        lambda frequency: None,
    )

    suggestions, error = (
        service.get_random_suggestions(
            parent_id="parent-id",
            child_ids=["child-id"],
            category="FINANCIAL",
            lang="EN",
            count=5,
        )
    )

    assert error is None
    assert suggestions[0]["title"] == "English title"


def test_service_checks_every_child_for_guardian(
    monkeypatch,
):
    service = task_bank_routes.task_bank_service
    captured = []

    monkeypatch.setattr(
        service_module,
        "TASK_BANK",
        {"SOCIAL": []},
    )

    def fake_get_child_for_guardian(
        child_id,
        parent_id,
    ):
        captured.append((child_id, parent_id))
        return FakeChild(10)

    monkeypatch.setattr(
        service.child_repository,
        "get_child_for_guardian",
        fake_get_child_for_guardian,
    )

    suggestions, error = (
        service.get_random_suggestions(
            parent_id="parent-123",
            child_ids=["child-1", "child-2"],
            category="SOCIAL",
            lang="en",
            count=5,
        )
    )

    assert error is None
    assert suggestions == []
    assert captured == [
        ("child-1", "parent-123"),
        ("child-2", "parent-123"),
    ]


def test_service_returns_child_not_found_when_any_child_is_missing(
    monkeypatch,
):
    service = task_bank_routes.task_bank_service

    monkeypatch.setattr(
        service_module,
        "TASK_BANK",
        {"SOCIAL": []},
    )

    children = {
        "child-1": FakeChild(10),
        "child-2": None,
    }

    monkeypatch.setattr(
        service.child_repository,
        "get_child_for_guardian",
        lambda child_id, parent_id: (
            children[child_id]
        ),
    )

    result = service.get_random_suggestions(
        parent_id="parent-123",
        child_ids=["child-1", "child-2"],
        category="SOCIAL",
        lang="en",
        count=5,
    )

    assert result == (
        None,
        "child_not_found",
    )


def test_service_filters_tasks_for_all_children_age_range(
    monkeypatch,
):
    service = task_bank_routes.task_bank_service

    suitable = make_task(
        title_en="Suitable",
        age_min=6,
        age_max=18,
    )
    too_old_for_youngest = make_task(
        title_en="Too old",
        age_min=11,
        age_max=18,
    )
    too_young_for_oldest = make_task(
        title_en="Too young",
        age_min=6,
        age_max=13,
    )

    monkeypatch.setattr(
        service_module,
        "TASK_BANK",
        {
            "MORAL": [
                suitable,
                too_old_for_youngest,
                too_young_for_oldest,
            ]
        },
    )

    children = {
        "child-1": FakeChild(10),
        "child-2": FakeChild(14),
    }

    monkeypatch.setattr(
        service.child_repository,
        "get_child_for_guardian",
        lambda child_id, parent_id: (
            children[child_id]
        ),
    )

    captured = {}

    def fake_sample(population, count):
        captured["population"] = population
        captured["count"] = count
        return population[:count]

    monkeypatch.setattr(
        service_module.random,
        "sample",
        fake_sample,
    )
    monkeypatch.setattr(
        service,
        "_default_recurrence_day",
        lambda frequency: None,
    )

    suggestions, error = (
        service.get_random_suggestions(
            parent_id="parent-id",
            child_ids=["child-1", "child-2"],
            category="MORAL",
            lang="en",
            count=5,
        )
    )

    assert error is None
    assert captured["population"] == [suitable]
    assert captured["count"] == 1
    assert len(suggestions) == 1
    assert suggestions[0]["title"] == "Suitable"


def test_service_samples_at_most_available_tasks(
    monkeypatch,
):
    service = task_bank_routes.task_bank_service

    tasks = [
        make_task(title_en="Task 1"),
        make_task(title_en="Task 2"),
    ]

    monkeypatch.setattr(
        service_module,
        "TASK_BANK",
        {"RELIGIOUS": tasks},
    )
    monkeypatch.setattr(
        service.child_repository,
        "get_child_for_guardian",
        lambda child_id, parent_id: FakeChild(10),
    )

    captured = {}

    def fake_sample(population, count):
        captured["count"] = count
        return population[:count]

    monkeypatch.setattr(
        service_module.random,
        "sample",
        fake_sample,
    )
    monkeypatch.setattr(
        service,
        "_default_recurrence_day",
        lambda frequency: None,
    )

    suggestions, error = (
        service.get_random_suggestions(
            parent_id="parent-id",
            child_ids=["child-id"],
            category="RELIGIOUS",
            lang="en",
            count=5,
        )
    )

    assert error is None
    assert captured["count"] == 2
    assert len(suggestions) == 2


def test_service_builds_english_suggestion(
    monkeypatch,
):
    service = task_bank_routes.task_bank_service
    task = make_task(
        title_en="English title",
        title_ar="عنوان",
        description_en="English description",
        description_ar="وصف",
        default_points=25,
        suggested_frequency="WEEKLY",
    )

    monkeypatch.setattr(
        service_module,
        "TASK_BANK",
        {"FINANCIAL": [task]},
    )
    monkeypatch.setattr(
        service.child_repository,
        "get_child_for_guardian",
        lambda child_id, parent_id: FakeChild(12),
    )
    monkeypatch.setattr(
        service_module.random,
        "sample",
        lambda population, count: population[:count],
    )
    monkeypatch.setattr(
        service,
        "_default_recurrence_day",
        lambda frequency: 4,
    )

    suggestions, error = (
        service.get_random_suggestions(
            parent_id="parent-id",
            child_ids=["child-id"],
            category="financial",
            lang="en",
            count=5,
        )
    )

    assert error is None
    assert suggestions == [
        {
            "title": "English title",
            "description": "English description",
            "points": 25,
            "category": "FINANCIAL",
            "task_frequency": "WEEKLY",
            "recurrence_day": 4,
            "is_auto_verified": False,
        }
    ]


def test_service_builds_arabic_suggestion(
    monkeypatch,
):
    service = task_bank_routes.task_bank_service
    task = make_task(
        title_en="English title",
        title_ar="عنوان عربي",
        description_en="English description",
        description_ar="وصف عربي",
        default_points=15,
        suggested_frequency="MONTHLY",
    )

    monkeypatch.setattr(
        service_module,
        "TASK_BANK",
        {"SOCIAL": [task]},
    )
    monkeypatch.setattr(
        service.child_repository,
        "get_child_for_guardian",
        lambda child_id, parent_id: FakeChild(12),
    )
    monkeypatch.setattr(
        service_module.random,
        "sample",
        lambda population, count: population[:count],
    )
    monkeypatch.setattr(
        service,
        "_default_recurrence_day",
        lambda frequency: 1,
    )

    suggestions, error = (
        service.get_random_suggestions(
            parent_id="parent-id",
            child_ids=["child-id"],
            category="SOCIAL",
            lang="ar",
            count=5,
        )
    )

    assert error is None
    assert suggestions == [
        {
            "title": "عنوان عربي",
            "description": "وصف عربي",
            "points": 15,
            "category": "SOCIAL",
            "task_frequency": "MONTHLY",
            "recurrence_day": 1,
            "is_auto_verified": False,
        }
    ]


def test_service_uses_once_when_frequency_missing(
    monkeypatch,
):
    service = task_bank_routes.task_bank_service
    task = make_task(
        suggested_frequency=None,
    )
    captured = {}

    monkeypatch.setattr(
        service_module,
        "TASK_BANK",
        {"MORAL": [task]},
    )
    monkeypatch.setattr(
        service.child_repository,
        "get_child_for_guardian",
        lambda child_id, parent_id: FakeChild(10),
    )
    monkeypatch.setattr(
        service_module.random,
        "sample",
        lambda population, count: population[:count],
    )

    def fake_default_recurrence_day(frequency):
        captured["frequency"] = frequency
        return None

    monkeypatch.setattr(
        service,
        "_default_recurrence_day",
        fake_default_recurrence_day,
    )

    suggestions, error = (
        service.get_random_suggestions(
            parent_id="parent-id",
            child_ids=["child-id"],
            category="MORAL",
            lang="en",
            count=1,
        )
    )

    assert error is None
    assert captured["frequency"] == "ONCE"
    assert (
        suggestions[0]["task_frequency"]
        == "ONCE"
    )
    assert suggestions[0]["recurrence_day"] is None


def test_service_returns_empty_list_when_no_tasks_are_suitable(
    monkeypatch,
):
    service = task_bank_routes.task_bank_service

    monkeypatch.setattr(
        service_module,
        "TASK_BANK",
        {
            "FINANCIAL": [
                make_task(
                    age_min=15,
                    age_max=18,
                )
            ]
        },
    )
    monkeypatch.setattr(
        service.child_repository,
        "get_child_for_guardian",
        lambda child_id, parent_id: FakeChild(10),
    )

    captured = {}

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
            parent_id="parent-id",
            child_ids=["child-id"],
            category="FINANCIAL",
            lang="en",
            count=5,
        )
    )

    assert error is None
    assert suggestions == []
    assert captured["population"] == []
    assert captured["count"] == 0