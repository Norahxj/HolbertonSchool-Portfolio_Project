import pytest
from flask_jwt_extended import decode_token
from sqlalchemy.exc import IntegrityError

from app.routes import points_routes
import app.services.points_service as points_service_module
import app.repositories.point_repository as points_repository_module


REGISTER_URL = "/api/auth/register"
CHILDREN_URL = "/api/children/"
CHILD_LOGIN_URL = "/api/auth/child-login"
CHILD_POINTS_URL = "/api/points/child/{child_id}"


def auth_header(token):
    return {"Authorization": token}


def register_parent(
    client,
    email="child.points.parent@gmail.com",
    phone="0557900001",
    guardian_type="mother",
):
    response = client.post(
        REGISTER_URL,
        json={
            "first_name": "Manar",
            "last_name": "Zaid",
            "phone": phone,
            "email": email,
            "password": "Password123!",
            "guardian_type": guardian_type,
        },
    )
    assert response.status_code == 201, response.get_json()
    return response.get_json()


def create_child(
    client,
    parent_token,
    phone="0557900099",
):
    response = client.post(
        CHILDREN_URL,
        headers=auth_header(parent_token),
        json={
            "name": "Sara",
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


def get_child_points(client, token, child_id):
    return client.get(
        CHILD_POINTS_URL.format(child_id=child_id),
        headers=auth_header(token),
    )


# ===========================================================================
# Route tests
# ===========================================================================

def test_get_child_points_requires_access_token(client):
    response = client.get(
        CHILD_POINTS_URL.format(child_id="child-id")
    )

    assert response.status_code == 401


@pytest.mark.parametrize(
    "token",
    ["invalid-token", "abc.def", "abc.def.ghi"],
)
def test_get_child_points_rejects_invalid_token(
    client,
    token,
):
    response = client.get(
        CHILD_POINTS_URL.format(child_id="child-id"),
        headers=auth_header(token),
    )

    assert response.status_code in (401, 422)


def test_child_cannot_get_points_as_parent(client):
    parent = register_parent(client)
    child = create_child(
        client,
        parent["access_token"],
    )
    child_login = login_child(
        client,
        child["access_code"],
    )

    response = get_child_points(
        client,
        child_login["access_token"],
        child["id"],
    )

    assert response.status_code == 403
    assert response.get_json() == {
        "error": "Parent access required"
    }


def test_route_checks_child_belongs_to_parent(
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

    def fake_get_child_for_guardian(child_id, parent_id):
        captured["child_id"] = child_id
        captured["parent_id"] = parent_id
        return None

    monkeypatch.setattr(
        points_routes.child_repository,
        "get_child_for_guardian",
        fake_get_child_for_guardian,
    )

    response = get_child_points(
        client,
        parent["access_token"],
        "child-123",
    )

    assert response.status_code == 404
    assert response.get_json() == {
        "error": "Child not found"
    }
    assert captured == {
        "child_id": "child-123",
        "parent_id": expected_parent_id,
    }


def test_route_does_not_call_service_when_guardian_check_fails(
    client,
    monkeypatch,
):
    parent = register_parent(client)
    calls = {"count": 0}

    monkeypatch.setattr(
        points_routes.child_repository,
        "get_child_for_guardian",
        lambda child_id, parent_id: None,
    )

    def fake_get_child_points(child_id):
        calls["count"] += 1
        return None, "child_not_found"

    monkeypatch.setattr(
        points_routes.points_service,
        "get_child_points",
        fake_get_child_points,
    )

    response = get_child_points(
        client,
        parent["access_token"],
        "child-id",
    )

    assert response.status_code == 404
    assert calls["count"] == 0


def test_route_passes_child_id_to_service(
    client,
    monkeypatch,
):
    parent = register_parent(client)
    captured = {}

    monkeypatch.setattr(
        points_routes.child_repository,
        "get_child_for_guardian",
        lambda child_id, parent_id: object(),
    )

    def fake_get_child_points(child_id):
        captured["child_id"] = child_id
        return object(), None

    monkeypatch.setattr(
        points_routes.points_service,
        "get_child_points",
        fake_get_child_points,
    )
    monkeypatch.setattr(
        points_routes.points_response_schema,
        "dump",
        lambda points: {
            "child_id": "child-123",
            "total_points": 25,
        },
    )

    response = get_child_points(
        client,
        parent["access_token"],
        "child-123",
    )

    assert response.status_code == 200
    assert captured["child_id"] == "child-123"


def test_route_maps_service_child_not_found_to_404(
    client,
    monkeypatch,
):
    parent = register_parent(client)

    monkeypatch.setattr(
        points_routes.child_repository,
        "get_child_for_guardian",
        lambda child_id, parent_id: object(),
    )
    monkeypatch.setattr(
        points_routes.points_service,
        "get_child_points",
        lambda child_id: (
            None,
            "child_not_found",
        ),
    )

    response = get_child_points(
        client,
        parent["access_token"],
        "child-id",
    )

    assert response.status_code == 404
    assert response.get_json() == {
        "error": "Child not found"
    }


@pytest.mark.parametrize(
    "service_error",
    ["create_failed", "unexpected_error"],
)
def test_route_maps_other_service_errors_to_500(
    client,
    monkeypatch,
    service_error,
):
    parent = register_parent(client)

    monkeypatch.setattr(
        points_routes.child_repository,
        "get_child_for_guardian",
        lambda child_id, parent_id: object(),
    )
    monkeypatch.setattr(
        points_routes.points_service,
        "get_child_points",
        lambda child_id: (
            None,
            service_error,
        ),
    )

    response = get_child_points(
        client,
        parent["access_token"],
        "child-id",
    )

    assert response.status_code == 500
    assert response.get_json() == {
        "error": "Failed to retrieve child points"
    }


def test_route_does_not_serialize_when_service_fails(
    client,
    monkeypatch,
):
    parent = register_parent(client)
    dump_called = {"value": False}

    monkeypatch.setattr(
        points_routes.child_repository,
        "get_child_for_guardian",
        lambda child_id, parent_id: object(),
    )
    monkeypatch.setattr(
        points_routes.points_service,
        "get_child_points",
        lambda child_id: (
            None,
            "create_failed",
        ),
    )

    def fake_dump(points):
        dump_called["value"] = True
        return {}

    monkeypatch.setattr(
        points_routes.points_response_schema,
        "dump",
        fake_dump,
    )

    response = get_child_points(
        client,
        parent["access_token"],
        "child-id",
    )

    assert response.status_code == 500
    assert dump_called["value"] is False


def test_route_serializes_points_response(
    client,
    monkeypatch,
):
    parent = register_parent(client)
    points = object()
    serialized = {
        "child_id": "child-id",
        "total_points": 75,
    }
    captured = {}

    monkeypatch.setattr(
        points_routes.child_repository,
        "get_child_for_guardian",
        lambda child_id, parent_id: object(),
    )
    monkeypatch.setattr(
        points_routes.points_service,
        "get_child_points",
        lambda child_id: (
            points,
            None,
        ),
    )

    def fake_dump(value):
        captured["value"] = value
        return serialized

    monkeypatch.setattr(
        points_routes.points_response_schema,
        "dump",
        fake_dump,
    )

    response = get_child_points(
        client,
        parent["access_token"],
        "child-id",
    )

    assert response.status_code == 200
    assert response.get_json() == serialized
    assert captured["value"] is points


# ===========================================================================
# Service tests
# ===========================================================================

class FakeChild:
    def __init__(self, child_id="child-id"):
        self.id = child_id


class FakePoints:
    def __init__(
        self,
        child_id="child-id",
        total_points=0,
    ):
        self.child_id = child_id
        self.total_points = total_points


def test_service_queries_child_by_id(
    monkeypatch,
):
    service = points_routes.points_service
    captured = {}

    def fake_get_child(child_id):
        captured["child_id"] = child_id
        return None

    monkeypatch.setattr(
        service.child_repository,
        "get_child_by_id",
        fake_get_child,
    )

    result = service.get_child_points(
        "child-123"
    )

    assert result == (
        None,
        "child_not_found",
    )
    assert captured["child_id"] == "child-123"


def test_service_returns_child_not_found(
    monkeypatch,
):
    service = points_routes.points_service

    monkeypatch.setattr(
        service.child_repository,
        "get_child_by_id",
        lambda child_id: None,
    )

    result = service.get_child_points(
        "missing-child"
    )

    assert result == (
        None,
        "child_not_found",
    )


def test_service_does_not_query_points_when_child_missing(
    monkeypatch,
):
    service = points_routes.points_service
    calls = {"count": 0}

    monkeypatch.setattr(
        service.child_repository,
        "get_child_by_id",
        lambda child_id: None,
    )

    def fake_get_points(child_id):
        calls["count"] += 1
        return None

    monkeypatch.setattr(
        service.point_repository,
        "get_points_by_child_id",
        fake_get_points,
    )

    result = service.get_child_points(
        "missing-child"
    )

    assert result == (
        None,
        "child_not_found",
    )
    assert calls["count"] == 0


def test_service_returns_existing_points_record(
    monkeypatch,
):
    service = points_routes.points_service
    child = FakeChild()
    points = FakePoints(
        child_id=child.id,
        total_points=50,
    )

    monkeypatch.setattr(
        service.child_repository,
        "get_child_by_id",
        lambda child_id: child,
    )
    monkeypatch.setattr(
        service.point_repository,
        "get_points_by_child_id",
        lambda child_id: points,
    )

    returned_points, error = (
        service.get_child_points(child.id)
    )

    assert error is None
    assert returned_points is points


def test_service_does_not_create_record_when_points_exist(
    monkeypatch,
):
    service = points_routes.points_service
    child = FakeChild()
    points = FakePoints(
        child_id=child.id,
        total_points=10,
    )
    calls = {"count": 0}

    monkeypatch.setattr(
        service.child_repository,
        "get_child_by_id",
        lambda child_id: child,
    )
    monkeypatch.setattr(
        service.point_repository,
        "get_points_by_child_id",
        lambda child_id: points,
    )

    def fake_create(points_record, commit=True):
        calls["count"] += 1
        return points_record, None

    monkeypatch.setattr(
        service.point_repository,
        "create_points_record",
        fake_create,
    )

    returned_points, error = (
        service.get_child_points(child.id)
    )

    assert error is None
    assert returned_points is points
    assert calls["count"] == 0


def test_service_creates_zero_points_record_when_missing(
    monkeypatch,
):
    service = points_routes.points_service
    child = FakeChild("child-123")
    captured = {}

    monkeypatch.setattr(
        service.child_repository,
        "get_child_by_id",
        lambda child_id: child,
    )
    monkeypatch.setattr(
        service.point_repository,
        "get_points_by_child_id",
        lambda child_id: None,
    )

    def fake_create(points_record, commit=True):
        captured["record"] = points_record
        captured["commit"] = commit
        return points_record, None

    monkeypatch.setattr(
        service.point_repository,
        "create_points_record",
        fake_create,
    )

    points, error = service.get_child_points(
        child.id
    )

    assert error is None
    assert points is captured["record"]
    assert points.child_id == "child-123"
    assert points.total_points == 0
    assert captured["commit"] is True


def test_service_passes_commit_false_to_repository(
    monkeypatch,
):
    service = points_routes.points_service
    child = FakeChild("child-123")
    captured = {}

    monkeypatch.setattr(
        service.child_repository,
        "get_child_by_id",
        lambda child_id: child,
    )
    monkeypatch.setattr(
        service.point_repository,
        "get_points_by_child_id",
        lambda child_id: None,
    )

    def fake_create(points_record, commit=True):
        captured["commit"] = commit
        return points_record, None

    monkeypatch.setattr(
        service.point_repository,
        "create_points_record",
        fake_create,
    )

    points, error = service.get_child_points(
        child.id,
        commit=False,
    )

    assert error is None
    assert points is not None
    assert captured["commit"] is False


def test_service_returns_create_failed_when_repository_fails(
    monkeypatch,
):
    service = points_routes.points_service
    child = FakeChild()

    monkeypatch.setattr(
        service.child_repository,
        "get_child_by_id",
        lambda child_id: child,
    )
    monkeypatch.setattr(
        service.point_repository,
        "get_points_by_child_id",
        lambda child_id: None,
    )
    monkeypatch.setattr(
        service.point_repository,
        "create_points_record",
        lambda points_record, commit=True: (
            None,
            "integrity_error",
        ),
    )

    result = service.get_child_points(
        child.id
    )

    assert result == (
        None,
        "create_failed",
    )


# ===========================================================================
# Repository tests
# ===========================================================================

def test_repository_create_points_record_commits(
    app,
    monkeypatch,
):
    repository = (
        points_routes.points_service
        .point_repository
    )
    points_record = FakePoints()
    calls = {
        "add": 0,
        "commit": 0,
        "flush": 0,
        "rollback": 0,
    }

    with app.app_context():
        monkeypatch.setattr(
            points_repository_module.db.session,
            "add",
            lambda record: calls.__setitem__(
                "add",
                calls["add"] + 1,
            ),
        )
        monkeypatch.setattr(
            points_repository_module.db.session,
            "commit",
            lambda: calls.__setitem__(
                "commit",
                calls["commit"] + 1,
            ),
        )
        monkeypatch.setattr(
            points_repository_module.db.session,
            "flush",
            lambda: calls.__setitem__(
                "flush",
                calls["flush"] + 1,
            ),
        )
        monkeypatch.setattr(
            points_repository_module.db.session,
            "rollback",
            lambda: calls.__setitem__(
                "rollback",
                calls["rollback"] + 1,
            ),
        )

        result = repository.create_points_record(
            points_record,
            commit=True,
        )

    assert result == (
        points_record,
        None,
    )
    assert calls == {
        "add": 1,
        "commit": 1,
        "flush": 0,
        "rollback": 0,
    }


def test_repository_create_points_record_flushes_when_commit_false(
    app,
    monkeypatch,
):
    repository = (
        points_routes.points_service
        .point_repository
    )
    points_record = FakePoints()
    calls = {
        "add": 0,
        "commit": 0,
        "flush": 0,
        "rollback": 0,
    }

    with app.app_context():
        monkeypatch.setattr(
            points_repository_module.db.session,
            "add",
            lambda record: calls.__setitem__(
                "add",
                calls["add"] + 1,
            ),
        )
        monkeypatch.setattr(
            points_repository_module.db.session,
            "commit",
            lambda: calls.__setitem__(
                "commit",
                calls["commit"] + 1,
            ),
        )
        monkeypatch.setattr(
            points_repository_module.db.session,
            "flush",
            lambda: calls.__setitem__(
                "flush",
                calls["flush"] + 1,
            ),
        )
        monkeypatch.setattr(
            points_repository_module.db.session,
            "rollback",
            lambda: calls.__setitem__(
                "rollback",
                calls["rollback"] + 1,
            ),
        )

        result = repository.create_points_record(
            points_record,
            commit=False,
        )

    assert result == (
        points_record,
        None,
    )
    assert calls == {
        "add": 1,
        "commit": 0,
        "flush": 1,
        "rollback": 0,
    }


@pytest.mark.parametrize(
    "commit",
    [True, False],
)
def test_repository_rolls_back_on_integrity_error(
    app,
    monkeypatch,
    commit,
):
    repository = (
        points_routes.points_service
        .point_repository
    )
    points_record = FakePoints()
    calls = {
        "rollback": 0,
    }

    error = IntegrityError(
        "statement",
        {},
        Exception("duplicate child points"),
    )

    def raise_integrity_error():
        raise error

    with app.app_context():
        monkeypatch.setattr(
            points_repository_module.db.session,
            "add",
            lambda record: None,
        )
        monkeypatch.setattr(
            points_repository_module.db.session,
            "commit",
            raise_integrity_error,
        )
        monkeypatch.setattr(
            points_repository_module.db.session,
            "flush",
            raise_integrity_error,
        )
        monkeypatch.setattr(
            points_repository_module.db.session,
            "rollback",
            lambda: calls.__setitem__(
                "rollback",
                calls["rollback"] + 1,
            ),
        )

        result = repository.create_points_record(
            points_record,
            commit=commit,
        )

    assert result == (
        None,
        "integrity_error",
    )
    assert calls["rollback"] == 1