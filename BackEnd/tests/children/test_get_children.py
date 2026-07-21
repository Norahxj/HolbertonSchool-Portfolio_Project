import pytest
from flask_jwt_extended import decode_token

from app.routes import child_routes


REGISTER_URL = "/api/auth/register"
CHILDREN_URL = "/api/children/"
CHILD_LOGIN_URL = "/api/auth/child-login"


def valid_parent_data(
    *,
    first_name="Manar",
    last_name="Zaid",
    phone="0551234567",
    email="get.children.parent@gmail.com",
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
    return {"Authorization": access_token}


def register_parent(client, parent_data=None):
    response = client.post(
        REGISTER_URL,
        json=parent_data or valid_parent_data(),
    )
    response_data = response.get_json()

    assert response.status_code == 201, response_data
    assert "access_token" in response_data

    return response_data


def create_child_request(client, access_token, child_data=None):
    payload = valid_child_data() if child_data is None else child_data
    return client.post(
        CHILDREN_URL,
        headers=authorization_header(access_token),
        json=payload,
    )


def get_children_request(client, access_token):
    return client.get(
        CHILDREN_URL,
        headers=authorization_header(access_token),
    )


def extract_created_child(response_data):
    if isinstance(response_data, dict) and "child" in response_data:
        return response_data["child"]
    return response_data


def create_child(client, access_token, child_data=None):
    response = create_child_request(client, access_token, child_data)
    response_data = response.get_json()
    assert response.status_code == 201, response_data
    return extract_created_child(response_data)


# =========================================================
# Successful responses
# =========================================================


def test_get_children_returns_empty_list_when_parent_has_no_children(client):
    parent = register_parent(client)

    response = get_children_request(client, parent["access_token"])
    response_data = response.get_json()

    assert response.status_code == 200, response_data
    assert response_data == []


def test_get_children_returns_created_child(client):
    parent = register_parent(client)
    created_child = create_child(client, parent["access_token"])

    response = get_children_request(client, parent["access_token"])
    response_data = response.get_json()

    assert response.status_code == 200, response_data
    assert isinstance(response_data, list)
    assert len(response_data) == 1

    returned_child = response_data[0]
    assert returned_child["id"] == created_child["id"]
    assert returned_child["name"] == "Sara"
    assert returned_child["birth_date"] == "2015-05-10"
    assert returned_child["phone"] == "0559876543"


def test_get_children_response_contains_all_schema_fields(client):
    parent = register_parent(client)
    create_child(client, parent["access_token"])

    response = get_children_request(client, parent["access_token"])
    response_data = response.get_json()

    assert response.status_code == 200, response_data
    assert len(response_data) == 1

    expected_fields = {
        "id",
        "name",
        "birth_date",
        "phone",
        "age",
        "access_code",
        "role",
    }
    assert expected_fields.issubset(response_data[0].keys())


def test_get_children_returns_child_role(client):
    parent = register_parent(client)
    create_child(client, parent["access_token"])

    response = get_children_request(client, parent["access_token"])
    child = response.get_json()[0]

    assert response.status_code == 200
    assert child["role"] == "child"


def test_get_children_returns_access_code(client):
    parent = register_parent(client)
    created_child = create_child(client, parent["access_token"])

    response = get_children_request(client, parent["access_token"])
    child = response.get_json()[0]

    assert response.status_code == 200
    assert child["access_code"] == created_child["access_code"]
    assert isinstance(child["access_code"], str)
    assert len(child["access_code"]) == 6
    assert child["access_code"].isdigit()


def test_get_children_returns_integer_age(client):
    parent = register_parent(client)
    create_child(client, parent["access_token"])

    response = get_children_request(client, parent["access_token"])
    child = response.get_json()[0]

    assert response.status_code == 200
    assert isinstance(child["age"], int)
    assert 6 <= child["age"] <= 18


def test_get_children_returns_null_phone(client):
    parent = register_parent(client)
    create_child(
        client,
        parent["access_token"],
        valid_child_data(phone=None),
    )

    response = get_children_request(client, parent["access_token"])
    child = response.get_json()[0]

    assert response.status_code == 200
    assert child["phone"] is None


def test_get_children_returns_multiple_children(client):
    parent = register_parent(client)

    first_child = create_child(
        client,
        parent["access_token"],
        valid_child_data(
            name="Sara",
            birth_date="2015-05-10",
            phone="0559876543",
        ),
    )
    second_child = create_child(
        client,
        parent["access_token"],
        valid_child_data(
            name="Khalid",
            birth_date="2014-06-15",
            phone="0558765432",
        ),
    )
    third_child = create_child(
        client,
        parent["access_token"],
        valid_child_data(
            name="Noura",
            birth_date="2013-08-20",
            phone=None,
        ),
    )

    response = get_children_request(client, parent["access_token"])
    response_data = response.get_json()

    assert response.status_code == 200, response_data
    assert len(response_data) == 3

    returned_ids = {child["id"] for child in response_data}
    assert returned_ids == {
        first_child["id"],
        second_child["id"],
        third_child["id"],
    }


def test_get_children_preserves_each_child_data(client):
    parent = register_parent(client)

    create_child(
        client,
        parent["access_token"],
        valid_child_data(
            name="Sara Mohammed",
            birth_date="2015-05-10",
            phone="0559876543",
        ),
    )
    create_child(
        client,
        parent["access_token"],
        valid_child_data(
            name="Khalid Ahmed",
            birth_date="2014-06-15",
            phone="0558765432",
        ),
    )

    response = get_children_request(client, parent["access_token"])
    response_data = response.get_json()
    children_by_name = {child["name"]: child for child in response_data}

    assert response.status_code == 200
    assert children_by_name["Sara Mohammed"]["birth_date"] == "2015-05-10"
    assert children_by_name["Sara Mohammed"]["phone"] == "0559876543"
    assert children_by_name["Khalid Ahmed"]["birth_date"] == "2014-06-15"
    assert children_by_name["Khalid Ahmed"]["phone"] == "0558765432"


def test_get_children_does_not_return_another_family_children(client):
    first_parent = register_parent(
        client,
        valid_parent_data(
            phone="0551111111",
            email="first.get.children.parent@gmail.com",
        ),
    )
    first_child = create_child(
        client,
        first_parent["access_token"],
        valid_child_data(name="Sara", phone="0552222222"),
    )

    second_parent = register_parent(
        client,
        valid_parent_data(
            first_name="Noura",
            phone="0553333333",
            email="second.get.children.parent@gmail.com",
        ),
    )
    second_child = create_child(
        client,
        second_parent["access_token"],
        valid_child_data(
            name="Khalid",
            birth_date="2014-06-15",
            phone="0554444444",
        ),
    )

    first_response = get_children_request(client, first_parent["access_token"])
    second_response = get_children_request(client, second_parent["access_token"])

    first_children = first_response.get_json()
    second_children = second_response.get_json()

    assert first_response.status_code == 200
    assert second_response.status_code == 200
    assert {child["id"] for child in first_children} == {first_child["id"]}
    assert {child["id"] for child in second_children} == {second_child["id"]}


# =========================================================
# Authentication and authorization
# =========================================================


def test_get_children_requires_access_token(client):
    response = client.get(CHILDREN_URL)
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
def test_get_children_rejects_invalid_access_token(client, invalid_token):
    response = client.get(
        CHILDREN_URL,
        headers=authorization_header(invalid_token),
    )
    response_data = response.get_json()

    assert response.status_code in (401, 422), response_data


def test_child_token_cannot_get_parent_children(client):
    parent = register_parent(client)
    child = create_child(client, parent["access_token"])

    login_response = client.post(
        CHILD_LOGIN_URL,
        json={"access_code": child["access_code"]},
    )
    login_data = login_response.get_json()

    assert login_response.status_code == 200, login_data
    assert "access_token" in login_data

    response = get_children_request(client, login_data["access_token"])
    response_data = response.get_json()

    assert response.status_code == 403, response_data
    assert response_data["error"] == "Parent access required"


# =========================================================
# Route and service interaction
# =========================================================


def test_get_children_passes_parent_identity_to_service(client, app, monkeypatch):
    parent = register_parent(client)
    captured = {}

    with app.app_context():
        token_data = decode_token(parent["access_token"])
        expected_parent_id = token_data["sub"]

    def fake_get_children_by_parent(parent_id):
        captured["parent_id"] = parent_id
        return []

    monkeypatch.setattr(
        child_routes.child_service,
        "get_children_by_parent",
        fake_get_children_by_parent,
    )

    response = get_children_request(client, parent["access_token"])

    assert response.status_code == 200
    assert response.get_json() == []
    assert captured["parent_id"] == expected_parent_id


def test_get_children_serializes_service_result(client, monkeypatch):
    parent = register_parent(client)

    class FakeChild:
        id = "fake-child-id"
        name = "Fake Child"
        birth_date = None
        phone = None
        age = 10
        access_code = "123456"

    monkeypatch.setattr(
        child_routes.child_service,
        "get_children_by_parent",
        lambda parent_id: [FakeChild()],
    )

    response = get_children_request(client, parent["access_token"])
    response_data = response.get_json()

    assert response.status_code == 200
    assert response_data == [
        {
            "id": "fake-child-id",
            "name": "Fake Child",
            "birth_date": None,
            "phone": None,
            "age": 10,
            "access_code": "123456",
            "role": "child",
        }
    ]


def test_service_returns_empty_list_when_parent_not_found(monkeypatch):
    service = child_routes.child_service

    monkeypatch.setattr(
        service.user_repository,
        "get_user_by_id",
        lambda parent_id: None,
    )

    repository_called = {"value": False}

    def fake_get_children_by_guardian(guardian):
        repository_called["value"] = True
        return ["unexpected"]

    monkeypatch.setattr(
        service.child_repository,
        "get_children_by_guardian",
        fake_get_children_by_guardian,
    )

    result = service.get_children_by_parent("missing-parent-id")

    assert result == []
    assert repository_called["value"] is False


def test_service_passes_parent_to_repository(monkeypatch):
    service = child_routes.child_service
    fake_parent = object()
    expected_children = [object(), object()]
    captured = {}

    def fake_get_user_by_id(parent_id):
        captured["parent_id"] = parent_id
        return fake_parent

    def fake_get_children_by_guardian(guardian):
        captured["guardian"] = guardian
        return expected_children

    monkeypatch.setattr(
        service.user_repository,
        "get_user_by_id",
        fake_get_user_by_id,
    )
    monkeypatch.setattr(
        service.child_repository,
        "get_children_by_guardian",
        fake_get_children_by_guardian,
    )

    result = service.get_children_by_parent("parent-id-123")

    assert captured["parent_id"] == "parent-id-123"
    assert captured["guardian"] is fake_parent
    assert result is expected_children


def test_repository_returns_guardian_children():
    repository = child_routes.child_service.child_repository

    first_child = object()
    second_child = object()

    class FakeGuardian:
        children = [first_child, second_child]

    result = repository.get_children_by_guardian(FakeGuardian())

    assert result == [first_child, second_child]
    assert result[0] is first_child
    assert result[1] is second_child