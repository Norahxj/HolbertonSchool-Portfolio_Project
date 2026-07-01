mport pytest

from conftest import auth_header, create_child

def create_wish(client, token, name="Toy Car"):
return client.post("/api/wishlist/add", headers=auth_header(token), json={"name": name})

class TestWishlistFlows:
    def test_child_create_wish_success(self, client, parent):
# create child and child token
    child_res = create_child(client, parent["token"])
    assert child_res.status_code == 201
    child = child_res.get_json()
# child login
    login_res = client.post("/api/auth/child-login", json={"access_code": child["access_code"]})
    assert login_res.status_code == 200
    token = login_res.get_json()["access_token"]
    res = create_wish(client, token, name="New Toy")
    assert res.status_code == 201
    data = res.get_json()
    assert data["name"] == "New Toy"
    assert data["status"] == "PENDING"

def test_parent_approve_wish_success(self, client, parent):
    # create child and child token
    child_res = create_child(client, parent["token"])
    child = child_res.get_json()
    login_res = client.post("/api/auth/child-login", json={"access_code": child["access_code"]})
    token = login_res.get_json()["access_token"]

    # child creates wishlist item
    res = create_wish(client, token, name="Bike")
    assert res.status_code == 201
    wish = res.get_json()

    # parent approves
    approve_res = client.put(f"/api/wishlist/{wish['id']}/approve", headers=auth_header(parent["token"]), json={"target_points": 50})
    assert approve_res.status_code == 200
    data = approve_res.get_json()
    assert data["status"] == "APPROVED"
    assert data["target_points"] == 50
    assert data.get("reviewed_by") == parent["user"]["id"]

def test_parent_reject_wish_success(self, client, parent):
    child_res = create_child(client, parent["token"])
    child = child_res.get_json()
    login_res = client.post("/api/auth/child-login", json={"access_code": child["access_code"]})
    token = login_res.get_json()["access_token"]

    res = create_wish(client, token, name="Laptop")
    wish = res.get_json()

    reject_res = client.delete(f"/api/wishlist/{wish['id']}/reject", headers=auth_header(parent["token"]))
    assert reject_res.status_code == 200
    data = reject_res.get_json()
    assert data["status"] == "REJECTED"
    assert data.get("reviewed_by") == parent["user"]["id"]

def test_get_wishlist_status(self, client, parent):
    # create child, child token, create wish, approve and set child points then check status
    child_res = create_child(client, parent["token"])
    child = child_res.get_json()
    login_res = client.post("/api/auth/child-login", json={"access_code": child["access_code"]})
    token = login_res.get_json()["access_token"]

    res = create_wish(client, token, name="Tablet")
    wish = res.get_json()

    # parent approves with target 30
    approve_res = client.put(f"/api/wishlist/{wish['id']}/approve", headers=auth_header(parent["token"]), json={"target_points": 30})
    assert approve_res.status_code == 200

    # set child points directly in DB
    from app.extensions import db
    from app.models.point_model import ChildPoints

    cp = ChildPoints(child_id=child["id"], total_points=20)
    db.session.add(cp)
    db.session.commit()

    status_res = client.get("/api/wishlist/status", headers=auth_header(token))
    assert status_res.status_code == 200
    data = status_res.get_json()
    assert data["child_id"] == child["id"]
    assert isinstance(data["wishes"], list)
    # find the tablet wish
    w = next((x for x in data["wishes"] if x["wish_id"] == wish["id"]), None)
    assert w is not None
    assert w["current_points"] == 20
    assert w["remaining"] == 10