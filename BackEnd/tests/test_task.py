import pytest

from conftest import auth_header, assert_json_has_error_or_message, create_child, create_task


VALID_CATEGORIES = ["RELIGIOUS", "FINANCIAL", "MORAL", "SOCIAL"]
VALID_FREQUENCIES = ["ONCE", "DAILY", "WEEKLY", "MONTHLY"]


class TestTaskCreate:
    def test_create_task_once_success(self, client, parent, child):
        res = create_task(client, parent["token"], [child["id"]], task_frequency="ONCE", recurrence_day=None)
        assert res.status_code == 201
        data = res.get_json()
        assert data["title"] == "Clean Room"
        assert data["points"] == 10
        assert data["task_frequency"] == "ONCE"
        assert data["recurrence_day"] is None
        assert data["created_by"] == parent["user"]["id"]

    def test_create_task_daily_success(self, client, parent, child):
        res = create_task(client, parent["token"], [child["id"]], task_frequency="DAILY", recurrence_day=None)
        assert res.status_code == 201
        assert res.get_json()["task_frequency"] == "DAILY"

    @pytest.mark.parametrize("frequency,recurrence_day", [
        ("WEEKLY", 0), ("WEEKLY", 1), ("WEEKLY", 6),
        ("MONTHLY", 1), ("MONTHLY", 15), ("MONTHLY", 31),
    ])
    def test_create_task_recurrence_success_cases(self, client, parent, child, frequency, recurrence_day):
        res = create_task(client, parent["token"], [child["id"]], task_frequency=frequency, recurrence_day=recurrence_day)
        assert res.status_code == 201
        assert res.get_json()["task_frequency"] == frequency
        assert res.get_json()["recurrence_day"] == recurrence_day

    @pytest.mark.parametrize("frequency,recurrence_day", [
        ("ONCE", 1), ("DAILY", 1),
        ("WEEKLY", None), ("WEEKLY", -1), ("WEEKLY", 7),
        ("MONTHLY", None), ("MONTHLY", 0), ("MONTHLY", 32),
    ])
    def test_create_task_invalid_recurrence_cases_return_400(self, client, parent, child, frequency, recurrence_day):
        res = create_task(client, parent["token"], [child["id"]], task_frequency=frequency, recurrence_day=recurrence_day)
        assert res.status_code in (400, 415)

    @pytest.mark.parametrize("category", VALID_CATEGORIES)
    def test_create_task_valid_categories(self, client, parent, child, category):
        res = create_task(client, parent["token"], [child["id"]], category=category)
        assert res.status_code == 201
        assert res.get_json()["category"] == category

    @pytest.mark.parametrize("category", ["", "BAD", "religious", "EDUCATION", None])
    def test_create_task_invalid_category_returns_400(self, client, parent, child, category):
        res = create_task(client, parent["token"], [child["id"]], category=category)
        assert res.status_code in (400, 415)

    @pytest.mark.parametrize("points", [1, 2, 50, 100])
    def test_create_task_valid_points_boundaries(self, client, parent, child, points):
        res = create_task(client, parent["token"], [child["id"]], points=points)
        assert res.status_code == 201
        assert res.get_json()["points"] == points

    @pytest.mark.parametrize("points", [0, -1, 101, 1000, None])
    def test_create_task_invalid_points_returns_400(self, client, parent, child, points):
        res = create_task(client, parent["token"], [child["id"]], points=points)
        assert res.status_code in (400, 415)

    @pytest.mark.parametrize("title", ["", " ", "A", "x" * 101])
    def test_create_task_invalid_title_returns_400(self, client, parent, child, title):
        res = create_task(client, parent["token"], [child["id"]], title=title)
        assert res.status_code in (400, 415)

    @pytest.mark.parametrize("description", ["", " ", "A", "x" * 501])
    def test_create_task_invalid_description_returns_400(self, client, parent, child, description):
        res = create_task(client, parent["token"], [child["id"]], description=description)
        assert res.status_code in (400, 415)

    @pytest.mark.parametrize("title,description", [
        ("صلاة الفجر", "أداء صلاة الفجر في وقتها"),
        ("Save Money", "Put 5 riyals in savings"),
        ("Help 😊", "Help family at home"),
        ("<script>alert(1)</script>", "Description is stored as plain text"),
        ("' OR 1=1 --", "SQL-like text should not execute"),
    ])
    def test_create_task_unusual_text_does_not_break_api(self, client, parent, child, title, description):
        res = create_task(client, parent["token"], [child["id"]], title=title, description=description)
        assert res.status_code in (201, 400)

    def test_create_task_trims_title_and_description(self, client, parent, child):
        res = create_task(client, parent["token"], [child["id"]], title="  Title  ", description="  Desc  ")
        assert res.status_code == 201
        assert res.get_json()["title"] == "Title"
        assert res.get_json()["description"] == "Desc"

    @pytest.mark.parametrize("is_auto_verified", [True, False])
    def test_create_task_auto_verified_boolean(self, client, parent, child, is_auto_verified):
        res = create_task(client, parent["token"], [child["id"]], is_auto_verified=is_auto_verified)
        assert res.status_code == 201
        assert res.get_json()["is_auto_verified"] is is_auto_verified

    def test_create_task_defaults_frequency_and_auto_verified_when_omitted(self, client, parent, child):
        payload = {
            "child_ids": [child["id"]],
            "title": "Default Task",
            "description": "Default values",
            "points": 10,
            "category": "MORAL",
        }
        res = client.post("/api/tasks/", headers=auth_header(parent["token"]), json=payload)
        assert res.status_code == 201
        data = res.get_json()
        assert data["task_frequency"] == "ONCE"
        assert data["is_auto_verified"] is False

    @pytest.mark.parametrize("payload", [
        {}, None,
        {"title": "Task", "description": "Desc", "points": 10, "category": "MORAL"},
        {"child_ids": [], "title": "Task", "description": "Desc", "points": 10, "category": "MORAL"},
        {"child_ids": ["missing"], "title": "Task", "description": "Desc", "points": 10, "category": "MORAL"},
    ])
    def test_create_task_missing_or_bad_child_ids_return_error(self, client, parent, payload):
        res = client.post("/api/tasks/", headers=auth_header(parent["token"]), json=payload)
        assert res.status_code in (400, 404, 415)

    def test_create_task_for_multiple_children_success(self, client, parent):
        c1 = create_child(client, parent["token"], name="Ali", age=8).get_json()
        c2 = create_child(client, parent["token"], name="sara", age=9).get_json()
        res = create_task(client, parent["token"], [c1["id"], c2["id"]])
        assert res.status_code == 201

    def test_create_task_for_other_parent_child_returns_404(self, client, parent, parent2):
        other_child = create_child(client, parent2["token"], name="Other", age=8).get_json()
        res = create_task(client, parent["token"], [other_child["id"]])
        assert res.status_code == 404

    def test_create_task_mixed_own_and_other_child_returns_404(self, client, parent, parent2, child):
        other_child = create_child(client, parent2["token"], name="Other", age=8).get_json()
        res = create_task(client, parent["token"], [child["id"], other_child["id"]])
        assert res.status_code == 404

    @pytest.mark.parametrize("payload", [
        {"child_ids": "not-list", "title": "Task", "description": "Desc", "points": 10, "category": "MORAL"},
        {"child_ids": [123], "title": "Task", "description": "Desc", "points": 10, "category": "MORAL"},
        {"child_ids": [], "title": 123, "description": "Desc", "points": 10, "category": "MORAL"},
        {"child_ids": [], "title": "Task", "description": 123, "points": 10, "category": "MORAL"},
        {"child_ids": [], "title": "Task", "description": "Desc", "points": "ten", "category": "MORAL"},
    ])
    def test_create_task_wrong_types_return_400(self, client, parent, payload):
        res = client.post("/api/tasks/", headers=auth_header(parent["token"]), json=payload)
        assert res.status_code in (400, 415)

    def test_create_task_missing_token_returns_400_or_401(self, client, child):
        res = create_task(client, "", [child["id"]])
        assert res.status_code in (400, 401, 422)

    def test_create_task_child_token_forbidden(self, client, child_token):
        res = create_task(client, child_token["token"], [child_token["child"]["id"]])
        assert res.status_code == 403


class TestTaskRead:
    def test_get_tasks_empty_list(self, client, parent):
        res = client.get("/api/tasks/", headers=auth_header(parent["token"]))
        assert res.status_code == 200
        assert res.get_json() == []

    def test_get_tasks_returns_current_parent_tasks_only(self, client, parent, parent2):
        own_child = create_child(client, parent["token"], name="Own", age=8).get_json()
        other_child = create_child(client, parent2["token"], name="Other", age=8).get_json()
        own_task = create_task(client, parent["token"], [own_child["id"]]).get_json()
        create_task(client, parent2["token"], [other_child["id"]])
        res = client.get("/api/tasks/", headers=auth_header(parent["token"]))
        assert res.status_code == 200
        ids = [item["id"] for item in res.get_json()]
        assert ids == [own_task["id"]]

    def test_get_task_by_id_success(self, client, parent, task):
        res = client.get(f"/api/tasks/{task['id']}", headers=auth_header(parent["token"]))
        assert res.status_code == 200
        assert res.get_json()["id"] == task["id"]

    @pytest.mark.parametrize("task_id", ["missing", "123", "00000000-0000-0000-0000-000000000000"])
    def test_get_task_missing_or_invalid_id_returns_404(self, client, parent, task_id):
        res = client.get(f"/api/tasks/{task_id}", headers=auth_header(parent["token"]))
        assert res.status_code == 404

    def test_parent_cannot_get_other_parent_task(self, client, parent, parent2):
        other_child = create_child(client, parent2["token"], name="Other", age=8).get_json()
        other_task = create_task(client, parent2["token"], [other_child["id"]]).get_json()
        res = client.get(f"/api/tasks/{other_task['id']}", headers=auth_header(parent["token"]))
        assert res.status_code == 404

    def test_get_tasks_by_child_success(self, client, parent, child):
        t1 = create_task(client, parent["token"], [child["id"]], title="T1").get_json()
        t2 = create_task(client, parent["token"], [child["id"]], title="T2").get_json()
        res = client.get(f"/api/tasks/child/{child['id']}", headers=auth_header(parent["token"]))
        assert res.status_code == 200
        ids = {item["id"] for item in res.get_json()}
        assert {t1["id"], t2["id"]}.issubset(ids)

    def test_get_tasks_by_other_parent_child_returns_404(self, client, parent, parent2):
        other_child = create_child(client, parent2["token"], name="Other", age=8).get_json()
        res = client.get(f"/api/tasks/child/{other_child['id']}", headers=auth_header(parent["token"]))
        assert res.status_code == 404

    def test_child_token_cannot_read_tasks_parent_routes(self, client, child_token):
        res = client.get("/api/tasks/", headers=auth_header(child_token["token"]))
        assert res.status_code == 403


class TestTaskUpdate:
    def test_update_task_title_description_points_success(self, client, parent, task):
        res = client.put(f"/api/tasks/{task['id']}", headers=auth_header(parent["token"]), json={
            "title": "New Title",
            "description": "New Description",
            "points": 20,
        })
        assert res.status_code == 200
        data = res.get_json()
        assert data["title"] == "New Title"
        assert data["description"] == "New Description"
        assert data["points"] == 20

    def test_update_task_trims_strings(self, client, parent, task):
        res = client.put(f"/api/tasks/{task['id']}", headers=auth_header(parent["token"]), json={"title": "  New  ", "description": "  Desc  "})
        assert res.status_code == 200
        assert res.get_json()["title"] == "New"
        assert res.get_json()["description"] == "Desc"

    @pytest.mark.parametrize("category", VALID_CATEGORIES)
    def test_update_task_category_valid(self, client, parent, task, category):
        res = client.put(f"/api/tasks/{task['id']}", headers=auth_header(parent["token"]), json={"category": category})
        assert res.status_code == 200
        assert res.get_json()["category"] == category

    @pytest.mark.parametrize("category", ["BAD", "", "religious", None])
    def test_update_task_category_invalid(self, client, parent, task, category):
        res = client.put(f"/api/tasks/{task['id']}", headers=auth_header(parent["token"]), json={"category": category})
        assert res.status_code in (400, 415)

    @pytest.mark.parametrize("points", [1, 50, 100])
    def test_update_task_points_valid(self, client, parent, task, points):
        res = client.put(f"/api/tasks/{task['id']}", headers=auth_header(parent["token"]), json={"points": points})
        assert res.status_code == 200
        assert res.get_json()["points"] == points

    @pytest.mark.parametrize("points", [0, -1, 101, None])
    def test_update_task_points_invalid(self, client, parent, task, points):
        res = client.put(f"/api/tasks/{task['id']}", headers=auth_header(parent["token"]), json={"points": points})
        assert res.status_code in (400, 415)

    @pytest.mark.parametrize("frequency,recurrence_day,expected_status", [
        ("ONCE", None, 200), ("DAILY", None, 200),
        ("WEEKLY", 0, 200), ("WEEKLY", 6, 200),
        ("MONTHLY", 1, 200), ("MONTHLY", 31, 200),
        ("ONCE", 1, 400), ("DAILY", 1, 400),
        ("WEEKLY", None, 400), ("WEEKLY", 7, 400),
        ("MONTHLY", None, 400), ("MONTHLY", 32, 400),
    ])
    def test_update_task_recurrence_rules(self, client, parent, task, frequency, recurrence_day, expected_status):
        res = client.put(f"/api/tasks/{task['id']}", headers=auth_header(parent["token"]), json={
            "task_frequency": frequency,
            "recurrence_day": recurrence_day,
        })
        assert res.status_code == expected_status

    @pytest.mark.parametrize("payload", [{}, None])
    def test_update_task_empty_or_null_body_returns_400(self, client, parent, task, payload):
        res = client.put(f"/api/tasks/{task['id']}", headers=auth_header(parent["token"]), json=payload)
        assert res.status_code in (400, 415)

    @pytest.mark.parametrize("payload", [
        {"title": ""}, {"title": "A"}, {"title": "x" * 101},
        {"description": ""}, {"description": "A"}, {"description": "x" * 501},
        {"task_frequency": "YEARLY"},
        {"is_auto_verified": "not-bool"},
    ])
    def test_update_task_invalid_payloads_return_400(self, client, parent, task, payload):
        res = client.put(f"/api/tasks/{task['id']}", headers=auth_header(parent["token"]), json=payload)
        assert res.status_code in (400, 415)

    def test_update_other_parent_task_returns_404(self, client, parent, parent2):
        other_child = create_child(client, parent2["token"], name="Other", age=8).get_json()
        other_task = create_task(client, parent2["token"], [other_child["id"]]).get_json()
        res = client.put(f"/api/tasks/{other_task['id']}", headers=auth_header(parent["token"]), json={"title": "Bad"})
        assert res.status_code == 404

    def test_update_child_token_forbidden(self, client, child_token, task):
        res = client.put(f"/api/tasks/{task['id']}", headers=auth_header(child_token["token"]), json={"title": "Bad"})
        assert res.status_code == 403


class TestTaskDelete:
    def test_delete_task_success(self, client, parent, task):
        res = client.delete(f"/api/tasks/{task['id']}", headers=auth_header(parent["token"]))
        assert res.status_code == 200
        get_res = client.get(f"/api/tasks/{task['id']}", headers=auth_header(parent["token"]))
        assert get_res.status_code == 404

    def test_delete_task_twice_returns_404_second_time(self, client, parent, task):
        first = client.delete(f"/api/tasks/{task['id']}", headers=auth_header(parent["token"]))
        second = client.delete(f"/api/tasks/{task['id']}", headers=auth_header(parent["token"]))
        assert first.status_code == 200
        assert second.status_code == 404

    def test_delete_other_parent_task_returns_404(self, client, parent, parent2):
        other_child = create_child(client, parent2["token"], name="Other", age=8).get_json()
        other_task = create_task(client, parent2["token"], [other_child["id"]]).get_json()
        res = client.delete(f"/api/tasks/{other_task['id']}", headers=auth_header(parent["token"]))
        assert res.status_code == 404

    def test_delete_child_token_forbidden(self, client, child_token, task):
        res = client.delete(f"/api/tasks/{task['id']}", headers=auth_header(child_token["token"]))
        assert res.status_code == 403

    def test_delete_missing_token_returns_401(self, client, task):
        res = client.delete(f"/api/tasks/{task['id']}")
        assert res.status_code == 401


class TestProtectedRoutesGeneral:
    @pytest.mark.parametrize("method,path,json_body", [
        ("get", "/api/tasks/", None),
        ("post", "/api/tasks/", {}),
        ("get", "/api/tasks/missing", None),
        ("put", "/api/tasks/missing", {}),
        ("delete", "/api/tasks/missing", None),
        ("get", "/api/tasks/child/missing", None),
    ])
    def test_task_routes_without_token_return_400_or_401(self, client, method, path, json_body):
        caller = getattr(client, method)
        res = caller(path, json=json_body) if json_body is not None else caller(path)
        assert res.status_code in (400, 401)
