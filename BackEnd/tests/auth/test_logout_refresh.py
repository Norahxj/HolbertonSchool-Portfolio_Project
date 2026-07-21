from datetime import timedelta

import pytest
from flask_jwt_extended import (
    create_refresh_token,
    decode_token,
)

from app.routes.auth_routes import auth_service


REGISTER_URL = "/api/auth/register"
CHILDREN_URL = "/api/children/"
CHILD_LOGIN_URL = "/api/auth/child-login"
REFRESH_URL = "/api/auth/refresh"
LOGOUT_REFRESH_URL = "/api/auth/logout-refresh"

PARENT_EMAIL = "logout.refresh.parent@gmail.com"
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


def logout_refresh(client, refresh_token, json_body=None):
    request_kwargs = {
        "headers": auth_headers(refresh_token),
    }

    if json_body is not None:
        request_kwargs["json"] = json_body

    return client.post(
        LOGOUT_REFRESH_URL,
        **request_kwargs,
    )


# =========================================================
# Parent refresh-token logout
# =========================================================


def test_parent_refresh_token_logout_success(client):
    parent_data = register_parent(client)

    response = logout_refresh(
        client,
        parent_data["refresh_token"],
    )

    response_data = response.get_json()

    assert response.status_code == 200, response_data
    assert (
        response_data["message"]
        == "Refresh token logged out successfully"
    )


def test_parent_logout_refresh_returns_only_success_message(client):
    parent_data = register_parent(client)

    response = logout_refresh(
        client,
        parent_data["refresh_token"],
    )

    response_data = response.get_json()

    assert response.status_code == 200, response_data

    assert set(response_data.keys()) == {"message"}
    assert (
        response_data["message"]
        == "Refresh token logged out successfully"
    )

    assert "access_token" not in response_data
    assert "refresh_token" not in response_data
    assert "user" not in response_data
    assert "child" not in response_data


def test_parent_revoked_refresh_token_cannot_refresh_access_token(
    client,
):
    parent_data = register_parent(client)
    refresh_token = parent_data["refresh_token"]

    logout_response = logout_refresh(
        client,
        refresh_token,
    )

    logout_data = logout_response.get_json()

    assert logout_response.status_code == 200, logout_data

    refresh_response = client.post(
        REFRESH_URL,
        headers=auth_headers(refresh_token),
    )

    refresh_data = refresh_response.get_json()

    assert refresh_response.status_code == 401, refresh_data
    assert "access_token" not in refresh_data


def test_parent_refresh_token_cannot_logout_twice(client):
    parent_data = register_parent(client)
    refresh_token = parent_data["refresh_token"]

    first_response = logout_refresh(
        client,
        refresh_token,
    )

    first_data = first_response.get_json()

    assert first_response.status_code == 200, first_data

    second_response = logout_refresh(
        client,
        refresh_token,
    )

    second_data = second_response.get_json()

    assert second_response.status_code == 401, second_data
    assert (
        second_data.get("message")
        != "Refresh token logged out successfully"
    )


# =========================================================
# Child refresh-token logout
# =========================================================


def test_child_refresh_token_logout_success(client):
    child = create_child(client)

    child_login_data = login_child(
        client,
        child["access_code"],
    )

    response = logout_refresh(
        client,
        child_login_data["refresh_token"],
    )

    response_data = response.get_json()

    assert response.status_code == 200, response_data
    assert (
        response_data["message"]
        == "Refresh token logged out successfully"
    )


def test_child_logout_refresh_returns_only_success_message(client):
    child = create_child(client)

    child_login_data = login_child(
        client,
        child["access_code"],
    )

    response = logout_refresh(
        client,
        child_login_data["refresh_token"],
    )

    response_data = response.get_json()

    assert response.status_code == 200, response_data

    assert set(response_data.keys()) == {"message"}
    assert (
        response_data["message"]
        == "Refresh token logged out successfully"
    )


def test_child_revoked_refresh_token_cannot_refresh_access_token(
    client,
):
    child = create_child(client)

    child_login_data = login_child(
        client,
        child["access_code"],
    )

    refresh_token = child_login_data["refresh_token"]

    logout_response = logout_refresh(
        client,
        refresh_token,
    )

    logout_data = logout_response.get_json()

    assert logout_response.status_code == 200, logout_data

    refresh_response = client.post(
        REFRESH_URL,
        headers=auth_headers(refresh_token),
    )

    refresh_data = refresh_response.get_json()

    assert refresh_response.status_code == 401, refresh_data
    assert "access_token" not in refresh_data


def test_child_refresh_token_cannot_logout_twice(client):
    child = create_child(client)

    child_login_data = login_child(
        client,
        child["access_code"],
    )

    refresh_token = child_login_data["refresh_token"]

    first_response = logout_refresh(
        client,
        refresh_token,
    )

    first_data = first_response.get_json()

    assert first_response.status_code == 200, first_data

    second_response = logout_refresh(
        client,
        refresh_token,
    )

    second_data = second_response.get_json()

    assert second_response.status_code == 401, second_data
    assert (
        second_data.get("message")
        != "Refresh token logged out successfully"
    )


# =========================================================
# Access token versus refresh token
# =========================================================


def test_logout_refresh_rejects_parent_access_token(client):
    parent_data = register_parent(client)

    response = logout_refresh(
        client,
        parent_data["access_token"],
    )

    response_data = response.get_json()

    assert response.status_code in (401, 422), response_data
    assert (
        response_data.get("message")
        != "Refresh token logged out successfully"
    )


def test_logout_refresh_rejects_child_access_token(client):
    child = create_child(client)

    child_login_data = login_child(
        client,
        child["access_code"],
    )

    response = logout_refresh(
        client,
        child_login_data["access_token"],
    )

    response_data = response.get_json()

    assert response.status_code in (401, 422), response_data
    assert (
        response_data.get("message")
        != "Refresh token logged out successfully"
    )


def test_parent_logout_refresh_does_not_revoke_access_token(client):
    parent_data = register_parent(client)

    logout_response = logout_refresh(
        client,
        parent_data["refresh_token"],
    )

    logout_data = logout_response.get_json()

    assert logout_response.status_code == 200, logout_data

    protected_response = client.get(
        "/api/users/me",
        headers=auth_headers(parent_data["access_token"]),
    )

    protected_data = protected_response.get_json()

    assert protected_response.status_code == 200, protected_data


# =========================================================
# Missing and malformed tokens
# =========================================================


def test_logout_refresh_without_authorization_header_is_rejected(
    client,
):
    response = client.post(LOGOUT_REFRESH_URL)

    response_data = response.get_json()

    assert response.status_code == 401, response_data
    assert "error" in response_data
    assert (
        response_data.get("message")
        != "Refresh token logged out successfully"
    )


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
def test_logout_refresh_rejects_malformed_tokens(
    client,
    invalid_authorization,
):
    response = client.post(
        LOGOUT_REFRESH_URL,
        headers={
            "Authorization": invalid_authorization,
        },
    )

    response_data = response.get_json()

    assert response.status_code in (401, 422), response_data

    if isinstance(response_data, dict):
        assert (
            response_data.get("message")
            != "Refresh token logged out successfully"
        )


def test_logout_refresh_rejects_tampered_refresh_token(client):
    parent_data = register_parent(client)

    original_token = parent_data["refresh_token"]

    replacement_character = (
        "a"
        if original_token[-1] != "a"
        else "b"
    )

    tampered_token = (
        original_token[:-1]
        + replacement_character
    )

    response = logout_refresh(
        client,
        tampered_token,
    )

    response_data = response.get_json()

    assert response.status_code in (401, 422), response_data
    assert (
        response_data.get("message")
        != "Refresh token logged out successfully"
    )


def test_logout_refresh_rejects_expired_refresh_token(
    client,
    app,
):
    with app.app_context():
        expired_refresh_token = create_refresh_token(
            identity="expired-user",
            additional_claims={"role": "parent"},
            expires_delta=timedelta(seconds=-1),
        )

    response = logout_refresh(
        client,
        expired_refresh_token,
    )

    response_data = response.get_json()

    assert response.status_code == 401, response_data
    assert (
        response_data.get("message")
        != "Refresh token logged out successfully"
    )


# =========================================================
# Request body
# =========================================================


def test_logout_refresh_succeeds_without_request_body(client):
    parent_data = register_parent(client)

    response = client.post(
        LOGOUT_REFRESH_URL,
        headers=auth_headers(parent_data["refresh_token"]),
    )

    response_data = response.get_json()

    assert response.status_code == 200, response_data
    assert (
        response_data["message"]
        == "Refresh token logged out successfully"
    )


def test_logout_refresh_accepts_empty_json_body(client):
    parent_data = register_parent(client)

    response = logout_refresh(
        client,
        parent_data["refresh_token"],
        json_body={},
    )

    response_data = response.get_json()

    assert response.status_code == 200, response_data
    assert (
        response_data["message"]
        == "Refresh token logged out successfully"
    )


def test_logout_refresh_ignores_additional_json_body(client):
    parent_data = register_parent(client)

    response = logout_refresh(
        client,
        parent_data["refresh_token"],
        json_body={
            "unexpected_field": "unexpected value",
        },
    )

    response_data = response.get_json()

    assert response.status_code == 200, response_data
    assert (
        response_data["message"]
        == "Refresh token logged out successfully"
    )


# =========================================================
# Service failure
# =========================================================


def test_logout_refresh_returns_500_when_service_fails(
    client,
    monkeypatch,
):
    parent_data = register_parent(client)

    def fake_logout(jti):
        return False, "Logout failed"

    monkeypatch.setattr(
        auth_service,
        "logout",
        fake_logout,
    )

    response = logout_refresh(
        client,
        parent_data["refresh_token"],
    )

    response_data = response.get_json()

    assert response.status_code == 500, response_data
    assert response_data["error"] == "Logout failed"

    assert (
        response_data.get("message")
        != "Refresh token logged out successfully"
    )


def test_logout_refresh_service_receives_refresh_token_jti(
    client,
    app,
    monkeypatch,
):
    parent_data = register_parent(client)
    received_jti = {}

    with app.app_context():
        decoded_token = decode_token(
            parent_data["refresh_token"]
        )

    expected_jti = decoded_token["jti"]

    def fake_logout(jti):
        received_jti["value"] = jti
        return True, None

    monkeypatch.setattr(
        auth_service,
        "logout",
        fake_logout,
    )

    response = logout_refresh(
        client,
        parent_data["refresh_token"],
    )

    response_data = response.get_json()

    assert response.status_code == 200, response_data
    assert received_jti["value"] == expected_jti


# =========================================================
# Repository and service idempotency
# =========================================================


def test_logout_refresh_service_is_idempotent_for_same_jti(
    client,
    app,
):
    parent_data = register_parent(client)

    with app.app_context():
        decoded_token = decode_token(
            parent_data["refresh_token"]
        )

        jti = decoded_token["jti"]

        first_success, first_error = auth_service.logout(jti)
        second_success, second_error = auth_service.logout(jti)

    assert first_success is True
    assert first_error is None

    assert second_success is True
    assert second_error is None