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


def authorization_header(token):
    return {"Authorization": token}


def approve_wish_url(wish_id):
    return f"/api/wishlists/{wish_id}/approve"


def register_parent(
    client,
    email="approve.wish.parent@gmail.com",
    phone="0556300001",
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
    phone="0556300099",
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


def approve_wish_request(
    client,
    token,
    wish_id,
    payload,
):
    return client.put(
        approve_wish_url(wish_id),
        headers=authorization_header(token),
        json=payload,
    )


# ---------------------------------------------------------------------------
# Authentication and authorization
# ---------------------------------------------------------------------------

def test_approve_wish_requires_access_token(client):
    response = client.put(
        approve_wish_url("wish-id"),
        json={"target_points": 100},
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
def test_approve_wish_rejects_invalid_token(
    client,
    token,
):
    response = client.put(
        approve_wish_url("wish-id"),
        headers=authorization_header(token),
        json={"target_points": 100},
    )

    assert response.status_code in (401, 422)


def test_child_cannot_approve_wish(client):
    parent = register_parent(client)
    child = create_child(
        client,
        parent["access_token"],
    )
    child_login = login_child(
        client,
        child["access_code"],
    )

    response = approve_wish_request(
        client,
        child_login["access_token"],
        "wish-id",
        {"target_points": 100},
    )

    assert response.status_code == 403
    assert response.get_json() == {
        "error": "Parent access required"
    }


# ---------------------------------------------------------------------------
# Validation
# ---------------------------------------------------------------------------

def test_approve_wish_requires_target_points(
    client,
):
    parent = register_parent(client)

    response = approve_wish_request(
        client,
        parent["access_token"],
        "wish-id",
        {},
    )

    assert response.status_code == 400
    assert "errors" in response.get_json()
    assert "target_points" in response.get_json()["errors"]


@pytest.mark.parametrize(
    "target_points",
    [
        0,
        -1,
        10001,
        20000,
    ],
)
def test_approve_wish_rejects_target_points_outside_schema_range(
    client,
    target_points,
):
    parent = register_parent(client)

    response = approve_wish_request(
        client,
        parent["access_token"],
        "wish-id",
        {"target_points": target_points},
    )

    assert response.status_code == 400
    assert "errors" in response.get_json()
    assert "target_points" in response.get_json()["errors"]


def test_approve_wish_rejects_non_integer_target_points(
    client,
):
    parent = register_parent(client)

    response = approve_wish_request(
        client,
        parent["access_token"],
        "wish-id",
        {"target_points": "one hundred"},
    )

    assert response.status_code == 400
    assert "errors" in response.get_json()
    assert "target_points" in response.get_json()["errors"]


# ---------------------------------------------------------------------------
# Route behavior
# ---------------------------------------------------------------------------

def test_route_passes_wish_parent_and_target_points_to_service(
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

    def fake_approve_wish(
        wish_id,
        parent_id,
        target_points,
    ):
        captured["wish_id"] = wish_id
        captured["parent_id"] = parent_id
        captured["target_points"] = target_points
        return FakeWish(), None

    monkeypatch.setattr(
        wishlist_routes.wishlist_service,
        "approve_wish",
        fake_approve_wish,
    )
    monkeypatch.setattr(
        wishlist_routes.wishlist_response_schema,
        "dump",
        lambda wish: {"id": wish.id},
    )

    response = approve_wish_request(
        client,
        parent["access_token"],
        "wish-id",
        {"target_points": 250},
    )

    assert response.status_code == 200
    assert response.get_json() == {
        "id": "wish-id"
    }
    assert captured == {
        "wish_id": "wish-id",
        "parent_id": expected_parent_id,
        "target_points": 250,
    }


@pytest.mark.parametrize(
    (
        "service_error",
        "expected_status",
        "expected_body",
    ),
    [
        (
            "invalid_target_points",
            400,
            {
                "error": (
                    "Target points must be between 1 and 10000"
                )
            },
        ),
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
            "approved_limit_reached",
            400,
            {
                "error": (
                    "Approved wishlist limit reached. "
                    "Maximum 3 approved wishes allowed."
                )
            },
        ),
        (
            "update_failed",
            500,
            {"error": "Failed to approve wish"},
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
        "approve_wish",
        lambda wish_id, parent_id, target_points: (
            None,
            service_error,
        ),
    )

    response = approve_wish_request(
        client,
        parent["access_token"],
        "wish-id",
        {"target_points": 100},
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
        "approve_wish",
        lambda wish_id, parent_id, target_points: (
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

    response = approve_wish_request(
        client,
        parent["access_token"],
        "wish-id",
        {"target_points": 100},
    )

    assert response.status_code == 500
    assert dump_called["value"] is False


def test_route_serializes_approved_wish(
    client,
    monkeypatch,
):
    parent = register_parent(client)
    wish = object()
    serialized = {
        "id": "wish-id",
        "name": "Bicycle",
        "target_points": 250,
        "status": "APPROVED",
    }
    captured = {}

    monkeypatch.setattr(
        wishlist_routes.wishlist_service,
        "approve_wish",
        lambda wish_id, parent_id, target_points: (
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

    response = approve_wish_request(
        client,
        parent["access_token"],
        "wish-id",
        {"target_points": 250},
    )

    assert response.status_code == 200
    assert response.get_json() == serialized
    assert captured["wish"] is wish


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
        self.approved_at = None


def test_service_rejects_target_points_below_one(
    monkeypatch,
):
    service = wishlist_routes.wishlist_service
    repository_called = {"value": False}

    def fake_get_wish_by_id(wish_id):
        repository_called["value"] = True
        return FakeWish()

    monkeypatch.setattr(
        service.wishlist_repository,
        "get_wish_by_id",
        fake_get_wish_by_id,
    )

    result = service.approve_wish(
        "wish-id",
        "parent-id",
        0,
    )

    assert result == (
        None,
        "invalid_target_points",
    )
    assert repository_called["value"] is False


def test_service_rejects_target_points_above_10000(
    monkeypatch,
):
    service = wishlist_routes.wishlist_service

    result = service.approve_wish(
        "wish-id",
        "parent-id",
        10001,
    )

    assert result == (
        None,
        "invalid_target_points",
    )


def test_service_returns_wish_not_found_and_rolls_back(
    monkeypatch,
):
    service = wishlist_routes.wishlist_service
    rollback_calls = {"count": 0}

    monkeypatch.setattr(
        service.wishlist_repository,
        "get_wish_by_id",
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

    result = service.approve_wish(
        "missing-wish",
        "parent-id",
        100,
    )

    assert result == (None, "wish_not_found")
    assert rollback_calls["count"] == 1


def test_service_passes_wish_child_and_parent_to_guardian_lookup(
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
    monkeypatch.setattr(
        wishlist_service_module.db.session,
        "rollback",
        lambda: None,
    )

    result = service.approve_wish(
        "wish-id",
        "parent-id",
        100,
    )

    assert result == (None, "child_not_found")
    assert captured == {
        "child_id": "child-id",
        "parent_id": "parent-id",
    }


def test_service_returns_child_not_found_when_guardian_has_no_access(
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
        lambda child_id, parent_id: None,
    )
    monkeypatch.setattr(
        wishlist_service_module.db.session,
        "rollback",
        lambda: rollback_calls.__setitem__(
            "count",
            rollback_calls["count"] + 1,
        ),
    )

    result = service.approve_wish(
        "wish-id",
        "parent-id",
        100,
    )

    assert result == (None, "child_not_found")
    assert rollback_calls["count"] == 1


def test_service_locks_child_before_locking_wish(
    monkeypatch,
):
    service = wishlist_routes.wishlist_service
    wish = FakeWish()
    call_order = []

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

    def fake_lock_child(child_id):
        call_order.append("child")
        return object()

    def fake_lock_wish(wish_id):
        call_order.append("wish")
        return wish

    monkeypatch.setattr(
        service.child_repository,
        "get_child_by_id_for_update",
        fake_lock_child,
    )
    monkeypatch.setattr(
        service.wishlist_repository,
        "get_wish_by_id_for_update",
        fake_lock_wish,
    )
    monkeypatch.setattr(
        service.wishlist_repository,
        "get_approved_count_by_child_id",
        lambda child_id: 3,
    )
    monkeypatch.setattr(
        wishlist_service_module.db.session,
        "rollback",
        lambda: None,
    )

    service.approve_wish(
        "wish-id",
        "parent-id",
        100,
    )

    assert call_order == ["child", "wish"]


def test_service_returns_child_not_found_when_locked_child_missing(
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

    result = service.approve_wish(
        "wish-id",
        "parent-id",
        100,
    )

    assert result == (None, "child_not_found")
    assert rollback_calls["count"] == 1


def test_service_returns_wish_not_found_when_locked_wish_missing(
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
        service.child_repository,
        "get_child_by_id_for_update",
        lambda child_id: object(),
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

    result = service.approve_wish(
        "wish-id",
        "parent-id",
        100,
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
        service.child_repository,
        "get_child_by_id_for_update",
        lambda child_id: object(),
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

    result = service.approve_wish(
        "wish-id",
        "parent-id",
        100,
    )

    assert result == (
        None,
        "wish_already_reviewed",
    )
    assert rollback_calls["count"] == 1


@pytest.mark.parametrize(
    "approved_count",
    [3, 4, 10],
)
def test_service_rejects_when_approved_limit_reached(
    monkeypatch,
    approved_count,
):
    service = wishlist_routes.wishlist_service
    wish = FakeWish()
    rollback_calls = {"count": 0}
    update_called = {"value": False}

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
        service.child_repository,
        "get_child_by_id_for_update",
        lambda child_id: object(),
    )
    monkeypatch.setattr(
        service.wishlist_repository,
        "get_wish_by_id_for_update",
        lambda wish_id: wish,
    )
    monkeypatch.setattr(
        service.wishlist_repository,
        "get_approved_count_by_child_id",
        lambda child_id: approved_count,
    )

    def fake_update_wish():
        update_called["value"] = True
        return True, None

    monkeypatch.setattr(
        service.wishlist_repository,
        "update_wish",
        fake_update_wish,
    )
    monkeypatch.setattr(
        wishlist_service_module.db.session,
        "rollback",
        lambda: rollback_calls.__setitem__(
            "count",
            rollback_calls["count"] + 1,
        ),
    )

    result = service.approve_wish(
        "wish-id",
        "parent-id",
        100,
    )

    assert result == (
        None,
        "approved_limit_reached",
    )
    assert rollback_calls["count"] == 1
    assert update_called["value"] is False


def test_service_approves_wish_and_sets_all_review_fields(
    monkeypatch,
):
    service = wishlist_routes.wishlist_service
    initial_wish = FakeWish()
    locked_wish = FakeWish()
    expected_time = object()

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
        service.child_repository,
        "get_child_by_id_for_update",
        lambda child_id: object(),
    )
    monkeypatch.setattr(
        service.wishlist_repository,
        "get_wish_by_id_for_update",
        lambda wish_id: locked_wish,
    )
    monkeypatch.setattr(
        service.wishlist_repository,
        "get_approved_count_by_child_id",
        lambda child_id: 2,
    )
    monkeypatch.setattr(
        wishlist_service_module,
        "utc_now",
        lambda: expected_time,
    )
    monkeypatch.setattr(
        service.wishlist_repository,
        "update_wish",
        lambda: (True, None),
    )

    result, error = service.approve_wish(
        "wish-id",
        "parent-id",
        500,
    )

    assert error is None
    assert result is locked_wish
    assert locked_wish.status == "APPROVED"
    assert locked_wish.target_points == 500
    assert locked_wish.reviewed_by == "parent-id"
    assert locked_wish.approved_at is expected_time


def test_service_passes_child_id_to_approved_count_repository(
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
    monkeypatch.setattr(
        service.child_repository,
        "get_child_by_id_for_update",
        lambda child_id: object(),
    )
    monkeypatch.setattr(
        service.wishlist_repository,
        "get_wish_by_id_for_update",
        lambda wish_id: wish,
    )

    def fake_get_approved_count(child_id):
        captured["child_id"] = child_id
        return 3

    monkeypatch.setattr(
        service.wishlist_repository,
        "get_approved_count_by_child_id",
        fake_get_approved_count,
    )
    monkeypatch.setattr(
        wishlist_service_module.db.session,
        "rollback",
        lambda: None,
    )

    service.approve_wish(
        "wish-id",
        "parent-id",
        100,
    )

    assert captured["child_id"] == "child-id"


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
        service.child_repository,
        "get_child_by_id_for_update",
        lambda child_id: object(),
    )
    monkeypatch.setattr(
        service.wishlist_repository,
        "get_wish_by_id_for_update",
        lambda wish_id: wish,
    )
    monkeypatch.setattr(
        service.wishlist_repository,
        "get_approved_count_by_child_id",
        lambda child_id: 0,
    )
    monkeypatch.setattr(
        wishlist_service_module,
        "utc_now",
        lambda: object(),
    )
    monkeypatch.setattr(
        service.wishlist_repository,
        "update_wish",
        lambda: (
            False,
            "integrity_error",
        ),
    )

    result = service.approve_wish(
        "wish-id",
        "parent-id",
        100,
    )

    assert result == (None, "update_failed")


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

    result = service.approve_wish(
        "wish-id",
        "parent-id",
        100,
    )

    assert result == (None, "update_failed")
    assert rollback_calls["count"] == 1


# ---------------------------------------------------------------------------
# Repository behavior
# ---------------------------------------------------------------------------

def test_repository_update_wish_commits_successfully(
    monkeypatch,
):
    repository = wishlist_routes.wishlist_service.wishlist_repository
    commit_calls = {"count": 0}

    monkeypatch.setattr(
        wishlist_repository_module.db.session,
        "commit",
        lambda: commit_calls.__setitem__(
            "count",
            commit_calls["count"] + 1,
        ),
    )

    success, error = repository.update_wish()

    assert success is True
    assert error is None
    assert commit_calls["count"] == 1


def test_repository_update_wish_rolls_back_on_integrity_error(
    monkeypatch,
):
    repository = wishlist_routes.wishlist_service.wishlist_repository
    rollback_calls = {"count": 0}
    integrity_error = IntegrityError(
        "update wishlist",
        {},
        Exception("CHECK constraint failed"),
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

    success, error = repository.update_wish()

    assert success is False
    assert error == "integrity_error"
    assert rollback_calls["count"] == 1


def test_repository_approved_count_filters_by_child_and_approved(
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
            return 2

    with app.app_context():
        monkeypatch.setattr(
            wishlist_repository_module.Wishlist,
            "query",
            FakeQuery(),
        )

        result = repository.get_approved_count_by_child_id(
            "child-id"
        )

    assert result == 2
    assert captured["filters"] == {
        "child_id": "child-id",
        "status": "APPROVED",
    }


def test_repository_get_wish_for_update_filters_locks_and_returns_first(
    app,
    monkeypatch,
):
    repository = wishlist_routes.wishlist_service.wishlist_repository
    expected_wish = object()
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
            return expected_wish

    with app.app_context():
        monkeypatch.setattr(
            wishlist_repository_module.Wishlist,
            "query",
            FakeQuery(),
        )

        result = repository.get_wish_by_id_for_update(
            "wish-id"
        )

    assert result is expected_wish
    assert captured["filters"] == {
        "id": "wish-id"
    }
    assert captured["with_for_update_called"] is True
    assert captured["first_called"] is True


def test_child_repository_get_child_for_update_filters_locks_and_returns_first(
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