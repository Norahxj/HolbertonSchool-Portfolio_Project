import pytest
from flask_jwt_extended import decode_token

from app.routes import wishlist_routes
import app.services.wishlist_service as wishlist_service_module

REGISTER_URL="/api/auth/register"
CHILDREN_URL="/api/children/"
CHILD_LOGIN_URL="/api/auth/child-login"

def authorization_header(t): return {"Authorization": t}
def url(w): return f"/api/wishlists/{w}"

def register_parent(client,email="deletewish@gmail.com",phone="0556600001"):
    r=client.post(REGISTER_URL,json={"first_name":"Manar","last_name":"Zaid","phone":phone,"email":email,"password":"Password123!","guardian_type":"mother"})
    assert r.status_code==201
    return r.get_json()

def create_child(client,token,phone="0556600099"):
    r=client.post(CHILDREN_URL,headers=authorization_header(token),json={"name":"Sara","birth_date":"2015-05-10","phone":phone})
    assert r.status_code==201
    d=r.get_json()
    return d.get("child",d)

def login_child(client,code):
    r=client.post(CHILD_LOGIN_URL,json={"access_code":code})
    assert r.status_code==200
    return r.get_json()

def req(client,token,w):
    return client.delete(url(w),headers=authorization_header(token))

def test_requires_token(client):
    assert client.delete(url("x")).status_code==401

@pytest.mark.parametrize("tok",["bad","a.b","a.b.c"])
def test_invalid_token(client,tok):
    assert client.delete(url("x"),headers=authorization_header(tok)).status_code in (401,422)

def test_parent_forbidden(client):
    p=register_parent(client)
    r=req(client,p["access_token"],"x")
    assert r.status_code==403
    assert r.get_json()=={"error":"Child access required"}

def test_route_passes_ids(client,app,monkeypatch):
    p=register_parent(client)
    c=create_child(client,p["access_token"])
    l=login_child(client,c["access_code"])
    with app.app_context():
        cid=decode_token(l["access_token"])["sub"]
    cap={}
    def fake(w,cid2):
        cap["w"]=w;cap["c"]=cid2
        return True,None
    monkeypatch.setattr(wishlist_routes.wishlist_service,"delete_wish",fake)
    r=req(client,l["access_token"],"wish1")
    assert r.status_code==200
    assert cap=={"w":"wish1","c":cid}

@pytest.mark.parametrize("err,status,body",[
("wish_not_found",404,{"error":"Wish not found"}),
("wish_cannot_be_deleted",400,{"error":"Only pending or rejected wishes can be deleted"}),
("delete_error",500,{"error":"Failed to delete wish"})
])
def test_route_maps_errors(client,monkeypatch,err,status,body):
    p=register_parent(client);c=create_child(client,p["access_token"]);l=login_child(client,c["access_code"])
    monkeypatch.setattr(wishlist_routes.wishlist_service,"delete_wish",lambda w,c:(False,err))
    r=req(client,l["access_token"],"x")
    assert r.status_code==status
    assert r.get_json()==body

def test_route_success(client,monkeypatch):
    p=register_parent(client);c=create_child(client,p["access_token"]);l=login_child(client,c["access_code"])
    monkeypatch.setattr(wishlist_routes.wishlist_service,"delete_wish",lambda w,c:(True,None))
    r=req(client,l["access_token"],"x")
    assert r.status_code==200
    assert r.get_json()=={"message":"Wish deleted successfully"}

class Wish:
    def __init__(self,status="PENDING"):
        self.status=status

def test_service_passes_ids(monkeypatch):
    s=wishlist_routes.wishlist_service
    cap={}
    def fake(w,c):
        cap["w"]=w;cap["c"]=c
        return None
    monkeypatch.setattr(s.wishlist_repository,"get_wish_for_child_for_update",fake)
    monkeypatch.setattr(wishlist_service_module.db.session,"rollback",lambda:None)
    assert s.delete_wish("w","c")== (False,"wish_not_found")
    assert cap=={"w":"w","c":"c"}

def test_service_not_found(monkeypatch):
    s=wishlist_routes.wishlist_service
    n={"i":0}
    monkeypatch.setattr(s.wishlist_repository,"get_wish_for_child_for_update",lambda w,c:None)
    monkeypatch.setattr(wishlist_service_module.db.session,"rollback",lambda:n.__setitem__("i",n["i"]+1))
    assert s.delete_wish("w","c")== (False,"wish_not_found")
    assert n["i"]==1

@pytest.mark.parametrize("status",["APPROVED","ACHIEVED"])
def test_service_invalid_status(monkeypatch,status):
    s=wishlist_routes.wishlist_service
    n={"i":0}
    monkeypatch.setattr(s.wishlist_repository,"get_wish_for_child_for_update",lambda w,c:Wish(status))
    monkeypatch.setattr(wishlist_service_module.db.session,"rollback",lambda:n.__setitem__("i",n["i"]+1))
    assert s.delete_wish("w","c")== (False,"wish_cannot_be_deleted")
    assert n["i"]==1

@pytest.mark.parametrize("status",["PENDING","REJECTED"])
def test_service_allowed_status(monkeypatch,status):
    s=wishlist_routes.wishlist_service
    wish=Wish(status)
    cap={}
    monkeypatch.setattr(s.wishlist_repository,"get_wish_for_child_for_update",lambda w,c:wish)
    def fake_delete(obj):
        cap["wish"]=obj
        return True,None
    monkeypatch.setattr(s.wishlist_repository,"delete_wish",fake_delete)
    ok,err=s.delete_wish("w","c")
    assert ok is True and err is None
    assert cap["wish"] is wish

def test_service_delete_fail(monkeypatch):
    s=wishlist_routes.wishlist_service
    monkeypatch.setattr(s.wishlist_repository,"get_wish_for_child_for_update",lambda w,c:Wish())
    monkeypatch.setattr(s.wishlist_repository,"delete_wish",lambda w:(False,"x"))
    assert s.delete_wish("w","c")== (False,"delete_error")

def test_service_exception(monkeypatch):
    s=wishlist_routes.wishlist_service
    n={"i":0}
    monkeypatch.setattr(s.wishlist_repository,"get_wish_for_child_for_update",lambda w,c:(_ for _ in ()).throw(RuntimeError()))
    monkeypatch.setattr(wishlist_service_module.db.session,"rollback",lambda:n.__setitem__("i",n["i"]+1))
    assert s.delete_wish("w","c")== (False,"delete_error")
    assert n["i"]==1