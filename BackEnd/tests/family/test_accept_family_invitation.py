import pytest
from flask_jwt_extended import decode_token
from sqlalchemy.exc import IntegrityError

from app.routes import family_routes
import app.services.family_service as family_service_module


REGISTER_URL = "/api/auth/register"
CHILDREN_URL = "/api/children/"
CHILD_LOGIN_URL = "/api/auth/child-login"
ACCEPT_INVITATION_URL = (
    "/api/family/invitations/{invitation_id}/accept"
)


def auth_header(token):
    return {"Authorization": token}


def register_parent(
    client,
    email="accept.invite.parent@gmail.com",
    phone="0557100001",
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
    phone="0557100099",
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


def accept_request(client, token, invitation_id):
    return client.put(
        ACCEPT_INVITATION_URL.format(
            invitation_id=invitation_id
        ),
        headers=auth_header(token),
    )


# ===========================================================================
# Route tests
# ===========================================================================

def test_accept_invitation_requires_access_token(client):
    response = client.put(
        ACCEPT_INVITATION_URL.format(
            invitation_id="invitation-id"
        )
    )

    assert response.status_code == 401


@pytest.mark.parametrize(
    "token",
    ["invalid-token", "abc.def", "abc.def.ghi"],
)
def test_accept_invitation_rejects_invalid_token(
    client,
    token,
):
    response = client.put(
        ACCEPT_INVITATION_URL.format(
            invitation_id="invitation-id"
        ),
        headers=auth_header(token),
    )

    assert response.status_code in (401, 422)


def test_child_cannot_accept_family_invitation(client):
    parent = register_parent(client)
    child = create_child(
        client,
        parent["access_token"],
    )
    child_login = login_child(
        client,
        child["access_code"],
    )

    response = accept_request(
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
        invited_email = "accept.invite.parent@gmail.com"
        invited_by = "user-456"
        status = "ACCEPTED"
        created_at = None

    def fake_accept_invitation(user_id, invitation_id):
        captured["user_id"] = user_id
        captured["invitation_id"] = invitation_id
        return FakeInvitation(), None

    monkeypatch.setattr(
        family_routes.family_service,
        "accept_invitation",
        fake_accept_invitation,
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

    response = accept_request(
        client,
        parent["access_token"],
        "invitation-123",
    )

    assert response.status_code == 200
    assert response.get_json()["status"] == "ACCEPTED"
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
            "current_family_has_children",
            400,
            {
                "error": (
                    "User cannot leave a family "
                    "that has children"
                )
            },
        ),
        (
            "already_in_same_family",
            400,
            {
                "error": (
                    "User is already in this family"
                )
            },
        ),
        (
            "update_failed",
            500,
            {
                "error": (
                    "Failed to accept invitation"
                )
            },
        ),
        (
            "unexpected_error",
            500,
            {
                "error": (
                    "Failed to accept invitation"
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
        "accept_invitation",
        lambda user_id, invitation_id: (
            None,
            service_error,
        ),
    )

    response = accept_request(
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
        "accept_invitation",
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

    response = accept_request(
        client,
        parent["access_token"],
        "invitation-id",
    )

    assert response.status_code == 500
    assert dump_called["value"] is False


def test_route_serializes_accepted_invitation(
    client,
    monkeypatch,
):
    parent = register_parent(client)
    invitation = object()
    serialized = {
        "id": "invitation-id",
        "family_id": "family-id",
        "invited_email": "accept.invite.parent@gmail.com",
        "invited_by": "inviter-id",
        "status": "ACCEPTED",
        "created_at": "2026-07-21T12:00:00",
    }
    captured = {}

    monkeypatch.setattr(
        family_routes.family_service,
        "accept_invitation",
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

    response = accept_request(
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

class FakeFamily:
    def __init__(
        self,
        family_id="family-id",
        children=None,
    ):
        self.id = family_id
        self.children = (
            [] if children is None else children
        )


class FakeChild:
    def __init__(self, guardians=None):
        self.guardians = (
            [] if guardians is None else guardians
        )


class FakeUser:
    def __init__(
        self,
        user_id="user-id",
        email="accept.invite.parent@gmail.com",
        family_id=None,
        family=None,
        guardian_type="mother",
    ):
        self.id = user_id
        self.email = email
        self.family_id = family_id
        self.family = family
        self.guardian_type = guardian_type


class FakeInvitation:
    def __init__(
        self,
        invitation_id="invitation-id",
        family_id="target-family-id",
        invited_email="accept.invite.parent@gmail.com",
        status="PENDING",
        family=None,
    ):
        self.id = invitation_id
        self.family_id = family_id
        self.invited_email = invited_email
        self.status = status
        self.family = (
            family
            if family is not None
            else FakeFamily(family_id)
        )


def prepare_valid_acceptance(
    monkeypatch,
    *,
    user=None,
    invitation=None,
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
        "get_guardian_by_family_and_type",
        lambda family_id, guardian_type: None,
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

    result = service.accept_invitation(
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

    result = service.accept_invitation(
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

    result = service.accept_invitation(
        "user-id",
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
    service, _, _ = prepare_valid_acceptance(
        monkeypatch,
        user=user,
        invitation=invitation,
    )

    result = service.accept_invitation(
        user.id,
        invitation.id,
    )

    assert result == (
        None,
        "invitation_not_found",
    )


def test_service_rejects_user_already_in_same_family(
    monkeypatch,
):
    user = FakeUser(
        family_id="target-family-id"
    )
    invitation = FakeInvitation(
        family_id="target-family-id"
    )
    service, _, _ = prepare_valid_acceptance(
        monkeypatch,
        user=user,
        invitation=invitation,
    )

    result = service.accept_invitation(
        user.id,
        invitation.id,
    )

    assert result == (
        None,
        "already_in_same_family",
    )


def test_service_rejects_leaving_family_with_children(
    monkeypatch,
):
    current_child = FakeChild()
    current_family = FakeFamily(
        family_id="old-family-id",
        children=[current_child],
    )
    user = FakeUser(
        family_id="old-family-id",
        family=current_family,
    )
    invitation = FakeInvitation()
    service, _, _ = prepare_valid_acceptance(
        monkeypatch,
        user=user,
        invitation=invitation,
    )

    result = service.accept_invitation(
        user.id,
        invitation.id,
    )

    assert result == (
        None,
        "current_family_has_children",
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
    service, user, _ = prepare_valid_acceptance(
        monkeypatch,
        invitation=invitation,
    )

    result = service.accept_invitation(
        user.id,
        invitation.id,
    )

    assert result == (
        None,
        "invitation_not_pending",
    )


def test_service_checks_guardian_type_in_target_family(
    monkeypatch,
):
    service = family_routes.family_service
    user = FakeUser(guardian_type="father")
    invitation = FakeInvitation(
        family_id="target-family-123"
    )
    captured = {}

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

    result = service.accept_invitation(
        user.id,
        invitation.id,
    )

    assert result == (
        None,
        "guardian_type_already_exists",
    )
    assert captured == {
        "family_id": "target-family-123",
        "guardian_type": "father",
    }


def test_service_moves_user_to_invitation_family(
    monkeypatch,
):
    service, user, invitation = (
        prepare_valid_acceptance(monkeypatch)
    )

    monkeypatch.setattr(
        family_service_module.db.session,
        "flush",
        lambda: None,
    )
    monkeypatch.setattr(
        family_service_module.db.session,
        "commit",
        lambda: None,
    )

    result, error = service.accept_invitation(
        user.id,
        invitation.id,
    )

    assert error is None
    assert result is invitation
    assert user.family_id == invitation.family_id


def test_service_marks_invitation_as_accepted(
    monkeypatch,
):
    service, user, invitation = (
        prepare_valid_acceptance(monkeypatch)
    )

    monkeypatch.setattr(
        family_service_module.db.session,
        "flush",
        lambda: None,
    )
    monkeypatch.setattr(
        family_service_module.db.session,
        "commit",
        lambda: None,
    )

    result, error = service.accept_invitation(
        user.id,
        invitation.id,
    )

    assert error is None
    assert result is invitation
    assert invitation.status == "ACCEPTED"


def test_service_adds_user_to_each_target_child_guardians(
    monkeypatch,
):
    child_one = FakeChild()
    child_two = FakeChild()
    target_family = FakeFamily(
        family_id="target-family-id",
        children=[child_one, child_two],
    )
    invitation = FakeInvitation(
        family=target_family
    )
    service, user, _ = prepare_valid_acceptance(
        monkeypatch,
        invitation=invitation,
    )

    monkeypatch.setattr(
        family_service_module.db.session,
        "flush",
        lambda: None,
    )
    monkeypatch.setattr(
        family_service_module.db.session,
        "commit",
        lambda: None,
    )

    result, error = service.accept_invitation(
        user.id,
        invitation.id,
    )

    assert error is None
    assert result is invitation
    assert user in child_one.guardians
    assert user in child_two.guardians


def test_service_does_not_duplicate_existing_child_guardian(
    monkeypatch,
):
    user = FakeUser()
    child = FakeChild(guardians=[user])
    target_family = FakeFamily(
        family_id="target-family-id",
        children=[child],
    )
    invitation = FakeInvitation(
        family=target_family
    )
    service, _, _ = prepare_valid_acceptance(
        monkeypatch,
        user=user,
        invitation=invitation,
    )

    monkeypatch.setattr(
        family_service_module.db.session,
        "flush",
        lambda: None,
    )
    monkeypatch.setattr(
        family_service_module.db.session,
        "commit",
        lambda: None,
    )

    service.accept_invitation(
        user.id,
        invitation.id,
    )

    assert child.guardians.count(user) == 1


def test_service_flushes_before_old_family_cleanup(
    app,
    monkeypatch,
):
    user = FakeUser(
        family_id="old-family-id",
        family=FakeFamily(
            family_id="old-family-id",
            children=[],
        ),
    )

    service, _, invitation = prepare_valid_acceptance(
        monkeypatch,
        user=user,
    )

    calls = []

    class FakeUserQuery:
        def filter_by(self, **kwargs):
            return self

        def first(self):
            return object()

    class FakeChildQuery:
        def filter_by(self, **kwargs):
            return self

        def first(self):
            return object()

    with app.app_context():
        monkeypatch.setattr(
            family_service_module.db.session,
            "flush",
            lambda: calls.append("flush"),
        )

        monkeypatch.setattr(
            family_service_module.User,
            "query",
            FakeUserQuery(),
        )

        monkeypatch.setattr(
            family_service_module.Child,
            "query",
            FakeChildQuery(),
        )

        monkeypatch.setattr(
            family_service_module.db.session,
            "commit",
            lambda: calls.append("commit"),
        )

        result, error = service.accept_invitation(
            user.id,
            invitation.id,
        )

    assert error is None
    assert result is invitation
    assert calls == ["flush", "commit"]

def test_service_keeps_old_family_when_guardian_remains(
    app,
    monkeypatch,
):
    old_family_id = "old-family-id"

    user = FakeUser(
        family_id=old_family_id,
        family=FakeFamily(
            family_id=old_family_id,
            children=[],
        ),
    )

    service, _, invitation = prepare_valid_acceptance(
        monkeypatch,
        user=user,
    )

    deleted = []

    class FakeUserQuery:
        def filter_by(self, **kwargs):
            assert kwargs == {
                "family_id": old_family_id
            }
            return self

        def first(self):
            return object()

    class FakeChildQuery:
        def filter_by(self, **kwargs):
            return self

        def first(self):
            return None

    with app.app_context():
        monkeypatch.setattr(
            family_service_module.User,
            "query",
            FakeUserQuery(),
        )

        monkeypatch.setattr(
            family_service_module.Child,
            "query",
            FakeChildQuery(),
        )

        monkeypatch.setattr(
            family_service_module.db.session,
            "flush",
            lambda: None,
        )

        monkeypatch.setattr(
            family_service_module.db.session,
            "delete",
            lambda value: deleted.append(value),
        )

        monkeypatch.setattr(
            family_service_module.db.session,
            "commit",
            lambda: None,
        )

        result, error = service.accept_invitation(
            user.id,
            invitation.id,
        )

    assert error is None
    assert result is invitation
    assert deleted == []

def test_service_keeps_old_family_when_child_remains(
    app,
    monkeypatch,
):
    old_family_id = "old-family-id"

    user = FakeUser(
        family_id=old_family_id,
        family=FakeFamily(
            family_id=old_family_id,
            children=[],
        ),
    )

    service, _, invitation = prepare_valid_acceptance(
        monkeypatch,
        user=user,
    )

    deleted = []

    class FakeUserQuery:
        def filter_by(self, **kwargs):
            return self

        def first(self):
            return None

    class FakeChildQuery:
        def filter_by(self, **kwargs):
            assert kwargs == {
                "family_id": old_family_id
            }
            return self

        def first(self):
            return object()

    with app.app_context():
        monkeypatch.setattr(
            family_service_module.User,
            "query",
            FakeUserQuery(),
        )

        monkeypatch.setattr(
            family_service_module.Child,
            "query",
            FakeChildQuery(),
        )

        monkeypatch.setattr(
            family_service_module.db.session,
            "flush",
            lambda: None,
        )

        monkeypatch.setattr(
            family_service_module.db.session,
            "delete",
            lambda value: deleted.append(value),
        )

        monkeypatch.setattr(
            family_service_module.db.session,
            "commit",
            lambda: None,
        )

        result, error = service.accept_invitation(
            user.id,
            invitation.id,
        )

    assert error is None
    assert result is invitation
    assert deleted == []

def test_service_deletes_empty_old_family(
    app,
    monkeypatch,
):
    old_family_id = "old-family-id"

    old_family = FakeFamily(
        family_id=old_family_id,
    )

    user = FakeUser(
        family_id=old_family_id,
        family=FakeFamily(
            family_id=old_family_id,
            children=[],
        ),
    )

    service, _, invitation = prepare_valid_acceptance(
        monkeypatch,
        user=user,
    )

    deleted = []

    class FakeQuery:
        def filter_by(self, **kwargs):
            assert kwargs == {
                "family_id": old_family_id
            }
            return self

        def first(self):
            return None

    def fake_session_get(model, family_id):
        assert model is family_service_module.Family
        assert family_id == old_family_id
        return old_family

    with app.app_context():
        monkeypatch.setattr(
            family_service_module.User,
            "query",
            FakeQuery(),
        )

        monkeypatch.setattr(
            family_service_module.Child,
            "query",
            FakeQuery(),
        )

        monkeypatch.setattr(
            family_service_module.db.session,
            "flush",
            lambda: None,
        )

        monkeypatch.setattr(
            family_service_module.db.session,
            "get",
            fake_session_get,
        )

        monkeypatch.setattr(
            family_service_module.db.session,
            "delete",
            lambda value: deleted.append(value),
        )

        monkeypatch.setattr(
            family_service_module.db.session,
            "commit",
            lambda: None,
        )

        result, error = service.accept_invitation(
            user.id,
            invitation.id,
        )

    assert error is None
    assert result is invitation
    assert deleted == [old_family]

def test_service_does_not_delete_missing_old_family(
    app,
    monkeypatch,
):
    old_family_id = "old-family-id"

    user = FakeUser(
        family_id=old_family_id,
        family=FakeFamily(
            family_id=old_family_id,
            children=[],
        ),
    )

    service, _, invitation = prepare_valid_acceptance(
        monkeypatch,
        user=user,
    )

    deleted = []

    class FakeQuery:
        def filter_by(self, **kwargs):
            assert kwargs == {
                "family_id": old_family_id
            }
            return self

        def first(self):
            return None

    with app.app_context():
        monkeypatch.setattr(
            family_service_module.User,
            "query",
            FakeQuery(),
        )

        monkeypatch.setattr(
            family_service_module.Child,
            "query",
            FakeQuery(),
        )

        monkeypatch.setattr(
            family_service_module.db.session,
            "flush",
            lambda: None,
        )

        monkeypatch.setattr(
            family_service_module.db.session,
            "get",
            lambda model, family_id: None,
        )

        monkeypatch.setattr(
            family_service_module.db.session,
            "delete",
            lambda value: deleted.append(value),
        )

        monkeypatch.setattr(
            family_service_module.db.session,
            "commit",
            lambda: None,
        )

        result, error = service.accept_invitation(
            user.id,
            invitation.id,
        )

    assert error is None
    assert result is invitation
    assert deleted == []
    
def test_service_commits_on_success(
    monkeypatch,
):
    service, user, invitation = (
        prepare_valid_acceptance(monkeypatch)
    )
    calls = {
        "flush": 0,
        "commit": 0,
        "rollback": 0,
    }

    monkeypatch.setattr(
        family_service_module.db.session,
        "flush",
        lambda: calls.__setitem__(
            "flush",
            calls["flush"] + 1,
        ),
    )
    monkeypatch.setattr(
        family_service_module.db.session,
        "commit",
        lambda: calls.__setitem__(
            "commit",
            calls["commit"] + 1,
        ),
    )
    monkeypatch.setattr(
        family_service_module.db.session,
        "rollback",
        lambda: calls.__setitem__(
            "rollback",
            calls["rollback"] + 1,
        ),
    )

    result, error = service.accept_invitation(
        user.id,
        invitation.id,
    )

    assert error is None
    assert result is invitation
    assert calls == {
        "flush": 1,
        "commit": 1,
        "rollback": 0,
    }


def make_integrity_error(
    constraint_name=None,
):
    class FakeDiag:
        pass

    class FakeOrig(Exception):
        pass

    orig = FakeOrig("database integrity error")
    orig.diag = FakeDiag()
    orig.diag.constraint_name = constraint_name

    return IntegrityError(
        "statement",
        {},
        orig,
    )


def test_service_maps_guardian_constraint_integrity_error(
    monkeypatch,
):
    service, user, invitation = (
        prepare_valid_acceptance(monkeypatch)
    )
    rollback_calls = {"count": 0}

    monkeypatch.setattr(
        family_service_module.db.session,
        "flush",
        lambda: (_ for _ in ()).throw(
            make_integrity_error(
                "uq_users_family_guardian_type"
            )
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

    result = service.accept_invitation(
        user.id,
        invitation.id,
    )

    assert result == (
        None,
        "guardian_type_already_exists",
    )
    assert rollback_calls["count"] == 1


def test_service_maps_other_integrity_error_to_update_failed(
    monkeypatch,
):
    service, user, invitation = (
        prepare_valid_acceptance(monkeypatch)
    )
    rollback_calls = {"count": 0}

    monkeypatch.setattr(
        family_service_module.db.session,
        "flush",
        lambda: (_ for _ in ()).throw(
            make_integrity_error(
                "some_other_constraint"
            )
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

    result = service.accept_invitation(
        user.id,
        invitation.id,
    )

    assert result == (None, "update_failed")
    assert rollback_calls["count"] == 1


def test_service_handles_integrity_error_without_diag(
    monkeypatch,
):
    service, user, invitation = (
        prepare_valid_acceptance(monkeypatch)
    )
    rollback_calls = {"count": 0}

    class OrigWithoutDiag(Exception):
        pass

    error = IntegrityError(
        "statement",
        {},
        OrigWithoutDiag("integrity error"),
    )

    monkeypatch.setattr(
        family_service_module.db.session,
        "flush",
        lambda: (_ for _ in ()).throw(error),
    )
    monkeypatch.setattr(
        family_service_module.db.session,
        "rollback",
        lambda: rollback_calls.__setitem__(
            "count",
            rollback_calls["count"] + 1,
        ),
    )

    result = service.accept_invitation(
        user.id,
        invitation.id,
    )

    assert result == (None, "update_failed")
    assert rollback_calls["count"] == 1


def test_service_rolls_back_on_unexpected_exception(
    monkeypatch,
):
    service, user, invitation = (
        prepare_valid_acceptance(monkeypatch)
    )
    rollback_calls = {"count": 0}

    monkeypatch.setattr(
        family_service_module.db.session,
        "flush",
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

    result = service.accept_invitation(
        user.id,
        invitation.id,
    )

    assert result == (None, "update_failed")
    assert rollback_calls["count"] == 1


# ===========================================================================
# Repository tests
# ===========================================================================

def test_repository_filters_guardian_by_family_and_type(
    app,
    monkeypatch,
):
    repository = (
        family_routes.family_service
        .family_invitation_repository
    )
    expected_user = object()
    captured = {}

    class FakeQuery:
        def filter_by(self, **kwargs):
            captured["filters"] = kwargs
            return self

        def first(self):
            captured["first_called"] = True
            return expected_user

    with app.app_context():
        monkeypatch.setattr(
            family_service_module.User,
            "query",
            FakeQuery(),
        )

        result = (
            repository
            .get_guardian_by_family_and_type(
                "family-123",
                "mother",
            )
        )

    assert result is expected_user
    assert captured["filters"] == {
        "family_id": "family-123",
        "guardian_type": "mother",
    }
    assert captured["first_called"] is True


def test_repository_returns_none_when_guardian_not_found(
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

        def first(self):
            return None

    with app.app_context():
        monkeypatch.setattr(
            family_service_module.User,
            "query",
            FakeQuery(),
        )

        result = (
            repository
            .get_guardian_by_family_and_type(
                "family-123",
                "guardian",
            )
        )

    assert result is None