import pytest
from flask_jwt_extended import decode_token

from app.routes import task_routes

TASK_URL="/api/tasks/{}"
REGISTER_URL="/api/auth/register"
CHILD_LOGIN_URL="/api/auth/child-login"

def auth(t): return {"Authorization":t}

def register_parent(client,email="taskgetone@gmail.com",phone="0551234567"):
    r=client.post(REGISTER_URL,json={
        "first_name":"Manar","last_name":"Zaid",
        "phone":phone,"email":email,
        "password":"Password123!","guardian_type":"mother"})
    assert r.status_code==201
    return r.get_json()

def test_requires_token(client):
    assert client.get(TASK_URL.format("1")).status_code==401

@pytest.mark.parametrize("token",["bad","abc.def","abc.def.ghi"])
def test_invalid_token(client,token):
    r=client.get(TASK_URL.format("1"),headers=auth(token))
    assert r.status_code in (401,422)

def test_child_forbidden(client):
    parent=register_parent(client)
    child=client.post("/api/children/",headers=auth(parent["access_token"]),json={
        "name":"Sara","birth_date":"2015-05-10","phone":"0558888888"}).get_json()
    if "child" in child: child=child["child"]
    login=client.post(CHILD_LOGIN_URL,json={"access_code":child["access_code"]})
    r=client.get(TASK_URL.format("1"),headers=auth(login.get_json()["access_token"]))
    assert r.status_code==403
    assert r.get_json()=={"error":"Parent access required"}

def test_not_found(client,monkeypatch):
    parent=register_parent(client)
    monkeypatch.setattr(task_routes.task_service,"get_task_for_parent",lambda tid,pid:None)
    r=client.get(TASK_URL.format("missing"),headers=auth(parent["access_token"]))
    assert r.status_code==404
    assert r.get_json()=={"error":"Task not found"}

def test_route_passes_ids(client,app,monkeypatch):
    parent=register_parent(client,email="a@gmail.com",phone="0551111111")
    cap={}
    with app.app_context():
        pid=decode_token(parent["access_token"])["sub"]
    class T:
        id="1";title="Task";description="Desc";points=10
        task_frequency="ONCE";recurrence_day=None
        category="MORAL";is_auto_verified=False
        created_by=pid;created_at=None
    def fake(tid,parent_id):
        cap["tid"]=tid;cap["pid"]=parent_id
        return T()
    monkeypatch.setattr(task_routes.task_service,"get_task_for_parent",fake)
    r=client.get(TASK_URL.format("task123"),headers=auth(parent["access_token"]))
    assert r.status_code==200
    assert cap=={"tid":"task123","pid":pid}

def test_serialization(client,monkeypatch):
    parent=register_parent(client,email="c@gmail.com",phone="0552222222")
    class T:
        id="7";title="Clean";description="Room";points=5
        task_frequency="WEEKLY";recurrence_day=2
        category="SOCIAL";is_auto_verified=True
        created_by="p";created_at=None
    monkeypatch.setattr(task_routes.task_service,"get_task_for_parent",lambda tid,pid:T())
    data=client.get(TASK_URL.format("7"),headers=auth(parent["access_token"])).get_json()
    assert data=={
        "id":"7","title":"Clean","description":"Room","points":5,
        "task_frequency":"WEEKLY","recurrence_day":2,
        "category":"SOCIAL","is_auto_verified":True,
        "created_by":"p","created_at":None
    }

def test_service_passes_arguments(monkeypatch):
    service=task_routes.task_service
    cap={}
    obj=object()
    def fake(tid,pid):
        cap["tid"]=tid;cap["pid"]=pid
        return obj
    monkeypatch.setattr(service.task_repository,"get_task_for_guardian_children",fake)
    assert service.get_task_for_parent("t1","p1") is obj
    assert cap=={"tid":"t1","pid":"p1"}