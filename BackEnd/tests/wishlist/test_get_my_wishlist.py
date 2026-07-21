import pytest
from flask_jwt_extended import decode_token

from app.routes import wishlist_routes


REGISTER_URL = "/api/auth/register"
CHILDREN_URL = "/api/children/"
CHILD_LOGIN_URL = "/api/auth/child-login"
MY_WISHLIST_URL = "/api/wishlists/my"


def authorization_header(token):
    return {"Authorization": token}


def register_parent(
    client,
    email="my.wishlist.parent@gmail.com",
    phone="0556100001",
):
    response = client.post(
        REGISTER_URL,
        json={
            "first_name": "Manar",
            "last_name": "Zaid",
            "phone": phone,
            "email": email,
            "password": "Password123!",
            "guardian_type": "mother",
        },
    )

    assert response.status_code == 201, response.get_json()
    return response.get_json()


def create_child(
    client,
    parent_token,
    name="Sara",
    phone="0556100099",
):
    response = client.post(
        CHILDREN_URL,
        headers=authorization_header(parent_token),
        json={
            "name": name,
            "birth_date": "2015-05-10",
            "phone": phone,
        },
    )

    assert response.status_code == 201, response.get_json()

    data = response.get_json()
    return data.get("child", data)


def login_child(client, access_code):
    response = client.post(
        CHILD_LOGIN_URL,
        json={"access_code": access_code},
    )

    assert response.status_code == 200, response.get_json()
    return response.get_json()


def get_my_wishlist_request(client, token):
    return client.get(
        MY_WISHLIST_URL,
        headers=authorization_header(token),
    )


# ---------------------------------------------------------------------------
# Authentication and authorization
# ---------------------------------------------------------------------------

def test_get_my_wishlist_requires_access_token(client):
    response = client.get(MY_WISHLIST_URL)

    assert response.status_code == 401


@pytest.mark.parametrize(
    "token",
    [
        "invalid-token",
        "abc.def",
        "abc.def.ghi",
    ],
)
def test_get_my_wishlist_rejects_invalid_token(
    client,
    token,
):
    response = client.get(
        MY_WISHLIST_URL,
        headers=authorization_header(token),
    )

    assert response.status_code in (401, 422)


def test_parent_cannot_get_child_wishlist(client):
    parent = register_parent(client)

    response = get_my_wishlist_request(
        client,
        parent["access_token"],
    )

    assert response.status_code == 403
    assert response.get_json() == {
        "error": "Child access required"
    }


# ---------------------------------------------------------------------------
# Route behavior
# ---------------------------------------------------------------------------

def test_route_passes_child_id_from_token_to_service(
    client,
    app,
    monkeypatch,
):
    parent = register_parent(client)
    child = create_child(
        client,
        parent["access_token"],
    )
    child_login = login_child(
        client,
        child["access_code"],
    )

    with app.app_context():
        expected_child_id = decode_token(
            child_login["access_token"]
        )["sub"]

    captured = {}

    def fake_get_my_wishes(child_id):
        captured["child_id"] = child_id
        return [], None

    monkeypatch.setattr(
        wishlist_routes.wishlist_service,
        "get_my_wishes",
        fake_get_my_wishes,
    )
    monkeypatch.setattr(
        wishlist_routes.wishlists_response_schema,
        "dump",
        lambda wishes: [],
    )

    response = get_my_wishlist_request(
        client,
        child_login["access_token"],
    )

    assert response.status_code == 200
    assert response.get_json() == []
    assert captured["child_id"] == expected_child_id


def test_route_serializes_wishes_returned_by_service(
    client,
    monkeypatch,
):
    parent = register_parent(client)
    child = create_child(
        client,
        parent["access_token"],
    )
    child_login = login_child(
        client,
        child["access_code"],
    )

    wishes = [object(), object()]
    serialized = [
        {
            "id": "wish-1",
            "name": "Bicycle",
            "status": "PENDING",
        },
        {
            "id": "wish-2",
            "name": "Book",
            "status": "APPROVED",
        },
    ]
    captured = {}

    monkeypatch.setattr(
        wishlist_routes.wishlist_service,
        "get_my_wishes",
        lambda child_id: (wishes, None),
    )

    def fake_dump(value):
        captured["value"] = value
        return serialized

    monkeypatch.setattr(
        wishlist_routes.wishlists_response_schema,
        "dump",
        fake_dump,
    )

    response = get_my_wishlist_request(
        client,
        child_login["access_token"],
    )

    assert response.status_code == 200
    assert response.get_json() == serialized
    assert captured["value"] is wishes


def test_route_returns_empty_list_when_child_has_no_wishes(
    client,
    monkeypatch,
):
    parent = register_parent(client)
    child = create_child(
        client,
        parent["access_token"],
    )
    child_login = login_child(
        client,
        child["access_code"],
    )

    monkeypatch.setattr(
        wishlist_routes.wishlist_service,
        "get_my_wishes",
        lambda child_id: ([], None),
    )
    monkeypatch.setattr(
        wishlist_routes.wishlists_response_schema,
        "dump",
        lambda wishes: [],
    )

    response = get_my_wishlist_request(
        client,
        child_login["access_token"],
    )

    assert response.status_code == 200
    assert response.get_json() == []


def test_route_ignores_service_error_value_and_returns_200(
    client,
    monkeypatch,
):
    parent = register_parent(client)
    child = create_child(
        client,
        parent["access_token"],
    )
    child_login = login_child(
        client,
        child["access_code"],
    )

    wishes = [object()]

    monkeypatch.setattr(
        wishlist_routes.wishlist_service,
        "get_my_wishes",
        lambda child_id: (
            wishes,
            "unexpected_error",
        ),
    )
    monkeypatch.setattr(
        wishlist_routes.wishlists_response_schema,
        "dump",
        lambda value: [{"id": "wish-1"}],
    )

    response = get_my_wishlist_request(
        client,
        child_login["access_token"],
    )

    assert response.status_code == 200
    assert response.get_json() == [
        {"id": "wish-1"}
    ]


def test_route_serializes_all_wishlist_response_fields(
    client,
    monkeypatch,
):
    parent = register_parent(client)
    child = create_child(
        client,
        parent["access_token"],
    )
    child_login = login_child(
        client,
        child["access_code"],
    )

    class FakeWish:
        id = "wish-id"
        child_id = "child-id"
        name = "New bicycle"
        target_points = 150
        status = "APPROVED"
        reviewed_by = "parent-id"
        approved_at = None
        created_at = None

    monkeypatch.setattr(
        wishlist_routes.wishlist_service,
        "get_my_wishes",
        lambda child_id: ([FakeWish()], None),
    )

    response = get_my_wishlist_request(
        client,
        child_login["access_token"],
    )

    assert response.status_code == 200

    data = response.get_json()

    assert isinstance(data, list)
    assert len(data) == 1
    assert data[0]["id"] == "wish-id"
    assert data[0]["child_id"] == "child-id"
    assert data[0]["name"] == "New bicycle"
    assert data[0]["target_points"] == 150
    assert data[0]["status"] == "APPROVED"
    assert data[0]["reviewed_by"] == "parent-id"
    assert data[0]["approved_at"] is None
    assert data[0]["created_at"] is None


# ---------------------------------------------------------------------------
# Service behavior
# ---------------------------------------------------------------------------

def test_service_passes_child_id_to_repository(
    monkeypatch,
):
    service = wishlist_routes.wishlist_service
    captured = {}

    def fake_get_wishes_by_child_id(child_id):
        captured["child_id"] = child_id
        return []

    monkeypatch.setattr(
        service.wishlist_repository,
        "get_wishes_by_child_id",
        fake_get_wishes_by_child_id,
    )

    wishes, error = service.get_my_wishes(
        "child-id"
    )

    assert wishes == []
    assert error is None
    assert captured["child_id"] == "child-id"


def test_service_returns_same_wishes_from_repository(
    monkeypatch,
):
    service = wishlist_routes.wishlist_service
    repository_wishes = [object(), object()]

    monkeypatch.setattr(
        service.wishlist_repository,
        "get_wishes_by_child_id",
        lambda child_id: repository_wishes,
    )

    wishes, error = service.get_my_wishes(
        "child-id"
    )

    assert wishes is repository_wishes
    assert error is None


def test_service_returns_empty_list_without_modification(
    monkeypatch,
):
    service = wishlist_routes.wishlist_service
    repository_wishes = []

    monkeypatch.setattr(
        service.wishlist_repository,
        "get_wishes_by_child_id",
        lambda child_id: repository_wishes,
    )

    wishes, error = service.get_my_wishes(
        "child-id"
    )

    assert wishes is repository_wishes
    assert wishes == []
    assert error is None