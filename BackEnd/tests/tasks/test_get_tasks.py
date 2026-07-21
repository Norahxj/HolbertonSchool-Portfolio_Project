import pytest
from flask_jwt_extended import decode_token

from app.routes import task_routes

REGISTER_URL = "/api/auth/register"
CHILD_LOGIN_URL = "/api/auth/child-login"
TASKS_URL = "/api/tasks/"


def auth(token):
    return {"Authorization": token}


def register_parent(client):
    r = client.post("/api/auth/register", json={
        "first_name":"Manar",
        "last_name":"Zaid",
        "phone":"0551234567",
        "email":"tasksget@gmail.com",
        "password":"Password123!",
        "guardian_type":"mother",
    })
    assert r.status_code == 201
    return r.get_json()


def test_get_tasks_requires_token(client):
    r = client.get(TASKS_URL)
    assert r.status_code == 401


@pytest.mark.parametrize("token",[
    "bad-token",
    "abc.def",
    "abc.def.ghi",
])
def test_get_tasks_invalid_token(client,token):
    r=client.get(TASKS_URL,headers=auth(token))
    assert r.status_code in (401,422)


def test_child_token_cannot_get_tasks(client):
    parent=register_parent(client)

    child=client.post("/api/children/",
        headers=auth(parent["access_token"]),
        json={
            "name":"Sara",
            "birth_date":"2015-05-10",
            "phone":"0559999999",
        }).get_json()

    if "child" in child:
        child=child["child"]

    login=client.post(CHILD_LOGIN_URL,json={"access_code":child["access_code"]})
    assert login.status_code==200

    r=client.get(TASKS_URL,headers=auth(login.get_json()["access_token"]))
    assert r.status_code==403
    assert r.get_json()=={"error":"Parent access required"}


def test_get_tasks_returns_empty_list(client):
    parent=register_parent(client)
    r=client.get(TASKS_URL,headers=auth(parent["access_token"]))
    assert r.status_code==200
    assert r.get_json()==[]


def test_route_passes_parent_id_to_service(client,app,monkeypatch):
    parent=register_parent(client)
    captured={}

    with app.app_context():
        expected=decode_token(parent["access_token"])["sub"]

    def fake(parent_id):
        captured["parent_id"]=parent_id
        return []

    monkeypatch.setattr(task_routes.task_service,"get_tasks_for_parent",fake)

    r=client.get(TASKS_URL,headers=auth(parent["access_token"]))
    assert r.status_code==200
    assert captured["parent_id"]==expected
    assert r.get_json()==[]


def test_route_serializes_service_result(client,monkeypatch):
    parent=register_parent(client)

    class FakeTask:
        id="1"
        title="Task"
        description="Desc"
        points=10
        task_frequency="ONCE"
        recurrence_day=None
        category="MORAL"
        is_auto_verified=False
        created_by="parent"
        created_at=None

    monkeypatch.setattr(
        task_routes.task_service,
        "get_tasks_for_parent",
        lambda parent_id:[FakeTask()]
    )

    r=client.get(TASKS_URL,headers=auth(parent["access_token"]))
    data=r.get_json()

    assert r.status_code==200
    assert len(data)==1
    assert data[0]["title"]=="Task"
    assert data[0]["task_frequency"]=="ONCE"
    assert data[0]["category"]=="MORAL"


def test_service_returns_repository_result(monkeypatch):
    service=task_routes.task_service
    fake=[object(),object()]

    monkeypatch.setattr(
        service.task_repository,
        "get_tasks_for_guardian_children",
        lambda parent_id:fake
    )

    result=service.get_tasks_for_parent("parent-id")
    assert result is fake


def test_service_passes_parent_id(monkeypatch):
    service=task_routes.task_service
    captured={}

    def fake(parent_id):
        captured["parent_id"]=parent_id
        return []

    monkeypatch.setattr(
        service.task_repository,
        "get_tasks_for_guardian_children",
        fake
    )

    service.get_tasks_for_parent("abc")
    assert captured["parent_id"]=="abc"