import pytest
from flask_jwt_extended import decode_token
from sqlalchemy.exc import IntegrityError

from app.routes import wishlist_routes
import app.services.wishlist_service as wishlist_service_module
import app.repositories.wishlist_repository as wishlist_repository_module
import app.repositories.child_repository as child_repository_module


REGISTER_URL = "/api/auth/register"
CHILDREN_URL = "/api/children/"
CHILD_LOGIN_URL = "/api/auth/child-login"
WISHLIST_URL = "/api/wishlists/"


def authorization_header(token):
    return {"Authorization": token}


def register_parent(
    client,
    email="wishlist.parent@gmail.com",
    phone="0555000001",
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
    phone="0555000099",
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


def create_wish_request(client, token, payload):
    return client.post(
        WISHLIST_URL,
        headers=authorization_header(token),
        json=payload,
    )


# ---------------------------------------------------------------------------
# Authentication and authorization
# ---------------------------------------------------------------------------

def test_create_wish_requires_access_token(client):
    response = client.post(
        WISHLIST_URL,
        json={"name": "New bicycle"},
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
def test_create_wish_rejects_invalid_token(client, token):
    response = client.post(
        WISHLIST_URL,
        headers=authorization_header(token),
        json={"name": "New bicycle"},
    )

    assert response.status_code in (401, 422)


def test_parent_cannot_create_wish(client):
    parent = register_parent(client)

    response = create_wish_request(
        client,
        parent["access_token"],
        {"name": "New bicycle"},
    )

    assert response.status_code == 403
    assert response.get_json() == {
        "error": "Child access required"
    }


# ---------------------------------------------------------------------------
# Validation
# ---------------------------------------------------------------------------

def test_create_wish_requires_name(client):
    parent = register_parent(client)
    child = create_child(
        client,
        parent["access_token"],
    )
    child_login = login_child(
        client,
        child["access_code"],
    )

    response = create_wish_request(
        client,
        child_login["access_token"],
        {},
    )

    assert response.status_code == 400
    assert "errors" in response.get_json()
    assert "name" in response.get_json()["errors"]


@pytest.mark.parametrize(
    "name",
    [
        "",
        " ",
        "A",
        " A ",
    ],
)
def test_create_wish_rejects_name_shorter_than_two_characters(
    client,
    name,
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

    response = create_wish_request(
        client,
        child_login["access_token"],
        {"name": name},
    )

    assert response.status_code == 400
    assert response.get_json() == {
        "errors": {
            "name": [
                "Wish name must be at least 2 characters long."
            ]
        }
    }


def test_create_wish_rejects_name_longer_than_255_characters(
    client,
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

    response = create_wish_request(
        client,
        child_login["access_token"],
        {"name": "A" * 256},
    )

    assert response.status_code == 400
    assert response.get_json() == {
        "errors": {
            "name": [
                "Wish name must not exceed 255 characters."
            ]
        }
    }


# ---------------------------------------------------------------------------
# Route behavior
# ---------------------------------------------------------------------------

def test_route_passes_child_id_and_validated_data_to_service(
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

    class FakeWish:
        id = "wish-id"

    def fake_create_wish(child_id, wish_data):
        captured["child_id"] = child_id
        captured["wish_data"] = wish_data
        return FakeWish(), None

    monkeypatch.setattr(
        wishlist_routes.wishlist_service,
        "create_wish",
        fake_create_wish,
    )
    monkeypatch.setattr(
        wishlist_routes.wishlist_response_schema,
        "dump",
        lambda wish: {"id": wish.id},
    )

    response = create_wish_request(
        client,
        child_login["access_token"],
        {"name": "  New bicycle  "},
    )

    assert response.status_code == 201
    assert response.get_json() == {"id": "wish-id"}
    assert captured == {
        "child_id": expected_child_id,
        "wish_data": {"name": "  New bicycle  "},
    }


@pytest.mark.parametrize(
    (
        "service_error",
        "expected_status",
        "expected_body",
    ),
    [
        (
            "child_not_found",
            404,
            {"error": "Child not found"},
        ),
        (
            "wishlist_limit_reached",
            400,
            {
                "error": (
                    "Wishlist limit reached. "
                    "Maximum 5 pending wishes allowed."
                )
            },
        ),
        (
            "create_failed",
            500,
            {"error": "Failed to create wish"},
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
        "create_wish",
        lambda child_id, wish_data: (
            None,
            service_error,
        ),
    )

    response = create_wish_request(
        client,
        child_login["access_token"],
        {"name": "New bicycle"},
    )

    assert response.status_code == expected_status
    assert response.get_json() == expected_body


def test_route_serializes_created_wish(
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

    wish = object()
    serialized = {
        "id": "wish-id",
        "name": "New bicycle",
        "status": "PENDING",
    }
    captured = {}

    monkeypatch.setattr(
        wishlist_routes.wishlist_service,
        "create_wish",
        lambda child_id, wish_data: (
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

    response = create_wish_request(
        client,
        child_login["access_token"],
        {"name": "New bicycle"},
    )

    assert response.status_code == 201
    assert response.get_json() == serialized
    assert captured["wish"] is wish


def test_route_does_not_serialize_when_service_returns_error(
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
    dump_called = {"value": False}

    monkeypatch.setattr(
        wishlist_routes.wishlist_service,
        "create_wish",
        lambda child_id, wish_data: (
            None,
            "create_failed",
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

    response = create_wish_request(
        client,
        child_login["access_token"],
        {"name": "New bicycle"},
    )

    assert response.status_code == 500
    assert dump_called["value"] is False


# ---------------------------------------------------------------------------
# Service behavior
# ---------------------------------------------------------------------------

class FakeChild:
    id = "child-id"


def test_service_passes_child_id_to_locked_child_lookup(
    monkeypatch,
):
    service = wishlist_routes.wishlist_service
    captured = {}

    def fake_get_child_by_id_for_update(child_id):
        captured["child_id"] = child_id
        return None

    monkeypatch.setattr(
        service.child_repository,
        "get_child_by_id_for_update",
        fake_get_child_by_id_for_update,
    )
    monkeypatch.setattr(
        wishlist_service_module.db.session,
        "rollback",
        lambda: None,
    )

    result = service.create_wish(
        "child-id",
        {"name": "New bicycle"},
    )

    assert result == (None, "child_not_found")
    assert captured["child_id"] == "child-id"


def test_service_rolls_back_when_child_not_found(
    monkeypatch,
):
    service = wishlist_routes.wishlist_service
    rollback_calls = {"count": 0}

    monkeypatch.setattr(
        service.child_repository,
        "get_child_by_id_for_update",
        lambda child_id: None,
    )
    monkeypatch.setattr(
        wishlist_service_module.db.session,
        "rollback",
        lambda: rollback_calls.__setitem__(
            "count",
            rollback_calls["count"] + 1,
        ),
    )

    result = service.create_wish(
        "missing-child",
        {"name": "New bicycle"},
    )

    assert result == (None, "child_not_found")
    assert rollback_calls["count"] == 1


def test_service_passes_child_id_to_pending_count_repository(
    monkeypatch,
):
    service = wishlist_routes.wishlist_service
    captured = {}

    monkeypatch.setattr(
        service.child_repository,
        "get_child_by_id_for_update",
        lambda child_id: FakeChild(),
    )

    def fake_get_pending_count(child_id):
        captured["child_id"] = child_id
        return 5

    monkeypatch.setattr(
        service.wishlist_repository,
        "get_pending_count_by_child_id",
        fake_get_pending_count,
    )
    monkeypatch.setattr(
        wishlist_service_module.db.session,
        "rollback",
        lambda: None,
    )

    result = service.create_wish(
        "child-id",
        {"name": "New bicycle"},
    )

    assert result == (
        None,
        "wishlist_limit_reached",
    )
    assert captured["child_id"] == "child-id"


@pytest.mark.parametrize("pending_count", [5, 6, 10])
def test_service_rejects_wish_when_pending_limit_reached(
    monkeypatch,
    pending_count,
):
    service = wishlist_routes.wishlist_service
    rollback_calls = {"count": 0}
    create_called = {"value": False}

    monkeypatch.setattr(
        service.child_repository,
        "get_child_by_id_for_update",
        lambda child_id: FakeChild(),
    )
    monkeypatch.setattr(
        service.wishlist_repository,
        "get_pending_count_by_child_id",
        lambda child_id: pending_count,
    )

    def fake_create_wish(wish):
        create_called["value"] = True
        return wish, None

    monkeypatch.setattr(
        service.wishlist_repository,
        "create_wish",
        fake_create_wish,
    )
    monkeypatch.setattr(
        wishlist_service_module.db.session,
        "rollback",
        lambda: rollback_calls.__setitem__(
            "count",
            rollback_calls["count"] + 1,
        ),
    )

    result = service.create_wish(
        "child-id",
        {"name": "New bicycle"},
    )

    assert result == (
        None,
        "wishlist_limit_reached",
    )
    assert rollback_calls["count"] == 1
    assert create_called["value"] is False


def test_service_creates_pending_wish_with_trimmed_name(
    monkeypatch,
):
    service = wishlist_routes.wishlist_service
    captured = {}

    monkeypatch.setattr(
        service.child_repository,
        "get_child_by_id_for_update",
        lambda child_id: FakeChild(),
    )
    monkeypatch.setattr(
        service.wishlist_repository,
        "get_pending_count_by_child_id",
        lambda child_id: 4,
    )

    def fake_create_wish(wish):
        captured["wish"] = wish
        return wish, None

    monkeypatch.setattr(
        service.wishlist_repository,
        "create_wish",
        fake_create_wish,
    )

    result, error = service.create_wish(
        "child-id",
        {"name": "  New bicycle  "},
    )

    assert error is None
    assert result is captured["wish"]
    assert captured["wish"].child_id == "child-id"
    assert captured["wish"].name == "New bicycle"
    assert captured["wish"].status == "PENDING"


def test_service_returns_create_failed_when_repository_fails(
    monkeypatch,
):
    service = wishlist_routes.wishlist_service

    monkeypatch.setattr(
        service.child_repository,
        "get_child_by_id_for_update",
        lambda child_id: FakeChild(),
    )
    monkeypatch.setattr(
        service.wishlist_repository,
        "get_pending_count_by_child_id",
        lambda child_id: 0,
    )
    monkeypatch.setattr(
        service.wishlist_repository,
        "create_wish",
        lambda wish: (
            None,
            "integrity_error",
        ),
    )

    result = service.create_wish(
        "child-id",
        {"name": "New bicycle"},
    )

    assert result == (None, "create_failed")


def test_service_rolls_back_on_unexpected_exception(
    monkeypatch,
):
    service = wishlist_routes.wishlist_service
    rollback_calls = {"count": 0}

    monkeypatch.setattr(
        service.child_repository,
        "get_child_by_id_for_update",
        lambda child_id: FakeChild(),
    )
    monkeypatch.setattr(
        service.wishlist_repository,
        "get_pending_count_by_child_id",
        lambda child_id: (_ for _ in ()).throw(
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

    result = service.create_wish(
        "child-id",
        {"name": "New bicycle"},
    )

    assert result == (None, "create_failed")
    assert rollback_calls["count"] == 1


def test_service_returns_repository_wish_without_change(
    monkeypatch,
):
    service = wishlist_routes.wishlist_service
    repository_wish = object()

    monkeypatch.setattr(
        service.child_repository,
        "get_child_by_id_for_update",
        lambda child_id: FakeChild(),
    )
    monkeypatch.setattr(
        service.wishlist_repository,
        "get_pending_count_by_child_id",
        lambda child_id: 0,
    )
    monkeypatch.setattr(
        service.wishlist_repository,
        "create_wish",
        lambda wish: (
            repository_wish,
            None,
        ),
    )

    result, error = service.create_wish(
        "child-id",
        {"name": "New bicycle"},
    )

    assert error is None
    assert result is repository_wish


# ---------------------------------------------------------------------------
# Repository behavior
# ---------------------------------------------------------------------------

def test_repository_create_wish_adds_and_commits(
    monkeypatch,
):
    repository = wishlist_routes.wishlist_service.wishlist_repository
    wish = object()
    calls = {
        "added": None,
        "commit_count": 0,
    }

    monkeypatch.setattr(
        wishlist_repository_module.db.session,
        "add",
        lambda value: calls.__setitem__(
            "added",
            value,
        ),
    )
    monkeypatch.setattr(
        wishlist_repository_module.db.session,
        "commit",
        lambda: calls.__setitem__(
            "commit_count",
            calls["commit_count"] + 1,
        ),
    )

    result, error = repository.create_wish(wish)

    assert error is None
    assert result is wish
    assert calls["added"] is wish
    assert calls["commit_count"] == 1


def test_repository_create_wish_rolls_back_on_integrity_error(
    monkeypatch,
):
    repository = wishlist_routes.wishlist_service.wishlist_repository
    rollback_calls = {"count": 0}
    integrity_error = IntegrityError(
        "insert wishlist",
        {},
        Exception("UNIQUE constraint failed"),
    )

    monkeypatch.setattr(
        wishlist_repository_module.db.session,
        "add",
        lambda wish: None,
    )
    monkeypatch.setattr(
        wishlist_repository_module.db.session,
        "commit",
        lambda: (_ for _ in ()).throw(
            integrity_error
        ),
    )
    monkeypatch.setattr(
        wishlist_repository_module.db.session,
        "rollback",
        lambda: rollback_calls.__setitem__(
            "count",
            rollback_calls["count"] + 1,
        ),
    )

    result, error = repository.create_wish(object())

    assert result is None
    assert error == "integrity_error"
    assert rollback_calls["count"] == 1


def test_repository_pending_count_filters_by_child_and_pending(
    app,
    monkeypatch,
):
    repository = wishlist_routes.wishlist_service.wishlist_repository
    captured = {}

    class FakeQuery:
        def filter_by(self, **kwargs):
            captured["filters"] = kwargs
            return self

        def count(self):
            return 3

    with app.app_context():
        monkeypatch.setattr(
            wishlist_repository_module.Wishlist,
            "query",
            FakeQuery(),
        )

        result = repository.get_pending_count_by_child_id(
            "child-id"
        )

    assert result == 3
    assert captured["filters"] == {
        "child_id": "child-id",
        "status": "PENDING",
    }


def test_child_repository_uses_for_update_and_returns_first(
    app,
    monkeypatch,
):
    repository = wishlist_routes.wishlist_service.child_repository
    expected_child = object()

    captured = {
        "with_for_update_called": False,
        "first_called": False,
    }

    class FakeQuery:
        def filter_by(self, **kwargs):
            captured["filters"] = kwargs
            return self

        def with_for_update(self):
            captured["with_for_update_called"] = True
            return self

        def first(self):
            captured["first_called"] = True
            return expected_child

    with app.app_context():
        monkeypatch.setattr(
            child_repository_module.Child,
            "query",
            FakeQuery(),
        )

        result = repository.get_child_by_id_for_update(
            "child-id"
        )

    assert result is expected_child
    assert captured["filters"] == {
        "id": "child-id"
    }
    assert captured["with_for_update_called"] is True
    assert captured["first_called"] is True