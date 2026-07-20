from datetime import timedelta

import pytest
from flask_jwt_extended import (
    create_access_token,
    decode_token,
)

from app.routes.auth_routes import auth_service


REGISTER_URL = "/api/auth/register"
CHILDREN_URL = "/api/children/"
CHILD_LOGIN_URL = "/api/auth/child-login"
REFRESH_URL = "/api/auth/refresh"
LOGOUT_URL = "/api/auth/logout"

PARENT_EMAIL = "logout.parent@gmail.com"
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


def logout(client, access_token, json_body=None):
    request_kwargs = {
        "headers": auth_headers(access_token),
    }

    if json_body is not None:
        request_kwargs["json"] = json_body

    return client.post(
        LOGOUT_URL,
        **request_kwargs,
    )


# =========================================================
# Parent logout
# =========================================================


def test_parent_logout_success(client):
    parent_data = register_parent(client)

    response = logout(
        client,
        parent_data["access_token"],
    )

    response_data = response.get_json()

    assert response.status_code == 200, response_data
    assert response_data["message"] == "Logged out successfully"


def test_parent_logout_returns_only_success_message(client):
    parent_data = register_parent(client)

    response = logout(
        client,
        parent_data["access_token"],
    )

    response_data = response.get_json()

    assert response.status_code == 200, response_data

    assert set(response_data.keys()) == {"message"}
    assert response_data["message"] == "Logged out successfully"

    assert "access_token" not in response_data
    assert "refresh_token" not in response_data
    assert "user" not in response_data
    assert "child" not in response_data


def test_parent_access_token_cannot_logout_twice(client):
    parent_data = register_parent(client)
    access_token = parent_data["access_token"]

    first_response = logout(
        client,
        access_token,
    )

    first_data = first_response.get_json()

    assert first_response.status_code == 200, first_data

    second_response = logout(
        client,
        access_token,
    )

    second_data = second_response.get_json()

    assert second_response.status_code == 401, second_data
    assert "message" not in second_data


def test_parent_revoked_access_token_cannot_access_protected_route(
    client,
):
    parent_data = register_parent(client)
    access_token = parent_data["access_token"]

    logout_response = logout(
        client,
        access_token,
    )

    logout_data = logout_response.get_json()

    assert logout_response.status_code == 200, logout_data

    protected_response = client.get(
        "/api/users/me",
        headers=auth_headers(access_token),
    )

    protected_data = protected_response.get_json()

    assert protected_response.status_code == 401, protected_data


# =========================================================
# Child logout
# =========================================================


def test_child_logout_success(client):
    child = create_child(client)
    child_login_data = login_child(
        client,
        child["access_code"],
    )

    response = logout(
        client,
        child_login_data["access_token"],
    )

    response_data = response.get_json()

    assert response.status_code == 200, response_data
    assert response_data["message"] == "Logged out successfully"


def test_child_logout_returns_only_success_message(client):
    child = create_child(client)
    child_login_data = login_child(
        client,
        child["access_code"],
    )

    response = logout(
        client,
        child_login_data["access_token"],
    )

    response_data = response.get_json()

    assert response.status_code == 200, response_data
    assert set(response_data.keys()) == {"message"}
    assert response_data["message"] == "Logged out successfully"


def test_child_access_token_cannot_logout_twice(client):
    child = create_child(client)
    child_login_data = login_child(
        client,
        child["access_code"],
    )

    access_token = child_login_data["access_token"]

    first_response = logout(
        client,
        access_token,
    )

    first_data = first_response.get_json()

    assert first_response.status_code == 200, first_data

    second_response = logout(
        client,
        access_token,
    )

    second_data = second_response.get_json()

    assert second_response.status_code == 401, second_data
    assert "message" not in second_data


# =========================================================
# Access token versus refresh token
# =========================================================


def test_logout_rejects_parent_refresh_token(client):
    parent_data = register_parent(client)

    response = logout(
        client,
        parent_data["refresh_token"],
    )

    response_data = response.get_json()

    assert response.status_code in (401, 422), response_data
    assert "message" not in response_data


def test_logout_rejects_child_refresh_token(client):
    child = create_child(client)
    child_login_data = login_child(
        client,
        child["access_code"],
    )

    response = logout(
        client,
        child_login_data["refresh_token"],
    )

    response_data = response.get_json()

    assert response.status_code in (401, 422), response_data
    assert "message" not in response_data


def test_parent_logout_does_not_revoke_refresh_token(client):
    parent_data = register_parent(client)

    logout_response = logout(
        client,
        parent_data["access_token"],
    )

    logout_data = logout_response.get_json()

    assert logout_response.status_code == 200, logout_data

    refresh_response = client.post(
        REFRESH_URL,
        headers=auth_headers(parent_data["refresh_token"]),
    )

    refresh_data = refresh_response.get_json()

    assert refresh_response.status_code == 200, refresh_data
    assert "access_token" in refresh_data
    assert refresh_data["access_token"]


def test_child_logout_does_not_revoke_refresh_token(client):
    child = create_child(client)
    child_login_data = login_child(
        client,
        child["access_code"],
    )

    logout_response = logout(
        client,
        child_login_data["access_token"],
    )

    logout_data = logout_response.get_json()

    assert logout_response.status_code == 200, logout_data

    refresh_response = client.post(
        REFRESH_URL,
        headers=auth_headers(
            child_login_data["refresh_token"]
        ),
    )

    refresh_data = refresh_response.get_json()

    assert refresh_response.status_code == 200, refresh_data
    assert "access_token" in refresh_data
    assert refresh_data["access_token"]


# =========================================================
# Missing and invalid tokens
# =========================================================


def test_logout_without_authorization_header_is_rejected(client):
    response = client.post(LOGOUT_URL)

    response_data = response.get_json()

    assert response.status_code == 401, response_data


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
def test_logout_rejects_malformed_tokens(
    client,
    invalid_authorization,
):
    response = client.post(
        LOGOUT_URL,
        headers={
            "Authorization": invalid_authorization,
        },
    )

    response_data = response.get_json()

    assert response.status_code in (401, 422), response_data



def test_logout_rejects_tampered_access_token(client):
    parent_data = register_parent(client)

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

    response = logout(
        client,
        tampered_token,
    )

    response_data = response.get_json()

    assert response.status_code in (401, 422), response_data


def test_logout_rejects_expired_access_token(client, app):
    with app.app_context():
        expired_token = create_access_token(
            identity="expired-user",
            additional_claims={"role": "parent"},
            expires_delta=timedelta(seconds=-1),
        )

    response = logout(
        client,
        expired_token,
    )

    response_data = response.get_json()

    assert response.status_code == 401, response_data


# =========================================================
# Request body
# =========================================================


def test_logout_succeeds_without_request_body(client):
    parent_data = register_parent(client)

    response = client.post(
        LOGOUT_URL,
        headers=auth_headers(parent_data["access_token"]),
    )

    response_data = response.get_json()

    assert response.status_code == 200, response_data
    assert response_data["message"] == "Logged out successfully"


def test_logout_accepts_empty_json_body(client):
    parent_data = register_parent(client)

    response = logout(
        client,
        parent_data["access_token"],
        json_body={},
    )

    response_data = response.get_json()

    assert response.status_code == 200, response_data
    assert response_data["message"] == "Logged out successfully"


def test_logout_ignores_additional_json_body(client):
    parent_data = register_parent(client)

    response = logout(
        client,
        parent_data["access_token"],
        json_body={
            "unexpected_field": "unexpected value",
        },
    )

    response_data = response.get_json()

    assert response.status_code == 200, response_data
    assert response_data["message"] == "Logged out successfully"


# =========================================================
# Service failure
# =========================================================


def test_logout_returns_500_when_service_fails(
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

    response = logout(
        client,
        parent_data["access_token"],
    )

    response_data = response.get_json()

    assert response.status_code == 500, response_data
    assert response_data["error"] == "Logout failed"
    assert "message" not in response_data


def test_logout_service_receives_token_jti(
    client,
    app,
    monkeypatch,
):
    parent_data = register_parent(client)
    received_jti = {}

    with app.app_context():
        decoded_token = decode_token(
            parent_data["access_token"]
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

    response = logout(
        client,
        parent_data["access_token"],
    )

    response_data = response.get_json()

    assert response.status_code == 200, response_data
    assert received_jti["value"] == expected_jti


# =========================================================
# Repository and service idempotency
# =========================================================


def test_logout_service_is_idempotent_for_same_jti(
    client,
    app,
):
    parent_data = register_parent(client)

    with app.app_context():
        decoded_token = decode_token(
            parent_data["access_token"]
        )

        jti = decoded_token["jti"]

        first_success, first_error = auth_service.logout(jti)
        second_success, second_error = auth_service.logout(jti)

    assert first_success is True
    assert first_error is None

    assert second_success is True
    assert second_error is None