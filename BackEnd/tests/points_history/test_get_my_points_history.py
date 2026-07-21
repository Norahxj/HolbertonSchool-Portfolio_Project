import pytest
from flask_jwt_extended import decode_token

from app.routes import points_history_routes
import app.repositories.points_history_repository as points_history_repository_module


REGISTER_URL = "/api/auth/register"
CHILDREN_URL = "/api/children/"
CHILD_LOGIN_URL = "/api/auth/child-login"
MY_HISTORY_URL = "/api/points-history/my"


def auth_header(token):
    return {"Authorization": token}


def register_parent(
    client,
    email="points.history.parent@gmail.com",
    phone="0557920001",
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
    phone="0557920099",
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


def get_my_history(client, token):
    return client.get(
        MY_HISTORY_URL,
        headers=auth_header(token),
    )


# ===========================================================================
# Route tests
# ===========================================================================

def test_route_requires_access_token(client):
    response = client.get(MY_HISTORY_URL)

    assert response.status_code == 401


@pytest.mark.parametrize(
    "token",
    [
        "invalid-token",
        "abc.def",
        "abc.def.ghi",
    ],
)
def test_route_rejects_invalid_access_token(
    client,
    token,
):
    response = client.get(
        MY_HISTORY_URL,
        headers=auth_header(token),
    )

    assert response.status_code in (401, 422)


def test_parent_cannot_get_my_points_history(client):
    parent = register_parent(client)

    response = get_my_history(
        client,
        parent["access_token"],
    )

    assert response.status_code == 403
    assert response.get_json() == {
        "error": "Child access required"
    }


def test_route_passes_authenticated_child_id_to_service(
    client,
    app,
    monkeypatch,
):
    parent = register_parent(client)
    child = create_child(
        client,
        parent["access_token"],
    )
    child_data = login_child(
        client,
        child["access_code"],
    )

    with app.app_context():
        expected_child_id = decode_token(
            child_data["access_token"]
        )["sub"]

    captured = {}
    history = []

    def fake_get_history_for_child(child_id):
        captured["child_id"] = child_id
        return history, None

    monkeypatch.setattr(
        points_history_routes.points_history_service,
        "get_history_for_child",
        fake_get_history_for_child,
    )
    monkeypatch.setattr(
        points_history_routes.history_response_schema,
        "dump",
        lambda value: [],
    )

    response = get_my_history(
        client,
        child_data["access_token"],
    )

    assert response.status_code == 200
    assert captured["child_id"] == expected_child_id


def test_route_maps_child_not_found_to_404(
    client,
    monkeypatch,
):
    parent = register_parent(client)
    child = create_child(
        client,
        parent["access_token"],
    )
    child_data = login_child(
        client,
        child["access_code"],
    )

    monkeypatch.setattr(
        points_history_routes.points_history_service,
        "get_history_for_child",
        lambda child_id: (
            None,
            "child_not_found",
        ),
    )

    response = get_my_history(
        client,
        child_data["access_token"],
    )

    assert response.status_code == 404
    assert response.get_json() == {
        "error": "Child not found"
    }


@pytest.mark.parametrize(
    "service_error",
    [
        "repository_error",
        "unexpected_error",
    ],
)
def test_route_maps_other_errors_to_500(
    client,
    monkeypatch,
    service_error,
):
    parent = register_parent(client)
    child = create_child(
        client,
        parent["access_token"],
    )
    child_data = login_child(
        client,
        child["access_code"],
    )

    monkeypatch.setattr(
        points_history_routes.points_history_service,
        "get_history_for_child",
        lambda child_id: (
            None,
            service_error,
        ),
    )

    response = get_my_history(
        client,
        child_data["access_token"],
    )

    assert response.status_code == 500
    assert response.get_json() == {
        "error": "Failed to retrieve points history"
    }


def test_route_does_not_serialize_when_service_fails(
    client,
    monkeypatch,
):
    parent = register_parent(client)
    child = create_child(
        client,
        parent["access_token"],
    )
    child_data = login_child(
        client,
        child["access_code"],
    )
    dump_called = {"value": False}

    monkeypatch.setattr(
        points_history_routes.points_history_service,
        "get_history_for_child",
        lambda child_id: (
            None,
            "repository_error",
        ),
    )

    def fake_dump(history):
        dump_called["value"] = True
        return []

    monkeypatch.setattr(
        points_history_routes.history_response_schema,
        "dump",
        fake_dump,
    )

    response = get_my_history(
        client,
        child_data["access_token"],
    )

    assert response.status_code == 500
    assert dump_called["value"] is False


def test_route_serializes_history_response(
    client,
    monkeypatch,
):
    parent = register_parent(
        client,
        email="points.history.serialize@gmail.com",
        phone="0557920002",
    )
    child = create_child(
        client,
        parent["access_token"],
        phone="0557920098",
    )
    child_data = login_child(
        client,
        child["access_code"],
    )

    history = [object()]
    serialized_history = [
        {
            "id": "history-id",
            "child_id": child["id"],
            "points": 10,
            "action": "TASK_APPROVED",
            "task_assignment_id": "assignment-id",
            "wishlist_id": None,
            "task_assignment": None,
            "wishlist": None,
            "created_at": "2026-07-21T12:00:00",
        }
    ]
    captured = {}

    monkeypatch.setattr(
        points_history_routes.points_history_service,
        "get_history_for_child",
        lambda child_id: (
            history,
            None,
        ),
    )

    def fake_dump(value):
        captured["value"] = value
        return serialized_history

    monkeypatch.setattr(
        points_history_routes.history_response_schema,
        "dump",
        fake_dump,
    )

    response = get_my_history(
        client,
        child_data["access_token"],
    )

    assert response.status_code == 200
    assert response.get_json() == serialized_history
    assert captured["value"] is history


def test_route_returns_empty_list_when_history_is_empty(
    client,
    monkeypatch,
):
    parent = register_parent(
        client,
        email="points.history.empty@gmail.com",
        phone="0557920003",
    )
    child = create_child(
        client,
        parent["access_token"],
        phone="0557920097",
    )
    child_data = login_child(
        client,
        child["access_code"],
    )

    monkeypatch.setattr(
        points_history_routes.points_history_service,
        "get_history_for_child",
        lambda child_id: (
            [],
            None,
        ),
    )
    monkeypatch.setattr(
        points_history_routes.history_response_schema,
        "dump",
        lambda history: [],
    )

    response = get_my_history(
        client,
        child_data["access_token"],
    )

    assert response.status_code == 200
    assert response.get_json() == []


# ===========================================================================
# Service tests
# ===========================================================================

class FakeChild:
    def __init__(self, child_id="child-id"):
        self.id = child_id


def test_service_queries_child_by_id(monkeypatch):
    service = (
        points_history_routes
        .points_history_service
    )
    captured = {}

    def fake_get_child_by_id(child_id):
        captured["child_id"] = child_id
        return None

    monkeypatch.setattr(
        service.child_repository,
        "get_child_by_id",
        fake_get_child_by_id,
    )

    result = service.get_history_for_child(
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
    service = (
        points_history_routes
        .points_history_service
    )

    monkeypatch.setattr(
        service.child_repository,
        "get_child_by_id",
        lambda child_id: None,
    )

    result = service.get_history_for_child(
        "missing-child"
    )

    assert result == (
        None,
        "child_not_found",
    )


def test_service_does_not_query_history_when_child_missing(
    monkeypatch,
):
    service = (
        points_history_routes
        .points_history_service
    )
    calls = {"count": 0}

    monkeypatch.setattr(
        service.child_repository,
        "get_child_by_id",
        lambda child_id: None,
    )

    def fake_get_history(child_id):
        calls["count"] += 1
        return []

    monkeypatch.setattr(
        service.points_history_repository,
        "get_history_by_child_id",
        fake_get_history,
    )

    result = service.get_history_for_child(
        "missing-child"
    )

    assert result == (
        None,
        "child_not_found",
    )
    assert calls["count"] == 0


def test_service_passes_child_id_to_repository(
    monkeypatch,
):
    service = (
        points_history_routes
        .points_history_service
    )
    child = FakeChild("child-123")
    history = [object()]
    captured = {}

    monkeypatch.setattr(
        service.child_repository,
        "get_child_by_id",
        lambda child_id: child,
    )

    def fake_get_history(child_id):
        captured["child_id"] = child_id
        return history

    monkeypatch.setattr(
        service.points_history_repository,
        "get_history_by_child_id",
        fake_get_history,
    )

    returned_history, error = (
        service.get_history_for_child(
            "child-123"
        )
    )

    assert error is None
    assert returned_history is history
    assert captured["child_id"] == "child-123"


def test_service_returns_empty_history_list(
    monkeypatch,
):
    service = (
        points_history_routes
        .points_history_service
    )

    monkeypatch.setattr(
        service.child_repository,
        "get_child_by_id",
        lambda child_id: FakeChild(child_id),
    )
    monkeypatch.setattr(
        service.points_history_repository,
        "get_history_by_child_id",
        lambda child_id: [],
    )

    history, error = (
        service.get_history_for_child(
            "child-id"
        )
    )

    assert error is None
    assert history == []


# ===========================================================================
# Repository tests
# ===========================================================================

class FakeQuery:
    def __init__(self, results):
        self.results = results
        self.filtered_child_id = None
        self.order_argument = None
        self.filter_called = 0
        self.order_called = 0
        self.all_called = 0

    def filter_by(self, **kwargs):
        self.filter_called += 1
        self.filtered_child_id = kwargs.get(
            "child_id"
        )
        return self

    def order_by(self, argument):
        self.order_called += 1
        self.order_argument = argument
        return self

    def all(self):
        self.all_called += 1
        return self.results


class FakeCreatedAt:
    descending_expression = object()

    @classmethod
    def desc(cls):
        return cls.descending_expression


def test_repository_filters_orders_and_returns_all(
    app,
    monkeypatch,
):
    repository = (
        points_history_routes
        .points_history_service
        .points_history_repository
    )
    expected_history = [
        object(),
        object(),
    ]
    fake_query = FakeQuery(expected_history)

    with app.app_context():
        monkeypatch.setattr(
            points_history_repository_module
            .PointsHistory,
            "query",
            fake_query,
        )
        monkeypatch.setattr(
            points_history_repository_module
            .PointsHistory,
            "created_at",
            FakeCreatedAt,
        )

        result = (
            repository
            .get_history_by_child_id(
                "child-123"
            )
        )

    assert result is expected_history
    assert fake_query.filter_called == 1
    assert (
        fake_query.filtered_child_id
        == "child-123"
    )
    assert fake_query.order_called == 1
    assert (
        fake_query.order_argument
        is FakeCreatedAt.descending_expression
    )
    assert fake_query.all_called == 1