import pytest
from flask_jwt_extended import decode_token

from app.extensions import db
from app.models import Child, User
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
    email="get.child.parent@gmail.com",
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


def get_child_request(client, access_token, child_id):
    return client.get(
        child_detail_url(child_id),
        headers=authorization_header(access_token),
    )


# =========================================================
# Successful responses
# =========================================================


def test_get_child_returns_child_for_parent(client):
    parent = register_parent(client)

    created_child = create_child(
        client,
        parent["access_token"],
    )

    response = get_child_request(
        client,
        parent["access_token"],
        created_child["id"],
    )
    response_data = response.get_json()

    assert response.status_code == 200, response_data
    assert response_data["id"] == created_child["id"]
    assert response_data["name"] == "Sara"
    assert response_data["birth_date"] == "2015-05-10"
    assert response_data["phone"] == "0559876543"


def test_get_child_response_contains_all_schema_fields(client):
    parent = register_parent(client)

    created_child = create_child(
        client,
        parent["access_token"],
    )

    response = get_child_request(
        client,
        parent["access_token"],
        created_child["id"],
    )
    response_data = response.get_json()

    expected_fields = {
        "id",
        "name",
        "birth_date",
        "phone",
        "age",
        "access_code",
        "role",
    }

    assert response.status_code == 200, response_data
    assert expected_fields.issubset(response_data.keys())


def test_get_child_returns_child_role(client):
    parent = register_parent(client)

    created_child = create_child(
        client,
        parent["access_token"],
    )

    response = get_child_request(
        client,
        parent["access_token"],
        created_child["id"],
    )
    response_data = response.get_json()

    assert response.status_code == 200
    assert response_data["role"] == "child"


def test_get_child_returns_access_code(client):
    parent = register_parent(client)

    created_child = create_child(
        client,
        parent["access_token"],
    )

    response = get_child_request(
        client,
        parent["access_token"],
        created_child["id"],
    )
    response_data = response.get_json()

    assert response.status_code == 200
    assert response_data["access_code"] == created_child["access_code"]
    assert isinstance(response_data["access_code"], str)
    assert len(response_data["access_code"]) == 6
    assert response_data["access_code"].isdigit()


def test_get_child_returns_integer_age(client):
    parent = register_parent(client)

    created_child = create_child(
        client,
        parent["access_token"],
    )

    response = get_child_request(
        client,
        parent["access_token"],
        created_child["id"],
    )
    response_data = response.get_json()

    assert response.status_code == 200
    assert isinstance(response_data["age"], int)
    assert 6 <= response_data["age"] <= 18


def test_get_child_returns_null_phone(client):
    parent = register_parent(client)

    created_child = create_child(
        client,
        parent["access_token"],
        valid_child_data(phone=None),
    )

    response = get_child_request(
        client,
        parent["access_token"],
        created_child["id"],
    )
    response_data = response.get_json()

    assert response.status_code == 200, response_data
    assert response_data["phone"] is None


# =========================================================
# Not found and access isolation
# =========================================================


def test_get_child_returns_404_for_unknown_child_id(client):
    parent = register_parent(client)

    response = get_child_request(
        client,
        parent["access_token"],
        "00000000-0000-0000-0000-000000000000",
    )
    response_data = response.get_json()

    assert response.status_code == 404, response_data
    assert response_data == {
        "error": "Child not found",
    }


def test_parent_cannot_get_child_from_another_family(client):
    first_parent = register_parent(
        client,
        valid_parent_data(
            phone="0551111111",
            email="first.get.child.parent@gmail.com",
        ),
    )

    second_parent = register_parent(
        client,
        valid_parent_data(
            first_name="Noura",
            phone="0552222222",
            email="second.get.child.parent@gmail.com",
        ),
    )

    second_child = create_child(
        client,
        second_parent["access_token"],
        valid_child_data(
            name="Khalid",
            birth_date="2014-06-15",
            phone="0553333333",
        ),
    )

    response = get_child_request(
        client,
        first_parent["access_token"],
        second_child["id"],
    )
    response_data = response.get_json()

    assert response.status_code == 404, response_data
    assert response_data == {
        "error": "Child not found",
    }


# =========================================================
# Authentication and authorization
# =========================================================


def test_get_child_requires_access_token(client):
    response = client.get(
        child_detail_url(
            "00000000-0000-0000-0000-000000000000"
        )
    )
    response_data = response.get_json()

    assert response.status_code == 401, response_data


@pytest.mark.parametrize(
    "invalid_token",
    [
        "invalid-token",
        "abc.def",
        "abc.def.ghi",
    ],
)
def test_get_child_rejects_invalid_access_token(
    client,
    invalid_token,
):
    response = get_child_request(
        client,
        invalid_token,
        "00000000-0000-0000-0000-000000000000",
    )
    response_data = response.get_json()

    assert response.status_code in (401, 422), response_data


def test_child_token_cannot_get_child_detail(client):
    parent = register_parent(client)

    child = create_child(
        client,
        parent["access_token"],
    )

    login_response = client.post(
        CHILD_LOGIN_URL,
        json={
            "access_code": child["access_code"],
        },
    )
    login_data = login_response.get_json()

    assert login_response.status_code == 200, login_data
    assert "access_token" in login_data

    response = get_child_request(
        client,
        login_data["access_token"],
        child["id"],
    )
    response_data = response.get_json()

    assert response.status_code == 403, response_data
    assert response_data["error"] == "Parent access required"


# =========================================================
# Route interaction
# =========================================================


def test_route_passes_child_id_and_parent_id_to_service(
    client,
    app,
    monkeypatch,
):
    parent = register_parent(client)
    captured = {}

    with app.app_context():
        token_data = decode_token(parent["access_token"])
        expected_parent_id = token_data["sub"]

    class FakeChild:
        id = "child-id-123"
        name = "Sara"
        birth_date = None
        phone = None
        age = 10
        access_code = "123456"

    def fake_get_child_for_parent(child_id, parent_id):
        captured["child_id"] = child_id
        captured["parent_id"] = parent_id
        return FakeChild()

    monkeypatch.setattr(
        child_routes.child_service,
        "get_child_for_parent",
        fake_get_child_for_parent,
    )

    response = get_child_request(
        client,
        parent["access_token"],
        "child-id-123",
    )

    assert response.status_code == 200
    assert captured["child_id"] == "child-id-123"
    assert captured["parent_id"] == expected_parent_id


def test_route_returns_404_when_service_returns_none(
    client,
    monkeypatch,
):
    parent = register_parent(client)

    monkeypatch.setattr(
        child_routes.child_service,
        "get_child_for_parent",
        lambda child_id, parent_id: None,
    )

    response = get_child_request(
        client,
        parent["access_token"],
        "missing-child-id",
    )
    response_data = response.get_json()

    assert response.status_code == 404
    assert response_data == {
        "error": "Child not found",
    }


def test_route_serializes_service_result(
    client,
    monkeypatch,
):
    parent = register_parent(client)

    class FakeChild:
        id = "fake-child-id"
        name = "Fake Child"
        birth_date = None
        phone = None
        age = 11
        access_code = "123456"

    monkeypatch.setattr(
        child_routes.child_service,
        "get_child_for_parent",
        lambda child_id, parent_id: FakeChild(),
    )

    response = get_child_request(
        client,
        parent["access_token"],
        "fake-child-id",
    )
    response_data = response.get_json()

    assert response.status_code == 200
    assert response_data == {
        "id": "fake-child-id",
        "name": "Fake Child",
        "birth_date": None,
        "phone": None,
        "age": 11,
        "access_code": "123456",
        "role": "child",
    }


# =========================================================
# Service interaction
# =========================================================


def test_service_passes_ids_to_repository(monkeypatch):
    service = child_routes.child_service
    expected_child = object()
    captured = {}

    def fake_get_child_for_guardian(child_id, guardian_id):
        captured["child_id"] = child_id
        captured["guardian_id"] = guardian_id
        return expected_child

    monkeypatch.setattr(
        service.child_repository,
        "get_child_for_guardian",
        fake_get_child_for_guardian,
    )

    result = service.get_child_for_parent(
        "child-id-123",
        "parent-id-456",
    )

    assert captured == {
        "child_id": "child-id-123",
        "guardian_id": "parent-id-456",
    }
    assert result is expected_child


def test_service_returns_none_from_repository(monkeypatch):
    service = child_routes.child_service

    monkeypatch.setattr(
        service.child_repository,
        "get_child_for_guardian",
        lambda child_id, guardian_id: None,
    )

    result = service.get_child_for_parent(
        "missing-child-id",
        "parent-id-456",
    )

    assert result is None


# =========================================================
# Repository integration
# =========================================================


def test_repository_returns_child_for_its_guardian(
    client,
    app,
):
    parent = register_parent(client)

    created_child = create_child(
        client,
        parent["access_token"],
    )

    with app.app_context():
        token_data = decode_token(parent["access_token"])
        parent_id = token_data["sub"]

        result = (
            child_routes.child_service.child_repository
            .get_child_for_guardian(
                created_child["id"],
                parent_id,
            )
        )

        assert result is not None
        assert str(result.id) == created_child["id"]


def test_repository_returns_none_for_unrelated_guardian(
    client,
    app,
):
    first_parent = register_parent(
        client,
        valid_parent_data(
            phone="0551111111",
            email="repository.first.parent@gmail.com",
        ),
    )

    second_parent = register_parent(
        client,
        valid_parent_data(
            first_name="Noura",
            phone="0552222222",
            email="repository.second.parent@gmail.com",
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

    with app.app_context():
        first_parent_id = decode_token(
            first_parent["access_token"]
        )["sub"]

        result = (
            child_routes.child_service.child_repository
            .get_child_for_guardian(
                second_child["id"],
                first_parent_id,
            )
        )

        assert result is None


def test_repository_requires_matching_child_and_guardian(
    client,
    app,
):
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

    with app.app_context():
        parent_id = decode_token(
            parent["access_token"]
        )["sub"]

        repository = (
            child_routes.child_service.child_repository
        )

        first_result = repository.get_child_for_guardian(
            first_child["id"],
            parent_id,
        )
        second_result = repository.get_child_for_guardian(
            second_child["id"],
            parent_id,
        )

        assert first_result is not None
        assert second_result is not None
        assert str(first_result.id) == first_child["id"]
        assert str(second_result.id) == second_child["id"]