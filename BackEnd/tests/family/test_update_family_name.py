import pytest
from flask_jwt_extended import decode_token

from app.routes import family_routes
import app.services.family_service as family_service_module


REGISTER_URL = "/api/auth/register"
CHILDREN_URL = "/api/children/"
CHILD_LOGIN_URL = "/api/auth/child-login"
MY_FAMILY_URL = "/api/family/me"


def authorization_header(token):
    return {"Authorization": token}


def register_parent(
    client,
    email="update.family.parent@gmail.com",
    phone="0556800001",
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
    phone="0556800099",
):
    response = client.post(
        CHILDREN_URL,
        headers=authorization_header(parent_token),
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


def update_family_request(
    client,
    token,
    payload,
):
    return client.put(
        MY_FAMILY_URL,
        headers=authorization_header(token),
        json=payload,
    )


# ===========================================================================
# Route tests
# ===========================================================================

def test_update_family_requires_access_token(client):
    response = client.put(
        MY_FAMILY_URL,
        json={"name": "Al Zaid Family"},
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
def test_update_family_rejects_invalid_token(
    client,
    token,
):
    response = client.put(
        MY_FAMILY_URL,
        headers=authorization_header(token),
        json={"name": "Al Zaid Family"},
    )

    assert response.status_code in (401, 422)


def test_child_cannot_update_family_name(client):
    parent = register_parent(client)
    child = create_child(
        client,
        parent["access_token"],
    )
    child_login = login_child(
        client,
        child["access_code"],
    )

    response = update_family_request(
        client,
        child_login["access_token"],
        {"name": "Al Zaid Family"},
    )

    assert response.status_code == 403
    assert response.get_json() == {
        "error": "Parent access required"
    }


def test_update_family_requires_name_field(client):
    parent = register_parent(client)

    response = update_family_request(
        client,
        parent["access_token"],
        {},
    )

    assert response.status_code == 400
    assert "errors" in response.get_json()
    assert "name" in response.get_json()["errors"]


def test_update_family_handles_null_payload(
    client,
):
    parent = register_parent(client)

    response = client.put(
        MY_FAMILY_URL,
        headers=authorization_header(
            parent["access_token"]
        ),
        data="null",
        content_type="application/json",
    )

    assert response.status_code == 400
    assert "errors" in response.get_json()


def test_route_passes_user_id_and_loaded_data_to_service(
    client,
    app,
    monkeypatch,
):
    parent = register_parent(client)

    with app.app_context():
        expected_user_id = decode_token(
            parent["access_token"]
        )["sub"]

    captured = {}

    class FakeFamily:
        id = "family-id"
        name = "Al Zaid Family"

    def fake_update_family_name(
        user_id,
        family_data,
    ):
        captured["user_id"] = user_id
        captured["family_data"] = family_data
        return FakeFamily(), None

    monkeypatch.setattr(
        family_routes.family_service,
        "update_family_name",
        fake_update_family_name,
    )
    monkeypatch.setattr(
        family_routes.family_response_schema,
        "dump",
        lambda family: {
            "id": family.id,
            "name": family.name,
        },
    )

    response = update_family_request(
        client,
        parent["access_token"],
        {"name": "Al Zaid Family"},
    )

    assert response.status_code == 200
    assert response.get_json() == {
        "id": "family-id",
        "name": "Al Zaid Family",
    }
    assert captured == {
        "user_id": expected_user_id,
        "family_data": {
            "name": "Al Zaid Family"
        },
    }


@pytest.mark.parametrize(
    (
        "service_error",
        "expected_status",
        "expected_body",
    ),
    [
        (
            "user_not_found",
            404,
            {"error": "User not found"},
        ),
        (
            "family_not_found",
            404,
            {"error": "Family not found"},
        ),
        (
            "update_failed",
            500,
            {
                "error": (
                    "Failed to update family"
                )
            },
        ),
        (
            "unexpected_error",
            500,
            {
                "error": (
                    "Failed to update family"
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
        family_routes.family_service,
        "update_family_name",
        lambda user_id, family_data: (
            None,
            service_error,
        ),
    )

    response = update_family_request(
        client,
        parent["access_token"],
        {"name": "Al Zaid Family"},
    )

    assert response.status_code == expected_status
    assert response.get_json() == expected_body


def test_route_does_not_serialize_family_on_error(
    client,
    monkeypatch,
):
    parent = register_parent(client)
    dump_called = {"value": False}

    monkeypatch.setattr(
        family_routes.family_service,
        "update_family_name",
        lambda user_id, family_data: (
            None,
            "update_failed",
        ),
    )

    def fake_dump(family):
        dump_called["value"] = True
        return {}

    monkeypatch.setattr(
        family_routes.family_response_schema,
        "dump",
        fake_dump,
    )

    response = update_family_request(
        client,
        parent["access_token"],
        {"name": "Al Zaid Family"},
    )

    assert response.status_code == 500
    assert dump_called["value"] is False


def test_route_serializes_updated_family(
    client,
    monkeypatch,
):
    parent = register_parent(client)
    family = object()
    serialized = {
        "id": "family-id",
        "name": "Al Zaid Family",
    }
    captured = {}

    monkeypatch.setattr(
        family_routes.family_service,
        "update_family_name",
        lambda user_id, family_data: (
            family,
            None,
        ),
    )

    def fake_dump(value):
        captured["family"] = value
        return serialized

    monkeypatch.setattr(
        family_routes.family_response_schema,
        "dump",
        fake_dump,
    )

    response = update_family_request(
        client,
        parent["access_token"],
        {"name": "Al Zaid Family"},
    )

    assert response.status_code == 200
    assert response.get_json() == serialized
    assert captured["family"] is family


# ===========================================================================
# Service tests
# ===========================================================================

class FakeUser:
    def __init__(
        self,
        user_id="user-id",
        family_id="family-id",
    ):
        self.id = user_id
        self.family_id = family_id


class FakeFamily:
    def __init__(
        self,
        family_id="family-id",
        name="Old Family Name",
    ):
        self.id = family_id
        self.name = name


def test_service_looks_up_user_by_id(
    monkeypatch,
):
    service = family_routes.family_service
    captured = {}

    def fake_get_user_by_id(user_id):
        captured["user_id"] = user_id
        return None

    monkeypatch.setattr(
        service.user_repository,
        "get_user_by_id",
        fake_get_user_by_id,
    )

    result = service.update_family_name(
        "user-id",
        {"name": "New Family Name"},
    )

    assert result == (None, "user_not_found")
    assert captured["user_id"] == "user-id"


def test_service_returns_user_not_found(
    monkeypatch,
):
    service = family_routes.family_service

    monkeypatch.setattr(
        service.user_repository,
        "get_user_by_id",
        lambda user_id: None,
    )

    result = service.update_family_name(
        "missing-user-id",
        {"name": "New Family Name"},
    )

    assert result == (None, "user_not_found")


def test_service_returns_family_not_found_when_user_has_no_family(
    monkeypatch,
):
    service = family_routes.family_service
    user = FakeUser(family_id=None)

    monkeypatch.setattr(
        service.user_repository,
        "get_user_by_id",
        lambda user_id: user,
    )

    result = service.update_family_name(
        "user-id",
        {"name": "New Family Name"},
    )

    assert result == (None, "family_not_found")


def test_service_gets_family_using_user_family_id(
    monkeypatch,
):
    service = family_routes.family_service
    user = FakeUser(family_id="family-123")
    captured = {}

    monkeypatch.setattr(
        service.user_repository,
        "get_user_by_id",
        lambda user_id: user,
    )

    def fake_session_get(model, family_id):
        captured["model"] = model
        captured["family_id"] = family_id
        return None

    monkeypatch.setattr(
        family_service_module.db.session,
        "get",
        fake_session_get,
    )

    result = service.update_family_name(
        "user-id",
        {"name": "New Family Name"},
    )

    assert result == (None, "family_not_found")
    assert captured["model"] is (
        family_service_module.Family
    )
    assert captured["family_id"] == "family-123"


def test_service_returns_family_not_found_when_database_family_missing(
    monkeypatch,
):
    service = family_routes.family_service
    user = FakeUser(family_id="family-id")

    monkeypatch.setattr(
        service.user_repository,
        "get_user_by_id",
        lambda user_id: user,
    )
    monkeypatch.setattr(
        family_service_module.db.session,
        "get",
        lambda model, family_id: None,
    )

    result = service.update_family_name(
        "user-id",
        {"name": "New Family Name"},
    )

    assert result == (None, "family_not_found")


@pytest.mark.parametrize(
    (
        "provided_name",
        "expected_name",
    ),
    [
        (
            "  Al Zaid Family  ",
            "Al Zaid Family",
        ),
        (
            "\tFamily Name\n",
            "Family Name",
        ),
        (
            "Simple Family",
            "Simple Family",
        ),
    ],
)
def test_service_strips_family_name(
    monkeypatch,
    provided_name,
    expected_name,
):
    service = family_routes.family_service
    user = FakeUser(family_id="family-id")
    family = FakeFamily()
    commit_calls = {"count": 0}

    monkeypatch.setattr(
        service.user_repository,
        "get_user_by_id",
        lambda user_id: user,
    )
    monkeypatch.setattr(
        family_service_module.db.session,
        "get",
        lambda model, family_id: family,
    )
    monkeypatch.setattr(
        family_service_module.db.session,
        "commit",
        lambda: commit_calls.__setitem__(
            "count",
            commit_calls["count"] + 1,
        ),
    )

    result, error = service.update_family_name(
        "user-id",
        {"name": provided_name},
    )

    assert error is None
    assert result is family
    assert family.name == expected_name
    assert commit_calls["count"] == 1


def test_service_commits_and_returns_family_on_success(
    monkeypatch,
):
    service = family_routes.family_service
    user = FakeUser(family_id="family-id")
    family = FakeFamily()
    commit_calls = {"count": 0}
    rollback_calls = {"count": 0}

    monkeypatch.setattr(
        service.user_repository,
        "get_user_by_id",
        lambda user_id: user,
    )
    monkeypatch.setattr(
        family_service_module.db.session,
        "get",
        lambda model, family_id: family,
    )
    monkeypatch.setattr(
        family_service_module.db.session,
        "commit",
        lambda: commit_calls.__setitem__(
            "count",
            commit_calls["count"] + 1,
        ),
    )
    monkeypatch.setattr(
        family_service_module.db.session,
        "rollback",
        lambda: rollback_calls.__setitem__(
            "count",
            rollback_calls["count"] + 1,
        ),
    )

    result, error = service.update_family_name(
        "user-id",
        {"name": "New Family Name"},
    )

    assert error is None
    assert result is family
    assert family.name == "New Family Name"
    assert commit_calls["count"] == 1
    assert rollback_calls["count"] == 0


def test_service_rolls_back_and_returns_update_failed_when_commit_fails(
    monkeypatch,
):
    service = family_routes.family_service
    user = FakeUser(family_id="family-id")
    family = FakeFamily()
    rollback_calls = {"count": 0}

    monkeypatch.setattr(
        service.user_repository,
        "get_user_by_id",
        lambda user_id: user,
    )
    monkeypatch.setattr(
        family_service_module.db.session,
        "get",
        lambda model, family_id: family,
    )
    monkeypatch.setattr(
        family_service_module.db.session,
        "commit",
        lambda: (_ for _ in ()).throw(
            RuntimeError("database failure")
        ),
    )
    monkeypatch.setattr(
        family_service_module.db.session,
        "rollback",
        lambda: rollback_calls.__setitem__(
            "count",
            rollback_calls["count"] + 1,
        ),
    )

    result = service.update_family_name(
        "user-id",
        {"name": "New Family Name"},
    )

    assert result == (None, "update_failed")
    assert rollback_calls["count"] == 1


def test_service_name_is_assigned_before_commit(
    monkeypatch,
):
    service = family_routes.family_service
    user = FakeUser(family_id="family-id")
    family = FakeFamily(name="Old Name")
    captured = {}

    monkeypatch.setattr(
        service.user_repository,
        "get_user_by_id",
        lambda user_id: user,
    )
    monkeypatch.setattr(
        family_service_module.db.session,
        "get",
        lambda model, family_id: family,
    )

    def fake_commit():
        captured["name_at_commit"] = family.name

    monkeypatch.setattr(
        family_service_module.db.session,
        "commit",
        fake_commit,
    )

    result, error = service.update_family_name(
        "user-id",
        {"name": "  New Name  "},
    )

    assert error is None
    assert result is family
    assert captured["name_at_commit"] == "New Name"