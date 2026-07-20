import pytest
from flask_jwt_extended import decode_token


REGISTER_URL = "/api/auth/register"
CHILDREN_URL = "/api/children/"
CHILD_LOGIN_URL = "/api/auth/child-login"

PARENT_EMAIL = "parent.child.login@gmail.com"
PARENT_PASSWORD = "Password123!"


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


def register_parent(client, data=None):
    register_data = data or valid_parent_register_data()

    response = client.post(
        REGISTER_URL,
        json=register_data,
    )

    response_data = response.get_json()

    assert response.status_code == 201, response_data
    assert "access_token" in response_data

    return response_data


def get_parent_auth_headers(access_token):
    return {
        "Authorization": access_token,
    }


def extract_child_data(response_data):
    """
    Supports either response shape:

    {
        "id": "...",
        "name": "...",
        "access_code": "123456"
    }

    or:

    {
        "child": {
            "id": "...",
            "name": "...",
            "access_code": "123456"
        }
    }
    """
    if "child" in response_data:
        return response_data["child"]

    return response_data


def create_child(client, child_data=None):
    parent_data = register_parent(client)
    access_token = parent_data["access_token"]

    response = client.post(
        CHILDREN_URL,
        json=child_data or valid_child_data(),
        headers=get_parent_auth_headers(access_token),
    )

    response_data = response.get_json()

    assert response.status_code == 201, response_data

    child = extract_child_data(response_data)

    assert "id" in child
    assert "access_code" in child

    return child


def login_child(client, access_code):
    return client.post(
        CHILD_LOGIN_URL,
        json={"access_code": access_code},
    )


# =========================================================
# Successful child login
# =========================================================


def test_child_login_success(client):
    child = create_child(client)

    response = login_child(
        client,
        child["access_code"],
    )

    response_data = response.get_json()

    assert response.status_code == 200, response_data

    assert "access_token" in response_data
    assert "refresh_token" in response_data
    assert "child" in response_data

    assert response_data["child"]["id"] == child["id"]
    assert response_data["child"]["name"] == child["name"]


def test_child_login_returns_non_empty_tokens(client):
    child = create_child(client)

    response = login_child(
        client,
        child["access_code"],
    )

    response_data = response.get_json()

    assert response.status_code == 200, response_data

    assert isinstance(response_data["access_token"], str)
    assert isinstance(response_data["refresh_token"], str)

    assert response_data["access_token"]
    assert response_data["refresh_token"]


def test_child_login_returns_correct_child(client):
    child = create_child(client)

    response = login_child(
        client,
        child["access_code"],
    )

    response_data = response.get_json()

    assert response.status_code == 200, response_data

    returned_child = response_data["child"]

    assert returned_child["id"] == child["id"]
    assert returned_child["name"] == child["name"]


def test_child_login_tokens_have_correct_claims(client, app):
    child = create_child(client)

    response = login_child(
        client,
        child["access_code"],
    )

    response_data = response.get_json()

    assert response.status_code == 200, response_data

    with app.app_context():
        access_token_data = decode_token(
            response_data["access_token"]
        )
        refresh_token_data = decode_token(
            response_data["refresh_token"]
        )

    assert access_token_data["sub"] == child["id"]
    assert access_token_data["role"] == "child"
    assert access_token_data["type"] == "access"

    assert refresh_token_data["sub"] == child["id"]
    assert refresh_token_data["role"] == "child"
    assert refresh_token_data["type"] == "refresh"


def test_child_login_access_and_refresh_tokens_are_different(client):
    child = create_child(client)

    response = login_child(
        client,
        child["access_code"],
    )

    response_data = response.get_json()

    assert response.status_code == 200, response_data

    assert (
        response_data["access_token"]
        != response_data["refresh_token"]
    )


def test_child_login_response_does_not_return_parent_data(client):
    child = create_child(client)

    response = login_child(
        client,
        child["access_code"],
    )

    response_data = response.get_json()

    assert response.status_code == 200, response_data

    assert "user" not in response_data
    assert "parent" not in response_data
    assert "password" not in response_data
    assert "password_hash" not in response_data


# =========================================================
# Access code length and format
# =========================================================


@pytest.mark.parametrize(
    "invalid_access_code",
    [
        "",
        "1",
        "12345",
        "1234567",
        "12345678",
    ],
)
def test_child_login_rejects_invalid_access_code_length(
    client,
    invalid_access_code,
):
    response = login_child(
        client,
        invalid_access_code,
    )

    response_data = response.get_json()

    assert response.status_code == 400, response_data
    assert "errors" in response_data
    assert "access_code" in response_data["errors"]


@pytest.mark.parametrize(
    "invalid_access_code",
    [
        "abcdef",
        "ABCDEF",
        "12345A",
        "A12345",
        "12@456",
        "12 456",
        "-12345",
        "123.45",
        "١٢٣٤٥٦",
    ],
)
def test_child_login_rejects_non_digit_access_codes(
    client,
    invalid_access_code,
):
    response = login_child(
        client,
        invalid_access_code,
    )

    response_data = response.get_json()

    assert response.status_code == 400, response_data
    assert "errors" in response_data
    assert "access_code" in response_data["errors"]


def test_child_login_rejects_access_code_with_surrounding_spaces(
    client,
):
    response = login_child(
        client,
        " 123456 ",
    )

    response_data = response.get_json()

    assert response.status_code == 400, response_data
    assert "errors" in response_data
    assert "access_code" in response_data["errors"]


def test_child_login_accepts_code_starting_with_zero(client):
    child = create_child(client)

    original_code = child["access_code"]

    assert len(original_code) == 6
    assert original_code.isdigit()

    response = login_child(
        client,
        original_code,
    )

    response_data = response.get_json()

    assert response.status_code == 200, response_data


# =========================================================
# Unknown access code
# =========================================================


def get_unused_access_code(existing_code):
    candidates = [
        "000000",
        "111111",
        "222222",
        "333333",
        "444444",
        "555555",
        "666666",
        "777777",
        "888888",
        "999999",
    ]

    for candidate in candidates:
        if candidate != existing_code:
            return candidate

    raise AssertionError("Could not generate unused access code")


def test_child_login_with_unknown_access_code(client):
    child = create_child(client)

    unknown_code = get_unused_access_code(
        child["access_code"]
    )

    response = login_child(
        client,
        unknown_code,
    )

    response_data = response.get_json()

    assert response.status_code == 401, response_data
    assert response_data["error"] == "Invalid access code"


def test_unknown_access_code_does_not_return_tokens_or_child(client):
    child = create_child(client)

    unknown_code = get_unused_access_code(
        child["access_code"]
    )

    response = login_child(
        client,
        unknown_code,
    )

    response_data = response.get_json()

    assert response.status_code == 401, response_data

    assert "access_token" not in response_data
    assert "refresh_token" not in response_data
    assert "child" not in response_data


# =========================================================
# Missing required field
# =========================================================


def test_child_login_rejects_missing_access_code(client):
    response = client.post(
        CHILD_LOGIN_URL,
        json={},
    )

    response_data = response.get_json()

    assert response.status_code == 400, response_data
    assert "errors" in response_data
    assert "access_code" in response_data["errors"]


def test_child_login_rejects_empty_json_body(client):
    response = client.post(
        CHILD_LOGIN_URL,
        json={},
    )

    response_data = response.get_json()

    assert response.status_code == 400, response_data
    assert "errors" in response_data
    assert "access_code" in response_data["errors"]


def test_child_login_rejects_null_access_code(client):
    response = client.post(
        CHILD_LOGIN_URL,
        json={"access_code": None},
    )

    response_data = response.get_json()

    assert response.status_code == 400, response_data
    assert "errors" in response_data
    assert "access_code" in response_data["errors"]


# =========================================================
# Invalid access code types
# =========================================================


@pytest.mark.parametrize(
    "invalid_access_code",
    [
        123456,
        123.456,
        True,
        False,
        [],
        {},
    ],
)
def test_child_login_rejects_invalid_access_code_types(
    client,
    invalid_access_code,
):
    response = client.post(
        CHILD_LOGIN_URL,
        json={"access_code": invalid_access_code},
    )

    response_data = response.get_json()

    assert response.status_code == 400, response_data
    assert "errors" in response_data
    assert "access_code" in response_data["errors"]


# =========================================================
# Unknown fields and invalid body shapes
# =========================================================


def test_child_login_rejects_unknown_field(client):
    response = client.post(
        CHILD_LOGIN_URL,
        json={
            "access_code": "123456",
            "unexpected_field": "unexpected value",
        },
    )

    response_data = response.get_json()

    assert response.status_code == 400, response_data
    assert "errors" in response_data
    assert "unexpected_field" in response_data["errors"]


@pytest.mark.parametrize(
    "invalid_body",
    [
        [],
        ["123456"],
        "123456",
        123456,
        True,
    ],
)
def test_child_login_rejects_non_object_json_body(
    client,
    invalid_body,
):
    response = client.post(
        CHILD_LOGIN_URL,
        json=invalid_body,
    )

    response_data = response.get_json()

    assert response.status_code == 400, response_data
    assert "errors" in response_data


def test_child_login_without_request_body_returns_bad_request(client):
    response = client.post(
        CHILD_LOGIN_URL,
        content_type="application/json",
    )

    response_data = response.get_json()

    assert response.status_code == 400, response_data


# =========================================================
# Multiple children
# =========================================================


def create_two_children(client):
    parent_data = register_parent(client)
    headers = get_parent_auth_headers(
        parent_data["access_token"]
    )

    first_response = client.post(
        CHILDREN_URL,
        headers=headers,
        json={
            "name": "Sara",
            "birth_date": "2015-05-10",
            "phone": "0559876543",
        },
    )

    first_response_data = first_response.get_json()

    assert first_response.status_code == 201, first_response_data

    second_response = client.post(
        CHILDREN_URL,
        headers=headers,
        json={
            "name": "Khalid",
            "birth_date": "2014-06-15",
            "phone": "0558765432",
        },
    )

    second_response_data = second_response.get_json()

    assert second_response.status_code == 201, second_response_data

    first_child = extract_child_data(first_response_data)
    second_child = extract_child_data(second_response_data)

    return first_child, second_child


def test_two_different_children_can_login(client):
    first_child, second_child = create_two_children(client)

    first_response = login_child(
        client,
        first_child["access_code"],
    )

    second_response = login_child(
        client,
        second_child["access_code"],
    )

    first_data = first_response.get_json()
    second_data = second_response.get_json()

    assert first_response.status_code == 200, first_data
    assert second_response.status_code == 200, second_data

    assert first_data["child"]["id"] == first_child["id"]
    assert second_data["child"]["id"] == second_child["id"]

    assert (
        first_data["child"]["id"]
        != second_data["child"]["id"]
    )


def test_first_child_code_returns_first_child_only(client):
    first_child, second_child = create_two_children(client)

    response = login_child(
        client,
        first_child["access_code"],
    )

    response_data = response.get_json()

    assert response.status_code == 200, response_data

    assert response_data["child"]["id"] == first_child["id"]
    assert response_data["child"]["id"] != second_child["id"]


def test_second_child_code_returns_second_child_only(client):
    first_child, second_child = create_two_children(client)

    response = login_child(
        client,
        second_child["access_code"],
    )

    response_data = response.get_json()

    assert response.status_code == 200, response_data

    assert response_data["child"]["id"] == second_child["id"]
    assert response_data["child"]["id"] != first_child["id"]


# =========================================================
# Repeated child login
# =========================================================


def test_same_child_can_login_multiple_times(client):
    child = create_child(client)

    first_response = login_child(
        client,
        child["access_code"],
    )

    second_response = login_child(
        client,
        child["access_code"],
    )

    first_data = first_response.get_json()
    second_data = second_response.get_json()

    assert first_response.status_code == 200, first_data
    assert second_response.status_code == 200, second_data

    assert first_data["child"]["id"] == child["id"]
    assert second_data["child"]["id"] == child["id"]

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