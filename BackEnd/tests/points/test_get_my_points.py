import pytest
from flask_jwt_extended import decode_token

from app.routes import points_routes

REGISTER_URL="/api/auth/register"
CHILDREN_URL="/api/children/"
CHILD_LOGIN_URL="/api/auth/child-login"
MY_POINTS_URL="/api/points/my"

def auth_header(token):
    return {"Authorization":token}

def register_parent(client,email="my.points@gmail.com",phone="0557910001"):
    r=client.post(REGISTER_URL,json={
        "first_name":"Manar","last_name":"Zaid",
        "phone":phone,"email":email,
        "password":"Password123!","guardian_type":"mother"
    })
    assert r.status_code==201
    return r.get_json()

def create_child(client,token,phone="0557910099"):
    r=client.post("/api/children/",headers=auth_header(token),json={
        "name":"Sara","birth_date":"2015-05-10","phone":phone
    })
    assert r.status_code==201
    d=r.get_json()
    return d.get("child",d)

def child_login(client,code):
    r=client.post(CHILD_LOGIN_URL,json={"access_code":code})
    assert r.status_code==200
    return r.get_json()

def my_points(client,token):
    return client.get(MY_POINTS_URL,headers=auth_header(token))

# ---------- Route ----------

def test_requires_token(client):
    assert client.get(MY_POINTS_URL).status_code==401

@pytest.mark.parametrize("token",["bad","abc.def","abc.def.ghi"])
def test_invalid_token(client,token):
    assert client.get(MY_POINTS_URL,headers=auth_header(token)).status_code in (401,422)

def test_parent_forbidden(client):
    p=register_parent(client)
    r=my_points(client,p["access_token"])
    assert r.status_code==403
    assert r.get_json()=={"error":"Child access required"}

def test_passes_child_id_to_service(client,app,monkeypatch):
    p=register_parent(client)
    c=create_child(client,p["access_token"])
    ch=child_login(client,c["access_code"])
    with app.app_context():
        expected=decode_token(ch["access_token"])["sub"]
    captured={}
    monkeypatch.setattr(points_routes.points_service,"get_child_points",lambda cid:(captured.setdefault("id",cid) or object(),None))
    monkeypatch.setattr(points_routes.points_response_schema,"dump",lambda obj:{"child_id":expected,"total_points":0})
    r=my_points(client,ch["access_token"])
    assert r.status_code==200
    assert captured["id"]==expected

def test_child_not_found(client,monkeypatch):
    p=register_parent(client)
    c=create_child(client,p["access_token"])
    ch=child_login(client,c["access_code"])
    monkeypatch.setattr(points_routes.points_service,"get_child_points",lambda cid:(None,"child_not_found"))
    r=my_points(client,ch["access_token"])
    assert r.status_code==404

@pytest.mark.parametrize("err",["create_failed","unexpected"])
def test_other_errors(client,monkeypatch,err):
    p=register_parent(client)
    c=create_child(client,p["access_token"])
    ch=child_login(client,c["access_code"])
    monkeypatch.setattr(points_routes.points_service,"get_child_points",lambda cid:(None,err))
    r=my_points(client,ch["access_token"])
    assert r.status_code==500

def test_no_serialization_on_error(client,monkeypatch):
    p=register_parent(client)
    c=create_child(client,p["access_token"])
    ch=child_login(client,c["access_code"])
    called={"x":0}
    monkeypatch.setattr(points_routes.points_service,"get_child_points",lambda cid:(None,"create_failed"))
    monkeypatch.setattr(points_routes.points_response_schema,"dump",lambda obj:called.__setitem__("x",1))
    r=my_points(client,ch["access_token"])
    assert r.status_code==500
    assert called["x"]==0

def test_serializes_response(client,monkeypatch):
    p=register_parent(client)
    c=create_child(client,p["access_token"])
    ch=child_login(client,c["access_code"])
    pts=object()
    monkeypatch.setattr(points_routes.points_service,"get_child_points",lambda cid:(pts,None))
    monkeypatch.setattr(points_routes.points_response_schema,"dump",lambda obj:{"child_id":"c","total_points":99})
    r=my_points(client,ch["access_token"])
    assert r.status_code==200
    assert r.get_json()=={"child_id":"c","total_points":99}

# ---------- Service ----------

class FakeChild:
    pass

class FakePoints:
    def __init__(self):
        self.child_id="child"
        self.total_points=0

def test_service_child_missing(monkeypatch):
    s=points_routes.points_service
    monkeypatch.setattr(s.child_repository,"get_child_by_id",lambda cid:None)
    assert s.get_child_points("c")== (None,"child_not_found")

def test_service_returns_existing_points(monkeypatch):
    s=points_routes.points_service
    pts=FakePoints()
    monkeypatch.setattr(s.child_repository,"get_child_by_id",lambda cid:FakeChild())
    monkeypatch.setattr(s.point_repository,"get_points_by_child_id",lambda cid:pts)
    result,error=s.get_child_points("c")
    assert error is None
    assert result is pts

def test_service_creates_points_when_missing(monkeypatch):
    s=points_routes.points_service
    monkeypatch.setattr(s.child_repository,"get_child_by_id",lambda cid:FakeChild())
    monkeypatch.setattr(s.point_repository,"get_points_by_child_id",lambda cid:None)
    captured={}
    def fake_create(record,commit=True):
        captured["commit"]=commit
        return record,None
    monkeypatch.setattr(s.point_repository,"create_points_record",fake_create)
    result,error=s.get_child_points("child")
    assert error is None
    assert result.total_points==0
    assert captured["commit"] is True

def test_service_commit_false(monkeypatch):
    s=points_routes.points_service
    monkeypatch.setattr(s.child_repository,"get_child_by_id",lambda cid:FakeChild())
    monkeypatch.setattr(s.point_repository,"get_points_by_child_id",lambda cid:None)
    captured={}
    monkeypatch.setattr(s.point_repository,"create_points_record",lambda rec,commit=True:(captured.setdefault("commit",commit) or rec,None))
    s.get_child_points("child",commit=False)
    assert captured["commit"] is False

def test_service_create_failed(monkeypatch):
    s=points_routes.points_service
    monkeypatch.setattr(s.child_repository,"get_child_by_id",lambda cid:FakeChild())
    monkeypatch.setattr(s.point_repository,"get_points_by_child_id",lambda cid:None)
    monkeypatch.setattr(s.point_repository,"create_points_record",lambda rec,commit=True:(None,"integrity_error"))
    assert s.get_child_points("child")== (None,"create_failed")