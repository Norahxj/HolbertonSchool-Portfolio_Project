from pathlib import Path
import pytest
from flask_jwt_extended import decode_token

from app.routes import family_routes
import app.repositories.family_invitation_repository as invitation_repository_module


REGISTER_URL = "/api/auth/register"
CHILDREN_URL = "/api/children/"
CHILD_LOGIN_URL = "/api/auth/child-login"
INVITATIONS_URL = "/api/family/invitations"


def auth_header(token):
    return {"Authorization": token}


def register_parent(
    client,
    email="family.invites.parent@gmail.com",
    phone="0556900001",
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


def create_child(client, parent_token):
    response = client.post(
        CHILDREN_URL,
        headers=auth_header(parent_token),
        json={
            "name": "Sara",
            "birth_date": "2015-05-10",
            "phone": "0556900099",
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


# ===========================================================================
# Route tests
# ===========================================================================

def test_get_invitations_requires_access_token(client):
    response = client.get(INVITATIONS_URL)

    assert response.status_code == 401


@pytest.mark.parametrize(
    "token",
    ["invalid-token", "abc.def", "abc.def.ghi"],
)
def test_get_invitations_rejects_invalid_token(client, token):
    response = client.get(
        INVITATIONS_URL,
        headers=auth_header(token),
    )

    assert response.status_code in (401, 422)


def test_child_cannot_get_family_invitations(client):
    parent = register_parent(client)
    child = create_child(client, parent["access_token"])
    child_login = login_child(client, child["access_code"])

    response = client.get(
        INVITATIONS_URL,
        headers=auth_header(child_login["access_token"]),
    )

    assert response.status_code == 403
    assert response.get_json() == {
        "error": "Parent access required"
    }


def test_route_passes_jwt_identity_to_service(
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

    def fake_get_my_invitations(user_id):
        captured["user_id"] = user_id
        return [], None

    monkeypatch.setattr(
        family_routes.family_service,
        "get_my_invitations",
        fake_get_my_invitations,
    )
    monkeypatch.setattr(
        family_routes.family_invitations_response_schema,
        "dump",
        lambda invitations: [],
    )

    response = client.get(
        INVITATIONS_URL,
        headers=auth_header(parent["access_token"]),
    )

    assert response.status_code == 200
    assert response.get_json() == []
    assert captured["user_id"] == expected_user_id


def test_route_returns_404_when_user_not_found(
    client,
    monkeypatch,
):
    parent = register_parent(client)

    monkeypatch.setattr(
        family_routes.family_service,
        "get_my_invitations",
        lambda user_id: (None, "user_not_found"),
    )

    response = client.get(
        INVITATIONS_URL,
        headers=auth_header(parent["access_token"]),
    )

    assert response.status_code == 404
    assert response.get_json() == {
        "error": "User not found"
    }


@pytest.mark.parametrize(
    "service_error",
    ["repository_failed", "unexpected_error"],
)
def test_route_returns_500_for_other_service_errors(
    client,
    monkeypatch,
    service_error,
):
    parent = register_parent(client)

    monkeypatch.setattr(
        family_routes.family_service,
        "get_my_invitations",
        lambda user_id: (None, service_error),
    )

    response = client.get(
        INVITATIONS_URL,
        headers=auth_header(parent["access_token"]),
    )

    assert response.status_code == 500
    assert response.get_json() == {
        "error": "Failed to retrieve invitations"
    }


def test_route_does_not_serialize_when_service_returns_error(
    client,
    monkeypatch,
):
    parent = register_parent(client)
    dump_called = {"value": False}

    monkeypatch.setattr(
        family_routes.family_service,
        "get_my_invitations",
        lambda user_id: (None, "unexpected_error"),
    )

    def fake_dump(invitations):
        dump_called["value"] = True
        return []

    monkeypatch.setattr(
        family_routes.family_invitations_response_schema,
        "dump",
        fake_dump,
    )

    response = client.get(
        INVITATIONS_URL,
        headers=auth_header(parent["access_token"]),
    )

    assert response.status_code == 500
    assert dump_called["value"] is False


def test_route_serializes_invitations_on_success(
    client,
    monkeypatch,
):
    parent = register_parent(client)
    invitations = [object(), object()]
    serialized = [
        {
            "id": "invite-1",
            "family_id": "family-1",
            "invited_email": "parent.one@gmail.com",
            "invited_by": "user-1",
            "status": "PENDING",
            "created_at": "2026-07-21T12:00:00",
        },
        {
            "id": "invite-2",
            "family_id": "family-2",
            "invited_email": "parent.two@gmail.com",
            "invited_by": "user-2",
            "status": "PENDING",
            "created_at": "2026-07-21T13:00:00",
        },
    ]
    captured = {}

    monkeypatch.setattr(
        family_routes.family_service,
        "get_my_invitations",
        lambda user_id: (invitations, None),
    )

    def fake_dump(value):
        captured["value"] = value
        return serialized

    monkeypatch.setattr(
        family_routes.family_invitations_response_schema,
        "dump",
        fake_dump,
    )

    response = client.get(
        INVITATIONS_URL,
        headers=auth_header(parent["access_token"]),
    )

    assert response.status_code == 200
    assert response.get_json() == serialized
    assert captured["value"] is invitations


def test_route_returns_empty_list_when_no_pending_invitations(
    client,
    monkeypatch,
):
    parent = register_parent(client)

    monkeypatch.setattr(
        family_routes.family_service,
        "get_my_invitations",
        lambda user_id: ([], None),
    )
    monkeypatch.setattr(
        family_routes.family_invitations_response_schema,
        "dump",
        lambda invitations: [],
    )

    response = client.get(
        INVITATIONS_URL,
        headers=auth_header(parent["access_token"]),
    )

    assert response.status_code == 200
    assert response.get_json() == []


# ===========================================================================
# Service tests
# ===========================================================================

class FakeUser:
    def __init__(
        self,
        user_id="user-id",
        email="family.parent@gmail.com",
    ):
        self.id = user_id
        self.email = email


def test_service_looks_up_user_by_id(monkeypatch):
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

    result = service.get_my_invitations("user-123")

    assert result == (None, "user_not_found")
    assert captured["user_id"] == "user-123"


def test_service_returns_user_not_found(monkeypatch):
    service = family_routes.family_service

    monkeypatch.setattr(
        service.user_repository,
        "get_user_by_id",
        lambda user_id: None,
    )

    result = service.get_my_invitations("missing-user")

    assert result == (None, "user_not_found")


def test_service_uses_user_email_to_get_pending_invitations(
    monkeypatch,
):
    service = family_routes.family_service
    user = FakeUser(email="invited.parent@gmail.com")
    invitations = [object()]
    captured = {}

    monkeypatch.setattr(
        service.user_repository,
        "get_user_by_id",
        lambda user_id: user,
    )

    def fake_get_pending(email):
        captured["email"] = email
        return invitations

    monkeypatch.setattr(
        service.family_invitation_repository,
        "get_pending_invitations_for_email",
        fake_get_pending,
    )

    result, error = service.get_my_invitations("user-id")

    assert error is None
    assert result is invitations
    assert captured["email"] == "invited.parent@gmail.com"


def test_service_returns_empty_list_when_repository_returns_empty(
    monkeypatch,
):
    service = family_routes.family_service
    user = FakeUser()

    monkeypatch.setattr(
        service.user_repository,
        "get_user_by_id",
        lambda user_id: user,
    )
    monkeypatch.setattr(
        service.family_invitation_repository,
        "get_pending_invitations_for_email",
        lambda email: [],
    )

    result = service.get_my_invitations("user-id")

    assert result == ([], None)


# ===========================================================================
# Repository tests
# ===========================================================================

def test_repository_filters_by_email_and_pending_status(
    app,
    monkeypatch,
):
    repository = (
        family_routes.family_service
        .family_invitation_repository
    )
    captured = {}
    expected = [object(), object()]

    class FakeQuery:
        def filter_by(self, **kwargs):
            captured["filters"] = kwargs
            return self

        def all(self):
            captured["all_called"] = True
            return expected

    with app.app_context():
        monkeypatch.setattr(
            invitation_repository_module.FamilyInvitation,
            "query",
            FakeQuery(),
        )

        result = (
            repository
            .get_pending_invitations_for_email(
                "invited.parent@gmail.com"
            )
        )

    assert result is expected
    assert captured["filters"] == {
        "invited_email": "invited.parent@gmail.com",
        "status": "PENDING",
    }
    assert captured["all_called"] is True


def test_repository_returns_empty_list_when_no_matches(
    app,
    monkeypatch,
):
    repository = (
        family_routes.family_service
        .family_invitation_repository
    )

    class FakeQuery:
        def filter_by(self, **kwargs):
            return self

        def all(self):
            return []

    with app.app_context():
        monkeypatch.setattr(
            invitation_repository_module.FamilyInvitation,
            "query",
            FakeQuery(),
        )

        result = (
            repository
            .get_pending_invitations_for_email(
                "nobody@gmail.com"
            )
        )

    assert result == []


