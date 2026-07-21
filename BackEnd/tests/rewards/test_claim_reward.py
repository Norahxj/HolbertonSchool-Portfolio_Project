import pytest
from sqlalchemy.exc import IntegrityError

from app.routes import reward_routes
import app.repositories.reward_repository as reward_repository_module


REGISTER_URL="/api/auth/register"
CHILDREN_URL="/api/children/"
CHILD_LOGIN_URL="/api/auth/child-login"


def auth_header(token):
    return {"Authorization": token}


def register_parent(client,email="claim.reward@gmail.com",phone="0557800001"):
    r=client.post(REGISTER_URL,json={
        "first_name":"Manar",
        "last_name":"Zaid",
        "phone":phone,
        "email":email,
        "password":"Password123!",
        "guardian_type":"mother",
    })
    assert r.status_code==201
    return r.get_json()


def create_child(client,token,phone="0557800099"):
    r=client.post(CHILDREN_URL,headers=auth_header(token),json={
        "name":"Sara",
        "birth_date":"2015-05-10",
        "phone":phone,
    })
    assert r.status_code==201
    d=r.get_json()
    return d.get("child",d)


def login_child(client,code):
    r=client.post(CHILD_LOGIN_URL,json={"access_code":code})
    assert r.status_code==200
    return r.get_json()


def claim(client,token,reward_id):
    return client.put(f"/api/rewards/{reward_id}/claim",headers=auth_header(token))


# ---------------- Route ----------------

def test_requires_token(client):
    assert client.put("/api/rewards/x/claim").status_code==401


def test_parent_forbidden(client):
    p=register_parent(client)
    r=claim(client,p["access_token"],"x")
    assert r.status_code==403
    assert r.get_json()=={"error":"Child access required"}


def test_reward_not_found(client,monkeypatch):
    p=register_parent(client)
    c=create_child(client,p["access_token"])
    ch=login_child(client,c["access_code"])
    monkeypatch.setattr(reward_routes.reward_service,"claim_reward",lambda rid,cid:(None,"reward_not_found"))
    r=claim(client,ch["access_token"],"x")
    assert r.status_code==404


def test_reward_not_unlocked(client,monkeypatch):
    p=register_parent(client)
    c=create_child(client,p["access_token"])
    ch=login_child(client,c["access_code"])
    monkeypatch.setattr(reward_routes.reward_service,"claim_reward",lambda rid,cid:(None,"reward_not_unlocked"))
    r=claim(client,ch["access_token"],"x")
    assert r.status_code==400
    assert r.get_json()=={"error":"Reward is not unlocked yet"}


@pytest.mark.parametrize("err",["update_failed","unexpected"])
def test_other_errors_return_500(client,monkeypatch,err):
    p=register_parent(client)
    c=create_child(client,p["access_token"])
    ch=login_child(client,c["access_code"])
    monkeypatch.setattr(reward_routes.reward_service,"claim_reward",lambda rid,cid:(None,err))
    r=claim(client,ch["access_token"],"x")
    assert r.status_code==500


def test_success(client,monkeypatch):
    p=register_parent(client)
    c=create_child(client,p["access_token"])
    ch=login_child(client,c["access_code"])

    class Reward:
        id="r"
        child_id="c"
        reward_name="هدية"
        description=None
        status="CLAIMED"
        unlock_day=3
        assigned_by="p"
        created_at=None

    monkeypatch.setattr(reward_routes.reward_service,"claim_reward",lambda rid,cid:(Reward(),None))
    monkeypatch.setattr(reward_routes.reward_response_schema,"dump",lambda r:{"id":r.id,"status":r.status})
    r=claim(client,ch["access_token"],"r")
    assert r.status_code==200
    assert r.get_json()=={"id":"r","status":"CLAIMED"}


# ---------------- Service ----------------

class FakeReward:
    def __init__(self,status="UNLOCKED",child_id="child"):
        self.status=status
        self.child_id=child_id


def test_service_reward_missing(monkeypatch):
    s=reward_routes.reward_service
    monkeypatch.setattr(s.reward_repository,"get_reward_by_id",lambda rid:None)
    assert s.claim_reward("r","c")== (None,"reward_not_found")


def test_service_wrong_child(monkeypatch):
    s=reward_routes.reward_service
    monkeypatch.setattr(s.reward_repository,"get_reward_by_id",lambda rid:FakeReward(child_id="other"))
    assert s.claim_reward("r","child")== (None,"reward_not_found")


@pytest.mark.parametrize("status",["LOCKED","CLAIMED"])
def test_service_requires_unlocked(monkeypatch,status):
    s=reward_routes.reward_service
    monkeypatch.setattr(s.reward_repository,"get_reward_by_id",lambda rid:FakeReward(status=status))
    assert s.claim_reward("r","child")== (None,"reward_not_unlocked")


def test_service_success(monkeypatch):
    s=reward_routes.reward_service
    reward=FakeReward()
    monkeypatch.setattr(s.reward_repository,"get_reward_by_id",lambda rid:reward)
    monkeypatch.setattr(s.reward_repository,"update_reward",lambda:(True,None))
    result,error=s.claim_reward("r","child")
    assert error is None
    assert result is reward
    assert reward.status=="CLAIMED"


def test_service_update_failure(monkeypatch):
    s=reward_routes.reward_service
    reward=FakeReward()
    monkeypatch.setattr(s.reward_repository,"get_reward_by_id",lambda rid:reward)
    monkeypatch.setattr(s.reward_repository,"update_reward",lambda:(False,"integrity_error"))
    assert s.claim_reward("r","child")== (None,"update_failed")


# ---------------- Repository ----------------

def test_repository_commit(app,monkeypatch):
    repo=reward_routes.reward_service.reward_repository
    calls={"commit":0,"rollback":0}
    with app.app_context():
        monkeypatch.setattr(reward_repository_module.db.session,"commit",lambda:calls.__setitem__("commit",1))
        monkeypatch.setattr(reward_repository_module.db.session,"rollback",lambda:calls.__setitem__("rollback",1))
        assert repo.update_reward()==(True,None)
    assert calls=={"commit":1,"rollback":0}


def test_repository_integrity_error(app,monkeypatch):
    repo=reward_routes.reward_service.reward_repository
    calls={"rollback":0}
    err=IntegrityError("stmt",{},Exception("db"))
    def bad():
        raise err
    with app.app_context():
        monkeypatch.setattr(reward_repository_module.db.session,"commit",bad)
        monkeypatch.setattr(reward_repository_module.db.session,"rollback",lambda:calls.__setitem__("rollback",1))
        assert repo.update_reward()==(False,"integrity_error")
    assert calls["rollback"]==1