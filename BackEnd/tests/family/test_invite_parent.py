from pathlib import Path

import pytest
from flask_jwt_extended import decode_token
from sqlalchemy.exc import IntegrityError

from app.routes import family_routes
import app.services.family_service as family_service_module
import app.repositories.family_invitation_repository as family_invitation_repository_module


REGISTER_URL = "/api/auth/register"
CHILDREN_URL = "/api/children/"
CHILD_LOGIN_URL = "/api/auth/child-login"
INVITE_URL = "/api/family/invite"


def authorization_header(token):
    return {"Authorization": token}


def register_parent(
    client,
    email="family.inviter@gmail.com",
    phone="0556700001",
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
    phone="0556700099",
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


def invite_request(client, token, email):
    return client.post(
        INVITE_URL,
        headers=authorization_header(token),
        json={"email": email},
    )


# ===========================================================================
# Route tests
# ===========================================================================

def test_invite_parent_requires_access_token(client):
    response = client.post(
        INVITE_URL,
        json={"email": "invited.parent@gmail.com"},
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
def test_invite_parent_rejects_invalid_access_token(
    client,
    token,
):
    response = client.post(
        INVITE_URL,
        headers=authorization_header(token),
        json={"email": "invited.parent@gmail.com"},
    )

    assert response.status_code in (401, 422)


def test_child_cannot_invite_parent(client):
    parent = register_parent(client)
    child = create_child(
        client,
        parent["access_token"],
    )
    child_login = login_child(
        client,
        child["access_code"],
    )

    response = invite_request(
        client,
        child_login["access_token"],
        "invited.parent@gmail.com",
    )

    assert response.status_code == 403
    assert response.get_json() == {
        "error": "Parent access required"
    }


def test_invite_parent_requires_email_field(client):
    parent = register_parent(client)

    response = client.post(
        INVITE_URL,
        headers=authorization_header(
            parent["access_token"]
        ),
        json={},
    )

    assert response.status_code == 400


@pytest.mark.parametrize(
    "invalid_email",
    [
        "not-an-email",
        "missing-at-sign.com",
        "@gmail.com",
        "user@",
    ],
)
def test_invite_parent_rejects_invalid_email(
    client,
    invalid_email,
):
    parent = register_parent(client)

    response = invite_request(
        client,
        parent["access_token"],
        invalid_email,
    )

    assert response.status_code == 400


def test_route_passes_current_user_id_and_email_to_service(
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

    class FakeInvitation:
        id = "invitation-id"

    def fake_invite_parent(
        current_user_id,
        invited_email,
    ):
        captured["current_user_id"] = current_user_id
        captured["invited_email"] = invited_email
        return FakeInvitation(), None

    monkeypatch.setattr(
        family_routes.family_service,
        "invite_parent",
        fake_invite_parent,
    )
    monkeypatch.setattr(
        family_routes.family_invitation_response_schema,
        "dump",
        lambda invitation: {
            "id": invitation.id
        },
    )

    response = invite_request(
        client,
        parent["access_token"],
        "Invited.Parent@gmail.com",
    )

    assert response.status_code == 201
    assert response.get_json() == {
        "id": "invitation-id"
    }
    assert captured == {
        "current_user_id": expected_user_id,
        "invited_email": "Invited.Parent@gmail.com",
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
            {"error": "Current user not found"},
        ),
        (
            "family_not_found",
            400,
            {
                "error": (
                    "Current user is not assigned "
                    "to a family"
                )
            },
        ),
        (
            "invited_user_not_found",
            404,
            {
                "error": (
                    "Invited email does not belong "
                    "to an existing user"
                )
            },
        ),
        (
            "cannot_invite_self",
            400,
            {"error": "You cannot invite yourself"},
        ),
        (
            "invited_user_not_parent",
            400,
            {
                "error": (
                    "Invited user is not a parent"
                )
            },
        ),
        (
            "already_in_same_family",
            400,
            {
                "error": (
                    "User is already in your family"
                )
            },
        ),
        (
            "guardian_type_already_exists",
            400,
            {
                "error": (
                    "This family already has this "
                    "guardian type"
                )
            },
        ),
        (
            "invitation_already_pending",
            400,
            {
                "error": (
                    "An invitation is already pending "
                    "for this email"
                )
            },
        ),
        (
            "create_failed",
            500,
            {
                "error": (
                    "Failed to create invitation"
                )
            },
        ),
        (
            "unexpected_error",
            500,
            {
                "error": (
                    "Failed to create invitation"
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
        "invite_parent",
        lambda current_user_id, invited_email: (
            None,
            service_error,
        ),
    )

    response = invite_request(
        client,
        parent["access_token"],
        "invited.parent@gmail.com",
    )

    assert response.status_code == expected_status
    assert response.get_json() == expected_body


def test_route_does_not_serialize_invitation_on_error(
    client,
    monkeypatch,
):
    parent = register_parent(client)
    dump_called = {"value": False}

    monkeypatch.setattr(
        family_routes.family_service,
        "invite_parent",
        lambda current_user_id, invited_email: (
            None,
            "create_failed",
        ),
    )

    def fake_dump(invitation):
        dump_called["value"] = True
        return {}

    monkeypatch.setattr(
        family_routes.family_invitation_response_schema,
        "dump",
        fake_dump,
    )

    response = invite_request(
        client,
        parent["access_token"],
        "invited.parent@gmail.com",
    )

    assert response.status_code == 500
    assert dump_called["value"] is False


def test_route_serializes_created_invitation(
    client,
    monkeypatch,
):
    parent = register_parent(client)
    invitation = object()
    serialized = {
        "id": "invitation-id",
        "family_id": "family-id",
        "invited_email": "invited.parent@gmail.com",
        "invited_by": "parent-id",
        "status": "PENDING",
        "created_at": "2026-07-21T12:00:00",
    }
    captured = {}

    monkeypatch.setattr(
        family_routes.family_service,
        "invite_parent",
        lambda current_user_id, invited_email: (
            invitation,
            None,
        ),
    )

    def fake_dump(value):
        captured["invitation"] = value
        return serialized

    monkeypatch.setattr(
        family_routes.family_invitation_response_schema,
        "dump",
        fake_dump,
    )

    response = invite_request(
        client,
        parent["access_token"],
        "invited.parent@gmail.com",
    )

    assert response.status_code == 201
    assert response.get_json() == serialized
    assert captured["invitation"] is invitation


# ===========================================================================
# Service tests
# ===========================================================================

class FakeUser:
    def __init__(
        self,
        user_id="user-id",
        role="parent",
        family_id="family-id",
        guardian_type="mother",
        email="parent@gmail.com",
    ):
        self.id = user_id
        self.role = role
        self.family_id = family_id
        self.guardian_type = guardian_type
        self.email = email


def test_service_looks_up_current_user_by_id(
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

    result = service.invite_parent(
        "current-user-id",
        "invited.parent@gmail.com",
    )

    assert result == (None, "user_not_found")
    assert captured["user_id"] == "current-user-id"


def test_service_returns_user_not_found(
    monkeypatch,
):
    service = family_routes.family_service

    monkeypatch.setattr(
        service.user_repository,
        "get_user_by_id",
        lambda user_id: None,
    )

    result = service.invite_parent(
        "missing-user-id",
        "invited.parent@gmail.com",
    )

    assert result == (None, "user_not_found")


def test_service_normalizes_invited_email_before_lookup(
    monkeypatch,
):
    service = family_routes.family_service
    current_user = FakeUser(
        user_id="current-user-id",
        guardian_type="mother",
    )
    captured = {}

    monkeypatch.setattr(
        service.user_repository,
        "get_user_by_id",
        lambda user_id: current_user,
    )

    def fake_get_user_by_email(email):
        captured["email"] = email
        return None

    monkeypatch.setattr(
        service.user_repository,
        "get_user_by_email",
        fake_get_user_by_email,
    )

    result = service.invite_parent(
        "current-user-id",
        "  Invited.Parent@GMAIL.COM  ",
    )

    assert result == (
        None,
        "invited_user_not_found",
    )
    assert captured["email"] == (
        "invited.parent@gmail.com"
    )


def test_service_returns_invited_user_not_found(
    monkeypatch,
):
    service = family_routes.family_service
    current_user = FakeUser()

    monkeypatch.setattr(
        service.user_repository,
        "get_user_by_id",
        lambda user_id: current_user,
    )
    monkeypatch.setattr(
        service.user_repository,
        "get_user_by_email",
        lambda email: None,
    )

    result = service.invite_parent(
        "current-user-id",
        "invited.parent@gmail.com",
    )

    assert result == (
        None,
        "invited_user_not_found",
    )


def test_service_prevents_inviting_self(
    monkeypatch,
):
    service = family_routes.family_service
    current_user = FakeUser(
        user_id="same-user-id",
    )
    invited_user = FakeUser(
        user_id="same-user-id",
    )

    monkeypatch.setattr(
        service.user_repository,
        "get_user_by_id",
        lambda user_id: current_user,
    )
    monkeypatch.setattr(
        service.user_repository,
        "get_user_by_email",
        lambda email: invited_user,
    )

    result = service.invite_parent(
        "same-user-id",
        "same.parent@gmail.com",
    )

    assert result == (None, "cannot_invite_self")


def test_service_compares_user_ids_as_strings(
    monkeypatch,
):
    service = family_routes.family_service
    current_user = FakeUser(user_id=123)
    invited_user = FakeUser(user_id="123")

    monkeypatch.setattr(
        service.user_repository,
        "get_user_by_id",
        lambda user_id: current_user,
    )
    monkeypatch.setattr(
        service.user_repository,
        "get_user_by_email",
        lambda email: invited_user,
    )

    result = service.invite_parent(
        123,
        "same.parent@gmail.com",
    )

    assert result == (None, "cannot_invite_self")


def test_service_rejects_invited_non_parent_user(
    monkeypatch,
):
    service = family_routes.family_service
    current_user = FakeUser(
        user_id="current-user-id",
    )
    invited_user = FakeUser(
        user_id="invited-user-id",
        role="child",
    )

    monkeypatch.setattr(
        service.user_repository,
        "get_user_by_id",
        lambda user_id: current_user,
    )
    monkeypatch.setattr(
        service.user_repository,
        "get_user_by_email",
        lambda email: invited_user,
    )

    result = service.invite_parent(
        "current-user-id",
        "child.account@gmail.com",
    )

    assert result == (
        None,
        "invited_user_not_parent",
    )


def test_service_returns_family_not_found(
    monkeypatch,
):
    service = family_routes.family_service
    current_user = FakeUser(
        user_id="current-user-id",
        family_id=None,
    )
    invited_user = FakeUser(
        user_id="invited-user-id",
        family_id="other-family-id",
    )

    monkeypatch.setattr(
        service.user_repository,
        "get_user_by_id",
        lambda user_id: current_user,
    )
    monkeypatch.setattr(
        service.user_repository,
        "get_user_by_email",
        lambda email: invited_user,
    )

    result = service.invite_parent(
        "current-user-id",
        "invited.parent@gmail.com",
    )

    assert result == (None, "family_not_found")


def test_service_rejects_user_already_in_same_family(
    monkeypatch,
):
    service = family_routes.family_service
    current_user = FakeUser(
        user_id="current-user-id",
        family_id="same-family-id",
    )
    invited_user = FakeUser(
        user_id="invited-user-id",
        family_id="same-family-id",
    )

    monkeypatch.setattr(
        service.user_repository,
        "get_user_by_id",
        lambda user_id: current_user,
    )
    monkeypatch.setattr(
        service.user_repository,
        "get_user_by_email",
        lambda email: invited_user,
    )

    result = service.invite_parent(
        "current-user-id",
        "invited.parent@gmail.com",
    )

    assert result == (
        None,
        "already_in_same_family",
    )


def test_service_checks_existing_guardian_type(
    monkeypatch,
):
    service = family_routes.family_service
    current_user = FakeUser(
        user_id="current-user-id",
        family_id="family-id",
    )
    invited_user = FakeUser(
        user_id="invited-user-id",
        family_id="other-family-id",
        guardian_type="father",
    )
    captured = {}

    monkeypatch.setattr(
        service.user_repository,
        "get_user_by_id",
        lambda user_id: current_user,
    )
    monkeypatch.setattr(
        service.user_repository,
        "get_user_by_email",
        lambda email: invited_user,
    )

    def fake_get_guardian(
        family_id,
        guardian_type,
    ):
        captured["family_id"] = family_id
        captured["guardian_type"] = guardian_type
        return object()

    monkeypatch.setattr(
        service.family_invitation_repository,
        "get_guardian_by_family_and_type",
        fake_get_guardian,
    )

    result = service.invite_parent(
        "current-user-id",
        "invited.parent@gmail.com",
    )

    assert result == (
        None,
        "guardian_type_already_exists",
    )
    assert captured == {
        "family_id": "family-id",
        "guardian_type": "father",
    }


def test_service_checks_pending_invitation_using_normalized_email(
    monkeypatch,
):
    service = family_routes.family_service
    current_user = FakeUser(
        user_id="current-user-id",
        family_id="family-id",
    )
    invited_user = FakeUser(
        user_id="invited-user-id",
        family_id="other-family-id",
        guardian_type="father",
    )
    captured = {}

    monkeypatch.setattr(
        service.user_repository,
        "get_user_by_id",
        lambda user_id: current_user,
    )
    monkeypatch.setattr(
        service.user_repository,
        "get_user_by_email",
        lambda email: invited_user,
    )
    monkeypatch.setattr(
        service.family_invitation_repository,
        "get_guardian_by_family_and_type",
        lambda family_id, guardian_type: None,
    )

    def fake_get_pending(
        family_id,
        email,
    ):
        captured["family_id"] = family_id
        captured["email"] = email
        return object()

    monkeypatch.setattr(
        service.family_invitation_repository,
        "get_pending_invitation_by_family_and_email",
        fake_get_pending,
    )

    result = service.invite_parent(
        "current-user-id",
        "  Invited.Parent@GMAIL.COM ",
    )

    assert result == (
        None,
        "invitation_already_pending",
    )
    assert captured == {
        "family_id": "family-id",
        "email": "invited.parent@gmail.com",
    }


def test_service_creates_family_invitation_with_expected_values(
    monkeypatch,
):
    service = family_routes.family_service
    current_user = FakeUser(
        user_id="current-user-id",
        family_id="family-id",
    )
    invited_user = FakeUser(
        user_id="invited-user-id",
        family_id="other-family-id",
        guardian_type="father",
    )
    captured = {}

    monkeypatch.setattr(
        service.user_repository,
        "get_user_by_id",
        lambda user_id: current_user,
    )
    monkeypatch.setattr(
        service.user_repository,
        "get_user_by_email",
        lambda email: invited_user,
    )
    monkeypatch.setattr(
        service.family_invitation_repository,
        "get_guardian_by_family_and_type",
        lambda family_id, guardian_type: None,
    )
    monkeypatch.setattr(
        service.family_invitation_repository,
        "get_pending_invitation_by_family_and_email",
        lambda family_id, email: None,
    )

    class FakeFamilyInvitation:
        def __init__(
            self,
            family_id,
            invited_email,
            invited_by,
            status,
        ):
            self.family_id = family_id
            self.invited_email = invited_email
            self.invited_by = invited_by
            self.status = status

    monkeypatch.setattr(
        family_service_module,
        "FamilyInvitation",
        FakeFamilyInvitation,
    )

    def fake_create_invitation(invitation):
        captured["invitation"] = invitation
        return invitation, None

    monkeypatch.setattr(
        service.family_invitation_repository,
        "create_invitation",
        fake_create_invitation,
    )

    invitation, error = service.invite_parent(
        "current-user-id",
        "  Invited.Parent@GMAIL.COM ",
    )

    assert error is None
    assert invitation is captured["invitation"]
    assert invitation.family_id == "family-id"
    assert invitation.invited_email == (
        "invited.parent@gmail.com"
    )
    assert invitation.invited_by == "current-user-id"
    assert invitation.status == "PENDING"


def test_service_maps_repository_pending_error(
    monkeypatch,
):
    service = family_routes.family_service
    current_user = FakeUser(
        user_id="current-user-id",
        family_id="family-id",
    )
    invited_user = FakeUser(
        user_id="invited-user-id",
        family_id="other-family-id",
        guardian_type="father",
    )

    monkeypatch.setattr(
        service.user_repository,
        "get_user_by_id",
        lambda user_id: current_user,
    )
    monkeypatch.setattr(
        service.user_repository,
        "get_user_by_email",
        lambda email: invited_user,
    )
    monkeypatch.setattr(
        service.family_invitation_repository,
        "get_guardian_by_family_and_type",
        lambda family_id, guardian_type: None,
    )
    monkeypatch.setattr(
        service.family_invitation_repository,
        "get_pending_invitation_by_family_and_email",
        lambda family_id, email: None,
    )
    monkeypatch.setattr(
        service.family_invitation_repository,
        "create_invitation",
        lambda invitation: (
            None,
            "invitation_already_pending",
        ),
    )

    result = service.invite_parent(
        "current-user-id",
        "invited.parent@gmail.com",
    )

    assert result == (
        None,
        "invitation_already_pending",
    )


@pytest.mark.parametrize(
    "repository_error",
    [
        "integrity_error",
        "database_error",
        "unexpected_error",
    ],
)
def test_service_maps_other_repository_errors_to_create_failed(
    monkeypatch,
    repository_error,
):
    service = family_routes.family_service
    current_user = FakeUser(
        user_id="current-user-id",
        family_id="family-id",
    )
    invited_user = FakeUser(
        user_id="invited-user-id",
        family_id="other-family-id",
        guardian_type="father",
    )

    monkeypatch.setattr(
        service.user_repository,
        "get_user_by_id",
        lambda user_id: current_user,
    )
    monkeypatch.setattr(
        service.user_repository,
        "get_user_by_email",
        lambda email: invited_user,
    )
    monkeypatch.setattr(
        service.family_invitation_repository,
        "get_guardian_by_family_and_type",
        lambda family_id, guardian_type: None,
    )
    monkeypatch.setattr(
        service.family_invitation_repository,
        "get_pending_invitation_by_family_and_email",
        lambda family_id, email: None,
    )
    monkeypatch.setattr(
        service.family_invitation_repository,
        "create_invitation",
        lambda invitation: (
            None,
            repository_error,
        ),
    )

    result = service.invite_parent(
        "current-user-id",
        "invited.parent@gmail.com",
    )

    assert result == (None, "create_failed")


def test_service_returns_repository_invitation_on_success(
    monkeypatch,
):
    service = family_routes.family_service
    current_user = FakeUser(
        user_id="current-user-id",
        family_id="family-id",
    )
    invited_user = FakeUser(
        user_id="invited-user-id",
        family_id="other-family-id",
        guardian_type="father",
    )
    created_invitation = object()

    monkeypatch.setattr(
        service.user_repository,
        "get_user_by_id",
        lambda user_id: current_user,
    )
    monkeypatch.setattr(
        service.user_repository,
        "get_user_by_email",
        lambda email: invited_user,
    )
    monkeypatch.setattr(
        service.family_invitation_repository,
        "get_guardian_by_family_and_type",
        lambda family_id, guardian_type: None,
    )
    monkeypatch.setattr(
        service.family_invitation_repository,
        "get_pending_invitation_by_family_and_email",
        lambda family_id, email: None,
    )
    monkeypatch.setattr(
        service.family_invitation_repository,
        "create_invitation",
        lambda invitation: (
            created_invitation,
            None,
        ),
    )

    invitation, error = service.invite_parent(
        "current-user-id",
        "invited.parent@gmail.com",
    )

    assert error is None
    assert invitation is created_invitation


# ===========================================================================
# Repository tests
# ===========================================================================

def test_create_invitation_adds_and_commits(
    monkeypatch,
):
    repository = (
        family_routes.family_service
        .family_invitation_repository
    )
    invitation = object()
    captured = {
        "added": None,
        "commit_calls": 0,
    }

    monkeypatch.setattr(
        family_invitation_repository_module.db.session,
        "add",
        lambda value: captured.__setitem__(
            "added",
            value,
        ),
    )
    monkeypatch.setattr(
        family_invitation_repository_module.db.session,
        "commit",
        lambda: captured.__setitem__(
            "commit_calls",
            captured["commit_calls"] + 1,
        ),
    )

    result, error = repository.create_invitation(
        invitation
    )

    assert result is invitation
    assert error is None
    assert captured["added"] is invitation
    assert captured["commit_calls"] == 1


def test_create_invitation_rolls_back_pending_constraint_error(
    monkeypatch,
):
    repository = (
        family_routes.family_service
        .family_invitation_repository
    )
    rollback_calls = {"count": 0}

    class FakeDiag:
        constraint_name = (
            "uq_pending_family_invitation"
        )

    class FakeOriginalError(Exception):
        diag = FakeDiag()

    integrity_error = IntegrityError(
        "insert invitation",
        {},
        FakeOriginalError("duplicate invitation"),
    )

    monkeypatch.setattr(
        family_invitation_repository_module.db.session,
        "add",
        lambda invitation: None,
    )
    monkeypatch.setattr(
        family_invitation_repository_module.db.session,
        "commit",
        lambda: (_ for _ in ()).throw(
            integrity_error
        ),
    )
    monkeypatch.setattr(
        family_invitation_repository_module.db.session,
        "rollback",
        lambda: rollback_calls.__setitem__(
            "count",
            rollback_calls["count"] + 1,
        ),
    )

    result, error = repository.create_invitation(
        object()
    )

    assert result is None
    assert error == "invitation_already_pending"
    assert rollback_calls["count"] == 1


def test_create_invitation_returns_integrity_error_for_other_constraint(
    monkeypatch,
):
    repository = (
        family_routes.family_service
        .family_invitation_repository
    )
    rollback_calls = {"count": 0}

    class FakeDiag:
        constraint_name = "different_constraint"

    class FakeOriginalError(Exception):
        diag = FakeDiag()

    integrity_error = IntegrityError(
        "insert invitation",
        {},
        FakeOriginalError("other constraint"),
    )

    monkeypatch.setattr(
        family_invitation_repository_module.db.session,
        "add",
        lambda invitation: None,
    )
    monkeypatch.setattr(
        family_invitation_repository_module.db.session,
        "commit",
        lambda: (_ for _ in ()).throw(
            integrity_error
        ),
    )
    monkeypatch.setattr(
        family_invitation_repository_module.db.session,
        "rollback",
        lambda: rollback_calls.__setitem__(
            "count",
            rollback_calls["count"] + 1,
        ),
    )

    result, error = repository.create_invitation(
        object()
    )

    assert result is None
    assert error == "integrity_error"
    assert rollback_calls["count"] == 1


def test_create_invitation_returns_integrity_error_without_diag(
    monkeypatch,
):
    repository = (
        family_routes.family_service
        .family_invitation_repository
    )
    rollback_calls = {"count": 0}

    integrity_error = IntegrityError(
        "insert invitation",
        {},
        Exception("UNIQUE constraint failed"),
    )

    monkeypatch.setattr(
        family_invitation_repository_module.db.session,
        "add",
        lambda invitation: None,
    )
    monkeypatch.setattr(
        family_invitation_repository_module.db.session,
        "commit",
        lambda: (_ for _ in ()).throw(
            integrity_error
        ),
    )
    monkeypatch.setattr(
        family_invitation_repository_module.db.session,
        "rollback",
        lambda: rollback_calls.__setitem__(
            "count",
            rollback_calls["count"] + 1,
        ),
    )

    result, error = repository.create_invitation(
        object()
    )

    assert result is None
    assert error == "integrity_error"
    assert rollback_calls["count"] == 1


def test_get_pending_invitation_filters_and_returns_first(
    app,
    monkeypatch,
):
    repository = (
        family_routes.family_service
        .family_invitation_repository
    )
    expected_invitation = object()
    captured = {
        "first_called": False,
    }

    class FakeQuery:
        def filter_by(self, **kwargs):
            captured["filters"] = kwargs
            return self

        def first(self):
            captured["first_called"] = True
            return expected_invitation

    with app.app_context():
        monkeypatch.setattr(
            family_invitation_repository_module
            .FamilyInvitation,
            "query",
            FakeQuery(),
        )

        result = (
            repository
            .get_pending_invitation_by_family_and_email(
                "family-id",
                "invited.parent@gmail.com",
            )
        )

    assert result is expected_invitation
    assert captured["filters"] == {
        "family_id": "family-id",
        "invited_email": "invited.parent@gmail.com",
        "status": "PENDING",
    }
    assert captured["first_called"] is True
