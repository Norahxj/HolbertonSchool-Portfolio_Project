import pytest
from flask_jwt_extended import decode_token
from sqlalchemy.exc import IntegrityError

from app.routes import family_routes
import app.services.family_service as family_service_module
import app.repositories.family_invitation_repository as invitation_repository_module


REGISTER_URL = "/api/auth/register"
CHILDREN_URL = "/api/children/"
CHILD_LOGIN_URL = "/api/auth/child-login"
REJECT_INVITATION_URL = (
    "/api/family/invitations/{invitation_id}/reject"
)


def auth_header(token):
    return {"Authorization": token}


def register_parent(
    client,
    email="reject.invite.parent@gmail.com",
    phone="0557200001",
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
    phone="0557200099",
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


def reject_request(client, token, invitation_id):
    return client.put(
        REJECT_INVITATION_URL.format(
            invitation_id=invitation_id
        ),
        headers=auth_header(token),
    )


# ===========================================================================
# Route tests
# ===========================================================================

def test_reject_invitation_requires_access_token(client):
    response = client.put(
        REJECT_INVITATION_URL.format(
            invitation_id="invitation-id"
        )
    )

    assert response.status_code == 401


@pytest.mark.parametrize(
    "token",
    ["invalid-token", "abc.def", "abc.def.ghi"],
)
def test_reject_invitation_rejects_invalid_token(
    client,
    token,
):
    response = client.put(
        REJECT_INVITATION_URL.format(
            invitation_id="invitation-id"
        ),
        headers=auth_header(token),
    )

    assert response.status_code in (401, 422)


def test_child_cannot_reject_family_invitation(client):
    parent = register_parent(client)
    child = create_child(
        client,
        parent["access_token"],
    )
    child_login = login_child(
        client,
        child["access_code"],
    )

    response = reject_request(
        client,
        child_login["access_token"],
        "invitation-id",
    )

    assert response.status_code == 403
    assert response.get_json() == {
        "error": "Parent access required"
    }


def test_route_passes_identity_and_invitation_id_to_service(
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
        id = "invitation-123"
        family_id = "family-123"
        invited_email = "reject.invite.parent@gmail.com"
        invited_by = "user-456"
        status = "REJECTED"
        created_at = None

    def fake_reject_invitation(user_id, invitation_id):
        captured["user_id"] = user_id
        captured["invitation_id"] = invitation_id
        return FakeInvitation(), None

    monkeypatch.setattr(
        family_routes.family_service,
        "reject_invitation",
        fake_reject_invitation,
    )
    monkeypatch.setattr(
        family_routes.family_invitation_response_schema,
        "dump",
        lambda invitation: {
            "id": invitation.id,
            "family_id": invitation.family_id,
            "invited_email": invitation.invited_email,
            "invited_by": invitation.invited_by,
            "status": invitation.status,
            "created_at": invitation.created_at,
        },
    )

    response = reject_request(
        client,
        parent["access_token"],
        "invitation-123",
    )

    assert response.status_code == 200
    assert response.get_json()["status"] == "REJECTED"
    assert captured == {
        "user_id": expected_user_id,
        "invitation_id": "invitation-123",
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
            "invitation_not_found",
            404,
            {"error": "Invitation not found"},
        ),
        (
            "invitation_not_pending",
            400,
            {"error": "Invitation is not pending"},
        ),
        (
            "update_failed",
            500,
            {"error": "Failed to reject invitation"},
        ),
        (
            "unexpected_error",
            500,
            {"error": "Failed to reject invitation"},
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
        "reject_invitation",
        lambda user_id, invitation_id: (
            None,
            service_error,
        ),
    )

    response = reject_request(
        client,
        parent["access_token"],
        "invitation-id",
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
        family_routes.family_service,
        "reject_invitation",
        lambda user_id, invitation_id: (
            None,
            "update_failed",
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

    response = reject_request(
        client,
        parent["access_token"],
        "invitation-id",
    )

    assert response.status_code == 500
    assert dump_called["value"] is False


def test_route_serializes_rejected_invitation(
    client,
    monkeypatch,
):
    parent = register_parent(client)
    invitation = object()
    serialized = {
        "id": "invitation-id",
        "family_id": "family-id",
        "invited_email": "reject.invite.parent@gmail.com",
        "invited_by": "inviter-id",
        "status": "REJECTED",
        "created_at": "2026-07-21T12:00:00",
    }
    captured = {}

    monkeypatch.setattr(
        family_routes.family_service,
        "reject_invitation",
        lambda user_id, invitation_id: (
            invitation,
            None,
        ),
    )

    def fake_dump(value):
        captured["value"] = value
        return serialized

    monkeypatch.setattr(
        family_routes.family_invitation_response_schema,
        "dump",
        fake_dump,
    )

    response = reject_request(
        client,
        parent["access_token"],
        "invitation-id",
    )

    assert response.status_code == 200
    assert response.get_json() == serialized
    assert captured["value"] is invitation


# ===========================================================================
# Service tests
# ===========================================================================

class FakeUser:
    def __init__(
        self,
        user_id="user-id",
        email="reject.invite.parent@gmail.com",
    ):
        self.id = user_id
        self.email = email


class FakeInvitation:
    def __init__(
        self,
        invitation_id="invitation-id",
        invited_email="reject.invite.parent@gmail.com",
        status="PENDING",
    ):
        self.id = invitation_id
        self.invited_email = invited_email
        self.status = status


def prepare_valid_rejection(
    monkeypatch,
    *,
    user=None,
    invitation=None,
    update_result=(True, None),
):
    service = family_routes.family_service
    user = user or FakeUser()
    invitation = invitation or FakeInvitation()

    monkeypatch.setattr(
        service.user_repository,
        "get_user_by_id",
        lambda user_id: user,
    )
    monkeypatch.setattr(
        service.family_invitation_repository,
        "get_invitation_by_id",
        lambda invitation_id: invitation,
    )
    monkeypatch.setattr(
        service.family_invitation_repository,
        "update_invitation",
        lambda: update_result,
    )

    return service, user, invitation


def test_service_fetches_user_and_invitation(
    monkeypatch,
):
    service = family_routes.family_service
    captured = {}

    def fake_get_user(user_id):
        captured["user_id"] = user_id
        return None

    def fake_get_invitation(invitation_id):
        captured["invitation_id"] = invitation_id
        return None

    monkeypatch.setattr(
        service.user_repository,
        "get_user_by_id",
        fake_get_user,
    )
    monkeypatch.setattr(
        service.family_invitation_repository,
        "get_invitation_by_id",
        fake_get_invitation,
    )

    result = service.reject_invitation(
        "user-123",
        "invitation-456",
    )

    assert result == (None, "user_not_found")
    assert captured == {
        "user_id": "user-123",
        "invitation_id": "invitation-456",
    }


def test_service_returns_user_not_found(
    monkeypatch,
):
    service = family_routes.family_service

    monkeypatch.setattr(
        service.user_repository,
        "get_user_by_id",
        lambda user_id: None,
    )
    monkeypatch.setattr(
        service.family_invitation_repository,
        "get_invitation_by_id",
        lambda invitation_id: FakeInvitation(),
    )

    result = service.reject_invitation(
        "missing-user",
        "invitation-id",
    )

    assert result == (None, "user_not_found")


def test_service_returns_invitation_not_found_when_missing(
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
        "get_invitation_by_id",
        lambda invitation_id: None,
    )

    result = service.reject_invitation(
        user.id,
        "missing-invitation",
    )

    assert result == (
        None,
        "invitation_not_found",
    )


def test_service_rejects_invitation_for_different_email(
    monkeypatch,
):
    user = FakeUser(
        email="correct.parent@gmail.com"
    )
    invitation = FakeInvitation(
        invited_email="other.parent@gmail.com"
    )

    service, _, _ = prepare_valid_rejection(
        monkeypatch,
        user=user,
        invitation=invitation,
    )

    result = service.reject_invitation(
        user.id,
        invitation.id,
    )

    assert result == (
        None,
        "invitation_not_found",
    )


@pytest.mark.parametrize(
    "status",
    ["ACCEPTED", "REJECTED", "CANCELLED"],
)
def test_service_rejects_non_pending_invitation(
    monkeypatch,
    status,
):
    invitation = FakeInvitation(status=status)

    service, user, _ = prepare_valid_rejection(
        monkeypatch,
        invitation=invitation,
    )

    result = service.reject_invitation(
        user.id,
        invitation.id,
    )

    assert result == (
        None,
        "invitation_not_pending",
    )


def test_service_sets_status_to_rejected(
    monkeypatch,
):
    service, user, invitation = (
        prepare_valid_rejection(monkeypatch)
    )

    result, error = service.reject_invitation(
        user.id,
        invitation.id,
    )

    assert error is None
    assert result is invitation
    assert invitation.status == "REJECTED"


def test_service_calls_repository_update_invitation(
    monkeypatch,
):
    service = family_routes.family_service
    user = FakeUser()
    invitation = FakeInvitation()
    calls = {"count": 0}

    monkeypatch.setattr(
        service.user_repository,
        "get_user_by_id",
        lambda user_id: user,
    )
    monkeypatch.setattr(
        service.family_invitation_repository,
        "get_invitation_by_id",
        lambda invitation_id: invitation,
    )

    def fake_update():
        calls["count"] += 1
        return True, None

    monkeypatch.setattr(
        service.family_invitation_repository,
        "update_invitation",
        fake_update,
    )

    result, error = service.reject_invitation(
        user.id,
        invitation.id,
    )

    assert error is None
    assert result is invitation
    assert calls["count"] == 1


def test_service_returns_update_failed_when_repository_fails(
    monkeypatch,
):
    service, user, invitation = (
        prepare_valid_rejection(
            monkeypatch,
            update_result=(False, "integrity_error"),
        )
    )

    result = service.reject_invitation(
        user.id,
        invitation.id,
    )

    assert result == (None, "update_failed")
    assert invitation.status == "REJECTED"


def test_service_does_not_update_when_user_missing(
    monkeypatch,
):
    service = family_routes.family_service
    calls = {"count": 0}

    monkeypatch.setattr(
        service.user_repository,
        "get_user_by_id",
        lambda user_id: None,
    )
    monkeypatch.setattr(
        service.family_invitation_repository,
        "get_invitation_by_id",
        lambda invitation_id: FakeInvitation(),
    )

    def fake_update():
        calls["count"] += 1
        return True, None

    monkeypatch.setattr(
        service.family_invitation_repository,
        "update_invitation",
        fake_update,
    )

    result = service.reject_invitation(
        "missing-user",
        "invitation-id",
    )

    assert result == (None, "user_not_found")
    assert calls["count"] == 0


def test_service_does_not_update_when_invitation_missing(
    monkeypatch,
):
    service = family_routes.family_service
    user = FakeUser()
    calls = {"count": 0}

    monkeypatch.setattr(
        service.user_repository,
        "get_user_by_id",
        lambda user_id: user,
    )
    monkeypatch.setattr(
        service.family_invitation_repository,
        "get_invitation_by_id",
        lambda invitation_id: None,
    )

    def fake_update():
        calls["count"] += 1
        return True, None

    monkeypatch.setattr(
        service.family_invitation_repository,
        "update_invitation",
        fake_update,
    )

    result = service.reject_invitation(
        user.id,
        "missing-invitation",
    )

    assert result == (
        None,
        "invitation_not_found",
    )
    assert calls["count"] == 0


def test_service_does_not_update_non_pending_invitation(
    monkeypatch,
):
    service = family_routes.family_service
    user = FakeUser()
    invitation = FakeInvitation(status="ACCEPTED")
    calls = {"count": 0}

    monkeypatch.setattr(
        service.user_repository,
        "get_user_by_id",
        lambda user_id: user,
    )
    monkeypatch.setattr(
        service.family_invitation_repository,
        "get_invitation_by_id",
        lambda invitation_id: invitation,
    )

    def fake_update():
        calls["count"] += 1
        return True, None

    monkeypatch.setattr(
        service.family_invitation_repository,
        "update_invitation",
        fake_update,
    )

    result = service.reject_invitation(
        user.id,
        invitation.id,
    )

    assert result == (
        None,
        "invitation_not_pending",
    )
    assert calls["count"] == 0


# ===========================================================================
# Repository tests
# ===========================================================================

def test_repository_update_invitation_commits(
    app,
    monkeypatch,
):
    repository = (
        family_routes.family_service
        .family_invitation_repository
    )
    calls = {
        "commit": 0,
        "rollback": 0,
    }

    with app.app_context():
        monkeypatch.setattr(
            invitation_repository_module.db.session,
            "commit",
            lambda: calls.__setitem__(
                "commit",
                calls["commit"] + 1,
            ),
        )
        monkeypatch.setattr(
            invitation_repository_module.db.session,
            "rollback",
            lambda: calls.__setitem__(
                "rollback",
                calls["rollback"] + 1,
            ),
        )

        result = repository.update_invitation()

    assert result == (True, None)
    assert calls == {
        "commit": 1,
        "rollback": 0,
    }


def test_repository_update_invitation_rolls_back_on_integrity_error(
    app,
    monkeypatch,
):
    repository = (
        family_routes.family_service
        .family_invitation_repository
    )
    calls = {
        "commit": 0,
        "rollback": 0,
    }

    error = IntegrityError(
        "statement",
        {},
        Exception("database integrity error"),
    )

    def fake_commit():
        calls["commit"] += 1
        raise error

    with app.app_context():
        monkeypatch.setattr(
            invitation_repository_module.db.session,
            "commit",
            fake_commit,
        )
        monkeypatch.setattr(
            invitation_repository_module.db.session,
            "rollback",
            lambda: calls.__setitem__(
                "rollback",
                calls["rollback"] + 1,
            ),
        )

        result = repository.update_invitation()

    assert result == (
        False,
        "integrity_error",
    )
    assert calls == {
        "commit": 1,
        "rollback": 1,
    }