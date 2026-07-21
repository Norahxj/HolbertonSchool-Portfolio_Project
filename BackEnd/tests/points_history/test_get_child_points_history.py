import pytest
from flask_jwt_extended import decode_token

from app.routes import points_history_routes
import app.repositories.points_history_repository as repo_module


REGISTER = "/api/auth/register"
CHILDREN = "/api/children/"
LOGIN = "/api/auth/child-login"
URL = "/api/points-history/child/{child_id}"


def auth(token):
    return {"Authorization": token}


def register_parent(
    client,
    email="parent.history.child@gmail.com",
    phone="0557930001",
):
    response = client.post(
        REGISTER,
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
    token,
    phone="0557930099",
):
    response = client.post(
        CHILDREN,
        headers=auth(token),
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
        LOGIN,
        json={"access_code": access_code},
    )

    assert response.status_code == 200, response.get_json()
    return response.get_json()


def get_history(client, token, child_id):
    return client.get(
        URL.format(child_id=child_id),
        headers=auth(token),
    )


# ===========================================================================
# Route tests
# ===========================================================================

def test_requires_token(client):
    response = client.get(
        URL.format(child_id="child-id")
    )

    assert response.status_code == 401


def test_child_forbidden(client):
    parent = register_parent(client)
    child = create_child(
        client,
        parent["access_token"],
    )
    child_login = login_child(
        client,
        child["access_code"],
    )

    response = get_history(
        client,
        child_login["access_token"],
        child["id"],
    )

    assert response.status_code == 403
    assert response.get_json() == {
        "error": "Parent access required"
    }


def test_guardian_check_404_and_no_service(
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
    service_calls = {"count": 0}

    def fake_get_child_for_guardian(
        child_id,
        parent_id,
    ):
        captured["child_id"] = child_id
        captured["parent_id"] = parent_id
        return None

    def fake_get_history_for_child(child_id):
        service_calls["count"] += 1
        return [], None

    monkeypatch.setattr(
        points_history_routes.child_repository,
        "get_child_for_guardian",
        fake_get_child_for_guardian,
    )
    monkeypatch.setattr(
        points_history_routes.points_history_service,
        "get_history_for_child",
        fake_get_history_for_child,
    )

    response = get_history(
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
    assert service_calls["count"] == 0


def test_service_child_not_found(
    client,
    monkeypatch,
):
    parent = register_parent(
        client,
        email="points.history.child.missing@gmail.com",
        phone="0557930002",
    )

    monkeypatch.setattr(
        points_history_routes.child_repository,
        "get_child_for_guardian",
        lambda child_id, parent_id: object(),
    )
    monkeypatch.setattr(
        points_history_routes.points_history_service,
        "get_history_for_child",
        lambda child_id: (
            None,
            "child_not_found",
        ),
    )

    response = get_history(
        client,
        parent["access_token"],
        "child-123",
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
def test_service_other_errors(
    client,
    monkeypatch,
    service_error,
):
    parent = register_parent(
        client,
        email=(
            f"points.history.{service_error}"
            "@gmail.com"
        ),
        phone="0557930003",
    )

    monkeypatch.setattr(
        points_history_routes.child_repository,
        "get_child_for_guardian",
        lambda child_id, parent_id: object(),
    )
    monkeypatch.setattr(
        points_history_routes.points_history_service,
        "get_history_for_child",
        lambda child_id: (
            None,
            service_error,
        ),
    )

    response = get_history(
        client,
        parent["access_token"],
        "child-123",
    )

    assert response.status_code == 500
    assert response.get_json() == {
        "error": "Failed to retrieve points history"
    }


def test_success_serialization(
    client,
    monkeypatch,
):
    parent = register_parent(
        client,
        email="points.history.success@gmail.com",
        phone="0557930004",
    )

    history = [object()]
    serialized_history = [{"id": "history-1"}]
    captured = {}

    monkeypatch.setattr(
        points_history_routes.child_repository,
        "get_child_for_guardian",
        lambda child_id, parent_id: object(),
    )
    monkeypatch.setattr(
        points_history_routes.points_history_service,
        "get_history_for_child",
        lambda child_id: (
            history,
            None,
        ),
    )

    def fake_dump(value):
        captured["history"] = value
        return serialized_history

    monkeypatch.setattr(
        points_history_routes.history_response_schema,
        "dump",
        fake_dump,
    )

    response = get_history(
        client,
        parent["access_token"],
        "child-123",
    )

    assert response.status_code == 200
    assert response.get_json() == serialized_history
    assert captured["history"] is history


# ===========================================================================
# Service tests
# ===========================================================================

class FakeChild:
    pass


def test_service_missing_child(monkeypatch):
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
        "child-123"
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
    repository_calls = {"count": 0}

    monkeypatch.setattr(
        service.child_repository,
        "get_child_by_id",
        lambda child_id: None,
    )

    def fake_get_history_by_child_id(child_id):
        repository_calls["count"] += 1
        return []

    monkeypatch.setattr(
        service.points_history_repository,
        "get_history_by_child_id",
        fake_get_history_by_child_id,
    )

    result = service.get_history_for_child(
        "child-123"
    )

    assert result == (
        None,
        "child_not_found",
    )
    assert repository_calls["count"] == 0


def test_service_returns_history(monkeypatch):
    service = (
        points_history_routes
        .points_history_service
    )
    history = [object()]
    captured = {}

    monkeypatch.setattr(
        service.child_repository,
        "get_child_by_id",
        lambda child_id: FakeChild(),
    )

    def fake_get_history_by_child_id(child_id):
        captured["child_id"] = child_id
        return history

    monkeypatch.setattr(
        service.points_history_repository,
        "get_history_by_child_id",
        fake_get_history_by_child_id,
    )

    returned_history, error = (
        service.get_history_for_child(
            "child-123"
        )
    )

    assert error is None
    assert returned_history is history
    assert captured["child_id"] == "child-123"


def test_service_returns_empty_history(monkeypatch):
    service = (
        points_history_routes
        .points_history_service
    )

    monkeypatch.setattr(
        service.child_repository,
        "get_child_by_id",
        lambda child_id: FakeChild(),
    )
    monkeypatch.setattr(
        service.points_history_repository,
        "get_history_by_child_id",
        lambda child_id: [],
    )

    history, error = (
        service.get_history_for_child(
            "child-123"
        )
    )

    assert error is None
    assert history == []


# ===========================================================================
# Repository tests
# ===========================================================================

class FakeQuery:
    def __init__(self):
        self.child_id = None
        self.order_argument = None
        self.all_called = False

    def filter_by(self, **kwargs):
        self.child_id = kwargs["child_id"]
        return self

    def order_by(self, argument):
        self.order_argument = argument
        return self

    def all(self):
        self.all_called = True
        return ["history-1", "history-2"]


class FakeCreatedAt:
    descending_expression = object()

    @classmethod
    def desc(cls):
        return cls.descending_expression


def test_repository_query(
    app,
    monkeypatch,
):
    repository = (
        points_history_routes
        .points_history_service
        .points_history_repository
    )
    fake_query = FakeQuery()

    with app.app_context():
        monkeypatch.setattr(
            repo_module.PointsHistory,
            "query",
            fake_query,
        )
        monkeypatch.setattr(
            repo_module.PointsHistory,
            "created_at",
            FakeCreatedAt,
        )

        result = (
            repository
            .get_history_by_child_id(
                "child-123"
            )
        )

    assert fake_query.child_id == "child-123"
    assert (
        fake_query.order_argument
        is FakeCreatedAt.descending_expression
    )
    assert fake_query.all_called is True
    assert result == [
        "history-1",
        "history-2",
    ]