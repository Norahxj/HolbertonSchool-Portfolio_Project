import pytest
from flask_jwt_extended import decode_token

from app.routes import wishlist_routes
import app.services.wishlist_service as wishlist_service_module
import app.repositories.point_repository as points_repository_module


REGISTER_URL = "/api/auth/register"
CHILDREN_URL = "/api/children/"
CHILD_LOGIN_URL = "/api/auth/child-login"


def authorization_header(token):
    return {"Authorization": token}


def achieve_wish_url(wish_id):
    return f"/api/wishlists/{wish_id}/achieve"


def register_parent(
    client,
    email="achieve.wish.parent@gmail.com",
    phone="0556500001",
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
    phone="0556500099",
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


def achieve_wish_request(
    client,
    token,
    wish_id,
):
    return client.put(
        achieve_wish_url(wish_id),
        headers=authorization_header(token),
    )


# ---------------------------------------------------------------------------
# Authentication and authorization
# ---------------------------------------------------------------------------

def test_achieve_wish_requires_access_token(client):
    response = client.put(
        achieve_wish_url("wish-id")
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
def test_achieve_wish_rejects_invalid_token(
    client,
    token,
):
    response = client.put(
        achieve_wish_url("wish-id"),
        headers=authorization_header(token),
    )

    assert response.status_code in (401, 422)


def test_parent_cannot_achieve_wish(client):
    parent = register_parent(client)

    response = achieve_wish_request(
        client,
        parent["access_token"],
        "wish-id",
    )

    assert response.status_code == 403
    assert response.get_json() == {
        "error": "Child access required"
    }


# ---------------------------------------------------------------------------
# Route behavior
# ---------------------------------------------------------------------------

def test_route_passes_wish_id_and_child_id_to_service(
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

    def fake_achieve_wish(
        wish_id,
        child_id,
    ):
        captured["wish_id"] = wish_id
        captured["child_id"] = child_id
        return FakeWish(), None

    monkeypatch.setattr(
        wishlist_routes.wishlist_service,
        "achieve_wish",
        fake_achieve_wish,
    )
    monkeypatch.setattr(
        wishlist_routes.wishlist_response_schema,
        "dump",
        lambda wish: {"id": wish.id},
    )

    response = achieve_wish_request(
        client,
        child_login["access_token"],
        "wish-id",
    )

    assert response.status_code == 200
    assert response.get_json() == {
        "id": "wish-id"
    }
    assert captured == {
        "wish_id": "wish-id",
        "child_id": expected_child_id,
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
            "wish_already_achieved",
            400,
            {
                "error": (
                    "This wish has already been achieved"
                )
            },
        ),
        (
            "invalid_target_points",
            400,
            {
                "error": (
                    "Wish target points are invalid"
                )
            },
        ),
        (
            "wish_not_approved",
            400,
            {"error": "Wish is not approved"},
        ),
        (
            "not_enough_points",
            400,
            {
                "error": (
                    "Not enough points to achieve this wish"
                )
            },
        ),
        (
            "achieve_failed",
            500,
            {"error": "Failed to achieve wish"},
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
        "achieve_wish",
        lambda wish_id, child_id: (
            None,
            service_error,
        ),
    )

    response = achieve_wish_request(
        client,
        child_login["access_token"],
        "wish-id",
    )

    assert response.status_code == expected_status
    assert response.get_json() == expected_body


def test_route_does_not_serialize_on_error(
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
        "achieve_wish",
        lambda wish_id, child_id: (
            None,
            "achieve_failed",
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

    response = achieve_wish_request(
        client,
        child_login["access_token"],
        "wish-id",
    )

    assert response.status_code == 500
    assert dump_called["value"] is False


def test_route_serializes_achieved_wish(
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
        "name": "Bicycle",
        "target_points": 500,
        "status": "ACHIEVED",
    }
    captured = {}

    monkeypatch.setattr(
        wishlist_routes.wishlist_service,
        "achieve_wish",
        lambda wish_id, child_id: (
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

    response = achieve_wish_request(
        client,
        child_login["access_token"],
        "wish-id",
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
        status="APPROVED",
        target_points=100,
        child_id="child-id",
    ):
        self.id = "wish-id"
        self.child_id = child_id
        self.name = "Bicycle"
        self.target_points = target_points
        self.status = status


class FakePoints:
    def __init__(self, total_points=100):
        self.child_id = "child-id"
        self.total_points = total_points


def test_service_passes_wish_and_child_ids_to_locked_wish_lookup(
    monkeypatch,
):
    service = wishlist_routes.wishlist_service
    captured = {}

    def fake_get_wish_for_child_for_update(
        wish_id,
        child_id,
    ):
        captured["wish_id"] = wish_id
        captured["child_id"] = child_id
        return None

    monkeypatch.setattr(
        service.wishlist_repository,
        "get_wish_for_child_for_update",
        fake_get_wish_for_child_for_update,
    )
    monkeypatch.setattr(
        wishlist_service_module.db.session,
        "rollback",
        lambda: None,
    )

    result = service.achieve_wish(
        "wish-id",
        "child-id",
    )

    assert result == (None, "wish_not_found")
    assert captured == {
        "wish_id": "wish-id",
        "child_id": "child-id",
    }


def test_service_returns_wish_not_found_and_rolls_back(
    monkeypatch,
):
    service = wishlist_routes.wishlist_service
    rollback_calls = {"count": 0}

    monkeypatch.setattr(
        service.wishlist_repository,
        "get_wish_for_child_for_update",
        lambda wish_id, child_id: None,
    )
    monkeypatch.setattr(
        wishlist_service_module.db.session,
        "rollback",
        lambda: rollback_calls.__setitem__(
            "count",
            rollback_calls["count"] + 1,
        ),
    )

    result = service.achieve_wish(
        "missing-wish",
        "child-id",
    )

    assert result == (None, "wish_not_found")
    assert rollback_calls["count"] == 1


def test_service_returns_already_achieved_and_rolls_back(
    monkeypatch,
):
    service = wishlist_routes.wishlist_service
    wish = FakeWish(status="ACHIEVED")
    rollback_calls = {"count": 0}

    monkeypatch.setattr(
        service.wishlist_repository,
        "get_wish_for_child_for_update",
        lambda wish_id, child_id: wish,
    )
    monkeypatch.setattr(
        wishlist_service_module.db.session,
        "rollback",
        lambda: rollback_calls.__setitem__(
            "count",
            rollback_calls["count"] + 1,
        ),
    )

    result = service.achieve_wish(
        "wish-id",
        "child-id",
    )

    assert result == (
        None,
        "wish_already_achieved",
    )
    assert rollback_calls["count"] == 1


@pytest.mark.parametrize(
    "status",
    [
        "PENDING",
        "REJECTED",
    ],
)
def test_service_returns_wish_not_approved_for_other_statuses(
    monkeypatch,
    status,
):
    service = wishlist_routes.wishlist_service
    wish = FakeWish(status=status)
    rollback_calls = {"count": 0}

    monkeypatch.setattr(
        service.wishlist_repository,
        "get_wish_for_child_for_update",
        lambda wish_id, child_id: wish,
    )
    monkeypatch.setattr(
        wishlist_service_module.db.session,
        "rollback",
        lambda: rollback_calls.__setitem__(
            "count",
            rollback_calls["count"] + 1,
        ),
    )

    result = service.achieve_wish(
        "wish-id",
        "child-id",
    )

    assert result == (None, "wish_not_approved")
    assert rollback_calls["count"] == 1


@pytest.mark.parametrize(
    "target_points",
    [
        None,
        0,
        -1,
        -100,
    ],
)
def test_service_returns_invalid_target_points(
    monkeypatch,
    target_points,
):
    service = wishlist_routes.wishlist_service
    wish = FakeWish(
        status="APPROVED",
        target_points=target_points,
    )
    rollback_calls = {"count": 0}

    monkeypatch.setattr(
        service.wishlist_repository,
        "get_wish_for_child_for_update",
        lambda wish_id, child_id: wish,
    )
    monkeypatch.setattr(
        wishlist_service_module.db.session,
        "rollback",
        lambda: rollback_calls.__setitem__(
            "count",
            rollback_calls["count"] + 1,
        ),
    )

    result = service.achieve_wish(
        "wish-id",
        "child-id",
    )

    assert result == (
        None,
        "invalid_target_points",
    )
    assert rollback_calls["count"] == 1


def test_service_passes_child_id_to_locked_points_lookup(
    monkeypatch,
):
    service = wishlist_routes.wishlist_service
    wish = FakeWish(
        status="APPROVED",
        target_points=100,
    )
    captured = {}

    monkeypatch.setattr(
        service.wishlist_repository,
        "get_wish_for_child_for_update",
        lambda wish_id, child_id: wish,
    )

    def fake_get_points(child_id):
        captured["child_id"] = child_id
        return None

    monkeypatch.setattr(
        service.points_repository,
        "get_points_by_child_id_for_update",
        fake_get_points,
    )
    monkeypatch.setattr(
        wishlist_service_module.db.session,
        "rollback",
        lambda: None,
    )

    result = service.achieve_wish(
        "wish-id",
        "child-id",
    )

    assert result == (None, "not_enough_points")
    assert captured["child_id"] == "child-id"


def test_service_returns_not_enough_points_when_record_missing(
    monkeypatch,
):
    service = wishlist_routes.wishlist_service
    wish = FakeWish(target_points=100)
    rollback_calls = {"count": 0}

    monkeypatch.setattr(
        service.wishlist_repository,
        "get_wish_for_child_for_update",
        lambda wish_id, child_id: wish,
    )
    monkeypatch.setattr(
        service.points_repository,
        "get_points_by_child_id_for_update",
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

    result = service.achieve_wish(
        "wish-id",
        "child-id",
    )

    assert result == (None, "not_enough_points")
    assert rollback_calls["count"] == 1


def test_service_returns_not_enough_points_when_balance_is_lower(
    monkeypatch,
):
    service = wishlist_routes.wishlist_service
    wish = FakeWish(target_points=500)
    points = FakePoints(total_points=499)
    rollback_calls = {"count": 0}

    monkeypatch.setattr(
        service.wishlist_repository,
        "get_wish_for_child_for_update",
        lambda wish_id, child_id: wish,
    )
    monkeypatch.setattr(
        service.points_repository,
        "get_points_by_child_id_for_update",
        lambda child_id: points,
    )
    monkeypatch.setattr(
        wishlist_service_module.db.session,
        "rollback",
        lambda: rollback_calls.__setitem__(
            "count",
            rollback_calls["count"] + 1,
        ),
    )

    result = service.achieve_wish(
        "wish-id",
        "child-id",
    )

    assert result == (None, "not_enough_points")
    assert rollback_calls["count"] == 1


def test_service_allows_exact_points_balance(
    monkeypatch,
):
    service = wishlist_routes.wishlist_service
    wish = FakeWish(target_points=500)
    points = FakePoints(total_points=500)
    achieved_wish = FakeWish(
        status="ACHIEVED",
        target_points=500,
    )

    monkeypatch.setattr(
        service.wishlist_repository,
        "get_wish_for_child_for_update",
        lambda wish_id, child_id: wish,
    )
    monkeypatch.setattr(
        service.points_repository,
        "get_points_by_child_id_for_update",
        lambda child_id: points,
    )
    monkeypatch.setattr(
        service.wishlist_repository,
        "achieve_wish",
        lambda wish_arg, points_arg: (
            achieved_wish,
            None,
        ),
    )

    result, error = service.achieve_wish(
        "wish-id",
        "child-id",
    )

    assert error is None
    assert result is achieved_wish


def test_service_passes_wish_and_points_record_to_repository(
    monkeypatch,
):
    service = wishlist_routes.wishlist_service
    wish = FakeWish(target_points=250)
    points = FakePoints(total_points=1000)
    captured = {}

    monkeypatch.setattr(
        service.wishlist_repository,
        "get_wish_for_child_for_update",
        lambda wish_id, child_id: wish,
    )
    monkeypatch.setattr(
        service.points_repository,
        "get_points_by_child_id_for_update",
        lambda child_id: points,
    )

    def fake_achieve_wish(
        wish_arg,
        points_arg,
    ):
        captured["wish"] = wish_arg
        captured["points"] = points_arg
        return wish_arg, None

    monkeypatch.setattr(
        service.wishlist_repository,
        "achieve_wish",
        fake_achieve_wish,
    )

    result, error = service.achieve_wish(
        "wish-id",
        "child-id",
    )

    assert error is None
    assert result is wish
    assert captured["wish"] is wish
    assert captured["points"] is points


@pytest.mark.parametrize(
    "repository_error",
    [
        "integrity_error",
        "update_failed",
        "history_failed",
    ],
)
def test_service_returns_achieve_failed_when_repository_returns_error(
    monkeypatch,
    repository_error,
):
    service = wishlist_routes.wishlist_service
    wish = FakeWish(target_points=100)
    points = FakePoints(total_points=500)

    monkeypatch.setattr(
        service.wishlist_repository,
        "get_wish_for_child_for_update",
        lambda wish_id, child_id: wish,
    )
    monkeypatch.setattr(
        service.points_repository,
        "get_points_by_child_id_for_update",
        lambda child_id: points,
    )
    monkeypatch.setattr(
        service.wishlist_repository,
        "achieve_wish",
        lambda wish_arg, points_arg: (
            None,
            repository_error,
        ),
    )

    result = service.achieve_wish(
        "wish-id",
        "child-id",
    )

    assert result == (None, "achieve_failed")


def test_service_returns_same_wish_from_repository(
    monkeypatch,
):
    service = wishlist_routes.wishlist_service
    wish = FakeWish(target_points=100)
    points = FakePoints(total_points=500)
    repository_wish = FakeWish(
        status="ACHIEVED",
        target_points=100,
    )

    monkeypatch.setattr(
        service.wishlist_repository,
        "get_wish_for_child_for_update",
        lambda wish_id, child_id: wish,
    )
    monkeypatch.setattr(
        service.points_repository,
        "get_points_by_child_id_for_update",
        lambda child_id: points,
    )
    monkeypatch.setattr(
        service.wishlist_repository,
        "achieve_wish",
        lambda wish_arg, points_arg: (
            repository_wish,
            None,
        ),
    )

    result, error = service.achieve_wish(
        "wish-id",
        "child-id",
    )

    assert error is None
    assert result is repository_wish


def test_service_rolls_back_on_unexpected_exception(
    monkeypatch,
):
    service = wishlist_routes.wishlist_service
    rollback_calls = {"count": 0}

    monkeypatch.setattr(
        service.wishlist_repository,
        "get_wish_for_child_for_update",
        lambda wish_id, child_id: (
            _ for _ in ()
        ).throw(RuntimeError("database failure")),
    )
    monkeypatch.setattr(
        wishlist_service_module.db.session,
        "rollback",
        lambda: rollback_calls.__setitem__(
            "count",
            rollback_calls["count"] + 1,
        ),
    )

    result = service.achieve_wish(
        "wish-id",
        "child-id",
    )

    assert result == (None, "achieve_failed")
    assert rollback_calls["count"] == 1


# ---------------------------------------------------------------------------
# Points repository behavior
# ---------------------------------------------------------------------------

def test_points_repository_filters_locks_and_returns_first(
    app,
    monkeypatch,
):
    repository = wishlist_routes.wishlist_service.points_repository
    expected_points = object()
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
            return expected_points

    with app.app_context():
        monkeypatch.setattr(
            points_repository_module.ChildPoints,
            "query",
            FakeQuery(),
        )

        result = (
            repository
            .get_points_by_child_id_for_update(
                "child-id"
            )
        )

    assert result is expected_points
    assert captured["filters"] == {
        "child_id": "child-id"
    }
    assert captured["with_for_update_called"] is True
    assert captured["first_called"] is True