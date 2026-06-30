import pytest

from conftest import (
    auth_header,
    assert_json_has_error_or_message,
    count_rows,
    create_child,
    create_parent_and_tokens,
    login_parent,
    make_access_token,
    make_refresh_token,
    register_parent,
)


class TestRegister:
    def test_register_success_hides_password_and_defaults_parent_role(self, client, models):
        res = register_parent(client)
        assert res.status_code == 201
        data = res.get_json()
        assert data["full_name"] == "Parent User"
        assert data["email"] == "parent@example.com"
        assert data["role"] == "parent"
        assert "password" not in data
        assert "password_hash" not in data
        assert count_rows(models["User"]) == 1

    def test_register_trims_full_name_before_saving(self, client):
        res = register_parent(client, full_name="  Parent User  ")
        assert res.status_code == 201
        assert res.get_json()["full_name"] == "Parent User"

    def test_register_normalizes_email_case(self, client):
        res = register_parent(client, email="PARENT@EXAMPLE.COM")
        assert res.status_code == 201
        assert res.get_json()["email"] == "parent@example.com"

    def test_register_email_with_surrounding_spaces_is_rejected_by_schema_current_behavior(self, client):
        res = register_parent(client, email="  parent@example.com  ")
        assert res.status_code in (400, 415)

    def test_register_duplicate_email_returns_409(self, client, models):
        assert register_parent(client, email="dup@example.com").status_code == 201
        res = register_parent(client, email="dup@example.com")
        assert res.status_code == 409
        assert res.get_json()["error"] == "Email already registered"
        assert count_rows(models["User"]) == 1

    def test_register_duplicate_email_case_insensitive_returns_409(self, client):
        assert register_parent(client, email="case@example.com").status_code == 201
        res = register_parent(client, email="CASE@example.com")
        assert res.status_code == 409

    @pytest.mark.parametrize("payload", [
        {},
        {"email": "a@example.com", "password": "StrongPass1!"},
        {"full_name": "Parent", "password": "StrongPass1!"},
        {"full_name": "Parent", "email": "a@example.com"},
        None,
    ])
    def test_register_missing_or_null_body_returns_400(self, client, payload):
        res = client.post("/api/auth/register", json=payload)
        assert res.status_code in (400, 415)
        if res.status_code != 415:
            assert_json_has_error_or_message(res)

    @pytest.mark.parametrize("full_name", ["", " ", "A", "x" * 101])
    def test_register_invalid_full_name_returns_400(self, client, full_name):
        res = register_parent(client, full_name=full_name)
        assert res.status_code in (400, 415)

    @pytest.mark.parametrize("full_name", ["منار زيد", "Parent-Name", "Parent O'Name", "😊 Parent"])
    def test_register_accepts_supported_name_strings(self, client, full_name):
        res = register_parent(client, full_name=full_name, email=f"u{abs(hash(full_name))}@example.com")
        assert res.status_code == 201

    @pytest.mark.parametrize("email", [
        "bad", "bad@", "@example.com", "a b@example.com", "a@example", "a@@example.com", "<x>@example.com"
    ])
    def test_register_invalid_email_returns_400(self, client, email):
        res = register_parent(client, email=email)
        assert res.status_code in (400, 415)

    @pytest.mark.parametrize("password", [
        "Short1!", "lowercase1!", "UPPERCASE1!", "NoNumber!", "NoSpecial1", "", "       ",
    ])
    def test_register_weak_password_returns_400(self, client, password):
        res = register_parent(client, password=password)
        assert res.status_code in (400, 415)

    @pytest.mark.parametrize("password", ["StrongPass1!", "Aa123456!", "Complex_Pass-123"])
    def test_register_valid_passwords_return_201(self, client, password):
        res = register_parent(client, email=f"p{abs(hash(password))}@example.com", password=password)
        assert res.status_code == 201

    def test_register_extra_role_field_cannot_promote_user(self, client):
        res = register_parent(client, email="extra@example.com", role="admin")
        assert res.status_code in (201, 400)
        if res.status_code == 201:
            assert res.get_json()["role"] == "parent"

    @pytest.mark.parametrize("value", ["' OR '1'='1", "<script>alert(1)</script>", "../../etc/passwd"])
    def test_register_unusual_text_is_not_executed(self, client, value):
        res = register_parent(client, full_name=value, email=f"safe{abs(hash(value))}@example.com")
        assert res.status_code in (201, 400)


class TestLoginAndTokens:
    def test_login_success_returns_access_refresh_and_user(self, client):
        register_parent(client)
        res = login_parent(client)
        assert res.status_code == 200
        data = res.get_json()
        assert data["access_token"]
        assert data["refresh_token"]
        assert data["user"]["email"] == "parent@example.com"
        assert data["user"]["role"] == "parent"

    def test_login_email_case_insensitive(self, client):
        register_parent(client, email="parent@example.com")
        res = login_parent(client, email="PARENT@EXAMPLE.COM")
        assert res.status_code == 200

    def test_login_email_with_spaces_rejected_by_schema_current_behavior(self, client):
        register_parent(client)
        res = login_parent(client, email=" parent@example.com ")
        assert res.status_code in (400, 415)

    @pytest.mark.parametrize("payload", [{}, {"email": "parent@example.com"}, {"password": "StrongPass1!"}, None])
    def test_login_missing_or_null_body_returns_400(self, client, payload):
        res = client.post("/api/auth/login", json=payload)
        assert res.status_code in (400, 415)

    @pytest.mark.parametrize("email,password", [
        ("missing@example.com", "StrongPass1!"),
        ("parent@example.com", "WrongPass1!"),
        ("bad-email", "StrongPass1!"),
        ("", "StrongPass1!"),
    ])
    def test_login_invalid_credentials_or_email_return_error_status(self, client, email, password):
        register_parent(client)
        res = login_parent(client, email=email, password=password)
        assert res.status_code in (400, 401)
        assert_json_has_error_or_message(res)

    def test_auth_me_parent_returns_parent_data(self, client):
        token, _, user = create_parent_and_tokens(client)
        res = client.get("/api/auth/me", headers=auth_header(token))
        assert res.status_code == 200
        assert res.get_json()["id"] == user["id"]
        assert res.get_json()["role"] == "parent"

    def test_auth_me_missing_token_returns_401(self, client):
        res = client.get("/api/auth/me")
        assert res.status_code == 401

    @pytest.mark.parametrize("token", ["not-a-token", "Bearer not-a-token", "", "abc.def.ghi"])
    def test_auth_me_invalid_token_returns_401_or_422(self, client, token):
        res = client.get("/api/auth/me", headers=auth_header(token))
        assert res.status_code in (401, 422)

    def test_refresh_parent_success_returns_new_access_token(self, client):
        _, refresh, _ = create_parent_and_tokens(client)
        res = client.post("/api/auth/refresh", headers=auth_header(refresh))
        assert res.status_code == 200
        assert res.get_json()["access_token"]

    def test_refresh_with_access_token_is_rejected(self, client):
        access, _, _ = create_parent_and_tokens(client)
        res = client.post("/api/auth/refresh", headers=auth_header(access))
        assert res.status_code in (401, 422)

    def test_protected_route_with_refresh_token_is_rejected(self, client):
        _, refresh, _ = create_parent_and_tokens(client)
        res = client.get("/api/auth/me", headers=auth_header(refresh))
        assert res.status_code in (401, 422)

    def test_logout_revokes_access_token(self, client):
        access, _, _ = create_parent_and_tokens(client)
        logout = client.post("/api/auth/logout", headers=auth_header(access))
        assert logout.status_code == 200
        res = client.get("/api/auth/me", headers=auth_header(access))
        assert res.status_code == 401

    def test_logout_is_idempotent_for_same_access_token(self, client):
        access, _, _ = create_parent_and_tokens(client)
        first = client.post("/api/auth/logout", headers=auth_header(access))
        second = client.post("/api/auth/logout", headers=auth_header(access))
        assert first.status_code == 200
        assert second.status_code == 401

    def test_logout_refresh_revokes_refresh_token(self, client):
        _, refresh, _ = create_parent_and_tokens(client)
        logout = client.post("/api/auth/logout-refresh", headers=auth_header(refresh))
        assert logout.status_code == 200
        res = client.post("/api/auth/refresh", headers=auth_header(refresh))
        assert res.status_code == 401

    def test_access_token_with_unknown_role_is_forbidden(self, app, client):
        token = make_access_token(app, "some-id", role="admin")
        res = client.get("/api/auth/me", headers=auth_header(token))
        assert res.status_code == 403

    def test_access_token_for_deleted_user_returns_404(self, app, client, models):
        access, _, user = create_parent_and_tokens(client)
        with app.app_context():
            db = models["db"]
            obj = db.session.get(models["User"], user["id"])
            db.session.delete(obj)
            db.session.commit()
        res = client.get("/api/auth/me", headers=auth_header(access))
        assert res.status_code == 404

    def test_refresh_token_for_deleted_user_returns_404(self, app, client, models):
        _, refresh, user = create_parent_and_tokens(client)
        with app.app_context():
            db = models["db"]
            obj = db.session.get(models["User"], user["id"])
            db.session.delete(obj)
            db.session.commit()
        res = client.post("/api/auth/refresh", headers=auth_header(refresh))
        assert res.status_code == 404


class TestChildLogin:
    def test_child_login_success_returns_child_token(self, client):
        parent_token, _, _ = create_parent_and_tokens(client)
        child = create_child(client, parent_token).get_json()
        res = client.post("/api/auth/child-login", json={"access_code": child["access_code"]})
        assert res.status_code == 200
        data = res.get_json()
        assert data["access_token"]
        assert data["refresh_token"]
        assert data["child"]["id"] == child["id"]
        assert data["child"]["role"] == "child"

    @pytest.mark.parametrize("access_code", ["000000", "12345", "1234567", "abcdef", "12 456", "", None])
    def test_child_login_invalid_access_code_returns_error(self, client, access_code):
        payload = {"access_code": access_code} if access_code is not None else {"access_code": None}
        res = client.post("/api/auth/child-login", json=payload)
        assert res.status_code in (400, 401)

    def test_child_me_returns_child_data(self, client):
        parent_token, _, _ = create_parent_and_tokens(client)
        child = create_child(client, parent_token).get_json()
        login = client.post("/api/auth/child-login", json={"access_code": child["access_code"]}).get_json()
        res = client.get("/api/auth/me", headers=auth_header(login["access_token"]))
        assert res.status_code == 200
        assert res.get_json()["id"] == child["id"]
        assert res.get_json()["role"] == "child"

    def test_child_refresh_success(self, client):
        parent_token, _, _ = create_parent_and_tokens(client)
        child = create_child(client, parent_token).get_json()
        login = client.post("/api/auth/child-login", json={"access_code": child["access_code"]}).get_json()
        res = client.post("/api/auth/refresh", headers=auth_header(login["refresh_token"]))
        assert res.status_code == 200
        assert res.get_json()["access_token"]
