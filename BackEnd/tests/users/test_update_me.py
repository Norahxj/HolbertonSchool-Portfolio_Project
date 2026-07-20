from datetime import timedelta
from uuid import uuid4

import pytest
from flask_jwt_extended import create_access_token

from app.routes.user_routes import user_service


REGISTER_URL = "/api/auth/register"
LOGIN_URL = "/api/auth/login"
CHILDREN_URL = "/api/children/"
CHILD_LOGIN_URL = "/api/auth/child-login"
LOGOUT_URL = "/api/auth/logout"
UPDATE_ME_URL = "/api/users/me"


# =========================================================
# Helpers
# =========================================================


def valid_parent_data(
    *,
    first_name="Manar",
    last_name="Zaid",
    phone="0551234567",
    email="update.me.parent@gmail.com",
    password="Password123!",
    guardian_type="mother",
):
    return {
        "first_name": first_name,
        "last_name": last_name,
        "phone": phone,
        "email": email,
        "password": password,
        "guardian_type": guardian_type,
    }


def valid_child_data():
    return {
        "name": "Sara",
        "birth_date": "2015-05-10",
        "phone": "0559876543",
    }


def auth_headers(token):
    return {
        "Authorization": token,
    }


def register_parent(client, data=None):
    register_data = data or valid_parent_data()

    response = client.post(
        REGISTER_URL,
        json=register_data,
    )

    response_data = response.get_json()

    assert response.status_code == 201, response_data
    assert "access_token" in response_data
    assert "refresh_token" in response_data
    assert "user" in response_data

    return response_data, register_data


def update_me(client, token, data):
    return client.put(
        UPDATE_ME_URL,
        headers=auth_headers(token),
        json=data,
    )


def login_parent(client, email, password):
    return client.post(
        LOGIN_URL,
        json={
            "email": email,
            "password": password,
        },
    )


def extract_child_data(response_data):
    if "child" in response_data:
        return response_data["child"]

    return response_data


def create_child_and_login(client):
    parent_data, _ = register_parent(client)

    create_response = client.post(
        CHILDREN_URL,
        headers=auth_headers(parent_data["access_token"]),
        json=valid_child_data(),
    )

    create_data = create_response.get_json()

    assert create_response.status_code == 201, create_data

    child = extract_child_data(create_data)

    assert "id" in child
    assert "access_code" in child

    login_response = client.post(
        CHILD_LOGIN_URL,
        json={"access_code": child["access_code"]},
    )

    login_data = login_response.get_json()

    assert login_response.status_code == 200, login_data
    assert "access_token" in login_data

    return child, login_data


# =========================================================
# Successful partial updates
# =========================================================


def test_update_first_name_success(client):
    parent_data, register_data = register_parent(client)

    response = update_me(
        client,
        parent_data["access_token"],
        {"first_name": "Noura"},
    )

    response_data = response.get_json()

    assert response.status_code == 200, response_data
    assert response_data["first_name"] == "Noura"

    assert response_data["last_name"] == register_data["last_name"]
    assert response_data["email"] == register_data["email"]
    assert response_data["phone"] == register_data["phone"]


def test_update_last_name_success(client):
    parent_data, register_data = register_parent(client)

    response = update_me(
        client,
        parent_data["access_token"],
        {"last_name": "Ahmed"},
    )

    response_data = response.get_json()

    assert response.status_code == 200, response_data
    assert response_data["last_name"] == "Ahmed"

    assert response_data["first_name"] == register_data["first_name"]
    assert response_data["email"] == register_data["email"]
    assert response_data["phone"] == register_data["phone"]


def test_update_email_success(client):
    parent_data, register_data = register_parent(client)

    response = update_me(
        client,
        parent_data["access_token"],
        {"email": "new.parent@gmail.com"},
    )

    response_data = response.get_json()

    assert response.status_code == 200, response_data
    assert response_data["email"] == "new.parent@gmail.com"

    assert response_data["first_name"] == register_data["first_name"]
    assert response_data["phone"] == register_data["phone"]


def test_update_phone_success(client):
    parent_data, register_data = register_parent(client)

    response = update_me(
        client,
        parent_data["access_token"],
        {"phone": "0557654321"},
    )

    response_data = response.get_json()

    assert response.status_code == 200, response_data
    assert response_data["phone"] == "0557654321"

    assert response_data["first_name"] == register_data["first_name"]
    assert response_data["email"] == register_data["email"]


def test_update_all_fields_success(client):
    parent_data, _ = register_parent(client)

    response = update_me(
        client,
        parent_data["access_token"],
        {
            "first_name": "Noura",
            "last_name": "Ahmed",
            "email": "noura.updated@gmail.com",
            "phone": "0557654321",
            "password": "NewPassword123!",
        },
    )

    response_data = response.get_json()

    assert response.status_code == 200, response_data

    assert response_data["first_name"] == "Noura"
    assert response_data["last_name"] == "Ahmed"
    assert response_data["email"] == "noura.updated@gmail.com"
    assert response_data["phone"] == "0557654321"

    assert response_data["id"] == parent_data["user"]["id"]
    assert response_data["role"] == "parent"
    assert response_data["guardian_type"] == "mother"

    assert "password" not in response_data
    assert "password_hash" not in response_data


def test_update_response_contains_expected_fields_only(client):
    parent_data, _ = register_parent(client)

    response = update_me(
        client,
        parent_data["access_token"],
        {"first_name": "Noura"},
    )

    response_data = response.get_json()

    assert response.status_code == 200, response_data

    assert set(response_data.keys()) == {
        "id",
        "first_name",
        "last_name",
        "phone",
        "email",
        "role",
        "guardian_type",
    }


# =========================================================
# Data cleaning
# =========================================================


def test_update_first_name_removes_extra_spaces(client):
    parent_data, _ = register_parent(client)

    response = update_me(
        client,
        parent_data["access_token"],
        {"first_name": "  Noura   Mohammed  "},
    )

    response_data = response.get_json()

    assert response.status_code == 200, response_data
    assert response_data["first_name"] == "Noura Mohammed"


def test_update_last_name_removes_extra_spaces(client):
    parent_data, _ = register_parent(client)

    response = update_me(
        client,
        parent_data["access_token"],
        {"last_name": "  Abdul   Rahman  "},
    )

    response_data = response.get_json()

    assert response.status_code == 200, response_data
    assert response_data["last_name"] == "Abdul Rahman"


def test_update_arabic_name_success(client):
    parent_data, _ = register_parent(client)

    response = update_me(
        client,
        parent_data["access_token"],
        {
            "first_name": "منار",
            "last_name": "زيد",
        },
    )

    response_data = response.get_json()

    assert response.status_code == 200, response_data
    assert response_data["first_name"] == "منار"
    assert response_data["last_name"] == "زيد"


def test_update_email_is_lowercased(client):
    parent_data, _ = register_parent(client)

    response = update_me(
        client,
        parent_data["access_token"],
        {"email": "UPDATED.EMAIL@GMAIL.COM"},
    )

    response_data = response.get_json()

    assert response.status_code == 200, response_data
    assert response_data["email"] == "updated.email@gmail.com"


def test_update_email_removes_surrounding_spaces(client):
    parent_data, _ = register_parent(client)

    response = update_me(
        client,
        parent_data["access_token"],
        {"email": "  updated.email@gmail.com  "},
    )

    response_data = response.get_json()

    assert response.status_code == 200, response_data
    assert response_data["email"] == "updated.email@gmail.com"


# =========================================================
# First-name validation
# =========================================================


@pytest.mark.parametrize(
    "invalid_first_name",
    [
        "",
        "A",
        "A" * 51,
        "Manar1",
        "Manar@",
        "12345",
        "   ",
    ],
)
def test_update_rejects_invalid_first_name(
    client,
    invalid_first_name,
):
    parent_data, _ = register_parent(client)

    response = update_me(
        client,
        parent_data["access_token"],
        {"first_name": invalid_first_name},
    )

    response_data = response.get_json()

    assert response.status_code == 400, response_data
    assert "errors" in response_data


@pytest.mark.parametrize(
    "invalid_value",
    [
        None,
        123,
        True,
        [],
        {},
    ],
)
def test_update_rejects_invalid_first_name_types(
    client,
    invalid_value,
):
    parent_data, _ = register_parent(client)

    response = update_me(
        client,
        parent_data["access_token"],
        {"first_name": invalid_value},
    )

    response_data = response.get_json()

    assert response.status_code == 400, response_data
    assert "errors" in response_data


# =========================================================
# Last-name validation
# =========================================================


@pytest.mark.parametrize(
    "invalid_last_name",
    [
        "",
        "A",
        "A" * 51,
        "Zaid1",
        "Zaid@",
        "12345",
        "   ",
    ],
)
def test_update_rejects_invalid_last_name(
    client,
    invalid_last_name,
):
    parent_data, _ = register_parent(client)

    response = update_me(
        client,
        parent_data["access_token"],
        {"last_name": invalid_last_name},
    )

    response_data = response.get_json()

    assert response.status_code == 400, response_data
    assert "errors" in response_data


@pytest.mark.parametrize(
    "invalid_value",
    [
        None,
        123,
        True,
        [],
        {},
    ],
)
def test_update_rejects_invalid_last_name_types(
    client,
    invalid_value,
):
    parent_data, _ = register_parent(client)

    response = update_me(
        client,
        parent_data["access_token"],
        {"last_name": invalid_value},
    )

    response_data = response.get_json()

    assert response.status_code == 400, response_data
    assert "errors" in response_data


# =========================================================
# Email validation
# =========================================================


@pytest.mark.parametrize(
    "invalid_email",
    [
        "",
        "invalid-email",
        "user@",
        "@gmail.com",
        "user gmail.com",
        "user@gmail",
        "user@@gmail.com",
    ],
)
def test_update_rejects_invalid_email(
    client,
    invalid_email,
):
    parent_data, _ = register_parent(client)

    response = update_me(
        client,
        parent_data["access_token"],
        {"email": invalid_email},
    )

    response_data = response.get_json()

    assert response.status_code == 400, response_data
    assert "errors" in response_data
    assert "email" in response_data["errors"]


def test_update_rejects_email_longer_than_120_characters(client):
    parent_data, _ = register_parent(client)

    long_email = (
        ("a" * 110)
        + "@gmail.com"
    )

    response = update_me(
        client,
        parent_data["access_token"],
        {"email": long_email},
    )

    response_data = response.get_json()

    assert response.status_code == 400, response_data
    assert "errors" in response_data


@pytest.mark.parametrize(
    "invalid_value",
    [
        None,
        123,
        True,
        [],
        {},
    ],
)
def test_update_rejects_invalid_email_types(
    client,
    invalid_value,
):
    parent_data, _ = register_parent(client)

    response = update_me(
        client,
        parent_data["access_token"],
        {"email": invalid_value},
    )

    response_data = response.get_json()

    assert response.status_code == 400, response_data
    assert "errors" in response_data


def test_update_rejects_email_used_by_another_user(client):
    first_parent, _ = register_parent(
        client,
        valid_parent_data(
            phone="0551111111",
            email="first.update@gmail.com",
            guardian_type="mother",
        ),
    )

    register_parent(
        client,
        valid_parent_data(
            first_name="Noura",
            last_name="Ahmed",
            phone="0552222222",
            email="second.update@gmail.com",
            guardian_type="father",
        ),
    )

    response = update_me(
        client,
        first_parent["access_token"],
        {"email": "second.update@gmail.com"},
    )

    response_data = response.get_json()

    assert response.status_code == 409, response_data
    assert response_data["error"] == "Email already registered"


def test_update_accepts_current_email(client):
    parent_data, register_data = register_parent(client)

    response = update_me(
        client,
        parent_data["access_token"],
        {"email": register_data["email"]},
    )

    response_data = response.get_json()

    assert response.status_code == 200, response_data
    assert response_data["email"] == register_data["email"]


# =========================================================
# Phone validation
# =========================================================


@pytest.mark.parametrize(
    "invalid_phone",
    [
        "",
        "051234567",
        "05123456789",
        "5512345678",
        "0412345678",
        "05abcdefgh",
        "05-1234567",
        "05 1234567",
    ],
)
def test_update_rejects_invalid_phone(
    client,
    invalid_phone,
):
    parent_data, _ = register_parent(client)

    response = update_me(
        client,
        parent_data["access_token"],
        {"phone": invalid_phone},
    )

    response_data = response.get_json()

    assert response.status_code == 400, response_data
    assert "errors" in response_data
    assert "phone" in response_data["errors"]


@pytest.mark.parametrize(
    "invalid_value",
    [
        None,
        551234567,
        True,
        [],
        {},
    ],
)
def test_update_rejects_invalid_phone_types(
    client,
    invalid_value,
):
    parent_data, _ = register_parent(client)

    response = update_me(
        client,
        parent_data["access_token"],
        {"phone": invalid_value},
    )

    response_data = response.get_json()

    assert response.status_code == 400, response_data
    assert "errors" in response_data


def test_update_rejects_phone_used_by_another_user(client):
    first_parent, _ = register_parent(
        client,
        valid_parent_data(
            phone="0551111111",
            email="first.phone@gmail.com",
            guardian_type="mother",
        ),
    )

    register_parent(
        client,
        valid_parent_data(
            first_name="Noura",
            last_name="Ahmed",
            phone="0552222222",
            email="second.phone@gmail.com",
            guardian_type="father",
        ),
    )

    response = update_me(
        client,
        first_parent["access_token"],
        {"phone": "0552222222"},
    )

    response_data = response.get_json()

    assert response.status_code == 409, response_data
    assert response_data["error"] == "Phone number already used"


def test_update_accepts_current_phone(client):
    parent_data, register_data = register_parent(client)

    response = update_me(
        client,
        parent_data["access_token"],
        {"phone": register_data["phone"]},
    )

    response_data = response.get_json()

    assert response.status_code == 200, response_data
    assert response_data["phone"] == register_data["phone"]


# =========================================================
# Password update
# =========================================================


def test_update_password_success(client):
    parent_data, register_data = register_parent(client)

    response = update_me(
        client,
        parent_data["access_token"],
        {"password": "NewPassword123!"},
    )

    response_data = response.get_json()

    assert response.status_code == 200, response_data

    assert "password" not in response_data
    assert "password_hash" not in response_data

    login_response = login_parent(
        client,
        register_data["email"],
        "NewPassword123!",
    )

    login_data = login_response.get_json()

    assert login_response.status_code == 200, login_data
    assert "access_token" in login_data


def test_old_password_does_not_work_after_update(client):
    parent_data, register_data = register_parent(client)

    response = update_me(
        client,
        parent_data["access_token"],
        {"password": "NewPassword123!"},
    )

    assert response.status_code == 200, response.get_json()

    old_login_response = login_parent(
        client,
        register_data["email"],
        register_data["password"],
    )

    old_login_data = old_login_response.get_json()

    assert old_login_response.status_code == 401, old_login_data
    assert "access_token" not in old_login_data


@pytest.mark.parametrize(
    "invalid_password",
    [
        "",
        "Short1!",
        "password123!",
        "PASSWORD123!",
        "Password!",
        "Password123",
        "12345678!",
    ],
)
def test_update_rejects_invalid_password(
    client,
    invalid_password,
):
    parent_data, _ = register_parent(client)

    response = update_me(
        client,
        parent_data["access_token"],
        {"password": invalid_password},
    )

    response_data = response.get_json()

    assert response.status_code == 400, response_data
    assert "errors" in response_data
    assert "password" in response_data["errors"]


@pytest.mark.parametrize(
    "invalid_value",
    [
        None,
        12345678,
        True,
        [],
        {},
    ],
)
def test_update_rejects_invalid_password_types(
    client,
    invalid_value,
):
    parent_data, _ = register_parent(client)

    response = update_me(
        client,
        parent_data["access_token"],
        {"password": invalid_value},
    )

    response_data = response.get_json()

    assert response.status_code == 400, response_data
    assert "errors" in response_data


# =========================================================
# Empty, unknown and invalid request body
# =========================================================


def test_update_rejects_empty_json(client):
    parent_data, _ = register_parent(client)

    response = update_me(
        client,
        parent_data["access_token"],
        {},
    )

    response_data = response.get_json()

    assert response.status_code == 400, response_data
    assert "errors" in response_data


def test_update_rejects_unknown_field(client):
    parent_data, _ = register_parent(client)

    response = update_me(
        client,
        parent_data["access_token"],
        {"unknown_field": "value"},
    )

    response_data = response.get_json()

    assert response.status_code == 400, response_data
    assert "errors" in response_data
    assert "unknown_field" in response_data["errors"]


@pytest.mark.parametrize(
    "invalid_body",
    [
        [],
        "invalid body",
        123,
        True,
    ],
)
def test_update_rejects_non_object_json_body(
    client,
    invalid_body,
):
    parent_data, _ = register_parent(client)

    response = client.put(
        UPDATE_ME_URL,
        headers=auth_headers(parent_data["access_token"]),
        json=invalid_body,
    )

    response_data = response.get_json()

    assert response.status_code == 400, response_data


def test_update_without_request_body_is_rejected(client):
    parent_data, _ = register_parent(client)

    response = client.put(
        UPDATE_ME_URL,
        headers=auth_headers(parent_data["access_token"]),
        content_type="application/json",
    )

    response_data = response.get_json()

    assert response.status_code == 400, response_data


# =========================================================
# Authorization
# =========================================================


def test_update_rejects_child_access_token(client):
    _, child_login_data = create_child_and_login(client)

    response = update_me(
        client,
        child_login_data["access_token"],
        {"first_name": "Noura"},
    )

    response_data = response.get_json()

    assert response.status_code == 403, response_data
    assert response_data["error"] == "Parent access only"


@pytest.mark.parametrize(
    "invalid_role",
    [
        "admin",
        "guardian",
        "mother",
        "father",
        "",
        None,
        123,
    ],
)
def test_update_rejects_invalid_roles(
    client,
    app,
    invalid_role,
):
    with app.app_context():
        token = create_access_token(
            identity=str(uuid4()),
            additional_claims={"role": invalid_role},
        )

    response = update_me(
        client,
        token,
        {"first_name": "Noura"},
    )

    response_data = response.get_json()

    assert response.status_code == 403, response_data
    assert response_data["error"] == "Parent access only"


def test_update_rejects_token_without_role(client, app):
    with app.app_context():
        token = create_access_token(
            identity=str(uuid4()),
        )

    response = update_me(
        client,
        token,
        {"first_name": "Noura"},
    )

    response_data = response.get_json()

    assert response.status_code == 403, response_data
    assert response_data["error"] == "Parent access only"


def test_update_without_token_is_rejected(client):
    response = client.put(
        UPDATE_ME_URL,
        json={"first_name": "Noura"},
    )

    response_data = response.get_json()

    assert response.status_code == 401, response_data
    assert "error" in response_data


def test_update_rejects_refresh_token(client):
    parent_data, _ = register_parent(client)

    response = update_me(
        client,
        parent_data["refresh_token"],
        {"first_name": "Noura"},
    )

    response_data = response.get_json()

    assert response.status_code in (401, 422), response_data


@pytest.mark.parametrize(
    "invalid_token",
    [
        "",
        "Bearer",
        "not-a-token",
        "abc.def",
        "abc.def.ghi",
    ],
)
def test_update_rejects_malformed_token(
    client,
    invalid_token,
):
    response = client.put(
        UPDATE_ME_URL,
        headers={"Authorization": invalid_token},
        json={"first_name": "Noura"},
    )

    response_data = response.get_json()

    assert response.status_code in (401, 422), response_data


def test_update_rejects_expired_access_token(client, app):
    with app.app_context():
        expired_token = create_access_token(
            identity=str(uuid4()),
            additional_claims={"role": "parent"},
            expires_delta=timedelta(seconds=-1),
        )

    response = update_me(
        client,
        expired_token,
        {"first_name": "Noura"},
    )

    response_data = response.get_json()

    assert response.status_code == 401, response_data


def test_update_rejects_revoked_access_token(client):
    parent_data, _ = register_parent(client)
    access_token = parent_data["access_token"]

    logout_response = client.post(
        LOGOUT_URL,
        headers=auth_headers(access_token),
    )

    assert logout_response.status_code == 200, logout_response.get_json()

    response = update_me(
        client,
        access_token,
        {"first_name": "Noura"},
    )

    response_data = response.get_json()

    assert response.status_code == 401, response_data


# =========================================================
# User not found
# =========================================================


def test_update_returns_404_for_unknown_parent(client, app):
    with app.app_context():
        token = create_access_token(
            identity=str(uuid4()),
            additional_claims={"role": "parent"},
        )

    response = update_me(
        client,
        token,
        {"first_name": "Noura"},
    )

    response_data = response.get_json()

    assert response.status_code == 404, response_data
    assert response_data["error"] == "User not found"


# =========================================================
# Service error mapping
# =========================================================


@pytest.mark.parametrize(
    "service_error,expected_status,expected_message",
    [
        (
            "email_exists",
            409,
            "Email already registered",
        ),
        (
            "phone_exists",
            409,
            "Phone number already used",
        ),
        (
            "not_found",
            404,
            "User not found",
        ),
        (
            "integrity_error",
            409,
            "Email or phone already exists",
        ),
        (
            "unexpected_error",
            500,
            "Failed to update user",
        ),
    ],
)
def test_update_maps_service_errors_correctly(
    client,
    monkeypatch,
    service_error,
    expected_status,
    expected_message,
):
    parent_data, _ = register_parent(client)

    def fake_update_user(user_id, user_data):
        return None, service_error

    monkeypatch.setattr(
        user_service,
        "update_user",
        fake_update_user,
    )

    response = update_me(
        client,
        parent_data["access_token"],
        {"first_name": "Noura"},
    )

    response_data = response.get_json()

    assert response.status_code == expected_status, response_data
    assert response_data["error"] == expected_message