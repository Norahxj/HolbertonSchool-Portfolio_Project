from datetime import timedelta
from uuid import uuid4

import pytest
from flask_jwt_extended import create_access_token

from app.extensions import db
from app.models.Family_model import Family
from app.routes.user_routes import user_service


REGISTER_URL = "/api/auth/register"
LOGIN_URL = "/api/auth/login"
CHILDREN_URL = "/api/children/"
CHILD_LOGIN_URL = "/api/auth/child-login"
REFRESH_URL = "/api/auth/refresh"
LOGOUT_URL = "/api/auth/logout"

GET_ME_URL = "/api/users/me"
UPDATE_ME_URL = "/api/users/me"
DELETE_ME_URL = "/api/users/me"


# =========================================================
# Helpers
# =========================================================


def valid_parent_data(
    *,
    first_name="Manar",
    last_name="Zaid",
    phone="0551234567",
    email="delete.me.parent@gmail.com",
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


def valid_child_data(
    *,
    name="Sara",
    birth_date="2015-05-10",
    phone="0559876543",
):
    return {
        "name": name,
        "birth_date": birth_date,
        "phone": phone,
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


def login_parent(client, email, password):
    return client.post(
        LOGIN_URL,
        json={
            "email": email,
            "password": password,
        },
    )


def delete_me(client, token, **kwargs):
    return client.delete(
        DELETE_ME_URL,
        headers=auth_headers(token),
        **kwargs,
    )


def extract_child_data(response_data):
    if "child" in response_data:
        return response_data["child"]

    return response_data


def create_child(client, parent_token, data=None):
    child_data = data or valid_child_data()

    response = client.post(
        CHILDREN_URL,
        headers=auth_headers(parent_token),
        json=child_data,
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

    return response_data


def create_child_and_login(client):
    parent_data, _ = register_parent(client)

    child = create_child(
        client,
        parent_data["access_token"],
    )

    child_login_data = login_child(
        client,
        child["access_code"],
    )

    return parent_data, child, child_login_data


# =========================================================
# Successful deletion
# =========================================================


def test_delete_me_success(client):
    parent_data, _ = register_parent(client)

    response = delete_me(
        client,
        parent_data["access_token"],
    )

    response_data = response.get_json()

    assert response.status_code == 200, response_data
    assert response_data == {
        "message": "User deleted successfully",
    }


def test_delete_me_returns_exact_response_shape(client):
    parent_data, _ = register_parent(client)

    response = delete_me(
        client,
        parent_data["access_token"],
    )

    response_data = response.get_json()

    assert response.status_code == 200, response_data
    assert set(response_data.keys()) == {"message"}
    assert response_data["message"] == "User deleted successfully"


def test_delete_me_does_not_return_user_data(client):
    parent_data, register_data = register_parent(client)

    response = delete_me(
        client,
        parent_data["access_token"],
    )

    response_data = response.get_json()

    assert response.status_code == 200, response_data

    assert "id" not in response_data
    assert "first_name" not in response_data
    assert "last_name" not in response_data
    assert "email" not in response_data
    assert "phone" not in response_data
    assert "password" not in response_data
    assert "password_hash" not in response_data

    assert register_data["email"] not in str(response_data)
    assert register_data["phone"] not in str(response_data)


def test_delete_parent_without_children_success(client):
    parent_data, _ = register_parent(client)

    user_id = parent_data["user"]["id"]

    response = delete_me(
        client,
        parent_data["access_token"],
    )

    response_data = response.get_json()

    assert response.status_code == 200, response_data

    deleted_user = user_service.get_user(user_id)

    assert deleted_user is None


# =========================================================
# User state after deletion
# =========================================================


def test_deleted_parent_cannot_login(client):
    parent_data, register_data = register_parent(client)

    delete_response = delete_me(
        client,
        parent_data["access_token"],
    )

    assert delete_response.status_code == 200, delete_response.get_json()

    login_response = login_parent(
        client,
        register_data["email"],
        register_data["password"],
    )

    login_data = login_response.get_json()

    assert login_response.status_code == 401, login_data
    assert "access_token" not in login_data
    assert "refresh_token" not in login_data


def test_deleted_parent_get_me_returns_404(client):
    parent_data, _ = register_parent(client)

    access_token = parent_data["access_token"]

    delete_response = delete_me(
        client,
        access_token,
    )

    assert delete_response.status_code == 200, delete_response.get_json()

    response = client.get(
        GET_ME_URL,
        headers=auth_headers(access_token),
    )

    response_data = response.get_json()

    assert response.status_code == 404, response_data
    assert response_data["error"] == "User not found"


def test_deleted_parent_update_me_returns_404(client):
    parent_data, _ = register_parent(client)

    access_token = parent_data["access_token"]

    delete_response = delete_me(
        client,
        access_token,
    )

    assert delete_response.status_code == 200, delete_response.get_json()

    response = client.put(
        UPDATE_ME_URL,
        headers=auth_headers(access_token),
        json={"first_name": "Noura"},
    )

    response_data = response.get_json()

    assert response.status_code == 404, response_data
    assert response_data["error"] == "User not found"


def test_deleting_same_parent_twice_returns_404(client):
    parent_data, _ = register_parent(client)

    access_token = parent_data["access_token"]

    first_response = delete_me(
        client,
        access_token,
    )

    assert first_response.status_code == 200, first_response.get_json()

    second_response = delete_me(
        client,
        access_token,
    )

    second_response_data = second_response.get_json()

    assert second_response.status_code == 404, second_response_data
    assert second_response_data["error"] == "User not found"


# =========================================================
# Family deletion
# =========================================================


def test_family_is_deleted_when_last_guardian_is_deleted(
    client,
    app,
):
    parent_data, _ = register_parent(client)

    user_id = parent_data["user"]["id"]

    with app.app_context():
        user = user_service.get_user(user_id)

        assert user is not None
        assert user.family_id is not None

        family_id = user.family_id

    response = delete_me(
        client,
        parent_data["access_token"],
    )

    response_data = response.get_json()

    assert response.status_code == 200, response_data

    with app.app_context():
        deleted_family = db.session.get(
            Family,
            family_id,
        )

        assert deleted_family is None


def test_family_with_no_children_is_deleted_with_parent(
    client,
    app,
):
    parent_data, _ = register_parent(client)

    user_id = parent_data["user"]["id"]

    with app.app_context():
        user = user_service.get_user(user_id)

        family_id = user.family_id

        assert family_id is not None
        assert len(user.children) == 0

    response = delete_me(
        client,
        parent_data["access_token"],
    )

    assert response.status_code == 200, response.get_json()

    with app.app_context():
        family = db.session.get(
            Family,
            family_id,
        )

        assert family is None


# =========================================================
# Child deletion when parent is sole guardian
# =========================================================


def test_child_is_deleted_when_only_guardian_is_deleted(client):
    parent_data, _ = register_parent(client)

    child = create_child(
        client,
        parent_data["access_token"],
    )

    child_access_code = child["access_code"]

    child_login_before_delete = client.post(
        CHILD_LOGIN_URL,
        json={"access_code": child_access_code},
    )

    assert (
        child_login_before_delete.status_code == 200
    ), child_login_before_delete.get_json()

    delete_response = delete_me(
        client,
        parent_data["access_token"],
    )

    assert delete_response.status_code == 200, delete_response.get_json()

    child_login_after_delete = client.post(
        CHILD_LOGIN_URL,
        json={"access_code": child_access_code},
    )

    child_login_data = child_login_after_delete.get_json()

    assert child_login_after_delete.status_code in (
        401,
        404,
    ), child_login_data

    assert "access_token" not in child_login_data


def test_all_children_are_deleted_when_only_guardian_is_deleted(
    client,
):
    parent_data, _ = register_parent(client)

    first_child = create_child(
        client,
        parent_data["access_token"],
        valid_child_data(
            name="Sara",
            phone="0559876543",
        ),
    )

    second_child = create_child(
        client,
        parent_data["access_token"],
        valid_child_data(
            name="Noura",
            birth_date="2014-06-15",
            phone="0558765432",
        ),
    )

    delete_response = delete_me(
        client,
        parent_data["access_token"],
    )

    assert delete_response.status_code == 200, delete_response.get_json()

    for child in (first_child, second_child):
        login_response = client.post(
            CHILD_LOGIN_URL,
            json={
                "access_code": child["access_code"],
            },
        )

        login_data = login_response.get_json()

        assert login_response.status_code in (
            401,
            404,
        ), login_data

        assert "access_token" not in login_data


def test_parent_with_multiple_children_is_deleted_successfully(
    client,
):
    parent_data, _ = register_parent(client)

    create_child(
        client,
        parent_data["access_token"],
        valid_child_data(
            name="Sara",
            phone="0559876543",
        ),
    )

    create_child(
        client,
        parent_data["access_token"],
        valid_child_data(
            name="Noura",
            birth_date="2014-03-12",
            phone="0558765432",
        ),
    )

    response = delete_me(
        client,
        parent_data["access_token"],
    )

    response_data = response.get_json()

    assert response.status_code == 200, response_data
    assert response_data == {
        "message": "User deleted successfully",
    }


# =========================================================
# User not found
# =========================================================


def test_delete_returns_404_for_unknown_parent(
    client,
    app,
):
    with app.app_context():
        token = create_access_token(
            identity=str(uuid4()),
            additional_claims={"role": "parent"},
        )

    response = delete_me(
        client,
        token,
    )

    response_data = response.get_json()

    assert response.status_code == 404, response_data
    assert response_data["error"] == "User not found"


def test_delete_unknown_parent_does_not_return_success_message(
    client,
    app,
):
    with app.app_context():
        token = create_access_token(
            identity=str(uuid4()),
            additional_claims={"role": "parent"},
        )

    response = delete_me(
        client,
        token,
    )

    response_data = response.get_json()

    assert response.status_code == 404, response_data
    assert "message" not in response_data
    assert response_data == {
        "error": "User not found",
    }


# =========================================================
# Authorization
# =========================================================


def test_delete_rejects_child_access_token(client):
    _, _, child_login_data = create_child_and_login(client)

    response = delete_me(
        client,
        child_login_data["access_token"],
    )

    response_data = response.get_json()

    assert response.status_code == 403, response_data
    assert response_data["error"] == "Parent access only"


@pytest.mark.parametrize(
    "invalid_role",
    [
        "child",
        "admin",
        "guardian",
        "mother",
        "father",
        "",
        None,
        123,
    ],
)
def test_delete_rejects_invalid_roles(
    client,
    app,
    invalid_role,
):
    with app.app_context():
        token = create_access_token(
            identity=str(uuid4()),
            additional_claims={
                "role": invalid_role,
            },
        )

    response = delete_me(
        client,
        token,
    )

    response_data = response.get_json()

    assert response.status_code == 403, response_data
    assert response_data["error"] == "Parent access only"


def test_delete_rejects_token_without_role(client, app):
    with app.app_context():
        token = create_access_token(
            identity=str(uuid4()),
        )

    response = delete_me(
        client,
        token,
    )

    response_data = response.get_json()

    assert response.status_code == 403, response_data
    assert response_data["error"] == "Parent access only"


def test_delete_without_authorization_header_is_rejected(client):
    response = client.delete(
        DELETE_ME_URL,
    )

    response_data = response.get_json()

    assert response.status_code == 401, response_data


def test_delete_rejects_refresh_token(client):
    parent_data, _ = register_parent(client)

    response = delete_me(
        client,
        parent_data["refresh_token"],
    )

    response_data = response.get_json()

    assert response.status_code in (
        401,
        422,
    ), response_data


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
def test_delete_rejects_malformed_tokens(
    client,
    invalid_token,
):
    response = client.delete(
        DELETE_ME_URL,
        headers={
            "Authorization": invalid_token,
        },
    )

    response_data = response.get_json()

    assert response.status_code in (
        401,
        422,
    ), response_data


def test_delete_rejects_tampered_access_token(client):
    parent_data, _ = register_parent(client)

    token = parent_data["access_token"]

    tampered_token = (
        token[:-1]
        + ("a" if token[-1] != "a" else "b")
    )

    response = delete_me(
        client,
        tampered_token,
    )

    response_data = response.get_json()

    assert response.status_code in (
        401,
        422,
    ), response_data


def test_delete_rejects_expired_access_token(
    client,
    app,
):
    with app.app_context():
        expired_token = create_access_token(
            identity=str(uuid4()),
            additional_claims={"role": "parent"},
            expires_delta=timedelta(seconds=-1),
        )

    response = delete_me(
        client,
        expired_token,
    )

    response_data = response.get_json()

    assert response.status_code == 401, response_data


def test_delete_rejects_revoked_access_token(client):
    parent_data, _ = register_parent(client)

    access_token = parent_data["access_token"]

    logout_response = client.post(
        LOGOUT_URL,
        headers=auth_headers(access_token),
    )

    assert logout_response.status_code == 200, logout_response.get_json()

    response = delete_me(
        client,
        access_token,
    )

    response_data = response.get_json()

    assert response.status_code == 401, response_data


# =========================================================
# Request body and query parameters
# =========================================================


def test_delete_succeeds_without_request_body(client):
    parent_data, _ = register_parent(client)

    response = client.delete(
        DELETE_ME_URL,
        headers=auth_headers(
            parent_data["access_token"],
        ),
    )

    response_data = response.get_json()

    assert response.status_code == 200, response_data
    assert response_data["message"] == "User deleted successfully"


def test_delete_ignores_json_request_body(client):
    parent_data, _ = register_parent(client)

    response = client.delete(
        DELETE_ME_URL,
        headers=auth_headers(
            parent_data["access_token"],
        ),
        json={
            "first_name": "Should be ignored",
            "user_id": str(uuid4()),
        },
    )

    response_data = response.get_json()

    assert response.status_code == 200, response_data
    assert response_data == {
        "message": "User deleted successfully",
    }


def test_delete_ignores_query_parameters(client):
    parent_data, _ = register_parent(client)

    response = client.delete(
        f"{DELETE_ME_URL}?user_id={uuid4()}&force=true",
        headers=auth_headers(
            parent_data["access_token"],
        ),
    )

    response_data = response.get_json()

    assert response.status_code == 200, response_data
    assert response_data == {
        "message": "User deleted successfully",
    }


# =========================================================
# Service error mapping
# =========================================================


def test_delete_maps_user_not_found_error_to_404(
    client,
    monkeypatch,
):
    parent_data, _ = register_parent(client)

    def fake_delete_user(user_id):
        return False, "user_not_found"

    monkeypatch.setattr(
        user_service,
        "delete_user",
        fake_delete_user,
    )

    response = delete_me(
        client,
        parent_data["access_token"],
    )

    response_data = response.get_json()

    assert response.status_code == 404, response_data
    assert response_data == {
        "error": "User not found",
    }


def test_delete_maps_delete_error_to_500(
    client,
    monkeypatch,
):
    parent_data, _ = register_parent(client)

    def fake_delete_user(user_id):
        return False, "delete_error"

    monkeypatch.setattr(
        user_service,
        "delete_user",
        fake_delete_user,
    )

    response = delete_me(
        client,
        parent_data["access_token"],
    )

    response_data = response.get_json()

    assert response.status_code == 500, response_data
    assert response_data == {
        "error": "Failed to delete user and related data",
    }


def test_delete_maps_service_success_to_200(
    client,
    monkeypatch,
):
    parent_data, _ = register_parent(client)

    received_user_ids = []

    def fake_delete_user(user_id):
        received_user_ids.append(str(user_id))
        return True, None

    monkeypatch.setattr(
        user_service,
        "delete_user",
        fake_delete_user,
    )

    response = delete_me(
        client,
        parent_data["access_token"],
    )

    response_data = response.get_json()

    assert response.status_code == 200, response_data
    assert response_data == {
        "message": "User deleted successfully",
    }

    assert received_user_ids == [
        str(parent_data["user"]["id"]),
    ]


def test_delete_does_not_return_success_on_service_failure(
    client,
    monkeypatch,
):
    parent_data, _ = register_parent(client)

    def fake_delete_user(user_id):
        return False, "delete_error"

    monkeypatch.setattr(
        user_service,
        "delete_user",
        fake_delete_user,
    )

    response = delete_me(
        client,
        parent_data["access_token"],
    )

    response_data = response.get_json()

    assert response.status_code == 500, response_data
    assert "message" not in response_data
    assert "error" in response_data


# =========================================================
# Transaction rollback
# =========================================================


def test_delete_service_returns_delete_error_when_commit_fails(
    client,
    app,
    monkeypatch,
):
    parent_data, _ = register_parent(client)

    user_id = parent_data["user"]["id"]

    rollback_called = []

    def failing_commit():
        raise Exception("Database commit failed")

    original_rollback = db.session.rollback

    def tracked_rollback():
        rollback_called.append(True)
        return original_rollback()

    with app.app_context():
        monkeypatch.setattr(
            db.session,
            "commit",
            failing_commit,
        )

        monkeypatch.setattr(
            db.session,
            "rollback",
            tracked_rollback,
        )

        success, error = user_service.delete_user(
            user_id,
        )

    assert success is False
    assert error == "delete_error"
    assert rollback_called == [True]


def test_delete_route_returns_500_when_database_commit_fails(
    client,
    monkeypatch,
):
    parent_data, _ = register_parent(client)

    def fake_delete_user(user_id):
        return False, "delete_error"

    monkeypatch.setattr(
        user_service,
        "delete_user",
        fake_delete_user,
    )

    response = delete_me(
        client,
        parent_data["access_token"],
    )

    response_data = response.get_json()

    assert response.status_code == 500, response_data
    assert response_data["error"] == (
        "Failed to delete user and related data"
    )