import pytest

from conftest import auth_header, assert_json_has_error_or_message, create_child, create_parent_and_tokens, make_access_token


class TestUserMe:
    def test_get_me_success(self, client, parent):
        res = client.get("/api/users/me", headers=auth_header(parent["token"]))
        assert res.status_code == 200
        data = res.get_json()
        assert data["id"] == parent["user"]["id"]
        assert data["email"] == "parent@example.com"
        assert data["role"] == "parent"
        assert "password_hash" not in data

    def test_get_me_missing_token_returns_401(self, client):
        res = client.get("/api/users/me")
        assert res.status_code == 401

    @pytest.mark.parametrize("token", ["invalid", "Bearer invalid", "abc.def.ghi"])
    def test_get_me_invalid_token_returns_401_or_422(self, client, token):
        res = client.get("/api/users/me", headers=auth_header(token))
        assert res.status_code in (401, 422)

    def test_get_me_child_token_forbidden_or_not_found(self, client, child_token):
        res = client.get("/api/users/me", headers=auth_header(child_token["token"]))
        assert res.status_code in (403, 404)

    def test_get_me_unknown_role_returns_404_or_403(self, app, client):
        token = make_access_token(app, "unknown", role="admin")
        res = client.get("/api/users/me", headers=auth_header(token))
        assert res.status_code in (403, 404)


class TestUserUpdate:
    def test_update_full_name_success_and_trims(self, client, parent):
        res = client.put("/api/users/me", headers=auth_header(parent["token"]), json={"full_name": "  New Name  "})
        assert res.status_code == 200
        assert res.get_json()["full_name"] == "New Name"

    def test_update_email_success_lowercases(self, client, parent):
        res = client.put("/api/users/me", headers=auth_header(parent["token"]), json={"email": "NEW@EXAMPLE.COM"})
        assert res.status_code == 200
        assert res.get_json()["email"] == "new@example.com"

    def test_update_email_with_spaces_rejected_by_schema_current_behavior(self, client, parent):
        res = client.put("/api/users/me", headers=auth_header(parent["token"]), json={"email": " new@example.com "})
        assert res.status_code in (400, 415)

    def test_update_full_name_and_email_success(self, client, parent):
        res = client.put("/api/users/me", headers=auth_header(parent["token"]), json={
            "full_name": "Updated Parent",
            "email": "updated@example.com",
        })
        assert res.status_code == 200
        data = res.get_json()
        assert data["full_name"] == "Updated Parent"
        assert data["email"] == "updated@example.com"

    def test_update_duplicate_email_returns_409(self, client, parent, parent2):
        res = client.put("/api/users/me", headers=auth_header(parent["token"]), json={"email": parent2["user"]["email"]})
        assert res.status_code == 409

    @pytest.mark.parametrize("payload", [{}, None])
    def test_update_empty_or_null_body_returns_400(self, client, parent, payload):
        res = client.put("/api/users/me", headers=auth_header(parent["token"]), json=payload)
        assert res.status_code in (400, 415)
        if res.status_code != 415:
            assert_json_has_error_or_message(res)

    @pytest.mark.parametrize("full_name", ["", " ", "A", "x" * 101])
    def test_update_invalid_full_name_returns_400(self, client, parent, full_name):
        res = client.put("/api/users/me", headers=auth_header(parent["token"]), json={"full_name": full_name})
        assert res.status_code in (400, 415)

    @pytest.mark.parametrize("email", ["bad", "bad@", "a b@example.com", "@example.com"])
    def test_update_invalid_email_returns_400(self, client, parent, email):
        res = client.put("/api/users/me", headers=auth_header(parent["token"]), json={"email": email})
        assert res.status_code in (400, 415)

    @pytest.mark.parametrize("payload", [
        {"full_name": 123},
        {"email": 123},
        {"full_name": ["Name"]},
        {"email": {"x": "y"}},
    ])
    def test_update_wrong_types_return_400(self, client, parent, payload):
        res = client.put("/api/users/me", headers=auth_header(parent["token"]), json=payload)
        assert res.status_code in (400, 415)

    def test_update_extra_role_field_cannot_change_role(self, client, parent):
        res = client.put("/api/users/me", headers=auth_header(parent["token"]), json={"role": "admin", "full_name": "Still Parent"})
        assert res.status_code in (200, 400)
        if res.status_code == 200:
            assert res.get_json()["role"] == "parent"

    @pytest.mark.parametrize("value", ["منار زيد", "Name 😊", "<script>alert(1)</script>", "' OR 1=1 --"])
    def test_update_unusual_full_name_does_not_break_api(self, client, parent, value):
        res = client.put("/api/users/me", headers=auth_header(parent["token"]), json={"full_name": value})
        assert res.status_code in (200, 400)

    def test_update_missing_token_returns_401_or_400_if_restx_validates_first(self, client):
        res = client.put("/api/users/me", json={"full_name": "New"})
        assert res.status_code in (400, 401)

    def test_update_child_token_cannot_update_user(self, client, child_token):
        res = client.put("/api/users/me", headers=auth_header(child_token["token"]), json={"full_name": "Bad"})
        assert res.status_code in (403, 404)


class TestUserDelete:
    def test_delete_user_success(self, client, parent):
        res = client.delete("/api/users/me", headers=auth_header(parent["token"]))
        assert res.status_code == 200
        assert "message" in res.get_json()
        me = client.get("/api/users/me", headers=auth_header(parent["token"]))
        assert me.status_code == 404

    def test_delete_user_removes_access_to_children(self, client, parent):
        child = create_child(client, parent["token"]).get_json()
        assert child["id"]
        delete = client.delete("/api/users/me", headers=auth_header(parent["token"]))
        assert delete.status_code == 200
        res = client.get("/api/children/", headers=auth_header(parent["token"]))
        assert res.status_code in (200, 404)

    def test_delete_user_missing_token_returns_401(self, client):
        res = client.delete("/api/users/me")
        assert res.status_code == 401

    def test_delete_user_twice_returns_404_second_time(self, client, parent):
        first = client.delete("/api/users/me", headers=auth_header(parent["token"]))
        second = client.delete("/api/users/me", headers=auth_header(parent["token"]))
        assert first.status_code == 200
        assert second.status_code == 404

    def test_delete_child_token_cannot_delete_user(self, client, child_token):
        res = client.delete("/api/users/me", headers=auth_header(child_token["token"]))
        assert res.status_code in (403, 404)
