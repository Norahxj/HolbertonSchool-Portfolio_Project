import pytest
from sqlalchemy.exc import SQLAlchemyError

from app.routes import reward_routes
import app.repositories.reward_repository as reward_repository_module


REGISTER_URL = "/api/auth/register"
CHILDREN_URL = "/api/children/"
CHILD_LOGIN_URL = "/api/auth/child-login"


def auth_header(token):
    return {"Authorization": token}


def register_parent(client, email="delete.reward@gmail.com", phone="0557700001"):
    r = client.post(
        REGISTER_URL,
        json={
            "first_name":"Manar",
            "last_name":"Zaid",
            "phone":phone,
            "email":email,
            "password":"Password123!",
            "guardian_type":"mother",
        },
    )
    assert r.status_code == 201
    return r.get_json()


def create_child(client, token, phone="0557700099"):
    r = client.post(
        CHILDREN_URL,
        headers=auth_header(token),
        json={
            "name":"Sara",
            "birth_date":"2015-05-10",
            "phone":phone,
        },
    )
    assert r.status_code == 201
    data = r.get_json()
    return data.get("child", data)


def child_login(client, code):
    r = client.post(CHILD_LOGIN_URL, json={"access_code":code})
    assert r.status_code == 200
    return r.get_json()


def delete_reward(client, token, reward_id):
    return client.delete(f"/api/rewards/{reward_id}", headers=auth_header(token))


# ---------------- Route ----------------

def test_requires_token(client):
    assert client.delete("/api/rewards/x").status_code == 401


def test_child_forbidden(client):
    p = register_parent(client)
    c = create_child(client, p["access_token"])
    ch = child_login(client, c["access_code"])
    r = delete_reward(client, ch["access_token"], "r1")
    assert r.status_code == 403
    assert r.get_json() == {"error":"Parent access required"}


def test_reward_not_found(client, monkeypatch):
    p = register_parent(client)
    monkeypatch.setattr(
        reward_routes.reward_service,
        "delete_reward",
        lambda rid,pid:(False,"reward_not_found"),
    )
    r = delete_reward(client,p["access_token"],"x")
    assert r.status_code == 404


def test_claimed_reward_returns_400(client, monkeypatch):
    p = register_parent(client)
    monkeypatch.setattr(
        reward_routes.reward_service,
        "delete_reward",
        lambda rid,pid:(False,"claimed_reward_cannot_be_deleted"),
    )
    r = delete_reward(client,p["access_token"],"x")
    assert r.status_code == 400
    assert r.get_json()=={"error":"Claimed rewards cannot be deleted"}


@pytest.mark.parametrize("err",["delete_error","unexpected"])
def test_other_errors_return_500(client, monkeypatch, err):
    p = register_parent(client)
    monkeypatch.setattr(
        reward_routes.reward_service,
        "delete_reward",
        lambda rid,pid:(False,err),
    )
    r = delete_reward(client,p["access_token"],"x")
    assert r.status_code == 500


def test_success_route(client, monkeypatch):
    p = register_parent(client)
    monkeypatch.setattr(
        reward_routes.reward_service,
        "delete_reward",
        lambda rid,pid:(True,None),
    )
    r = delete_reward(client,p["access_token"],"x")
    assert r.status_code == 200
    assert r.get_json()=={"message":"Reward deleted successfully"}


# ---------------- Service ----------------

class FakeReward:
    def __init__(self,status="LOCKED"):
        self.status=status


def test_service_reward_not_found(monkeypatch):
    s=reward_routes.reward_service
    monkeypatch.setattr(s.reward_repository,"get_reward_for_parent",lambda rid,pid:None)
    assert s.delete_reward("r","p")== (False,"reward_not_found")


def test_service_claimed_reward(monkeypatch):
    s=reward_routes.reward_service
    monkeypatch.setattr(s.reward_repository,"get_reward_for_parent",lambda rid,pid:FakeReward("CLAIMED"))
    assert s.delete_reward("r","p")== (False,"claimed_reward_cannot_be_deleted")


def test_service_delete_success(monkeypatch):
    s=reward_routes.reward_service
    reward=FakeReward()
    monkeypatch.setattr(s.reward_repository,"get_reward_for_parent",lambda rid,pid:reward)
    called={}
    def fake_delete(obj):
        called["obj"]=obj
        return True,None
    monkeypatch.setattr(s.reward_repository,"delete_reward",fake_delete)
    assert s.delete_reward("r","p")== (True,None)
    assert called["obj"] is reward


def test_service_delete_failure(monkeypatch):
    s=reward_routes.reward_service
    reward=FakeReward()
    monkeypatch.setattr(s.reward_repository,"get_reward_for_parent",lambda rid,pid:reward)
    monkeypatch.setattr(s.reward_repository,"delete_reward",lambda obj:(False,"delete_error"))
    assert s.delete_reward("r","p")== (False,"delete_error")


# ---------------- Repository ----------------

def test_repository_delete_success(app, monkeypatch):
    repo=reward_routes.reward_service.reward_repository
    reward=FakeReward()
    calls={"delete":0,"commit":0,"rollback":0}
    with app.app_context():
        monkeypatch.setattr(reward_repository_module.db.session,"delete",lambda obj:calls.__setitem__("delete",calls["delete"]+1))
        monkeypatch.setattr(reward_repository_module.db.session,"commit",lambda:calls.__setitem__("commit",calls["commit"]+1))
        monkeypatch.setattr(reward_repository_module.db.session,"rollback",lambda:calls.__setitem__("rollback",calls["rollback"]+1))
        assert repo.delete_reward(reward)==(True,None)
    assert calls=={"delete":1,"commit":1,"rollback":0}


def test_repository_delete_exception(app, monkeypatch):
    repo=reward_routes.reward_service.reward_repository
    reward=FakeReward()
    calls={"rollback":0}
    with app.app_context():
        monkeypatch.setattr(reward_repository_module.db.session,"delete",lambda obj:None)
        def bad():
            raise SQLAlchemyError("boom")
        monkeypatch.setattr(reward_repository_module.db.session,"commit",bad)
        monkeypatch.setattr(reward_repository_module.db.session,"rollback",lambda:calls.__setitem__("rollback",1))
        assert repo.delete_reward(reward)==(False,"delete_error")
    assert calls["rollback"]==1