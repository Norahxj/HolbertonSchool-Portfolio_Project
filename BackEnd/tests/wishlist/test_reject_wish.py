import pytest
from flask_jwt_extended import decode_token

from app.routes import wishlist_routes
import app.services.wishlist_service as wishlist_service_module


REGISTER_URL = "/api/auth/register"
CHILDREN_URL = "/api/children/"
CHILD_LOGIN_URL = "/api/auth/child-login"


def authorization_header(token):
    return {"Authorization": token}


def reject_wish_url(wish_id):
    return f"/api/wishlists/{wish_id}/reject"


def register_parent(
    client,
    email="reject.wish.parent@gmail.com",
    phone="0556400001",
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
    phone="0556400099",
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


def reject_wish_request(
    client,
    token,
    wish_id,
):
    return client.put(
        reject_wish_url(wish_id),
        headers=authorization_header(token),
    )


# ---------------------------------------------------------------------------
# Authentication and authorization
# ---------------------------------------------------------------------------

def test_reject_wish_requires_access_token(client):
    response = client.put(
        reject_wish_url("wish-id")
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
def test_reject_wish_rejects_invalid_token(
    client,
    token,
):
    response = client.put(
        reject_wish_url("wish-id"),
        headers=authorization_header(token),
    )

    assert response.status_code in (401, 422)


def test_child_cannot_reject_wish(client):
    parent = register_parent(client)
    child = create_child(
        client,
        parent["access_token"],
    )
    child_login = login_child(
        client,
        child["access_code"],
    )

    response = reject_wish_request(
        client,
        child_login["access_token"],
        "wish-id",
    )

    assert response.status_code == 403
    assert response.get_json() == {
        "error": "Parent access required"
    }


# ---------------------------------------------------------------------------
# Route behavior
# ---------------------------------------------------------------------------

def test_route_passes_wish_id_and_parent_id_to_service(
    client,
    app,
    monkeypatch,
):
    parent = register_parent(client)

    with app.app_context():
        expected_parent_id = decode_token(
            parent["access_token"]
        )["sub"]

    captured = {}

    class FakeWish:
        id = "wish-id"

    def fake_reject_wish(
        wish_id,
        parent_id,
    ):
        captured["wish_id"] = wish_id
        captured["parent_id"] = parent_id
        return FakeWish(), None

    monkeypatch.setattr(
        wishlist_routes.wishlist_service,
        "reject_wish",
        fake_reject_wish,
    )
    monkeypatch.setattr(
        wishlist_routes.wishlist_response_schema,
        "dump",
        lambda wish: {"id": wish.id},
    )

    response = reject_wish_request(
        client,
        parent["access_token"],
        "wish-id",
    )

    assert response.status_code == 200
    assert response.get_json() == {
        "id": "wish-id"
    }
    assert captured == {
        "wish_id": "wish-id",
        "parent_id": expected_parent_id,
    }


@pytest.mark.parametrize(
    (
        "service_error",
        "expected_status",
        "expected_body",
    ),
    [
        (
            "wish_not_found",
            404,
            {"error": "Wish not found"},
        ),
        (
            "child_not_found",
            404,
            {"error": "Child not found"},
        ),
        (
            "wish_already_reviewed",
            400,
            {
                "error": (
                    "Wish has already been reviewed"
                )
            },
        ),
        (
            "update_failed",
            500,
            {"error": "Failed to reject wish"},
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
        wishlist_routes.wishlist_service,
        "reject_wish",
        lambda wish_id, parent_id: (
            None,
            service_error,
        ),
    )

    response = reject_wish_request(
        client,
        parent["access_token"],
        "wish-id",
    )

    assert response.status_code == expected_status
    assert response.get_json() == expected_body


def test_route_does_not_serialize_on_error(
    client,
    monkeypatch,
):
    parent = register_parent(client)
    dump_called = {"value": False}

    monkeypatch.setattr(
        wishlist_routes.wishlist_service,
        "reject_wish",
        lambda wish_id, parent_id: (
            None,
            "update_failed",
        ),
    )

    def fake_dump(value):
        dump_called["value"] = True
        return {}

    monkeypatch.setattr(
        wishlist_routes.wishlist_response_schema,
        "dump",
        fake_dump,
    )

    response = reject_wish_request(
        client,
        parent["access_token"],
        "wish-id",
    )

    assert response.status_code == 500
    assert dump_called["value"] is False


def test_route_serializes_rejected_wish(
    client,
    monkeypatch,
):
    parent = register_parent(client)
    wish = object()
    serialized = {
        "id": "wish-id",
        "name": "Bicycle",
        "status": "REJECTED",
        "reviewed_by": "parent-id",
        "approved_at": None,
    }
    captured = {}

    monkeypatch.setattr(
        wishlist_routes.wishlist_service,
        "reject_wish",
        lambda wish_id, parent_id: (
            wish,
            None,
        ),
    )

    def fake_dump(value):
        captured["wish"] = value
        return serialized

    monkeypatch.setattr(
        wishlist_routes.wishlist_response_schema,
        "dump",
        fake_dump,
    )

    response = reject_wish_request(
        client,
        parent["access_token"],
        "wish-id",
    )

    assert response.status_code == 200
    assert response.get_json() == serialized
    assert captured["wish"] is wish


def test_route_serializes_all_wishlist_response_fields(
    client,
    monkeypatch,
):
    parent = register_parent(client)

    class FakeWish:
        id = "wish-id"
        child_id = "child-id"
        name = "New bicycle"
        target_points = None
        status = "REJECTED"
        reviewed_by = "parent-id"
        approved_at = None
        created_at = None

    monkeypatch.setattr(
        wishlist_routes.wishlist_service,
        "reject_wish",
        lambda wish_id, parent_id: (
            FakeWish(),
            None,
        ),
    )

    response = reject_wish_request(
        client,
        parent["access_token"],
        "wish-id",
    )

    assert response.status_code == 200

    data = response.get_json()

    assert data["id"] == "wish-id"
    assert data["child_id"] == "child-id"
    assert data["name"] == "New bicycle"
    assert data["target_points"] is None
    assert data["status"] == "REJECTED"
    assert data["reviewed_by"] == "parent-id"
    assert data["approved_at"] is None
    assert data["created_at"] is None


# ---------------------------------------------------------------------------
# Service behavior
# ---------------------------------------------------------------------------

class FakeWish:
    def __init__(
        self,
        status="PENDING",
        child_id="child-id",
    ):
        self.id = "wish-id"
        self.child_id = child_id
        self.name = "Bicycle"
        self.target_points = None
        self.status = status
        self.reviewed_by = None
        self.approved_at = object()


def test_service_passes_wish_id_to_repository(
    monkeypatch,
):
    service = wishlist_routes.wishlist_service
    captured = {}

    def fake_get_wish_by_id(wish_id):
        captured["wish_id"] = wish_id
        return None

    monkeypatch.setattr(
        service.wishlist_repository,
        "get_wish_by_id",
        fake_get_wish_by_id,
    )

    result = service.reject_wish(
        "wish-id",
        "parent-id",
    )

    assert result == (None, "wish_not_found")
    assert captured["wish_id"] == "wish-id"


def test_service_returns_wish_not_found(
    monkeypatch,
):
    service = wishlist_routes.wishlist_service

    monkeypatch.setattr(
        service.wishlist_repository,
        "get_wish_by_id",
        lambda wish_id: None,
    )

    result = service.reject_wish(
        "missing-wish",
        "parent-id",
    )

    assert result == (None, "wish_not_found")


def test_service_passes_child_and_parent_to_guardian_lookup(
    monkeypatch,
):
    service = wishlist_routes.wishlist_service
    wish = FakeWish()
    captured = {}

    monkeypatch.setattr(
        service.wishlist_repository,
        "get_wish_by_id",
        lambda wish_id: wish,
    )

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

    result = service.reject_wish(
        "wish-id",
        "parent-id",
    )

    assert result == (None, "child_not_found")
    assert captured == {
        "child_id": "child-id",
        "parent_id": "parent-id",
    }


def test_service_does_not_lock_wish_when_parent_has_no_access(
    monkeypatch,
):
    service = wishlist_routes.wishlist_service
    wish = FakeWish()
    lock_called = {"value": False}

    monkeypatch.setattr(
        service.wishlist_repository,
        "get_wish_by_id",
        lambda wish_id: wish,
    )
    monkeypatch.setattr(
        service.child_repository,
        "get_child_for_guardian",
        lambda child_id, parent_id: None,
    )

    def fake_get_wish_by_id_for_update(wish_id):
        lock_called["value"] = True
        return wish

    monkeypatch.setattr(
        service.wishlist_repository,
        "get_wish_by_id_for_update",
        fake_get_wish_by_id_for_update,
    )

    result = service.reject_wish(
        "wish-id",
        "parent-id",
    )

    assert result == (None, "child_not_found")
    assert lock_called["value"] is False


def test_service_passes_wish_id_to_locked_lookup(
    monkeypatch,
):
    service = wishlist_routes.wishlist_service
    wish = FakeWish()
    captured = {}

    monkeypatch.setattr(
        service.wishlist_repository,
        "get_wish_by_id",
        lambda wish_id: wish,
    )
    monkeypatch.setattr(
        service.child_repository,
        "get_child_for_guardian",
        lambda child_id, parent_id: object(),
    )

    def fake_get_wish_by_id_for_update(wish_id):
        captured["wish_id"] = wish_id
        return None

    monkeypatch.setattr(
        service.wishlist_repository,
        "get_wish_by_id_for_update",
        fake_get_wish_by_id_for_update,
    )
    monkeypatch.setattr(
        wishlist_service_module.db.session,
        "rollback",
        lambda: None,
    )

    result = service.reject_wish(
        "wish-id",
        "parent-id",
    )

    assert result == (None, "wish_not_found")
    assert captured["wish_id"] == "wish-id"


def test_service_rolls_back_when_locked_wish_not_found(
    monkeypatch,
):
    service = wishlist_routes.wishlist_service
    wish = FakeWish()
    rollback_calls = {"count": 0}

    monkeypatch.setattr(
        service.wishlist_repository,
        "get_wish_by_id",
        lambda wish_id: wish,
    )
    monkeypatch.setattr(
        service.child_repository,
        "get_child_for_guardian",
        lambda child_id, parent_id: object(),
    )
    monkeypatch.setattr(
        service.wishlist_repository,
        "get_wish_by_id_for_update",
        lambda wish_id: None,
    )
    monkeypatch.setattr(
        wishlist_service_module.db.session,
        "rollback",
        lambda: rollback_calls.__setitem__(
            "count",
            rollback_calls["count"] + 1,
        ),
    )

    result = service.reject_wish(
        "wish-id",
        "parent-id",
    )

    assert result == (None, "wish_not_found")
    assert rollback_calls["count"] == 1


@pytest.mark.parametrize(
    "status",
    [
        "APPROVED",
        "REJECTED",
        "ACHIEVED",
    ],
)
def test_service_rejects_already_reviewed_wish(
    monkeypatch,
    status,
):
    service = wishlist_routes.wishlist_service
    initial_wish = FakeWish()
    locked_wish = FakeWish(status=status)
    rollback_calls = {"count": 0}

    monkeypatch.setattr(
        service.wishlist_repository,
        "get_wish_by_id",
        lambda wish_id: initial_wish,
    )
    monkeypatch.setattr(
        service.child_repository,
        "get_child_for_guardian",
        lambda child_id, parent_id: object(),
    )
    monkeypatch.setattr(
        service.wishlist_repository,
        "get_wish_by_id_for_update",
        lambda wish_id: locked_wish,
    )
    monkeypatch.setattr(
        wishlist_service_module.db.session,
        "rollback",
        lambda: rollback_calls.__setitem__(
            "count",
            rollback_calls["count"] + 1,
        ),
    )

    result = service.reject_wish(
        "wish-id",
        "parent-id",
    )

    assert result == (
        None,
        "wish_already_reviewed",
    )
    assert rollback_calls["count"] == 1


def test_service_rejects_wish_and_sets_review_fields(
    monkeypatch,
):
    service = wishlist_routes.wishlist_service
    initial_wish = FakeWish()
    locked_wish = FakeWish()

    monkeypatch.setattr(
        service.wishlist_repository,
        "get_wish_by_id",
        lambda wish_id: initial_wish,
    )
    monkeypatch.setattr(
        service.child_repository,
        "get_child_for_guardian",
        lambda child_id, parent_id: object(),
    )
    monkeypatch.setattr(
        service.wishlist_repository,
        "get_wish_by_id_for_update",
        lambda wish_id: locked_wish,
    )
    monkeypatch.setattr(
        service.wishlist_repository,
        "update_wish",
        lambda: (True, None),
    )

    result, error = service.reject_wish(
        "wish-id",
        "parent-id",
    )

    assert error is None
    assert result is locked_wish
    assert locked_wish.status == "REJECTED"
    assert locked_wish.reviewed_by == "parent-id"
    assert locked_wish.approved_at is None


def test_service_calls_update_wish(
    monkeypatch,
):
    service = wishlist_routes.wishlist_service
    wish = FakeWish()
    update_calls = {"count": 0}

    monkeypatch.setattr(
        service.wishlist_repository,
        "get_wish_by_id",
        lambda wish_id: wish,
    )
    monkeypatch.setattr(
        service.child_repository,
        "get_child_for_guardian",
        lambda child_id, parent_id: object(),
    )
    monkeypatch.setattr(
        service.wishlist_repository,
        "get_wish_by_id_for_update",
        lambda wish_id: wish,
    )

    def fake_update_wish():
        update_calls["count"] += 1
        return True, None

    monkeypatch.setattr(
        service.wishlist_repository,
        "update_wish",
        fake_update_wish,
    )

    result, error = service.reject_wish(
        "wish-id",
        "parent-id",
    )

    assert error is None
    assert result is wish
    assert update_calls["count"] == 1


def test_service_returns_update_failed_when_repository_update_fails(
    monkeypatch,
):
    service = wishlist_routes.wishlist_service
    wish = FakeWish()

    monkeypatch.setattr(
        service.wishlist_repository,
        "get_wish_by_id",
        lambda wish_id: wish,
    )
    monkeypatch.setattr(
        service.child_repository,
        "get_child_for_guardian",
        lambda child_id, parent_id: object(),
    )
    monkeypatch.setattr(
        service.wishlist_repository,
        "get_wish_by_id_for_update",
        lambda wish_id: wish,
    )
    monkeypatch.setattr(
        service.wishlist_repository,
        "update_wish",
        lambda: (
            False,
            "integrity_error",
        ),
    )

    result = service.reject_wish(
        "wish-id",
        "parent-id",
    )

    assert result == (None, "update_failed")


def test_service_returns_same_locked_wish(
    monkeypatch,
):
    service = wishlist_routes.wishlist_service
    initial_wish = FakeWish()
    locked_wish = FakeWish()

    monkeypatch.setattr(
        service.wishlist_repository,
        "get_wish_by_id",
        lambda wish_id: initial_wish,
    )
    monkeypatch.setattr(
        service.child_repository,
        "get_child_for_guardian",
        lambda child_id, parent_id: object(),
    )
    monkeypatch.setattr(
        service.wishlist_repository,
        "get_wish_by_id_for_update",
        lambda wish_id: locked_wish,
    )
    monkeypatch.setattr(
        service.wishlist_repository,
        "update_wish",
        lambda: (True, None),
    )

    result, error = service.reject_wish(
        "wish-id",
        "parent-id",
    )

    assert error is None
    assert result is locked_wish
    assert result is not initial_wish


def test_service_rolls_back_on_unexpected_exception(
    monkeypatch,
):
    service = wishlist_routes.wishlist_service
    rollback_calls = {"count": 0}

    monkeypatch.setattr(
        service.wishlist_repository,
        "get_wish_by_id",
        lambda wish_id: (_ for _ in ()).throw(
            RuntimeError("database failure")
        ),
    )
    monkeypatch.setattr(
        wishlist_service_module.db.session,
        "rollback",
        lambda: rollback_calls.__setitem__(
            "count",
            rollback_calls["count"] + 1,
        ),
    )

    result = service.reject_wish(
        "wish-id",
        "parent-id",
    )

    assert result == (None, "update_failed")
    assert rollback_calls["count"] == 1