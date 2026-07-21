from flask_jwt_extended import decode_token

from app.routes import task_bank_routes
import app.services.task_bank_service as service_module


REGISTER_URL = "/api/auth/register"
CHILDREN_URL = "/api/children/"
CHILD_LOGIN_URL = "/api/auth/child-login"
CATEGORIES_URL = "/api/task-bank/categories"


def auth_header(token):
    return {"Authorization": token}


def register_parent(
    client,
    email="task.bank.categories.parent@gmail.com",
    phone="0557980001",
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
    phone="0557980099",
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


def get_categories(client, token):
    return client.get(
        CATEGORIES_URL,
        headers=auth_header(token),
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
            task_bank_routes,
            "get_jwt",
            lambda: {"role": "parent"},
        )

        result = task_bank_routes.require_parent()

    assert result is None


def test_require_parent_returns_403_for_child(
    app,
    monkeypatch,
):
    with app.test_request_context():
        monkeypatch.setattr(
            task_bank_routes,
            "get_jwt",
            lambda: {"role": "child"},
        )

        result = task_bank_routes.require_parent()

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
            task_bank_routes,
            "get_jwt",
            lambda: {},
        )

        result = task_bank_routes.require_parent()

    assert result == (
        {"error": "Parent access required"},
        403,
    )


# ===========================================================================
# Route tests
# ===========================================================================

def test_route_requires_access_token(client):
    response = client.get(CATEGORIES_URL)

    assert response.status_code == 401


def test_route_rejects_invalid_access_token(client):
    response = client.get(
        CATEGORIES_URL,
        headers=auth_header("invalid-token"),
    )

    assert response.status_code in (401, 422)


def test_child_cannot_get_categories(client):
    parent = register_parent(client)
    child = create_child(
        client,
        parent["access_token"],
    )
    child_login = login_child(
        client,
        child["access_code"],
    )

    response = get_categories(
        client,
        child_login["access_token"],
    )

    assert response.status_code == 403
    assert response.get_json() == {
        "error": "Parent access required"
    }


def test_parent_can_get_categories(
    client,
    monkeypatch,
):
    parent = register_parent(client)

    expected_categories = [
        "FINANCIAL",
        "SOCIAL",
        "MORAL",
        "RELIGIOUS",
    ]

    monkeypatch.setattr(
        task_bank_routes.task_bank_service,
        "get_categories",
        lambda: expected_categories,
    )

    response = get_categories(
        client,
        parent["access_token"],
    )

    assert response.status_code == 200
    assert response.get_json() == {
        "categories": expected_categories
    }


def test_route_calls_service_once(
    client,
    monkeypatch,
):
    parent = register_parent(
        client,
        email="task.bank.categories.calls@gmail.com",
        phone="0557980002",
    )
    calls = {"count": 0}

    def fake_get_categories():
        calls["count"] += 1
        return ["FINANCIAL"]

    monkeypatch.setattr(
        task_bank_routes.task_bank_service,
        "get_categories",
        fake_get_categories,
    )

    response = get_categories(
        client,
        parent["access_token"],
    )

    assert response.status_code == 200
    assert calls["count"] == 1
    assert response.get_json() == {
        "categories": ["FINANCIAL"]
    }


def test_route_does_not_call_service_for_child(
    client,
    monkeypatch,
):
    parent = register_parent(
        client,
        email="task.bank.categories.child@gmail.com",
        phone="0557980003",
    )
    child = create_child(
        client,
        parent["access_token"],
        phone="0557980098",
    )
    child_login = login_child(
        client,
        child["access_code"],
    )
    calls = {"count": 0}

    def fake_get_categories():
        calls["count"] += 1
        return []

    monkeypatch.setattr(
        task_bank_routes.task_bank_service,
        "get_categories",
        fake_get_categories,
    )

    response = get_categories(
        client,
        child_login["access_token"],
    )

    assert response.status_code == 403
    assert calls["count"] == 0


def test_route_wraps_empty_categories_in_object(
    client,
    monkeypatch,
):
    parent = register_parent(
        client,
        email="task.bank.categories.empty@gmail.com",
        phone="0557980004",
    )

    monkeypatch.setattr(
        task_bank_routes.task_bank_service,
        "get_categories",
        lambda: [],
    )

    response = get_categories(
        client,
        parent["access_token"],
    )

    assert response.status_code == 200
    assert response.get_json() == {
        "categories": []
    }


def test_route_does_not_use_parent_identity(
    client,
    app,
    monkeypatch,
):
    parent = register_parent(
        client,
        email="task.bank.categories.identity@gmail.com",
        phone="0557980005",
    )

    with app.app_context():
        parent_id = decode_token(
            parent["access_token"]
        )["sub"]

    captured = {"identity_called": False}

    def fake_get_jwt_identity():
        captured["identity_called"] = True
        return parent_id

    monkeypatch.setattr(
        task_bank_routes,
        "get_jwt_identity",
        fake_get_jwt_identity,
    )
    monkeypatch.setattr(
        task_bank_routes.task_bank_service,
        "get_categories",
        lambda: ["FINANCIAL"],
    )

    response = get_categories(
        client,
        parent["access_token"],
    )

    assert response.status_code == 200
    assert captured["identity_called"] is False


# ===========================================================================
# Service tests
# ===========================================================================

def test_service_returns_task_bank_keys_in_order(
    monkeypatch,
):
    service = task_bank_routes.task_bank_service

    fake_task_bank = {
        "FINANCIAL": ["Task 1"],
        "SOCIAL": ["Task 2"],
        "MORAL": ["Task 3"],
        "RELIGIOUS": ["Task 4"],
    }

    monkeypatch.setattr(
        service_module,
        "TASK_BANK",
        fake_task_bank,
    )

    result = service.get_categories()

    assert result == [
        "FINANCIAL",
        "SOCIAL",
        "MORAL",
        "RELIGIOUS",
    ]


def test_service_returns_list_not_dict_keys_view(
    monkeypatch,
):
    service = task_bank_routes.task_bank_service

    monkeypatch.setattr(
        service_module,
        "TASK_BANK",
        {
            "FINANCIAL": [],
            "SOCIAL": [],
        },
    )

    result = service.get_categories()

    assert isinstance(result, list)
    assert result == [
        "FINANCIAL",
        "SOCIAL",
    ]


def test_service_returns_empty_list_for_empty_task_bank(
    monkeypatch,
):
    service = task_bank_routes.task_bank_service

    monkeypatch.setattr(
        service_module,
        "TASK_BANK",
        {},
    )

    result = service.get_categories()

    assert result == []


def test_service_returns_new_list_each_time(
    monkeypatch,
):
    service = task_bank_routes.task_bank_service

    monkeypatch.setattr(
        service_module,
        "TASK_BANK",
        {
            "FINANCIAL": [],
            "SOCIAL": [],
        },
    )

    first_result = service.get_categories()
    second_result = service.get_categories()

    assert first_result == second_result
    assert first_result is not second_result


def test_service_result_changes_do_not_modify_task_bank(
    monkeypatch,
):
    service = task_bank_routes.task_bank_service

    fake_task_bank = {
        "FINANCIAL": [],
        "SOCIAL": [],
    }

    monkeypatch.setattr(
        service_module,
        "TASK_BANK",
        fake_task_bank,
    )

    result = service.get_categories()
    result.append("MORAL")

    assert list(fake_task_bank.keys()) == [
        "FINANCIAL",
        "SOCIAL",
    ]