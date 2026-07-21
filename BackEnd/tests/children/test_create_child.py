from datetime import date, timedelta
from types import SimpleNamespace
from uuid import uuid4

import pytest
from flask_jwt_extended import create_access_token
from sqlalchemy.exc import IntegrityError

from app.extensions import db
from app.models import Child, User
from app.repositories.child_repository import ChildRepository
from app.routes.child_routes import child_service
from app.schemas import ChildCreateSchema
from app.utils.datetime_utils import riyadh_today


REGISTER_URL = "/api/auth/register"
CHILDREN_URL = "/api/children/"
CHILD_LOGIN_URL = "/api/auth/child-login"
LOGOUT_URL = "/api/auth/logout"

child_create_schema = ChildCreateSchema()


# =========================================================
# Helpers
# =========================================================


def authorization_header(token):
    return {"Authorization": token}


def birth_date_for_exact_age(age):
    """
    Returns a date representing exactly `age` years old today.
    """
    today = riyadh_today()

    try:
        return today.replace(year=today.year - age)
    except ValueError:
        # Handles February 29.
        return today.replace(
            year=today.year - age,
            day=28,
        )


def valid_parent_data(
    *,
    first_name="Manar",
    last_name="Zaid",
    phone="0551111111",
    email="child.tests.parent@gmail.com",
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
    birth_date=None,
    phone="0552222222",
):
    if birth_date is None:
        birth_date = birth_date_for_exact_age(10)

    if isinstance(birth_date, date):
        birth_date = birth_date.isoformat()

    return {
        "name": name,
        "birth_date": birth_date,
        "phone": phone,
    }


def register_parent(client, parent_data=None):
    payload = parent_data or valid_parent_data()

    response = client.post(
        REGISTER_URL,
        json=payload,
    )
    response_data = response.get_json()

    assert response.status_code == 201, response_data
    assert "access_token" in response_data
    assert "refresh_token" in response_data

    return response_data, payload


def create_child_request(
    client,
    token,
    payload=None,
    **kwargs,
):
    request_kwargs = {
        "headers": authorization_header(token),
    }

    if payload is not None:
        request_kwargs["json"] = payload

    request_kwargs.update(kwargs)

    return client.post(
        CHILDREN_URL,
        **request_kwargs,
    )


def extract_created_child(response_data):
    """
    The current route returns the serialized child directly.
    This fallback also supports a wrapped {"child": {...}} response.
    """
    if isinstance(response_data, dict) and "child" in response_data:
        return response_data["child"]

    return response_data


def create_parent_and_child(
    client,
    *,
    parent_data=None,
    child_data=None,
):
    parent_response, _ = register_parent(
        client,
        parent_data,
    )

    response = create_child_request(
        client,
        parent_response["access_token"],
        child_data or valid_child_data(),
    )

    response_data = response.get_json()

    assert response.status_code == 201, response_data

    return (
        parent_response,
        extract_created_child(response_data),
    )


# =========================================================
# Successful creation
# =========================================================


def test_create_child_success(client):
    parent_response, _ = register_parent(client)

    response = create_child_request(
        client,
        parent_response["access_token"],
        valid_child_data(),
    )

    response_data = response.get_json()
    child = extract_created_child(response_data)

    assert response.status_code == 201, response_data
    assert child["name"] == "Sara"
    assert child["birth_date"] == birth_date_for_exact_age(10).isoformat()
    assert child["phone"] == "0552222222"
    assert child["role"] == "child"


def test_create_child_response_contains_expected_fields(client):
    parent_response, _ = register_parent(client)

    response = create_child_request(
        client,
        parent_response["access_token"],
        valid_child_data(),
    )

    response_data = response.get_json()
    child = extract_created_child(response_data)

    assert response.status_code == 201, response_data

    assert set(child.keys()) == {
        "id",
        "name",
        "birth_date",
        "phone",
        "age",
        "access_code",
        "role",
    }


def test_create_child_returns_access_code_as_string(client):
    parent_response, _ = register_parent(client)

    response = create_child_request(
        client,
        parent_response["access_token"],
        valid_child_data(),
    )

    child = extract_created_child(response.get_json())

    assert response.status_code == 201, child
    assert isinstance(child["access_code"], str)
    assert child["access_code"]


def test_create_child_returns_role_child(client):
    parent_response, _ = register_parent(client)

    response = create_child_request(
        client,
        parent_response["access_token"],
        valid_child_data(),
    )

    child = extract_created_child(response.get_json())

    assert response.status_code == 201, child
    assert child["role"] == "child"


def test_create_child_returns_age_as_integer(client):
    parent_response, _ = register_parent(client)

    response = create_child_request(
        client,
        parent_response["access_token"],
        valid_child_data(),
    )

    child = extract_created_child(response.get_json())

    assert response.status_code == 201, child
    assert isinstance(child["age"], int)
    assert child["age"] == 10


def test_create_child_without_phone_success(client):
    parent_response, _ = register_parent(client)

    payload = valid_child_data()
    payload.pop("phone")

    response = create_child_request(
        client,
        parent_response["access_token"],
        payload,
    )

    child = extract_created_child(response.get_json())

    assert response.status_code == 201, child
    assert child["phone"] is None


def test_create_child_with_null_phone_success(client):
    parent_response, _ = register_parent(client)

    payload = valid_child_data(phone=None)

    response = create_child_request(
        client,
        parent_response["access_token"],
        payload,
    )

    child = extract_created_child(response.get_json())

    assert response.status_code == 201, child
    assert child["phone"] is None


def test_create_child_does_not_return_family_or_guardians(client):
    parent_response, _ = register_parent(client)

    response = create_child_request(
        client,
        parent_response["access_token"],
        valid_child_data(),
    )

    child = extract_created_child(response.get_json())

    assert response.status_code == 201, child
    assert "family_id" not in child
    assert "family" not in child
    assert "guardians" not in child
    assert "password" not in child
    assert "password_hash" not in child


# =========================================================
# Name cleaning
# =========================================================


@pytest.mark.parametrize(
    ("raw_name", "expected_name"),
    [
        ("   Sara   ", "Sara"),
        ("Sara     Ahmed", "Sara Ahmed"),
        ("   Sara     Ahmed   ", "Sara Ahmed"),
        ("   سارة   ", "سارة"),
        ("سارة      أحمد", "سارة أحمد"),
        ("   سارة      أحمد   ", "سارة أحمد"),
    ],
)
def test_create_child_cleans_name_spaces(
    client,
    raw_name,
    expected_name,
):
    parent_response, _ = register_parent(client)

    response = create_child_request(
        client,
        parent_response["access_token"],
        valid_child_data(name=raw_name),
    )

    child = extract_created_child(response.get_json())

    assert response.status_code == 201, child
    assert child["name"] == expected_name


# =========================================================
# Name validation
# =========================================================


def test_create_child_rejects_missing_name(client):
    parent_response, _ = register_parent(client)

    payload = valid_child_data()
    payload.pop("name")

    response = create_child_request(
        client,
        parent_response["access_token"],
        payload,
    )

    response_data = response.get_json()

    assert response.status_code == 400, response_data
    assert "name" in response_data.get("errors", response_data)


@pytest.mark.parametrize(
    "invalid_name",
    [
        "",
        " ",
        "     ",
        "A",
        "س",
    ],
)
def test_create_child_rejects_name_shorter_than_two_characters(
    client,
    invalid_name,
):
    parent_response, _ = register_parent(client)

    response = create_child_request(
        client,
        parent_response["access_token"],
        valid_child_data(name=invalid_name),
    )

    response_data = response.get_json()

    assert response.status_code == 400, response_data


def test_create_child_accepts_two_character_name(client):
    parent_response, _ = register_parent(client)

    response = create_child_request(
        client,
        parent_response["access_token"],
        valid_child_data(name="Al"),
    )

    response_data = response.get_json()

    assert response.status_code == 201, response_data


def test_create_child_accepts_name_with_100_characters(client):
    parent_response, _ = register_parent(client)

    name = "A" * 100

    response = create_child_request(
        client,
        parent_response["access_token"],
        valid_child_data(name=name),
    )

    response_data = response.get_json()

    assert response.status_code == 201, response_data
    assert extract_created_child(response_data)["name"] == name


def test_create_child_rejects_name_longer_than_100_characters(client):
    parent_response, _ = register_parent(client)

    response = create_child_request(
        client,
        parent_response["access_token"],
        valid_child_data(name="A" * 101),
    )

    response_data = response.get_json()

    assert response.status_code == 400, response_data


@pytest.mark.parametrize(
    "valid_name",
    [
        "Sara",
        "Sara Ahmed",
        "سارة",
        "سارة أحمد",
        "Sara سارة",
    ],
)
def test_create_child_accepts_arabic_and_english_letters(
    client,
    valid_name,
):
    parent_response, _ = register_parent(client)

    response = create_child_request(
        client,
        parent_response["access_token"],
        valid_child_data(name=valid_name),
    )

    response_data = response.get_json()

    assert response.status_code == 201, response_data


@pytest.mark.parametrize(
    "invalid_name",
    [
        "Sara1",
        "123",
        "سارة2",
        "Sara!",
        "Sara@",
        "Sara-Ahmed",
        "Sara_Ahmed",
        "Sara.Ahmed",
        "Sara/Ahmed",
        "Sara أحمد 1",
        "سارة؟",
    ],
)
def test_create_child_rejects_invalid_name_characters(
    client,
    invalid_name,
):
    parent_response, _ = register_parent(client)

    response = create_child_request(
        client,
        parent_response["access_token"],
        valid_child_data(name=invalid_name),
    )

    response_data = response.get_json()

    assert response.status_code == 400, response_data


@pytest.mark.parametrize(
    "invalid_name",
    [
        123,
        True,
        [],
        {},
    ],
)
def test_create_child_rejects_non_string_name(
    client,
    invalid_name,
):
    parent_response, _ = register_parent(client)

    response = create_child_request(
        client,
        parent_response["access_token"],
        valid_child_data(name=invalid_name),
    )

    response_data = response.get_json()

    assert response.status_code == 400, response_data


# =========================================================
# Birth-date validation
# =========================================================


def test_create_child_rejects_missing_birth_date(client):
    parent_response, _ = register_parent(client)

    payload = valid_child_data()
    payload.pop("birth_date")

    response = create_child_request(
        client,
        parent_response["access_token"],
        payload,
    )

    response_data = response.get_json()

    assert response.status_code == 400, response_data
    assert "birth_date" in response_data.get("errors", response_data)


@pytest.mark.parametrize(
    "invalid_birth_date",
    [
        "",
        "not-a-date",
        "10-05-2015",
        "2015/05/10",
        "2015-13-01",
        "2015-02-30",
        20150510,
        True,
        [],
        {},
    ],
)
def test_create_child_rejects_invalid_birth_date_format(
    client,
    invalid_birth_date,
):
    parent_response, _ = register_parent(client)

    response = create_child_request(
        client,
        parent_response["access_token"],
        valid_child_data(
            birth_date=invalid_birth_date,
        ),
    )

    response_data = response.get_json()

    assert response.status_code == 400, response_data


def test_create_child_rejects_future_birth_date(client):
    parent_response, _ = register_parent(client)

    future_date = riyadh_today() + timedelta(days=1)

    response = create_child_request(
        client,
        parent_response["access_token"],
        valid_child_data(
            birth_date=future_date,
        ),
    )

    response_data = response.get_json()

    assert response.status_code == 400, response_data


def test_create_child_rejects_child_younger_than_six(client):
    parent_response, _ = register_parent(client)

    birth_date = birth_date_for_exact_age(6) + timedelta(days=1)

    response = create_child_request(
        client,
        parent_response["access_token"],
        valid_child_data(
            birth_date=birth_date,
        ),
    )

    response_data = response.get_json()

    assert response.status_code == 400, response_data


def test_create_child_accepts_exactly_six_years_old(client):
    parent_response, _ = register_parent(client)

    response = create_child_request(
        client,
        parent_response["access_token"],
        valid_child_data(
            birth_date=birth_date_for_exact_age(6),
        ),
    )

    response_data = response.get_json()

    assert response.status_code == 201, response_data
    assert extract_created_child(response_data)["age"] == 6


@pytest.mark.parametrize(
    "age",
    [7, 10, 14, 17],
)
def test_create_child_accepts_age_between_six_and_eighteen(
    client,
    age,
):
    parent_response, _ = register_parent(client)

    response = create_child_request(
        client,
        parent_response["access_token"],
        valid_child_data(
            birth_date=birth_date_for_exact_age(age),
        ),
    )

    response_data = response.get_json()

    assert response.status_code == 201, response_data
    assert extract_created_child(response_data)["age"] == age


def test_create_child_accepts_exactly_eighteen_years_old(client):
    parent_response, _ = register_parent(client)

    response = create_child_request(
        client,
        parent_response["access_token"],
        valid_child_data(
            birth_date=birth_date_for_exact_age(18),
        ),
    )

    response_data = response.get_json()

    assert response.status_code == 201, response_data
    assert extract_created_child(response_data)["age"] == 18


def test_create_child_rejects_child_older_than_eighteen(client):
    parent_response, _ = register_parent(client)

    birth_date = birth_date_for_exact_age(19)

    response = create_child_request(
        client,
        parent_response["access_token"],
        valid_child_data(
            birth_date=birth_date,
        ),
    )

    response_data = response.get_json()

    assert response.status_code == 400, response_data


# =========================================================
# Phone validation
# =========================================================


def test_create_child_accepts_valid_phone(client):
    parent_response, _ = register_parent(client)

    response = create_child_request(
        client,
        parent_response["access_token"],
        valid_child_data(phone="0553333333"),
    )

    response_data = response.get_json()

    assert response.status_code == 201, response_data
    assert extract_created_child(response_data)["phone"] == "0553333333"


def test_create_child_trims_phone_surrounding_spaces(client):
    parent_response, _ = register_parent(client)

    response = create_child_request(
        client,
        parent_response["access_token"],
        valid_child_data(
            phone="  0553333333  ",
        ),
    )

    response_data = response.get_json()

    assert response.status_code == 201, response_data
    assert extract_created_child(response_data)["phone"] == "0553333333"


@pytest.mark.parametrize(
    "invalid_phone",
    [
        "055123456",
        "05512345678",
        "5512345678",
        "051234567",
        "0612345678",
        "abcdefghij",
        "05512abcde",
        "055-123-456",
        "055 123 456",
        "055123456!",
        "",
    ],
)
def test_create_child_rejects_invalid_phone(
    client,
    invalid_phone,
):
    parent_response, _ = register_parent(client)

    response = create_child_request(
        client,
        parent_response["access_token"],
        valid_child_data(
            phone=invalid_phone,
        ),
    )

    response_data = response.get_json()

    assert response.status_code == 400, response_data


def test_create_child_rejects_duplicate_phone(client):
    parent_response, _ = register_parent(client)

    first_response = create_child_request(
        client,
        parent_response["access_token"],
        valid_child_data(
            name="Sara",
            phone="0554444444",
        ),
    )

    assert first_response.status_code == 201, first_response.get_json()

    second_response = create_child_request(
        client,
        parent_response["access_token"],
        valid_child_data(
            name="Noura",
            birth_date=birth_date_for_exact_age(12),
            phone="0554444444",
        ),
    )

    response_data = second_response.get_json()

    assert second_response.status_code == 409, response_data
    assert response_data == {
        "error": "Phone number already used",
    }


# =========================================================
# Request body validation
# =========================================================


def test_create_child_rejects_empty_json_object(client):
    parent_response, _ = register_parent(client)

    response = create_child_request(
        client,
        parent_response["access_token"],
        {},
    )

    response_data = response.get_json()

    assert response.status_code == 400, response_data


def test_create_child_rejects_request_without_json_body(client):
    parent_response, _ = register_parent(client)

    response = client.post(
        CHILDREN_URL,
        headers=authorization_header(
            parent_response["access_token"],
        ),
    )

    assert response.status_code == 415


@pytest.mark.parametrize(
    "invalid_body",
    [
        [],
        "invalid body",
        123,
        True,
    ],
)
def test_create_child_rejects_non_object_json_body(
    client,
    invalid_body,
):
    parent_response, _ = register_parent(client)

    response = create_child_request(
        client,
        parent_response["access_token"],
        invalid_body,
    )

    response_data = response.get_json()

    assert response.status_code == 400, response_data


# =========================================================
# Authorization
# =========================================================


def test_create_child_without_token_returns_401(client):
    response = client.post(
        CHILDREN_URL,
        json=valid_child_data(),
    )

    response_data = response.get_json()

    assert response.status_code == 401, response_data


@pytest.mark.parametrize(
    "invalid_token",
    [
        "",
        "not-a-token",
        "abc.def",
        "abc.def.ghi",
    ],
)
def test_create_child_rejects_invalid_token(
    client,
    invalid_token,
):
    response = client.post(
        CHILDREN_URL,
        headers=authorization_header(invalid_token),
        json=valid_child_data(),
    )

    response_data = response.get_json()

    assert response.status_code in (401, 422), response_data


def test_create_child_rejects_refresh_token(client):
    parent_response, _ = register_parent(client)

    response = create_child_request(
        client,
        parent_response["refresh_token"],
        valid_child_data(),
    )

    response_data = response.get_json()

    assert response.status_code in (401, 422), response_data


def test_create_child_rejects_child_role(client, app):
    with app.app_context():
        token = create_access_token(
            identity=str(uuid4()),
            additional_claims={"role": "child"},
        )

    response = create_child_request(
        client,
        token,
        valid_child_data(),
    )

    response_data = response.get_json()

    assert response.status_code == 403, response_data


@pytest.mark.parametrize(
    "role",
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
def test_create_child_rejects_non_parent_roles(
    client,
    app,
    role,
):
    with app.app_context():
        token = create_access_token(
            identity=str(uuid4()),
            additional_claims={"role": role},
        )

    response = create_child_request(
        client,
        token,
        valid_child_data(),
    )

    response_data = response.get_json()

    assert response.status_code == 403, response_data


def test_create_child_rejects_token_without_role(client, app):
    with app.app_context():
        token = create_access_token(
            identity=str(uuid4()),
        )

    response = create_child_request(
        client,
        token,
        valid_child_data(),
    )

    response_data = response.get_json()

    assert response.status_code == 403, response_data


def test_create_child_rejects_revoked_access_token(client):
    parent_response, _ = register_parent(client)

    access_token = parent_response["access_token"]

    logout_response = client.post(
        LOGOUT_URL,
        headers=authorization_header(access_token),
    )

    assert logout_response.status_code == 200, logout_response.get_json()

    response = create_child_request(
        client,
        access_token,
        valid_child_data(),
    )

    response_data = response.get_json()

    assert response.status_code == 401, response_data


# =========================================================
# Route error mapping
# =========================================================


def test_route_returns_404_when_parent_not_found(
    client,
    app,
    monkeypatch,
):
    with app.app_context():
        token = create_access_token(
            identity=str(uuid4()),
            additional_claims={"role": "parent"},
        )

    monkeypatch.setattr(
        child_service,
        "create_child",
        lambda parent_id, child_data: (
            None,
            "parent_not_found",
        ),
    )

    response = create_child_request(
        client,
        token,
        valid_child_data(),
    )

    response_data = response.get_json()

    assert response.status_code == 404, response_data
    assert response_data == {
        "error": "Parent not found",
    }


def test_route_returns_400_when_family_not_found(
    client,
    app,
    monkeypatch,
):
    parent_id = str(uuid4())

    with app.app_context():
        token = create_access_token(
            identity=parent_id,
            additional_claims={"role": "parent"},
        )

    monkeypatch.setattr(
        child_service,
        "create_child",
        lambda received_parent_id, child_data: (
            None,
            "family_not_found",
        ),
    )

    response = create_child_request(
        client,
        token,
        valid_child_data(),
    )

    response_data = response.get_json()

    assert response.status_code == 400, response_data
    assert response_data == {
        "error": "Parent is not assigned to a family",
    }


def test_route_returns_409_for_phone_exists(
    client,
    app,
    monkeypatch,
):
    with app.app_context():
        token = create_access_token(
            identity=str(uuid4()),
            additional_claims={"role": "parent"},
        )

    monkeypatch.setattr(
        child_service,
        "create_child",
        lambda parent_id, child_data: (
            None,
            "phone_exists",
        ),
    )

    response = create_child_request(
        client,
        token,
        valid_child_data(),
    )

    response_data = response.get_json()

    assert response.status_code == 409, response_data
    assert response_data == {
        "error": "Phone number already used",
    }


def test_route_returns_500_for_access_code_exists(
    client,
    app,
    monkeypatch,
):
    with app.app_context():
        token = create_access_token(
            identity=str(uuid4()),
            additional_claims={"role": "parent"},
        )

    monkeypatch.setattr(
        child_service,
        "create_child",
        lambda parent_id, child_data: (
            None,
            "access_code_exists",
        ),
    )

    response = create_child_request(
        client,
        token,
        valid_child_data(),
    )

    response_data = response.get_json()

    assert response.status_code == 500, response_data
    assert response_data == {
        "error": "Failed to generate child access code",
    }


def test_route_returns_500_for_integrity_error(
    client,
    app,
    monkeypatch,
):
    with app.app_context():
        token = create_access_token(
            identity=str(uuid4()),
            additional_claims={"role": "parent"},
        )

    monkeypatch.setattr(
        child_service,
        "create_child",
        lambda parent_id, child_data: (
            None,
            "integrity_error",
        ),
    )

    response = create_child_request(
        client,
        token,
        valid_child_data(),
    )

    response_data = response.get_json()

    assert response.status_code == 500, response_data
    assert response_data == {
        "error": (
            "Could not create child due to invalid related data"
        ),
    }


def test_route_returns_500_for_unknown_service_error(
    client,
    app,
    monkeypatch,
):
    with app.app_context():
        token = create_access_token(
            identity=str(uuid4()),
            additional_claims={"role": "parent"},
        )

    monkeypatch.setattr(
        child_service,
        "create_child",
        lambda parent_id, child_data: (
            None,
            "unexpected_error",
        ),
    )

    response = create_child_request(
        client,
        token,
        valid_child_data(),
    )

    response_data = response.get_json()

    assert response.status_code == 500, response_data
    assert response_data == {
        "error": "Could not create child",
    }


def test_route_passes_parent_identity_and_loaded_data_to_service(
    client,
    app,
    monkeypatch,
):
    parent_id = str(uuid4())
    received_arguments = {}

    with app.app_context():
        token = create_access_token(
            identity=parent_id,
            additional_claims={"role": "parent"},
        )

    fake_child = SimpleNamespace(
        id=str(uuid4()),
        name="Sara Ahmed",
        birth_date=birth_date_for_exact_age(10),
        phone="0552222222",
        age=10,
        access_code="123456",
    )

    def fake_create_child(received_parent_id, child_data):
        received_arguments["parent_id"] = received_parent_id
        received_arguments["child_data"] = child_data
        return fake_child, None

    monkeypatch.setattr(
        child_service,
        "create_child",
        fake_create_child,
    )

    response = create_child_request(
        client,
        token,
        valid_child_data(
            name="   Sara      Ahmed   ",
        ),
    )

    response_data = response.get_json()

    assert response.status_code == 201, response_data

    assert received_arguments["parent_id"] == parent_id
    assert received_arguments["child_data"]["name"] == "Sara Ahmed"
    assert isinstance(
        received_arguments["child_data"]["birth_date"],
        date,
    )


# =========================================================
# Service behavior
# =========================================================


def test_service_returns_parent_not_found(
    monkeypatch,
):
    monkeypatch.setattr(
        child_service.user_repository,
        "get_user_by_id",
        lambda parent_id: None,
    )

    child, error = child_service.create_child(
        str(uuid4()),
        {
            "name": "Sara",
            "birth_date": birth_date_for_exact_age(10),
            "phone": "0552222222",
        },
    )

    assert child is None
    assert error == "parent_not_found"


def test_service_returns_family_not_found(
    monkeypatch,
):
    parent = SimpleNamespace(
        family=None,
        family_id=None,
    )

    monkeypatch.setattr(
        child_service.user_repository,
        "get_user_by_id",
        lambda parent_id: parent,
    )

    child, error = child_service.create_child(
        str(uuid4()),
        {
            "name": "Sara",
            "birth_date": birth_date_for_exact_age(10),
            "phone": "0552222222",
        },
    )

    assert child is None
    assert error == "family_not_found"


def test_service_builds_child_with_expected_values(
    monkeypatch,
):
    guardian = User(
    first_name="Guardian",
    last_name="One",
    phone="0557000001",
    email="guardian.one@gmail.com",
    password_hash="test-hash",
    role="parent",
    guardian_type="mother",
)

    family = SimpleNamespace(
        guardians=[guardian],
    )

    parent = SimpleNamespace(
        family=family,
        family_id=str(uuid4()),
    )

    captured = {}

    monkeypatch.setattr(
        child_service.user_repository,
        "get_user_by_id",
        lambda parent_id: parent,
    )

    monkeypatch.setattr(
        child_service,
        "generate_access_code",
        lambda: "654321",
    )

    def fake_repository_create(child):
        captured["child"] = child
        return child, None

    monkeypatch.setattr(
        child_service.child_repository,
        "create_child",
        fake_repository_create,
    )

    created_child, error = child_service.create_child(
        str(uuid4()),
        {
            "name": "  Sara  ",
            "birth_date": birth_date_for_exact_age(10),
            "phone": "  0552222222  ",
        },
    )

    assert error is None
    assert created_child is captured["child"]

    assert created_child.name == "Sara"
    assert created_child.phone == "0552222222"
    assert created_child.access_code == "654321"
    assert created_child.family_id == parent.family_id
    assert guardian in created_child.guardians


def test_service_supports_none_phone(
    monkeypatch,
):
    parent = SimpleNamespace(
        family=SimpleNamespace(guardians=[]),
        family_id=str(uuid4()),
    )

    captured = {}

    monkeypatch.setattr(
        child_service.user_repository,
        "get_user_by_id",
        lambda parent_id: parent,
    )

    monkeypatch.setattr(
        child_service,
        "generate_access_code",
        lambda: "123456",
    )

    def fake_create(child):
        captured["child"] = child
        return child, None

    monkeypatch.setattr(
        child_service.child_repository,
        "create_child",
        fake_create,
    )

    child, error = child_service.create_child(
        str(uuid4()),
        {
            "name": "Sara",
            "birth_date": birth_date_for_exact_age(10),
            "phone": None,
        },
    )

    assert error is None
    assert child.phone is None


def test_service_adds_all_family_guardians(
    monkeypatch,
):
    first_guardian = User(
    first_name="Guardian",
    last_name="One",
    phone="0557000001",
    email="guardian.one@gmail.com",
    password_hash="test-hash",
    role="parent",
    guardian_type="mother",
)

    second_guardian = User(
    first_name="Guardian",
    last_name="Two",
    phone="0557000002",
    email="guardian.two@gmail.com",
    password_hash="test-hash",
    role="parent",
    guardian_type="father",
)

    third_guardian = User(
    first_name="Guardian",
    last_name="Three",
    phone="0557000003",
    email="guardian.three@gmail.com",
    password_hash="test-hash",
    role="parent",
    guardian_type="guardian",
)

    parent = SimpleNamespace(
        family=SimpleNamespace(
            guardians=[
                first_guardian,
                second_guardian,
                third_guardian,
            ],
        ),
        family_id=str(uuid4()),
    )

    monkeypatch.setattr(
        child_service.user_repository,
        "get_user_by_id",
        lambda parent_id: parent,
    )

    monkeypatch.setattr(
        child_service,
        "generate_access_code",
        lambda: "123456",
    )

    monkeypatch.setattr(
        child_service.child_repository,
        "create_child",
        lambda child: (child, None),
    )

    child, error = child_service.create_child(
        str(uuid4()),
        {
            "name": "Sara",
            "birth_date": birth_date_for_exact_age(10),
            "phone": None,
        },
    )

    assert error is None
    assert child.guardians == [
        first_guardian,
        second_guardian,
        third_guardian,
    ]


def test_service_calls_generate_access_code(
    monkeypatch,
):
    parent = SimpleNamespace(
        family=SimpleNamespace(guardians=[]),
        family_id=str(uuid4()),
    )

    calls = []

    monkeypatch.setattr(
        child_service.user_repository,
        "get_user_by_id",
        lambda parent_id: parent,
    )

    def fake_generate_access_code():
        calls.append(True)
        return "999999"

    monkeypatch.setattr(
        child_service,
        "generate_access_code",
        fake_generate_access_code,
    )

    monkeypatch.setattr(
        child_service.child_repository,
        "create_child",
        lambda child: (child, None),
    )

    child, error = child_service.create_child(
        str(uuid4()),
        {
            "name": "Sara",
            "birth_date": birth_date_for_exact_age(10),
            "phone": None,
        },
    )

    assert error is None
    assert calls == [True]
    assert child.access_code == "999999"


@pytest.mark.parametrize(
    "repository_error",
    [
        "phone_exists",
        "access_code_exists",
        "integrity_error",
    ],
)
def test_service_returns_repository_error(
    monkeypatch,
    repository_error,
):
    parent = SimpleNamespace(
        family=SimpleNamespace(guardians=[]),
        family_id=str(uuid4()),
    )

    monkeypatch.setattr(
        child_service.user_repository,
        "get_user_by_id",
        lambda parent_id: parent,
    )

    monkeypatch.setattr(
        child_service,
        "generate_access_code",
        lambda: "123456",
    )

    monkeypatch.setattr(
        child_service.child_repository,
        "create_child",
        lambda child: (None, repository_error),
    )

    child, error = child_service.create_child(
        str(uuid4()),
        {
            "name": "Sara",
            "birth_date": birth_date_for_exact_age(10),
            "phone": None,
        },
    )

    assert child is None
    assert error == repository_error


# =========================================================
# Repository behavior
# =========================================================


def test_repository_create_child_success(
    app,
    monkeypatch,
):
    repository = ChildRepository()

    child = Child(
        name="Sara",
        birth_date=birth_date_for_exact_age(10),
        phone=None,
        access_code="123456",
        family_id=str(uuid4()),
    )

    added = []
    committed = []

    monkeypatch.setattr(
        db.session,
        "add",
        lambda value: added.append(value),
    )

    monkeypatch.setattr(
        db.session,
        "commit",
        lambda: committed.append(True),
    )

    with app.app_context():
        created_child, error = repository.create_child(child)

    assert created_child is child
    assert error is None
    assert added == [child]
    assert committed == [True]


class FakeDatabaseDiagnostic:
    def __init__(self, constraint_name):
        self.constraint_name = constraint_name


class FakeDatabaseOriginalError(Exception):
    def __init__(self, constraint_name):
        super().__init__("database integrity error")
        self.diag = FakeDatabaseDiagnostic(constraint_name)


def make_integrity_error(constraint_name):
    return IntegrityError(
        statement="INSERT INTO children ...",
        params={},
        orig=FakeDatabaseOriginalError(constraint_name),
    )


@pytest.mark.parametrize(
    ("constraint_name", "expected_error"),
    [
        (
            "children_access_code_key",
            "access_code_exists",
        ),
        (
            "children_phone_key",
            "phone_exists",
        ),
        (
            "unknown_constraint",
            "integrity_error",
        ),
        (
            None,
            "integrity_error",
        ),
    ],
)
def test_repository_maps_integrity_constraints(
    app,
    monkeypatch,
    constraint_name,
    expected_error,
):
    repository = ChildRepository()

    child = SimpleNamespace()
    rollback_calls = []

    monkeypatch.setattr(
        db.session,
        "add",
        lambda value: None,
    )

    def failing_commit():
        raise make_integrity_error(constraint_name)

    monkeypatch.setattr(
        db.session,
        "commit",
        failing_commit,
    )

    monkeypatch.setattr(
        db.session,
        "rollback",
        lambda: rollback_calls.append(True),
    )

    with app.app_context():
        created_child, error = repository.create_child(child)

    assert created_child is None
    assert error == expected_error
    assert rollback_calls == [True]


# =========================================================
# Schema unit tests
# =========================================================


@pytest.mark.parametrize(
    ("raw_name", "expected_name"),
    [
        ("   Sara   ", "Sara"),
        ("Sara      Ahmed", "Sara Ahmed"),
        ("   سارة      أحمد   ", "سارة أحمد"),
    ],
)
def test_child_schema_cleans_name(
    raw_name,
    expected_name,
):
    result = child_create_schema.load(
        {
            "name": raw_name,
            "birth_date": birth_date_for_exact_age(10).isoformat(),
            "phone": None,
        }
    )

    assert result["name"] == expected_name


def test_child_schema_converts_birth_date_to_date_object():
    birth_date = birth_date_for_exact_age(10)

    result = child_create_schema.load(
        {
            "name": "Sara",
            "birth_date": birth_date.isoformat(),
            "phone": None,
        }
    )

    assert result["birth_date"] == birth_date
    assert isinstance(result["birth_date"], date)