import pytest

from conftest import auth_header, assert_json_has_error_or_message, create_child


class TestChildCreate:
    def test_create_child_success_returns_access_code_and_role(self, client, parent):
        res = create_child(client, parent["token"], name="Ali", age=10)
        assert res.status_code == 201
        data = res.get_json()
        assert data["id"]
        assert data["name"] == "Ali"
        assert data["age"] == 10
        assert data["role"] == "child"
        assert data["access_code"].isdigit()
        assert len(data["access_code"]) == 6

    def test_create_child_trims_name(self, client, parent):
        res = create_child(client, parent["token"], name="  Sara  ", age=8)
        assert res.status_code == 201
        assert res.get_json()["name"] == "Sara"

    @pytest.mark.parametrize("name", ["منار", "Ali-Sara", "Child 😊", "O'Child"])
    def test_create_child_supported_names(self, client, parent, name):
        res = create_child(client, parent["token"], name=name, age=8)
        assert res.status_code == 201

    @pytest.mark.parametrize("payload", [{}, {"name": "Ali"}, {"age": 10}, None])
    def test_create_child_missing_or_null_body_returns_400(self, client, parent, payload):
        res = client.post("/api/children/", headers=auth_header(parent["token"]), json=payload)
        assert res.status_code in (400, 415)
        if res.status_code != 415:
            assert_json_has_error_or_message(res)

    @pytest.mark.parametrize("name", ["", " ", "A", "x" * 101])
    def test_create_child_invalid_name_returns_400(self, client, parent, name):
        res = create_child(client, parent["token"], name=name)
        assert res.status_code in (400, 415)

    @pytest.mark.parametrize("age", [0, -1, 19, 200])
    def test_create_child_invalid_age_range_returns_400(self, client, parent, age):
        res = create_child(client, parent["token"], age=age)
        assert res.status_code in (400, 415)

    @pytest.mark.parametrize("age", [1, 2, 10, 18])
    def test_create_child_valid_age_boundaries_return_201(self, client, parent, age):
        res = create_child(client, parent["token"], name=f"Age {age}", age=age)
        assert res.status_code == 201

    @pytest.mark.parametrize("payload", [
        {"name": 123, "age": 8},
        {"name": "Ali", "age": "old"},
        {"name": ["Ali"], "age": 8},
        {"name": "Ali", "age": None},
    ])
    def test_create_child_wrong_types_return_400(self, client, parent, payload):
        res = client.post("/api/children/", headers=auth_header(parent["token"]), json=payload)
        assert res.status_code in (400, 415)

    def test_create_child_missing_token_returns_401_or_400_if_restx_validates_first(self, client):
        res = client.post("/api/children/", json={"name": "Ali", "age": 8})
        assert res.status_code in (400, 401)

    def test_create_child_child_token_forbidden(self, client, child_token):
        res = create_child(client, child_token["token"], name="Bad", age=8)
        assert res.status_code == 403

    def test_create_many_children_have_unique_access_codes(self, client, parent):
        codes = set()
        for idx in range(10):
            res = create_child(client, parent["token"], name=f"Child {idx}", age=idx % 18 + 1)
            assert res.status_code == 201
            code = res.get_json()["access_code"]
            assert code not in codes
            codes.add(code)


class TestChildRead:
    def test_get_children_empty_list(self, client, parent):
        res = client.get("/api/children/", headers=auth_header(parent["token"]))
        assert res.status_code == 200
        assert res.get_json() == []

    def test_get_children_returns_only_current_parent_children(self, client, parent, parent2):
        c1 = create_child(client, parent["token"], name="Parent One Child", age=8).get_json()
        create_child(client, parent2["token"], name="Parent Two Child", age=9)
        res = client.get("/api/children/", headers=auth_header(parent["token"]))
        assert res.status_code == 200
        ids = [item["id"] for item in res.get_json()]
        assert ids == [c1["id"]]

    def test_get_child_by_id_success(self, client, parent):
        child = create_child(client, parent["token"]).get_json()
        res = client.get(f"/api/children/{child['id']}", headers=auth_header(parent["token"]))
        assert res.status_code == 200
        assert res.get_json()["id"] == child["id"]
        assert "access_code" not in res.get_json()

    @pytest.mark.parametrize("child_id", ["missing-id", "123", "00000000-0000-0000-0000-000000000000"])
    def test_get_child_missing_or_invalid_id_returns_404(self, client, parent, child_id):
        res = client.get(f"/api/children/{child_id}", headers=auth_header(parent["token"]))
        assert res.status_code == 404

    def test_parent_cannot_get_other_parent_child(self, client, parent, parent2):
        other = create_child(client, parent2["token"], name="Other Child", age=7).get_json()
        res = client.get(f"/api/children/{other['id']}", headers=auth_header(parent["token"]))
        assert res.status_code == 404

    def test_child_token_cannot_list_children(self, client, child_token):
        res = client.get("/api/children/", headers=auth_header(child_token["token"]))
        assert res.status_code == 403


class TestChildUpdate:
    def test_update_child_name_success_and_trims(self, client, parent):
        child = create_child(client, parent["token"]).get_json()
        res = client.put(f"/api/children/{child['id']}", headers=auth_header(parent["token"]), json={"name": "  New Child  "})
        assert res.status_code == 200
        assert res.get_json()["name"] == "New Child"

    def test_update_child_age_success(self, client, parent):
        child = create_child(client, parent["token"]).get_json()
        res = client.put(f"/api/children/{child['id']}", headers=auth_header(parent["token"]), json={"age": 12})
        assert res.status_code == 200
        assert res.get_json()["age"] == 12

    def test_update_child_both_fields_success(self, client, parent):
        child = create_child(client, parent["token"]).get_json()
        res = client.put(f"/api/children/{child['id']}", headers=auth_header(parent["token"]), json={"name": "Reem", "age": 11})
        assert res.status_code == 200
        assert res.get_json()["name"] == "Reem"
        assert res.get_json()["age"] == 11

    @pytest.mark.parametrize("payload", [{}, None])
    def test_update_child_empty_or_null_body_returns_400(self, client, parent, payload):
        child = create_child(client, parent["token"]).get_json()
        res = client.put(f"/api/children/{child['id']}", headers=auth_header(parent["token"]), json=payload)
        assert res.status_code in (400, 415)

    @pytest.mark.parametrize("name", ["", " ", "A", "x" * 101])
    def test_update_child_invalid_name_returns_400(self, client, parent, name):
        child = create_child(client, parent["token"]).get_json()
        res = client.put(f"/api/children/{child['id']}", headers=auth_header(parent["token"]), json={"name": name})
        assert res.status_code in (400, 415)

    @pytest.mark.parametrize("age", [0, -1, 19, 100])
    def test_update_child_invalid_age_returns_400(self, client, parent, age):
        child = create_child(client, parent["token"]).get_json()
        res = client.put(f"/api/children/{child['id']}", headers=auth_header(parent["token"]), json={"age": age})
        assert res.status_code in (400, 415)

    def test_update_other_parent_child_returns_404(self, client, parent, parent2):
        other = create_child(client, parent2["token"], name="Other", age=7).get_json()
        res = client.put(f"/api/children/{other['id']}", headers=auth_header(parent["token"]), json={"name": "Bad"})
        assert res.status_code == 404

    def test_update_child_token_forbidden(self, client, child_token):
        res = client.put(f"/api/children/{child_token['child']['id']}", headers=auth_header(child_token["token"]), json={"name": "Bad"})
        assert res.status_code == 403


class TestChildDelete:
    def test_delete_child_success(self, client, parent):
        child = create_child(client, parent["token"]).get_json()
        res = client.delete(f"/api/children/{child['id']}", headers=auth_header(parent["token"]))
        assert res.status_code == 200
        get_res = client.get(f"/api/children/{child['id']}", headers=auth_header(parent["token"]))
        assert get_res.status_code == 404

    def test_delete_child_twice_returns_404_second_time(self, client, parent):
        child = create_child(client, parent["token"]).get_json()
        first = client.delete(f"/api/children/{child['id']}", headers=auth_header(parent["token"]))
        second = client.delete(f"/api/children/{child['id']}", headers=auth_header(parent["token"]))
        assert first.status_code == 200
        assert second.status_code == 404

    def test_delete_other_parent_child_returns_404(self, client, parent, parent2):
        other = create_child(client, parent2["token"], name="Other", age=7).get_json()
        res = client.delete(f"/api/children/{other['id']}", headers=auth_header(parent["token"]))
        assert res.status_code == 404

    def test_delete_child_token_forbidden(self, client, child_token):
        res = client.delete(f"/api/children/{child_token['child']['id']}", headers=auth_header(child_token["token"]))
        assert res.status_code == 403
