from datetime import timedelta
from uuid import uuid4

import pytest
from flask_jwt_extended import (
    create_access_token,
)


REGISTER_URL = "/api/auth/register"
CHILDREN_URL = "/api/children/"
CHILD_LOGIN_URL = "/api/auth/child-login"
LOGOUT_URL = "/api/auth/logout"
GET_ME_URL = "/api/users/me"


# =========================================================
# Helpers
# =========================================================


def valid_parent_data(
    *,
    first_name="Manar",
    last_name="Zaid",
    phone="0551234567",
    email="get.me.parent@gmail.com",
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


def extract_child_data(response_data):
    if "child" in response_data:
        return response_data["child"]

    return response_data


def create_child_and_login(client):
    parent_data, _ = register_parent(client)

    create_response = client.post(
        CHILDREN_URL,
        json=valid_child_data(),
        headers=auth_headers(parent_data["access_token"]),
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
    assert "refresh_token" in login_data

    return child, login_data


def get_me(client, access_token):
    return client.get(
        GET_ME_URL,
        headers=auth_headers(access_token),
    )


# =========================================================
# Successful request
# =========================================================


def test_get_me_success(client):
    parent_data, register_data = register_parent(client)

    response = get_me(
        client,
        parent_data["access_token"],
    )

    response_data = response.get_json()

    assert response.status_code == 200, response_data

    assert response_data["id"] == parent_data["user"]["id"]
    assert response_data["first_name"] == register_data["first_name"]
    assert response_data["last_name"] == register_data["last_name"]
    assert response_data["phone"] == register_data["phone"]
    assert response_data["email"] == register_data["email"]
    assert response_data["role"] == "parent"
    assert (
        response_data["guardian_type"]
        == register_data["guardian_type"]
    )


def test_get_me_returns_all_expected_fields(client):
    parent_data, _ = register_parent(client)

    response = get_me(
        client,
        parent_data["access_token"],
    )

    response_data = response.get_json()

    assert response.status_code == 200, response_data

    expected_fields = {
        "id",
        "first_name",
        "last_name",
        "phone",
        "email",
        "role",
        "guardian_type",
    }

    assert set(response_data.keys()) == expected_fields


def test_get_me_does_not_return_sensitive_data(client):
    parent_data, _ = register_parent(client)

    response = get_me(
        client,
        parent_data["access_token"],
    )

    response_data = response.get_json()

    assert response.status_code == 200, response_data

    assert "password" not in response_data
    assert "password_hash" not in response_data
    assert "access_token" not in response_data
    assert "refresh_token" not in response_data


def test_get_me_returns_parent_role(client):
    parent_data, _ = register_parent(client)

    response = get_me(
        client,
        parent_data["access_token"],
    )

    response_data = response.get_json()

    assert response.status_code == 200, response_data
    assert response_data["role"] == "parent"


# =========================================================
# Parent-only access
# =========================================================


def test_get_me_rejects_child_token(client):
    _, child_login_data = create_child_and_login(client)

    response = get_me(
        client,
        child_login_data["access_token"],
    )

    response_data = response.get_json()

    assert response.status_code == 403, response_data
    assert response_data["error"] == "Parent access only"

    assert "id" not in response_data
    assert "email" not in response_data


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
def test_get_me_rejects_invalid_roles(
    client,
    app,
    invalid_role,
):
    with app.app_context():
        token = create_access_token(
            identity=str(uuid4()),
            additional_claims={"role": invalid_role},
        )

    response = get_me(
        client,
        token,
    )

    response_data = response.get_json()

    assert response.status_code == 403, response_data
    assert response_data["error"] == "Parent access only"

    assert "id" not in response_data
    assert "email" not in response_data


def test_get_me_rejects_token_without_role(client, app):
    with app.app_context():
        token = create_access_token(
            identity=str(uuid4()),
        )

    response = get_me(
        client,
        token,
    )

    response_data = response.get_json()

    assert response.status_code == 403, response_data
    assert response_data["error"] == "Parent access only"


# =========================================================
# User not found
# =========================================================


def test_get_me_returns_404_for_unknown_parent(client, app):
    unknown_user_id = str(uuid4())

    with app.app_context():
        token = create_access_token(
            identity=unknown_user_id,
            additional_claims={"role": "parent"},
        )

    response = get_me(
        client,
        token,
    )

    response_data = response.get_json()

    assert response.status_code == 404, response_data
    assert response_data["error"] == "User not found"

    assert "id" not in response_data
    assert "first_name" not in response_data
    assert "email" not in response_data


# =========================================================
# Missing and malformed tokens
# =========================================================


def test_get_me_without_authorization_header_is_rejected(client):
    response = client.get(GET_ME_URL)

    response_data = response.get_json()

    assert response.status_code == 401, response_data
    assert "error" in response_data


@pytest.mark.parametrize(
    "invalid_authorization",
    [
        "",
        "Bearer",
        "not-a-token",
        "abc.def",
        "abc.def.ghi",
    ],
)
def test_get_me_rejects_malformed_tokens(
    client,
    invalid_authorization,
):
    response = client.get(
        GET_ME_URL,
        headers={
            "Authorization": invalid_authorization,
        },
    )

    response_data = response.get_json()

    assert response.status_code in (401, 422), response_data

    if isinstance(response_data, dict):
        assert "id" not in response_data
        assert "email" not in response_data


def test_get_me_rejects_tampered_access_token(client):
    parent_data, _ = register_parent(client)

    original_token = parent_data["access_token"]

    replacement_character = (
        "a"
        if original_token[-1] != "a"
        else "b"
    )

    tampered_token = (
        original_token[:-1]
        + replacement_character
    )

    response = get_me(
        client,
        tampered_token,
    )

    response_data = response.get_json()

    assert response.status_code in (401, 422), response_data
    assert "id" not in response_data
    assert "email" not in response_data


def test_get_me_rejects_expired_access_token(client, app):
    with app.app_context():
        expired_token = create_access_token(
            identity=str(uuid4()),
            additional_claims={"role": "parent"},
            expires_delta=timedelta(seconds=-1),
        )

    response = get_me(
        client,
        expired_token,
    )

    response_data = response.get_json()

    assert response.status_code == 401, response_data
    assert "id" not in response_data
    assert "email" not in response_data


def test_get_me_rejects_refresh_token(client):
    parent_data, _ = register_parent(client)

    response = get_me(
        client,
        parent_data["refresh_token"],
    )

    response_data = response.get_json()

    assert response.status_code in (401, 422), response_data
    assert "id" not in response_data
    assert "email" not in response_data


def test_get_me_rejects_revoked_access_token(client):
    parent_data, _ = register_parent(client)
    access_token = parent_data["access_token"]

    logout_response = client.post(
        LOGOUT_URL,
        headers=auth_headers(access_token),
    )

    logout_data = logout_response.get_json()

    assert logout_response.status_code == 200, logout_data

    response = get_me(
        client,
        access_token,
    )

    response_data = response.get_json()

    assert response.status_code == 401, response_data
    assert "id" not in response_data
    assert "email" not in response_data


# =========================================================
# Multiple users
# =========================================================


def test_each_parent_receives_only_their_own_data(client):
    first_parent, first_register_data = register_parent(
        client,
        valid_parent_data(
            first_name="Manar",
            last_name="Zaid",
            phone="0551234567",
            email="first.parent@gmail.com",
            guardian_type="mother",
        ),
    )

    second_parent, second_register_data = register_parent(
        client,
        valid_parent_data(
            first_name="Khalid",
            last_name="Ali",
            phone="0557654321",
            email="second.parent@gmail.com",
            guardian_type="father",
        ),
    )

    first_response = get_me(
        client,
        first_parent["access_token"],
    )

    second_response = get_me(
        client,
        second_parent["access_token"],
    )

    first_data = first_response.get_json()
    second_data = second_response.get_json()

    assert first_response.status_code == 200, first_data
    assert second_response.status_code == 200, second_data

    assert first_data["id"] == first_parent["user"]["id"]
    assert first_data["email"] == first_register_data["email"]

    assert second_data["id"] == second_parent["user"]["id"]
    assert second_data["email"] == second_register_data["email"]

    assert first_data["id"] != second_data["id"]
    assert first_data["email"] != second_data["email"]


def test_first_parent_token_does_not_return_second_parent(client):
    first_parent, first_register_data = register_parent(
        client,
        valid_parent_data(
            first_name="Manar",
            last_name="Zaid",
            phone="0551234567",
            email="first.only@gmail.com",
            guardian_type="mother",
        ),
    )

    second_parent, second_register_data = register_parent(
        client,
        valid_parent_data(
            first_name="Khalid",
            last_name="Ali",
            phone="0557654321",
            email="second.only@gmail.com",
            guardian_type="father",
        ),
    )

    response = get_me(
        client,
        first_parent["access_token"],
    )

    response_data = response.get_json()

    assert response.status_code == 200, response_data

    assert response_data["id"] == first_parent["user"]["id"]
    assert response_data["email"] == first_register_data["email"]

    assert response_data["id"] != second_parent["user"]["id"]
    assert response_data["email"] != second_register_data["email"]


# =========================================================
# Request body
# =========================================================


def test_get_me_succeeds_without_request_body(client):
    parent_data, _ = register_parent(client)

    response = client.get(
        GET_ME_URL,
        headers=auth_headers(parent_data["access_token"]),
    )

    response_data = response.get_json()

    assert response.status_code == 200, response_data
    assert response_data["id"] == parent_data["user"]["id"]


def test_get_me_ignores_additional_json_body(client):
    parent_data, _ = register_parent(client)

    response = client.get(
        GET_ME_URL,
        headers=auth_headers(parent_data["access_token"]),
        json={
            "unexpected_field": "unexpected value",
        },
    )

    response_data = response.get_json()

    assert response.status_code == 200, response_data
    assert response_data["id"] == parent_data["user"]["id"]