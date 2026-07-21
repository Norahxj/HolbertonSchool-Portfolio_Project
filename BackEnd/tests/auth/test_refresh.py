from datetime import timedelta
from uuid import uuid4

import pytest
from flask_jwt_extended import (
    create_refresh_token,
    decode_token,
)


REGISTER_URL = "/api/auth/register"
CHILDREN_URL = "/api/children/"
CHILD_LOGIN_URL = "/api/auth/child-login"
REFRESH_URL = "/api/auth/refresh"
LOGOUT_REFRESH_URL = "/api/auth/logout-refresh"

PARENT_EMAIL = "refresh.parent@gmail.com"
PARENT_PASSWORD = "Password123!"


# =========================================================
# Helpers
# =========================================================


def valid_parent_register_data():
    return {
        "first_name": "Manar",
        "last_name": "Zaid",
        "phone": "0551234567",
        "email": PARENT_EMAIL,
        "password": PARENT_PASSWORD,
        "guardian_type": "mother",
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


def register_parent(client):
    response = client.post(
        REGISTER_URL,
        json=valid_parent_register_data(),
    )

    response_data = response.get_json()

    assert response.status_code == 201, response_data
    assert "access_token" in response_data
    assert "refresh_token" in response_data
    assert "user" in response_data

    return response_data


def extract_child_data(response_data):
    if "child" in response_data:
        return response_data["child"]

    return response_data


def create_child(client):
    parent_data = register_parent(client)

    response = client.post(
        CHILDREN_URL,
        json=valid_child_data(),
        headers=auth_headers(parent_data["access_token"]),
    )

    response_data = response.get_json()

    assert response.status_code == 201, response_data

    child = extract_child_data(response_data)

    assert "id" in child
    assert "access_code" in child

    return child


def login_child(client, access_code):
    response = client.post(
        CHILD_LOGIN_URL,
        json={"access_code": access_code},
    )

    response_data = response.get_json()

    assert response.status_code == 200, response_data
    assert "access_token" in response_data
    assert "refresh_token" in response_data
    assert "child" in response_data

    return response_data


def refresh_access_token(client, refresh_token):
    return client.post(
        REFRESH_URL,
        headers=auth_headers(refresh_token),
    )


def create_custom_refresh_token(
    app,
    identity,
    role_marker=object(),
    expires_delta=None,
):
    """
    role_marker has a unique default value so the helper can distinguish
    between:

    - role omitted completely
    - role explicitly provided as None or an empty string
    """

    claims = {}

    if role_marker is not create_custom_refresh_token.__defaults__[0]:
        claims["role"] = role_marker

    with app.app_context():
        return create_refresh_token(
            identity=identity,
            additional_claims=claims,
            expires_delta=expires_delta,
        )


# =========================================================
# Parent refresh
# =========================================================


def test_parent_can_refresh_access_token(client):
    parent_data = register_parent(client)

    response = refresh_access_token(
        client,
        parent_data["refresh_token"],
    )

    response_data = response.get_json()

    assert response.status_code == 200, response_data
    assert "access_token" in response_data


def test_parent_refresh_returns_non_empty_access_token(client):
    parent_data = register_parent(client)

    response = refresh_access_token(
        client,
        parent_data["refresh_token"],
    )

    response_data = response.get_json()

    assert response.status_code == 200, response_data

    assert isinstance(response_data["access_token"], str)
    assert response_data["access_token"]


def test_parent_refreshed_token_has_correct_claims(client, app):
    parent_data = register_parent(client)

    response = refresh_access_token(
        client,
        parent_data["refresh_token"],
    )

    response_data = response.get_json()

    assert response.status_code == 200, response_data

    with app.app_context():
        decoded_token = decode_token(
            response_data["access_token"]
        )

    assert decoded_token["sub"] == parent_data["user"]["id"]
    assert decoded_token["role"] == "parent"
    assert decoded_token["type"] == "access"


def test_parent_refreshed_access_token_differs_from_old_token(client):
    parent_data = register_parent(client)

    response = refresh_access_token(
        client,
        parent_data["refresh_token"],
    )

    response_data = response.get_json()

    assert response.status_code == 200, response_data

    assert (
        response_data["access_token"]
        != parent_data["access_token"]
    )


def test_parent_refresh_does_not_return_new_refresh_token(client):
    parent_data = register_parent(client)

    response = refresh_access_token(
        client,
        parent_data["refresh_token"],
    )

    response_data = response.get_json()

    assert response.status_code == 200, response_data

    assert "refresh_token" not in response_data
    assert "user" not in response_data
    assert "child" not in response_data


def test_parent_can_use_same_refresh_token_multiple_times(client):
    parent_data = register_parent(client)

    first_response = refresh_access_token(
        client,
        parent_data["refresh_token"],
    )

    second_response = refresh_access_token(
        client,
        parent_data["refresh_token"],
    )

    first_data = first_response.get_json()
    second_data = second_response.get_json()

    assert first_response.status_code == 200, first_data
    assert second_response.status_code == 200, second_data

    assert first_data["access_token"]
    assert second_data["access_token"]

    assert (
        first_data["access_token"]
        != second_data["access_token"]
    )


# =========================================================
# Child refresh
# =========================================================


def test_child_can_refresh_access_token(client):
    child = create_child(client)
    child_login_data = login_child(
        client,
        child["access_code"],
    )

    response = refresh_access_token(
        client,
        child_login_data["refresh_token"],
    )

    response_data = response.get_json()

    assert response.status_code == 200, response_data
    assert "access_token" in response_data


def test_child_refresh_returns_non_empty_access_token(client):
    child = create_child(client)
    child_login_data = login_child(
        client,
        child["access_code"],
    )

    response = refresh_access_token(
        client,
        child_login_data["refresh_token"],
    )

    response_data = response.get_json()

    assert response.status_code == 200, response_data

    assert isinstance(response_data["access_token"], str)
    assert response_data["access_token"]


def test_child_refreshed_token_has_correct_claims(client, app):
    child = create_child(client)
    child_login_data = login_child(
        client,
        child["access_code"],
    )

    response = refresh_access_token(
        client,
        child_login_data["refresh_token"],
    )

    response_data = response.get_json()

    assert response.status_code == 200, response_data

    with app.app_context():
        decoded_token = decode_token(
            response_data["access_token"]
        )

    assert decoded_token["sub"] == child["id"]
    assert decoded_token["role"] == "child"
    assert decoded_token["type"] == "access"


def test_child_refreshed_access_token_differs_from_old_token(client):
    child = create_child(client)
    child_login_data = login_child(
        client,
        child["access_code"],
    )

    response = refresh_access_token(
        client,
        child_login_data["refresh_token"],
    )

    response_data = response.get_json()

    assert response.status_code == 200, response_data

    assert (
        response_data["access_token"]
        != child_login_data["access_token"]
    )


def test_child_refresh_does_not_return_new_refresh_token(client):
    child = create_child(client)
    child_login_data = login_child(
        client,
        child["access_code"],
    )

    response = refresh_access_token(
        client,
        child_login_data["refresh_token"],
    )

    response_data = response.get_json()

    assert response.status_code == 200, response_data

    assert "refresh_token" not in response_data
    assert "child" not in response_data
    assert "user" not in response_data


def test_child_can_use_same_refresh_token_multiple_times(client):
    child = create_child(client)
    child_login_data = login_child(
        client,
        child["access_code"],
    )

    first_response = refresh_access_token(
        client,
        child_login_data["refresh_token"],
    )

    second_response = refresh_access_token(
        client,
        child_login_data["refresh_token"],
    )

    first_data = first_response.get_json()
    second_data = second_response.get_json()

    assert first_response.status_code == 200, first_data
    assert second_response.status_code == 200, second_data

    assert first_data["access_token"]
    assert second_data["access_token"]

    assert (
        first_data["access_token"]
        != second_data["access_token"]
    )


# =========================================================
# Missing and malformed tokens
# =========================================================


def test_refresh_without_authorization_header_is_rejected(client):
    response = client.post(REFRESH_URL)

    response_data = response.get_json()

    assert response.status_code == 401, response_data
    assert "access_token" not in response_data


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
def test_refresh_rejects_malformed_token(
    client,
    invalid_authorization,
):
    response = client.post(
        REFRESH_URL,
        headers={
            "Authorization": invalid_authorization,
        },
    )

    response_data = response.get_json()

    assert response.status_code in (401, 422), response_data

    if isinstance(response_data, dict):
        assert "access_token" not in response_data


def test_refresh_rejects_access_token(client):
    parent_data = register_parent(client)

    response = client.post(
        REFRESH_URL,
        headers=auth_headers(parent_data["access_token"]),
    )

    response_data = response.get_json()

    assert response.status_code in (401, 422), response_data
    assert "access_token" not in response_data


def test_refresh_rejects_expired_refresh_token(client, app):
    expired_token = create_custom_refresh_token(
        app=app,
        identity=str(uuid4()),
        role_marker="parent",
        expires_delta=timedelta(seconds=-1),
    )

    response = refresh_access_token(
        client,
        expired_token,
    )

    response_data = response.get_json()

    assert response.status_code == 401, response_data
    assert "access_token" not in response_data


# =========================================================
# Missing database identities
# =========================================================


def test_refresh_returns_user_not_found_for_unknown_parent(
    client,
    app,
):
    unknown_parent_id = str(uuid4())

    refresh_token = create_custom_refresh_token(
        app=app,
        identity=unknown_parent_id,
        role_marker="parent",
    )

    response = refresh_access_token(
        client,
        refresh_token,
    )

    response_data = response.get_json()

    assert response.status_code == 404, response_data
    assert response_data["error"] == "User not found"
    assert "access_token" not in response_data


def test_refresh_returns_child_not_found_for_unknown_child(
    client,
    app,
):
    unknown_child_id = str(uuid4())

    refresh_token = create_custom_refresh_token(
        app=app,
        identity=unknown_child_id,
        role_marker="child",
    )

    response = refresh_access_token(
        client,
        refresh_token,
    )

    response_data = response.get_json()

    assert response.status_code == 404, response_data
    assert response_data["error"] == "Child not found"
    assert "access_token" not in response_data


# =========================================================
# Invalid roles
# =========================================================


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
def test_refresh_rejects_invalid_role(
    client,
    app,
    invalid_role,
):
    refresh_token = create_custom_refresh_token(
        app=app,
        identity=str(uuid4()),
        role_marker=invalid_role,
    )

    response = refresh_access_token(
        client,
        refresh_token,
    )

    response_data = response.get_json()

    assert response.status_code == 403, response_data
    assert response_data["error"] == "Invalid role"
    assert "access_token" not in response_data


def test_refresh_rejects_token_without_role(client, app):
    with app.app_context():
        refresh_token = create_refresh_token(
            identity=str(uuid4()),
        )

    response = refresh_access_token(
        client,
        refresh_token,
    )

    response_data = response.get_json()

    assert response.status_code == 403, response_data
    assert response_data["error"] == "Invalid role"
    assert "access_token" not in response_data


# =========================================================
# Revoked refresh token
# =========================================================


def test_revoked_parent_refresh_token_cannot_be_used(client):
    parent_data = register_parent(client)
    refresh_token = parent_data["refresh_token"]

    logout_response = client.post(
        LOGOUT_REFRESH_URL,
        headers=auth_headers(refresh_token),
    )

    logout_data = logout_response.get_json()

    assert logout_response.status_code == 200, logout_data

    refresh_response = refresh_access_token(
        client,
        refresh_token,
    )

    refresh_data = refresh_response.get_json()

    assert refresh_response.status_code == 401, refresh_data
    assert "access_token" not in refresh_data


def test_revoked_child_refresh_token_cannot_be_used(client):
    child = create_child(client)
    child_login_data = login_child(
        client,
        child["access_code"],
    )

    refresh_token = child_login_data["refresh_token"]

    logout_response = client.post(
        LOGOUT_REFRESH_URL,
        headers=auth_headers(refresh_token),
    )

    logout_data = logout_response.get_json()

    assert logout_response.status_code == 200, logout_data

    refresh_response = refresh_access_token(
        client,
        refresh_token,
    )

    refresh_data = refresh_response.get_json()

    assert refresh_response.status_code == 401, refresh_data
    assert "access_token" not in refresh_data


# =========================================================
# Response shape
# =========================================================


def test_successful_refresh_returns_only_access_token(client):
    parent_data = register_parent(client)

    response = refresh_access_token(
        client,
        parent_data["refresh_token"],
    )

    response_data = response.get_json()

    assert response.status_code == 200, response_data
    assert set(response_data.keys()) == {"access_token"}


def test_failed_refresh_returns_error_without_token(client, app):
    refresh_token = create_custom_refresh_token(
        app=app,
        identity=str(uuid4()),
        role_marker="admin",
    )

    response = refresh_access_token(
        client,
        refresh_token,
    )

    response_data = response.get_json()

    assert response.status_code == 403, response_data
    assert set(response_data.keys()) == {"error"}
    assert response_data["error"] == "Invalid role"