import pytest
from flask_jwt_extended import decode_token
from sqlalchemy.exc import IntegrityError

from app.extensions import db
from app.routes import child_routes


REGISTER_URL = "/api/auth/register"
CHILDREN_URL = "/api/children"
CHILD_LOGIN_URL = "/api/auth/child-login"


def child_detail_url(child_id):
    return f"{CHILDREN_URL}/{child_id}"


def valid_parent_data(
    *,
    first_name="Manar",
    last_name="Zaid",
    phone="0551234567",
    email="update.child.parent@gmail.com",
    guardian_type="mother",
):
    return {
        "first_name": first_name,
        "last_name": last_name,
        "phone": phone,
        "email": email,
        "password": "Password123!",
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


def authorization_header(access_token):
    return {
        "Authorization": access_token,
    }


def register_parent(client, parent_data=None):
    response = client.post(
        REGISTER_URL,
        json=parent_data or valid_parent_data(),
    )
    response_data = response.get_json()

    assert response.status_code == 201, response_data
    assert "access_token" in response_data

    return response_data


def create_child(client, access_token, child_data=None):
    response = client.post(
        f"{CHILDREN_URL}/",
        headers=authorization_header(access_token),
        json=child_data or valid_child_data(),
    )
    response_data = response.get_json()

    assert response.status_code == 201, response_data

    if isinstance(response_data, dict) and "child" in response_data:
        return response_data["child"]

    return response_data


def update_child_request(
    client,
    access_token,
    child_id,
    payload,
):
    return client.put(
        child_detail_url(child_id),
        headers=authorization_header(access_token),
        json=payload,
    )


def get_child_request(client, access_token, child_id):
    return client.get(
        child_detail_url(child_id),
        headers=authorization_header(access_token),
    )


# =========================================================
# Successful update cases
# =========================================================


def test_update_child_name_success(client):
    parent = register_parent(client)
    child = create_child(client, parent["access_token"])

    response = update_child_request(
        client,
        parent["access_token"],
        child["id"],
        {"name": "Noura"},
    )
    response_data = response.get_json()

    assert response.status_code == 200, response_data
    assert response_data["name"] == "Noura"
    assert response_data["birth_date"] == child["birth_date"]
    assert response_data["phone"] == child["phone"]


def test_update_child_birth_date_success(client):
    parent = register_parent(client)
    child = create_child(client, parent["access_token"])

    response = update_child_request(
        client,
        parent["access_token"],
        child["id"],
        {"birth_date": "2014-06-15"},
    )
    response_data = response.get_json()

    assert response.status_code == 200, response_data
    assert response_data["birth_date"] == "2014-06-15"
    assert response_data["name"] == child["name"]
    assert response_data["phone"] == child["phone"]


def test_update_child_phone_success(client):
    parent = register_parent(client)
    child = create_child(client, parent["access_token"])

    response = update_child_request(
        client,
        parent["access_token"],
        child["id"],
        {"phone": "0551111111"},
    )
    response_data = response.get_json()

    assert response.status_code == 200, response_data
    assert response_data["phone"] == "0551111111"


def test_update_child_phone_to_null_success(client):
    parent = register_parent(client)
    child = create_child(client, parent["access_token"])

    response = update_child_request(
        client,
        parent["access_token"],
        child["id"],
        {"phone": None},
    )
    response_data = response.get_json()

    assert response.status_code == 200, response_data
    assert response_data["phone"] is None


def test_update_child_multiple_fields_success(client):
    parent = register_parent(client)
    child = create_child(client, parent["access_token"])

    response = update_child_request(
        client,
        parent["access_token"],
        child["id"],
        {
            "name": "Khalid",
            "birth_date": "2013-08-20",
        },
    )
    response_data = response.get_json()

    assert response.status_code == 200, response_data
    assert response_data["name"] == "Khalid"
    assert response_data["birth_date"] == "2013-08-20"


def test_update_child_all_fields_success(client):
    parent = register_parent(client)
    child = create_child(client, parent["access_token"])

    response = update_child_request(
        client,
        parent["access_token"],
        child["id"],
        {
            "name": "Khalid Ahmed",
            "birth_date": "2013-08-20",
            "phone": "0552222222",
        },
    )
    response_data = response.get_json()

    assert response.status_code == 200, response_data
    assert response_data["name"] == "Khalid Ahmed"
    assert response_data["birth_date"] == "2013-08-20"
    assert response_data["phone"] == "0552222222"


def test_update_child_preserves_access_code(client):
    parent = register_parent(client)
    child = create_child(client, parent["access_token"])

    response = update_child_request(
        client,
        parent["access_token"],
        child["id"],
        {"name": "Noura"},
    )
    response_data = response.get_json()

    assert response.status_code == 200
    assert response_data["access_code"] == child["access_code"]


def test_update_child_returns_child_role(client):
    parent = register_parent(client)
    child = create_child(client, parent["access_token"])

    response = update_child_request(
        client,
        parent["access_token"],
        child["id"],
        {"name": "Noura"},
    )
    response_data = response.get_json()

    assert response.status_code == 200
    assert response_data["role"] == "child"


def test_update_child_returns_integer_age(client):
    parent = register_parent(client)
    child = create_child(client, parent["access_token"])

    response = update_child_request(
        client,
        parent["access_token"],
        child["id"],
        {"birth_date": "2014-06-15"},
    )
    response_data = response.get_json()

    assert response.status_code == 200
    assert isinstance(response_data["age"], int)
    assert 6 <= response_data["age"] <= 18


def test_update_child_persists_changes(client):
    parent = register_parent(client)
    child = create_child(client, parent["access_token"])

    update_response = update_child_request(
        client,
        parent["access_token"],
        child["id"],
        {
            "name": "Noura",
            "phone": "0553333333",
        },
    )

    assert update_response.status_code == 200

    get_response = get_child_request(
        client,
        parent["access_token"],
        child["id"],
    )
    response_data = get_response.get_json()

    assert get_response.status_code == 200
    assert response_data["name"] == "Noura"
    assert response_data["phone"] == "0553333333"


def test_update_child_normalizes_name_spaces(client):
    parent = register_parent(client)
    child = create_child(client, parent["access_token"])

    response = update_child_request(
        client,
        parent["access_token"],
        child["id"],
        {"name": "  Noura    Ahmed  "},
    )
    response_data = response.get_json()

    assert response.status_code == 200, response_data
    assert response_data["name"] == "Noura Ahmed"


# =========================================================
# Validation cases
# =========================================================


def test_update_child_rejects_empty_body(client):
    parent = register_parent(client)
    child = create_child(client, parent["access_token"])

    response = update_child_request(
        client,
        parent["access_token"],
        child["id"],
        {},
    )
    response_data = response.get_json()

    assert response.status_code == 400, response_data


@pytest.mark.parametrize(
    "invalid_body",
    [
        [],
        "invalid body",
        123,
        True,
    ],
)
def test_update_child_rejects_non_object_body(
    client,
    invalid_body,
):
    parent = register_parent(client)
    child = create_child(client, parent["access_token"])

    response = update_child_request(
        client,
        parent["access_token"],
        child["id"],
        invalid_body,
    )

    assert response.status_code == 400


@pytest.mark.parametrize(
    "invalid_name",
    [
        "",
        "A",
        "Sara1",
        "سارة2",
        "Sara!",
        "Sara@",
        "Sara-Ahmed",
        "Sara_Ahmed",
        "سارة؟",
    ],
)
def test_update_child_rejects_invalid_name(
    client,
    invalid_name,
):
    parent = register_parent(client)
    child = create_child(client, parent["access_token"])

    response = update_child_request(
        client,
        parent["access_token"],
        child["id"],
        {"name": invalid_name},
    )

    assert response.status_code == 400


def test_update_child_rejects_name_longer_than_100(client):
    parent = register_parent(client)
    child = create_child(client, parent["access_token"])

    response = update_child_request(
        client,
        parent["access_token"],
        child["id"],
        {"name": "A" * 101},
    )

    assert response.status_code == 400


@pytest.mark.parametrize(
    "invalid_birth_date",
    [
        "2030-01-01",
        "2022-01-01",
        "2000-01-01",
        "not-a-date",
    ],
)
def test_update_child_rejects_invalid_birth_date(
    client,
    invalid_birth_date,
):
    parent = register_parent(client)
    child = create_child(client, parent["access_token"])

    response = update_child_request(
        client,
        parent["access_token"],
        child["id"],
        {"birth_date": invalid_birth_date},
    )

    assert response.status_code == 400


@pytest.mark.parametrize(
    "invalid_phone",
    [
        "055123456",
        "05512345678",
        "051234567",
        "05123456789",
        "0451234567",
        "05512345ab",
        "05512345!@",
        "",
    ],
)
def test_update_child_rejects_invalid_phone(
    client,
    invalid_phone,
):
    parent = register_parent(client)
    child = create_child(client, parent["access_token"])

    response = update_child_request(
        client,
        parent["access_token"],
        child["id"],
        {"phone": invalid_phone},
    )

    assert response.status_code == 400


# =========================================================
# Authentication and access
# =========================================================


def test_update_child_requires_access_token(client):
    response = client.put(
        child_detail_url(
            "00000000-0000-0000-0000-000000000000"
        ),
        json={"name": "Noura"},
    )

    assert response.status_code == 401


@pytest.mark.parametrize(
    "invalid_token",
    [
        "invalid-token",
        "abc.def",
        "abc.def.ghi",
    ],
)
def test_update_child_rejects_invalid_token(
    client,
    invalid_token,
):
    response = update_child_request(
        client,
        invalid_token,
        "00000000-0000-0000-0000-000000000000",
        {"name": "Noura"},
    )

    assert response.status_code in (401, 422)


def test_child_token_cannot_update_child(client):
    parent = register_parent(client)
    child = create_child(client, parent["access_token"])

    login_response = client.post(
        CHILD_LOGIN_URL,
        json={"access_code": child["access_code"]},
    )
    login_data = login_response.get_json()

    assert login_response.status_code == 200, login_data

    response = update_child_request(
        client,
        login_data["access_token"],
        child["id"],
        {"name": "Noura"},
    )
    response_data = response.get_json()

    assert response.status_code == 403, response_data
    assert response_data["error"] == "Parent access required"


def test_update_child_returns_404_for_unknown_child(client):
    parent = register_parent(client)

    response = update_child_request(
        client,
        parent["access_token"],
        "00000000-0000-0000-0000-000000000000",
        {"name": "Noura"},
    )
    response_data = response.get_json()

    assert response.status_code == 404, response_data
    assert response_data == {"error": "Child not found"}


def test_parent_cannot_update_another_family_child(client):
    first_parent = register_parent(
        client,
        valid_parent_data(
            phone="0551111111",
            email="first.update.parent@gmail.com",
        ),
    )

    second_parent = register_parent(
        client,
        valid_parent_data(
            first_name="Noura",
            phone="0552222222",
            email="second.update.parent@gmail.com",
        ),
    )

    second_child = create_child(
        client,
        second_parent["access_token"],
        valid_child_data(
            name="Khalid",
            phone="0553333333",
        ),
    )

    response = update_child_request(
        client,
        first_parent["access_token"],
        second_child["id"],
        {"name": "Updated"},
    )

    assert response.status_code == 404


# =========================================================
# Duplicate phone
# =========================================================


def test_update_child_rejects_duplicate_phone(client):
    parent = register_parent(client)

    first_child = create_child(
        client,
        parent["access_token"],
        valid_child_data(
            name="Sara",
            phone="0554444444",
        ),
    )

    second_child = create_child(
        client,
        parent["access_token"],
        valid_child_data(
            name="Noura",
            birth_date="2014-06-15",
            phone="0555555555",
        ),
    )

    response = update_child_request(
        client,
        parent["access_token"],
        second_child["id"],
        {"phone": first_child["phone"]},
    )
    response_data = response.get_json()

    assert response.status_code == 409, response_data
    assert response_data == {
        "error": "Phone number already used",
    }


# =========================================================
# Route behavior
# =========================================================


def test_route_passes_ids_and_data_to_service(
    client,
    app,
    monkeypatch,
):
    parent = register_parent(client)
    captured = {}

    with app.app_context():
        expected_parent_id = decode_token(
            parent["access_token"]
        )["sub"]

    class FakeChild:
        id = "child-id-123"
        name = "Noura"
        birth_date = None
        phone = None
        age = 10
        access_code = "123456"

    def fake_update_child_for_parent(
        child_id,
        parent_id,
        child_data,
    ):
        captured["child_id"] = child_id
        captured["parent_id"] = parent_id
        captured["child_data"] = child_data
        return FakeChild(), None

    monkeypatch.setattr(
        child_routes.child_service,
        "update_child_for_parent",
        fake_update_child_for_parent,
    )

    response = update_child_request(
        client,
        parent["access_token"],
        "child-id-123",
        {"name": "Noura"},
    )

    assert response.status_code == 200
    assert captured == {
        "child_id": "child-id-123",
        "parent_id": expected_parent_id,
        "child_data": {"name": "Noura"},
    }


@pytest.mark.parametrize(
    "service_error, expected_status, expected_body",
    [
        (
            "not_found",
            404,
            {"error": "Child not found"},
        ),
        (
            "phone_exists",
            409,
            {"error": "Phone number already used"},
        ),
        (
            "integrity_error",
            500,
            {"error": "Failed to update child"},
        ),
        (
            "unknown_error",
            500,
            {"error": "Failed to update child"},
        ),
    ],
)
def test_route_maps_service_errors(
    client,
    monkeypatch,
    service_error,
    expected_status,
    expected_body,
):
    parent = register_parent(client)

    monkeypatch.setattr(
        child_routes.child_service,
        "update_child_for_parent",
        lambda child_id, parent_id, child_data: (
            None,
            service_error,
        ),
    )

    response = update_child_request(
        client,
        parent["access_token"],
        "child-id-123",
        {"name": "Noura"},
    )

    assert response.status_code == expected_status
    assert response.get_json() == expected_body


def test_route_serializes_updated_child(
    client,
    monkeypatch,
):
    parent = register_parent(client)

    class FakeChild:
        id = "fake-child-id"
        name = "Noura"
        birth_date = None
        phone = None
        age = 11
        access_code = "123456"

    monkeypatch.setattr(
        child_routes.child_service,
        "update_child_for_parent",
        lambda child_id, parent_id, child_data: (
            FakeChild(),
            None,
        ),
    )

    response = update_child_request(
        client,
        parent["access_token"],
        "fake-child-id",
        {"name": "Noura"},
    )

    assert response.status_code == 200
    assert response.get_json() == {
        "id": "fake-child-id",
        "name": "Noura",
        "birth_date": None,
        "phone": None,
        "age": 11,
        "access_code": "123456",
        "role": "child",
    }


# =========================================================
# Service behavior
# =========================================================


def test_service_returns_not_found_when_child_missing(
    monkeypatch,
):
    service = child_routes.child_service

    monkeypatch.setattr(
        service.child_repository,
        "get_child_for_guardian",
        lambda child_id, parent_id: None,
    )

    update_called = {"value": False}

    def fake_update_child():
        update_called["value"] = True
        return True, None

    monkeypatch.setattr(
        service.child_repository,
        "update_child",
        fake_update_child,
    )

    child, error = service.update_child_for_parent(
        "missing-child",
        "parent-id",
        {"name": "Noura"},
    )

    assert child is None
    assert error == "not_found"
    assert update_called["value"] is False


def test_service_updates_only_provided_fields(monkeypatch):
    service = child_routes.child_service

    class FakeChild:
        name = "Sara"
        birth_date = "old-date"
        phone = "0551111111"

    fake_child = FakeChild()

    monkeypatch.setattr(
        service.child_repository,
        "get_child_for_guardian",
        lambda child_id, parent_id: fake_child,
    )

    monkeypatch.setattr(
        service.child_repository,
        "update_child",
        lambda: (True, None),
    )

    child, error = service.update_child_for_parent(
        "child-id",
        "parent-id",
        {"name": "  Noura  "},
    )

    assert error is None
    assert child is fake_child
    assert child.name == "Noura"
    assert child.birth_date == "old-date"
    assert child.phone == "0551111111"


def test_service_updates_birth_date(monkeypatch):
    service = child_routes.child_service

    class FakeChild:
        name = "Sara"
        birth_date = "old-date"
        phone = "0551111111"

    fake_child = FakeChild()
    new_birth_date = object()

    monkeypatch.setattr(
        service.child_repository,
        "get_child_for_guardian",
        lambda child_id, parent_id: fake_child,
    )

    monkeypatch.setattr(
        service.child_repository,
        "update_child",
        lambda: (True, None),
    )

    child, error = service.update_child_for_parent(
        "child-id",
        "parent-id",
        {"birth_date": new_birth_date},
    )

    assert error is None
    assert child.birth_date is new_birth_date


def test_service_strips_phone(monkeypatch):
    service = child_routes.child_service

    class FakeChild:
        name = "Sara"
        birth_date = "old-date"
        phone = "0551111111"

    fake_child = FakeChild()

    monkeypatch.setattr(
        service.child_repository,
        "get_child_for_guardian",
        lambda child_id, parent_id: fake_child,
    )

    monkeypatch.setattr(
        service.child_repository,
        "update_child",
        lambda: (True, None),
    )

    child, error = service.update_child_for_parent(
        "child-id",
        "parent-id",
        {"phone": "  0552222222  "},
    )

    assert error is None
    assert child.phone == "0552222222"


def test_service_sets_phone_to_none(monkeypatch):
    service = child_routes.child_service

    class FakeChild:
        name = "Sara"
        birth_date = "old-date"
        phone = "0551111111"

    fake_child = FakeChild()

    monkeypatch.setattr(
        service.child_repository,
        "get_child_for_guardian",
        lambda child_id, parent_id: fake_child,
    )

    monkeypatch.setattr(
        service.child_repository,
        "update_child",
        lambda: (True, None),
    )

    child, error = service.update_child_for_parent(
        "child-id",
        "parent-id",
        {"phone": None},
    )

    assert error is None
    assert child.phone is None


@pytest.mark.parametrize(
    "repository_error",
    [
        "phone_exists",
        "integrity_error",
    ],
)
def test_service_returns_repository_error(
    monkeypatch,
    repository_error,
):
    service = child_routes.child_service

    class FakeChild:
        name = "Sara"
        birth_date = "old-date"
        phone = "0551111111"

    fake_child = FakeChild()

    monkeypatch.setattr(
        service.child_repository,
        "get_child_for_guardian",
        lambda child_id, parent_id: fake_child,
    )

    monkeypatch.setattr(
        service.child_repository,
        "update_child",
        lambda: (False, repository_error),
    )

    child, error = service.update_child_for_parent(
        "child-id",
        "parent-id",
        {"name": "Noura"},
    )

    assert child is None
    assert error == repository_error


# =========================================================
# Repository behavior
# =========================================================


def test_repository_update_child_success(
    app,
    monkeypatch,
):
    repository = child_routes.child_service.child_repository

    monkeypatch.setattr(
        db.session,
        "commit",
        lambda: None,
    )

    success, error = repository.update_child()

    assert success is True
    assert error is None


def test_repository_update_child_rolls_back_on_integrity_error(
    app,
    monkeypatch,
):
    repository = child_routes.child_service.child_repository
    rollback_called = {"value": False}

    class FakeOriginalError(Exception):
        pass

    original_error = FakeOriginalError("constraint failure")

    def fake_commit():
        raise IntegrityError(
            "UPDATE children",
            {},
            original_error,
        )

    def fake_rollback():
        rollback_called["value"] = True

    monkeypatch.setattr(
        db.session,
        "commit",
        fake_commit,
    )

    monkeypatch.setattr(
        db.session,
        "rollback",
        fake_rollback,
    )

    success, error = repository.update_child()

    assert success is False
    assert error == "integrity_error"
    assert rollback_called["value"] is True