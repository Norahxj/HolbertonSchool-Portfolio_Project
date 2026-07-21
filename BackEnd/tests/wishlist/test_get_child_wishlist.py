import pytest
from flask_jwt_extended import decode_token

from app.routes import wishlist_routes


REGISTER_URL = "/api/auth/register"
CHILDREN_URL = "/api/children/"
CHILD_LOGIN_URL = "/api/auth/child-login"


def authorization_header(token):
    return {"Authorization": token}


def child_wishlist_url(child_id):
    return f"/api/wishlists/child/{child_id}"


def register_parent(
    client,
    email="child.wishlist.parent@gmail.com",
    phone="0556200001",
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
    phone="0556200099",
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


def get_child_wishlist_request(
    client,
    token,
    child_id,
):
    return client.get(
        child_wishlist_url(child_id),
        headers=authorization_header(token),
    )


# ---------------------------------------------------------------------------
# Authentication and authorization
# ---------------------------------------------------------------------------

def test_get_child_wishlist_requires_access_token(client):
    response = client.get(
        child_wishlist_url("child-id")
    )

    assert response.status_code == 401


@pytest.mark.parametrize(
    "token",
    [
        "invalid-token",
        "abc.def",
        "abc.def.ghi",
    ],
)
def test_get_child_wishlist_rejects_invalid_token(
    client,
    token,
):
    response = client.get(
        child_wishlist_url("child-id"),
        headers=authorization_header(token),
    )

    assert response.status_code in (401, 422)


def test_child_cannot_get_child_wishlist(client):
    parent = register_parent(client)
    child = create_child(
        client,
        parent["access_token"],
    )
    child_login = login_child(
        client,
        child["access_code"],
    )

    response = get_child_wishlist_request(
        client,
        child_login["access_token"],
        child["id"],
    )

    assert response.status_code == 403
    assert response.get_json() == {
        "error": "Parent access required"
    }


# ---------------------------------------------------------------------------
# Route behavior
# ---------------------------------------------------------------------------

def test_route_passes_child_id_and_parent_id_to_service(
    client,
    app,
    monkeypatch,
):
    parent = register_parent(client)
    child = create_child(
        client,
        parent["access_token"],
    )

    with app.app_context():
        expected_parent_id = decode_token(
            parent["access_token"]
        )["sub"]

    captured = {}

    def fake_get_child_wishes(
        child_id,
        parent_id,
    ):
        captured["child_id"] = child_id
        captured["parent_id"] = parent_id
        return [], None

    monkeypatch.setattr(
        wishlist_routes.wishlist_service,
        "get_child_wishes",
        fake_get_child_wishes,
    )
    monkeypatch.setattr(
        wishlist_routes.wishlists_response_schema,
        "dump",
        lambda wishes: [],
    )

    response = get_child_wishlist_request(
        client,
        parent["access_token"],
        child["id"],
    )

    assert response.status_code == 200
    assert response.get_json() == []
    assert captured == {
        "child_id": child["id"],
        "parent_id": expected_parent_id,
    }


def test_route_returns_404_when_child_not_found(
    client,
    monkeypatch,
):
    parent = register_parent(client)

    monkeypatch.setattr(
        wishlist_routes.wishlist_service,
        "get_child_wishes",
        lambda child_id, parent_id: (
            None,
            "child_not_found",
        ),
    )

    response = get_child_wishlist_request(
        client,
        parent["access_token"],
        "missing-child",
    )

    assert response.status_code == 404
    assert response.get_json() == {
        "error": "Child not found"
    }


def test_route_does_not_serialize_when_child_not_found(
    client,
    monkeypatch,
):
    parent = register_parent(client)
    dump_called = {"value": False}

    monkeypatch.setattr(
        wishlist_routes.wishlist_service,
        "get_child_wishes",
        lambda child_id, parent_id: (
            None,
            "child_not_found",
        ),
    )

    def fake_dump(value):
        dump_called["value"] = True
        return []

    monkeypatch.setattr(
        wishlist_routes.wishlists_response_schema,
        "dump",
        fake_dump,
    )

    response = get_child_wishlist_request(
        client,
        parent["access_token"],
        "missing-child",
    )

    assert response.status_code == 404
    assert dump_called["value"] is False


def test_route_serializes_wishes_returned_by_service(
    client,
    monkeypatch,
):
    parent = register_parent(client)
    child = create_child(
        client,
        parent["access_token"],
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
        "get_child_wishes",
        lambda child_id, parent_id: (
            wishes,
            None,
        ),
    )

    def fake_dump(value):
        captured["value"] = value
        return serialized

    monkeypatch.setattr(
        wishlist_routes.wishlists_response_schema,
        "dump",
        fake_dump,
    )

    response = get_child_wishlist_request(
        client,
        parent["access_token"],
        child["id"],
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

    monkeypatch.setattr(
        wishlist_routes.wishlist_service,
        "get_child_wishes",
        lambda child_id, parent_id: (
            [],
            None,
        ),
    )
    monkeypatch.setattr(
        wishlist_routes.wishlists_response_schema,
        "dump",
        lambda wishes: [],
    )

    response = get_child_wishlist_request(
        client,
        parent["access_token"],
        child["id"],
    )

    assert response.status_code == 200
    assert response.get_json() == []


def test_route_serializes_all_wishlist_response_fields(
    client,
    monkeypatch,
):
    parent = register_parent(client)
    child = create_child(
        client,
        parent["access_token"],
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
        "get_child_wishes",
        lambda child_id, parent_id: (
            [FakeWish()],
            None,
        ),
    )

    response = get_child_wishlist_request(
        client,
        parent["access_token"],
        child["id"],
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

def test_service_passes_child_id_and_parent_id_to_child_repository(
    monkeypatch,
):
    service = wishlist_routes.wishlist_service
    captured = {}

    def fake_get_child_for_guardian(
        child_id,
        parent_id,
    ):
        captured["child_id"] = child_id
        captured["parent_id"] = parent_id
        return None

    monkeypatch.setattr(
        service.child_repository,
        "get_child_for_guardian",
        fake_get_child_for_guardian,
    )

    wishes, error = service.get_child_wishes(
        "child-id",
        "parent-id",
    )

    assert wishes is None
    assert error == "child_not_found"
    assert captured == {
        "child_id": "child-id",
        "parent_id": "parent-id",
    }


def test_service_returns_child_not_found_when_parent_has_no_access(
    monkeypatch,
):
    service = wishlist_routes.wishlist_service
    wishlist_repository_called = {
        "value": False
    }

    monkeypatch.setattr(
        service.child_repository,
        "get_child_for_guardian",
        lambda child_id, parent_id: None,
    )

    def fake_get_wishes_by_child_id(child_id):
        wishlist_repository_called["value"] = True
        return []

    monkeypatch.setattr(
        service.wishlist_repository,
        "get_wishes_by_child_id",
        fake_get_wishes_by_child_id,
    )

    wishes, error = service.get_child_wishes(
        "child-id",
        "parent-id",
    )

    assert wishes is None
    assert error == "child_not_found"
    assert wishlist_repository_called["value"] is False


def test_service_passes_child_id_to_wishlist_repository(
    monkeypatch,
):
    service = wishlist_routes.wishlist_service
    captured = {}

    monkeypatch.setattr(
        service.child_repository,
        "get_child_for_guardian",
        lambda child_id, parent_id: object(),
    )

    def fake_get_wishes_by_child_id(child_id):
        captured["child_id"] = child_id
        return []

    monkeypatch.setattr(
        service.wishlist_repository,
        "get_wishes_by_child_id",
        fake_get_wishes_by_child_id,
    )

    wishes, error = service.get_child_wishes(
        "child-id",
        "parent-id",
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
        service.child_repository,
        "get_child_for_guardian",
        lambda child_id, parent_id: object(),
    )
    monkeypatch.setattr(
        service.wishlist_repository,
        "get_wishes_by_child_id",
        lambda child_id: repository_wishes,
    )

    wishes, error = service.get_child_wishes(
        "child-id",
        "parent-id",
    )

    assert wishes is repository_wishes
    assert error is None


def test_service_returns_empty_list_without_modification(
    monkeypatch,
):
    service = wishlist_routes.wishlist_service
    repository_wishes = []

    monkeypatch.setattr(
        service.child_repository,
        "get_child_for_guardian",
        lambda child_id, parent_id: object(),
    )
    monkeypatch.setattr(
        service.wishlist_repository,
        "get_wishes_by_child_id",
        lambda child_id: repository_wishes,
    )

    wishes, error = service.get_child_wishes(
        "child-id",
        "parent-id",
    )

    assert wishes is repository_wishes
    assert wishes == []
    assert error is None