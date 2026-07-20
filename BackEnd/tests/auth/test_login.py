import pytest
from flask_jwt_extended import decode_token


LOGIN_URL = "/api/auth/login"
REGISTER_URL = "/api/auth/register"

VALID_EMAIL = "manar.testing2026@gmail.com"
VALID_PASSWORD = "Password123!"


def valid_register_data():
    return {
        "first_name": "Manar",
        "last_name": "Zaid",
        "phone": "0551234567",
        "email": VALID_EMAIL,
        "password": VALID_PASSWORD,
        "guardian_type": "mother",
    }


def valid_login_data():
    return {
        "email": VALID_EMAIL,
        "password": VALID_PASSWORD,
    }


def register_user(client, data=None):
    register_data = data or valid_register_data()

    response = client.post(
        REGISTER_URL,
        json=register_data,
    )

    assert response.status_code == 201, response.get_json()

    return response.get_json()


# =========================================================
# Successful login
# =========================================================


def test_login_success(client):
    registered_user = register_user(client)

    response = client.post(
        LOGIN_URL,
        json=valid_login_data(),
    )

    response_data = response.get_json()

    assert response.status_code == 200, response_data

    assert "access_token" in response_data
    assert "refresh_token" in response_data
    assert "user" in response_data

    assert response_data["user"]["id"] == registered_user["user"]["id"]
    assert response_data["user"]["first_name"] == "Manar"
    assert response_data["user"]["last_name"] == "Zaid"
    assert response_data["user"]["email"] == VALID_EMAIL
    assert response_data["user"]["phone"] == "0551234567"
    assert response_data["user"]["guardian_type"] == "mother"
    assert response_data["user"]["role"] == "parent"


def test_login_returns_non_empty_tokens(client):
    register_user(client)

    response = client.post(
        LOGIN_URL,
        json=valid_login_data(),
    )

    response_data = response.get_json()

    assert response.status_code == 200, response_data

    assert isinstance(response_data["access_token"], str)
    assert isinstance(response_data["refresh_token"], str)

    assert response_data["access_token"]
    assert response_data["refresh_token"]


def test_login_response_does_not_expose_password(client):
    register_user(client)

    response = client.post(
        LOGIN_URL,
        json=valid_login_data(),
    )

    response_data = response.get_json()

    assert response.status_code == 200, response_data

    assert "password" not in response_data["user"]
    assert "password_hash" not in response_data["user"]


def test_login_returns_parent_role(client):
    register_user(client)

    response = client.post(
        LOGIN_URL,
        json=valid_login_data(),
    )

    response_data = response.get_json()

    assert response.status_code == 200, response_data
    assert response_data["user"]["role"] == "parent"


def test_login_tokens_contain_correct_claims(client, app):
    registered_user = register_user(client)

    response = client.post(
        LOGIN_URL,
        json=valid_login_data(),
    )

    response_data = response.get_json()

    assert response.status_code == 200, response_data

    with app.app_context():
        access_token = decode_token(response_data["access_token"])
        refresh_token = decode_token(response_data["refresh_token"])

    assert access_token["sub"] == registered_user["user"]["id"]
    assert access_token["role"] == "parent"
    assert access_token["type"] == "access"

    assert refresh_token["sub"] == registered_user["user"]["id"]
    assert refresh_token["role"] == "parent"
    assert refresh_token["type"] == "refresh"


# =========================================================
# Email cases
# =========================================================


def test_login_with_nonexistent_email(client):
    register_user(client)

    data = valid_login_data()
    data["email"] = "another.testing2026@gmail.com"

    response = client.post(
        LOGIN_URL,
        json=data,
    )

    response_data = response.get_json()

    assert response.status_code == 401, response_data
    assert response_data["error"] == "Invalid email or password"


@pytest.mark.parametrize(
    "invalid_email",
    [
        "manar",
        "manar@",
        "@gmail.com",
        "manar@gmail",
        "manar gmail@gmail.com",
        "",
    ],
)
def test_login_rejects_invalid_email_format(client, invalid_email):
    data = valid_login_data()
    data["email"] = invalid_email

    response = client.post(
        LOGIN_URL,
        json=data,
    )

    response_data = response.get_json()

    assert response.status_code == 400, response_data
    assert "errors" in response_data
    assert "email" in response_data["errors"]


def test_login_email_is_case_insensitive(client):
    register_user(client)

    data = valid_login_data()
    data["email"] = "MANAR.TESTING2026@GMAIL.COM"

    response = client.post(
        LOGIN_URL,
        json=data,
    )

    response_data = response.get_json()

    assert response.status_code == 200, response_data
    assert response_data["user"]["email"] == VALID_EMAIL


def test_login_email_with_mixed_case(client):
    register_user(client)

    data = valid_login_data()
    data["email"] = "MaNaR.TeStInG2026@GmAiL.CoM"

    response = client.post(
        LOGIN_URL,
        json=data,
    )

    response_data = response.get_json()

    assert response.status_code == 200, response_data
    assert response_data["user"]["email"] == VALID_EMAIL


def test_login_email_with_surrounding_spaces_is_rejected(client):
    register_user(client)

    data = valid_login_data()
    data["email"] = f"  {VALID_EMAIL}  "

    response = client.post(
        LOGIN_URL,
        json=data,
    )

    response_data = response.get_json()

    assert response.status_code == 400, response_data
    assert "errors" in response_data
    assert "email" in response_data["errors"]


# =========================================================
# Password cases
# =========================================================


def test_login_with_wrong_password(client):
    register_user(client)

    data = valid_login_data()
    data["password"] = "WrongPassword123!"

    response = client.post(
        LOGIN_URL,
        json=data,
    )

    response_data = response.get_json()

    assert response.status_code == 401, response_data
    assert response_data["error"] == "Invalid email or password"


def test_login_password_is_case_sensitive(client):
    register_user(client)

    data = valid_login_data()
    data["password"] = "password123!"

    response = client.post(
        LOGIN_URL,
        json=data,
    )

    response_data = response.get_json()

    assert response.status_code == 401, response_data
    assert response_data["error"] == "Invalid email or password"


def test_login_password_with_leading_space_fails(client):
    register_user(client)

    data = valid_login_data()
    data["password"] = f" {VALID_PASSWORD}"

    response = client.post(
        LOGIN_URL,
        json=data,
    )

    response_data = response.get_json()

    assert response.status_code == 401, response_data
    assert response_data["error"] == "Invalid email or password"


def test_login_password_with_trailing_space_fails(client):
    register_user(client)

    data = valid_login_data()
    data["password"] = f"{VALID_PASSWORD} "

    response = client.post(
        LOGIN_URL,
        json=data,
    )

    response_data = response.get_json()

    assert response.status_code == 401, response_data
    assert response_data["error"] == "Invalid email or password"


def test_login_with_empty_password_returns_unauthorized(client):
    register_user(client)

    data = valid_login_data()
    data["password"] = ""

    response = client.post(
        LOGIN_URL,
        json=data,
    )

    response_data = response.get_json()

    assert response.status_code == 401, response_data
    assert response_data["error"] == "Invalid email or password"


# =========================================================
# Missing required fields
# =========================================================


@pytest.mark.parametrize(
    "missing_field",
    [
        "email",
        "password",
    ],
)
def test_login_rejects_missing_required_fields(client, missing_field):
    data = valid_login_data()
    data.pop(missing_field)

    response = client.post(
        LOGIN_URL,
        json=data,
    )

    response_data = response.get_json()

    assert response.status_code == 400, response_data
    assert "errors" in response_data
    assert missing_field in response_data["errors"]


def test_login_rejects_empty_json_body(client):
    response = client.post(
        LOGIN_URL,
        json={},
    )

    response_data = response.get_json()

    assert response.status_code == 400, response_data
    assert "errors" in response_data
    assert "email" in response_data["errors"]
    assert "password" in response_data["errors"]


# =========================================================
# Null values
# =========================================================


@pytest.mark.parametrize(
    "field_name",
    [
        "email",
        "password",
    ],
)
def test_login_rejects_null_required_fields(client, field_name):
    data = valid_login_data()
    data[field_name] = None

    response = client.post(
        LOGIN_URL,
        json=data,
    )

    response_data = response.get_json()

    assert response.status_code == 400, response_data
    assert "errors" in response_data
    assert field_name in response_data["errors"]


# =========================================================
# Invalid field types
# =========================================================


@pytest.mark.parametrize(
    ("field_name", "invalid_value"),
    [
        ("email", 123),
        ("email", True),
        ("email", []),
        ("email", {}),
        ("password", 123),
        ("password", True),
        ("password", []),
        ("password", {}),
    ],
)
def test_login_rejects_invalid_field_types(
    client,
    field_name,
    invalid_value,
):
    data = valid_login_data()
    data[field_name] = invalid_value

    response = client.post(
        LOGIN_URL,
        json=data,
    )

    response_data = response.get_json()

    assert response.status_code == 400, response_data
    assert "errors" in response_data
    assert field_name in response_data["errors"]


# =========================================================
# Unexpected fields and body types
# =========================================================


def test_login_rejects_unknown_field(client):
    data = valid_login_data()
    data["unexpected_field"] = "unexpected value"

    response = client.post(
        LOGIN_URL,
        json=data,
    )

    response_data = response.get_json()

    assert response.status_code == 400, response_data
    assert "errors" in response_data
    assert "unexpected_field" in response_data["errors"]


@pytest.mark.parametrize(
    "invalid_body",
    [
        [],
        ["email", "password"],
        "invalid body",
        123,
        True,
    ],
)
def test_login_rejects_non_object_json_body(client, invalid_body):
    response = client.post(
        LOGIN_URL,
        json=invalid_body,
    )

    response_data = response.get_json()

    assert response.status_code == 400, response_data
    assert "errors" in response_data


def test_login_without_request_body_returns_bad_request(client):
    response = client.post(
        LOGIN_URL,
        content_type="application/json",
    )

    response_data = response.get_json()

    assert response.status_code == 400, response_data


# =========================================================
# Security and consistent errors
# =========================================================


def test_login_wrong_password_and_unknown_email_return_same_error(client):
    register_user(client)

    wrong_password_response = client.post(
        LOGIN_URL,
        json={
            "email": VALID_EMAIL,
            "password": "WrongPassword123!",
        },
    )

    unknown_email_response = client.post(
        LOGIN_URL,
        json={
            "email": "unknown.testing2026@gmail.com",
            "password": VALID_PASSWORD,
        },
    )

    wrong_password_data = wrong_password_response.get_json()
    unknown_email_data = unknown_email_response.get_json()

    assert wrong_password_response.status_code == 401
    assert unknown_email_response.status_code == 401

    assert wrong_password_data["error"] == "Invalid email or password"
    assert unknown_email_data["error"] == "Invalid email or password"


@pytest.mark.parametrize(
    "login_data",
    [
        {
            "email": VALID_EMAIL,
            "password": "WrongPassword123!",
        },
        {
            "email": "unknown.testing2026@gmail.com",
            "password": VALID_PASSWORD,
        },
    ],
)
def test_failed_login_does_not_return_tokens_or_user(
    client,
    login_data,
):
    register_user(client)

    response = client.post(
        LOGIN_URL,
        json=login_data,
    )

    response_data = response.get_json()

    assert response.status_code == 401, response_data

    assert "access_token" not in response_data
    assert "refresh_token" not in response_data
    assert "user" not in response_data


# =========================================================
# Multiple users
# =========================================================


def test_two_different_users_can_login(client):
    first_user = valid_register_data()
    register_user(client, first_user)

    second_user = {
        "first_name": "Sara",
        "last_name": "Ahmed",
        "phone": "0559876543",
        "email": "sara.testing2026@gmail.com",
        "password": "SecondPassword123!",
        "guardian_type": "father",
    }
    register_user(client, second_user)

    first_login_response = client.post(
        LOGIN_URL,
        json={
            "email": first_user["email"],
            "password": first_user["password"],
        },
    )

    second_login_response = client.post(
        LOGIN_URL,
        json={
            "email": second_user["email"],
            "password": second_user["password"],
        },
    )

    first_login_data = first_login_response.get_json()
    second_login_data = second_login_response.get_json()

    assert first_login_response.status_code == 200, first_login_data
    assert second_login_response.status_code == 200, second_login_data

    assert first_login_data["user"]["email"] == first_user["email"]
    assert second_login_data["user"]["email"] == second_user["email"]

    assert (
        first_login_data["user"]["id"]
        != second_login_data["user"]["id"]
    )


def test_first_user_password_does_not_work_for_second_user(client):
    first_user = valid_register_data()
    register_user(client, first_user)

    second_user = {
        "first_name": "Sara",
        "last_name": "Ahmed",
        "phone": "0559876543",
        "email": "sara.testing2026@gmail.com",
        "password": "SecondPassword123!",
        "guardian_type": "father",
    }
    register_user(client, second_user)

    response = client.post(
        LOGIN_URL,
        json={
            "email": second_user["email"],
            "password": first_user["password"],
        },
    )

    response_data = response.get_json()

    assert response.status_code == 401, response_data
    assert response_data["error"] == "Invalid email or password"


def test_second_user_password_does_not_work_for_first_user(client):
    first_user = valid_register_data()
    register_user(client, first_user)

    second_user = {
        "first_name": "Sara",
        "last_name": "Ahmed",
        "phone": "0559876543",
        "email": "sara.testing2026@gmail.com",
        "password": "SecondPassword123!",
        "guardian_type": "father",
    }
    register_user(client, second_user)

    response = client.post(
        LOGIN_URL,
        json={
            "email": first_user["email"],
            "password": second_user["password"],
        },
    )

    response_data = response.get_json()

    assert response.status_code == 401, response_data
    assert response_data["error"] == "Invalid email or password"


# =========================================================
# Repeated login
# =========================================================


def test_same_user_can_login_multiple_times(client):
    register_user(client)

    first_response = client.post(
        LOGIN_URL,
        json=valid_login_data(),
    )

    second_response = client.post(
        LOGIN_URL,
        json=valid_login_data(),
    )

    first_data = first_response.get_json()
    second_data = second_response.get_json()

    assert first_response.status_code == 200, first_data
    assert second_response.status_code == 200, second_data

    assert first_data["user"]["id"] == second_data["user"]["id"]

    assert first_data["access_token"]
    assert second_data["access_token"]

    assert first_data["refresh_token"]
    assert second_data["refresh_token"]

    assert (
        first_data["access_token"]
        != second_data["access_token"]
    )

    assert (
        first_data["refresh_token"]
        != second_data["refresh_token"]
    )