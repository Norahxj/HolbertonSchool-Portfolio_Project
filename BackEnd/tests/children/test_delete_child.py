import pytest
from flask_jwt_extended import decode_token

from app.extensions import db
from app.routes import child_routes


REGISTER_URL = "/api/auth/register"
CHILDREN_URL = "/api/children"
CHILD_LOGIN_URL = "/api/auth/child-login"


def child_detail_url(child_id):
    return f"{CHILDREN_URL}/{child_id}"


def valid_parent_data(
    *,
    first_name="Manar",
    last_name="Zaid",
    phone="0551234567",
    email="delete.child.parent@gmail.com",
    guardian_type="mother",
):
    return {
        "first_name": first_name,
        "last_name": last_name,
        "phone": phone,
        "email": email,
        "password": "Password123!",
        "guardian_type": guardian_type,
    }


def valid_child_data(
    *,
    name="Sara",
    birth_date="2015-05-10",
    phone="0559876543",
):
    return {
        "name": name,
        "birth_date": birth_date,
        "phone": phone,
    }


def authorization_header(access_token):
    return {
        "Authorization": access_token,
    }


def register_parent(client, parent_data=None):
    response = client.post(
        REGISTER_URL,
        json=parent_data or valid_parent_data(),
    )
    response_data = response.get_json()

    assert response.status_code == 201, response_data
    assert "access_token" in response_data

    return response_data


def create_child(client, access_token, child_data=None):
    response = client.post(
        f"{CHILDREN_URL}/",
        headers=authorization_header(access_token),
        json=child_data or valid_child_data(),
    )
    response_data = response.get_json()

    assert response.status_code == 201, response_data

    if isinstance(response_data, dict) and "child" in response_data:
        return response_data["child"]

    return response_data


def delete_child_request(client, access_token, child_id):
    return client.delete(
        child_detail_url(child_id),
        headers=authorization_header(access_token),
    )


def get_child_request(client, access_token, child_id):
    return client.get(
        child_detail_url(child_id),
        headers=authorization_header(access_token),
    )


def get_children_request(client, access_token):
    return client.get(
        f"{CHILDREN_URL}/",
        headers=authorization_header(access_token),
    )


# =========================================================
# Successful deletion
# =========================================================


def test_delete_child_success(client):
    parent = register_parent(client)
    child = create_child(client, parent["access_token"])

    response = delete_child_request(
        client,
        parent["access_token"],
        child["id"],
    )
    response_data = response.get_json()

    assert response.status_code == 200, response_data
    assert response_data == {
        "message": "Child and related data deleted successfully"
    }


def test_deleted_child_can_no_longer_be_retrieved(client):
    parent = register_parent(client)
    child = create_child(client, parent["access_token"])

    delete_response = delete_child_request(
        client,
        parent["access_token"],
        child["id"],
    )

    assert delete_response.status_code == 200

    get_response = get_child_request(
        client,
        parent["access_token"],
        child["id"],
    )
    get_data = get_response.get_json()

    assert get_response.status_code == 404
    assert get_data == {"error": "Child not found"}


def test_deleted_child_is_removed_from_parent_children_list(client):
    parent = register_parent(client)

    first_child = create_child(
        client,
        parent["access_token"],
        valid_child_data(
            name="Sara",
            phone="0551111111",
        ),
    )

    second_child = create_child(
        client,
        parent["access_token"],
        valid_child_data(
            name="Noura",
            birth_date="2014-06-15",
            phone="0552222222",
        ),
    )

    delete_response = delete_child_request(
        client,
        parent["access_token"],
        first_child["id"],
    )

    assert delete_response.status_code == 200

    list_response = get_children_request(
        client,
        parent["access_token"],
    )
    response_data = list_response.get_json()

    assert list_response.status_code == 200

    returned_ids = {
        child["id"]
        for child in response_data
    }

    assert first_child["id"] not in returned_ids
    assert second_child["id"] in returned_ids


def test_delete_one_child_does_not_delete_another_child(client):
    parent = register_parent(client)

    first_child = create_child(
        client,
        parent["access_token"],
        valid_child_data(
            name="Sara",
            phone="0553333333",
        ),
    )

    second_child = create_child(
        client,
        parent["access_token"],
        valid_child_data(
            name="Khalid",
            birth_date="2014-06-15",
            phone="0554444444",
        ),
    )

    response = delete_child_request(
        client,
        parent["access_token"],
        first_child["id"],
    )

    assert response.status_code == 200

    second_response = get_child_request(
        client,
        parent["access_token"],
        second_child["id"],
    )

    assert second_response.status_code == 200
    assert second_response.get_json()["id"] == second_child["id"]


# =========================================================
# Not found and family isolation
# =========================================================


def test_delete_child_returns_404_for_unknown_child(client):
    parent = register_parent(client)

    response = delete_child_request(
        client,
        parent["access_token"],
        "00000000-0000-0000-0000-000000000000",
    )
    response_data = response.get_json()

    assert response.status_code == 404, response_data
    assert response_data == {
        "error": "Child not found",
    }


def test_parent_cannot_delete_another_family_child(client):
    first_parent = register_parent(
        client,
        valid_parent_data(
            phone="0555555555",
            email="first.delete.parent@gmail.com",
        ),
    )

    second_parent = register_parent(
        client,
        valid_parent_data(
            first_name="Noura",
            phone="0556666666",
            email="second.delete.parent@gmail.com",
        ),
    )

    second_child = create_child(
        client,
        second_parent["access_token"],
        valid_child_data(
            name="Khalid",
            phone="0557777777",
        ),
    )

    response = delete_child_request(
        client,
        first_parent["access_token"],
        second_child["id"],
    )
    response_data = response.get_json()

    assert response.status_code == 404, response_data
    assert response_data == {
        "error": "Child not found",
    }

    still_exists_response = get_child_request(
        client,
        second_parent["access_token"],
        second_child["id"],
    )

    assert still_exists_response.status_code == 200


# =========================================================
# Authentication and authorization
# =========================================================


def test_delete_child_requires_access_token(client):
    response = client.delete(
        child_detail_url(
            "00000000-0000-0000-0000-000000000000"
        )
    )

    assert response.status_code == 401


@pytest.mark.parametrize(
    "invalid_token",
    [
        "invalid-token",
        "abc.def",
        "abc.def.ghi",
    ],
)
def test_delete_child_rejects_invalid_token(
    client,
    invalid_token,
):
    response = delete_child_request(
        client,
        invalid_token,
        "00000000-0000-0000-0000-000000000000",
    )

    assert response.status_code in (401, 422)


def test_child_token_cannot_delete_child(client):
    parent = register_parent(client)
    child = create_child(client, parent["access_token"])

    login_response = client.post(
        CHILD_LOGIN_URL,
        json={
            "access_code": child["access_code"],
        },
    )
    login_data = login_response.get_json()

    assert login_response.status_code == 200, login_data
    assert "access_token" in login_data

    response = delete_child_request(
        client,
        login_data["access_token"],
        child["id"],
    )
    response_data = response.get_json()

    assert response.status_code == 403, response_data
    assert response_data["error"] == "Parent access required"


# =========================================================
# Route behavior
# =========================================================


def test_route_passes_child_id_and_parent_id_to_service(
    client,
    app,
    monkeypatch,
):
    parent = register_parent(client)
    captured = {}

    with app.app_context():
        expected_parent_id = decode_token(
            parent["access_token"]
        )["sub"]

    def fake_delete_child_for_parent(child_id, parent_id):
        captured["child_id"] = child_id
        captured["parent_id"] = parent_id
        return True, None

    monkeypatch.setattr(
        child_routes.child_service,
        "delete_child_for_parent",
        fake_delete_child_for_parent,
    )

    response = delete_child_request(
        client,
        parent["access_token"],
        "child-id-123",
    )

    assert response.status_code == 200
    assert captured == {
        "child_id": "child-id-123",
        "parent_id": expected_parent_id,
    }


@pytest.mark.parametrize(
    "service_error, expected_status, expected_body",
    [
        (
            "parent_not_found",
            404,
            {"error": "Parent not found"},
        ),
        (
            "child_not_found",
            404,
            {"error": "Child not found"},
        ),
        (
            "delete_error",
            500,
            {"error": "Failed to delete child and related data"},
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
        child_routes.child_service,
        "delete_child_for_parent",
        lambda child_id, parent_id: (
            False,
            service_error,
        ),
    )

    response = delete_child_request(
        client,
        parent["access_token"],
        "child-id-123",
    )

    assert response.status_code == expected_status
    assert response.get_json() == expected_body


def test_route_returns_success_response_when_service_succeeds(
    client,
    monkeypatch,
):
    parent = register_parent(client)

    monkeypatch.setattr(
        child_routes.child_service,
        "delete_child_for_parent",
        lambda child_id, parent_id: (True, None),
    )

    response = delete_child_request(
        client,
        parent["access_token"],
        "child-id-123",
    )

    assert response.status_code == 200
    assert response.get_json() == {
        "message": "Child and related data deleted successfully"
    }


# =========================================================
# Service behavior
# =========================================================


def test_service_returns_parent_not_found(
    monkeypatch,
):
    service = child_routes.child_service

    monkeypatch.setattr(
        service.user_repository,
        "get_user_by_id",
        lambda parent_id: None,
    )

    child_lookup_called = {"value": False}
    delete_called = {"value": False}

    def fake_get_child_for_guardian(child_id, parent_id):
        child_lookup_called["value"] = True
        return object()

    def fake_delete_child(child):
        delete_called["value"] = True
        return True, None

    monkeypatch.setattr(
        service.child_repository,
        "get_child_for_guardian",
        fake_get_child_for_guardian,
    )

    monkeypatch.setattr(
        service.child_repository,
        "delete_child",
        fake_delete_child,
    )

    success, error = service.delete_child_for_parent(
        "child-id",
        "missing-parent-id",
    )

    assert success is False
    assert error == "parent_not_found"
    assert child_lookup_called["value"] is False
    assert delete_called["value"] is False


def test_service_returns_child_not_found(
    monkeypatch,
):
    service = child_routes.child_service
    fake_parent = object()

    monkeypatch.setattr(
        service.user_repository,
        "get_user_by_id",
        lambda parent_id: fake_parent,
    )

    monkeypatch.setattr(
        service.child_repository,
        "get_child_for_guardian",
        lambda child_id, parent_id: None,
    )

    delete_called = {"value": False}

    def fake_delete_child(child):
        delete_called["value"] = True
        return True, None

    monkeypatch.setattr(
        service.child_repository,
        "delete_child",
        fake_delete_child,
    )

    success, error = service.delete_child_for_parent(
        "missing-child-id",
        "parent-id",
    )

    assert success is False
    assert error == "child_not_found"
    assert delete_called["value"] is False


def test_service_passes_child_to_repository_delete(
    monkeypatch,
):
    service = child_routes.child_service
    fake_parent = object()
    fake_child = object()
    captured = {}

    monkeypatch.setattr(
        service.user_repository,
        "get_user_by_id",
        lambda parent_id: fake_parent,
    )

    def fake_get_child_for_guardian(child_id, parent_id):
        captured["child_id"] = child_id
        captured["parent_id"] = parent_id
        return fake_child

    def fake_delete_child(child):
        captured["child"] = child
        return True, None

    monkeypatch.setattr(
        service.child_repository,
        "get_child_for_guardian",
        fake_get_child_for_guardian,
    )

    monkeypatch.setattr(
        service.child_repository,
        "delete_child",
        fake_delete_child,
    )

    success, error = service.delete_child_for_parent(
        "child-id-123",
        "parent-id-456",
    )

    assert captured == {
        "child_id": "child-id-123",
        "parent_id": "parent-id-456",
        "child": fake_child,
    }
    assert success is True
    assert error is None


def test_service_returns_repository_delete_error(
    monkeypatch,
):
    service = child_routes.child_service
    fake_parent = object()
    fake_child = object()

    monkeypatch.setattr(
        service.user_repository,
        "get_user_by_id",
        lambda parent_id: fake_parent,
    )

    monkeypatch.setattr(
        service.child_repository,
        "get_child_for_guardian",
        lambda child_id, parent_id: fake_child,
    )

    monkeypatch.setattr(
        service.child_repository,
        "delete_child",
        lambda child: (False, "delete_error"),
    )

    success, error = service.delete_child_for_parent(
        "child-id",
        "parent-id",
    )

    assert success is False
    assert error == "delete_error"


# =========================================================
# Repository behavior
# =========================================================


def test_repository_delete_child_success(
    app,
    monkeypatch,
):
    repository = child_routes.child_service.child_repository
    fake_child = object()
    captured = {
        "deleted": None,
        "commit_called": False,
    }

    def fake_delete(child):
        captured["deleted"] = child

    def fake_commit():
        captured["commit_called"] = True

    monkeypatch.setattr(
        db.session,
        "delete",
        fake_delete,
    )

    monkeypatch.setattr(
        db.session,
        "commit",
        fake_commit,
    )

    success, error = repository.delete_child(fake_child)

    assert success is True
    assert error is None
    assert captured["deleted"] is fake_child
    assert captured["commit_called"] is True


def test_repository_delete_child_rolls_back_on_error(
    app,
    monkeypatch,
):
    repository = child_routes.child_service.child_repository
    fake_child = object()
    rollback_called = {"value": False}

    monkeypatch.setattr(
        db.session,
        "delete",
        lambda child: None,
    )

    def fake_commit():
        raise RuntimeError("database failure")

    def fake_rollback():
        rollback_called["value"] = True

    monkeypatch.setattr(
        db.session,
        "commit",
        fake_commit,
    )

    monkeypatch.setattr(
        db.session,
        "rollback",
        fake_rollback,
    )

    success, error = repository.delete_child(fake_child)

    assert success is False
    assert error == "delete_error"
    assert rollback_called["value"] is True


def test_repository_delete_child_rolls_back_when_delete_raises(
    app,
    monkeypatch,
):
    repository = child_routes.child_service.child_repository
    fake_child = object()
    rollback_called = {"value": False}
    commit_called = {"value": False}

    def fake_delete(child):
        raise RuntimeError("delete failure")

    def fake_commit():
        commit_called["value"] = True

    def fake_rollback():
        rollback_called["value"] = True

    monkeypatch.setattr(
        db.session,
        "delete",
        fake_delete,
    )

    monkeypatch.setattr(
        db.session,
        "commit",
        fake_commit,
    )

    monkeypatch.setattr(
        db.session,
        "rollback",
        fake_rollback,
    )

    success, error = repository.delete_child(fake_child)

    assert success is False
    assert error == "delete_error"
    assert rollback_called["value"] is True
    assert commit_called["value"] is False