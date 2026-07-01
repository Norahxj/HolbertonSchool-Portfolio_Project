"""
Shared pytest setup for Asalah backend tests.

Put this file inside: backEnd/tests/conftest.py
Run from backEnd:
    $env:PYTHONPATH="."   # PowerShell, only if imports fail
    python -m pytest -q
"""
import os
import sys
from pathlib import Path

import pytest
from flask_jwt_extended import create_access_token, create_refresh_token

ROOT_DIR = Path(__file__).resolve().parents[1]
if str(ROOT_DIR) not in sys.path:
    sys.path.insert(0, str(ROOT_DIR))

os.environ.setdefault("JWT_SECRET_KEY", "test-secret-key-must-be-long-enough-32-bytes")
os.environ.setdefault("DATABASE_URL", "sqlite:///:memory:")

from app import create_app  # noqa: E402
from app.extensions import db, bcrypt  # noqa: E402
from app.models.user_model import User  # noqa: E402
from app.models.child_model import Child  # noqa: E402
from app.models.task_model import Task  # noqa: E402
from app.models.task_assignment_model import TaskAssignment  # noqa: E402
from app.models.revoked_token_model import RevokedToken  # noqa: E402

# Import all current project models so db.create_all() can resolve FKs/relationships.
try:
    from app.models.daily_feedback_model import DailyFeedback  # noqa: F401,E402
except Exception:
    pass
try:
    from app.models.point_model import ChildPoints  # noqa: F401,E402
except Exception:
    pass
try:
    from app.models.reward_model import Reward  # noqa: F401,E402
except Exception:
    pass
try:
    from app.models.wishlist_model import Wishlist  # noqa: F401,E402
except Exception:
    pass


@pytest.fixture()
def app():
    test_app = create_app()
    test_app.config.update(
        TESTING=True,
        SQLALCHEMY_DATABASE_URI="sqlite:///:memory:",
        JWT_SECRET_KEY="test-secret-key-must-be-long-enough-32-bytes",
        JWT_HEADER_NAME="Authorization",
        JWT_HEADER_TYPE="",  # project uses raw token without Bearer
        RESTX_VALIDATE=True,
        PROPAGATE_EXCEPTIONS=True,
        BCRYPT_LOG_ROUNDS=4,
    )
    with test_app.app_context():
        db.drop_all()
        db.create_all()
        yield test_app
        db.session.remove()
        db.drop_all()


@pytest.fixture()
def client(app):
    return app.test_client()


@pytest.fixture()
def models():
    return {
        "db": db,
        "bcrypt": bcrypt,
        "User": User,
        "Child": Child,
        "Task": Task,
        "TaskAssignment": TaskAssignment,
        "RevokedToken": RevokedToken,
    }


@pytest.fixture()
def parent(client):
    token, refresh, user = create_parent_and_tokens(client)
    return {"token": token, "refresh": refresh, "user": user}


@pytest.fixture()
def parent2(client):
    token, refresh, user = create_parent_and_tokens(
        client,
        full_name="Second Parent",
        email="second.parent@example.com",
        password="StrongPass2!",
    )
    return {"token": token, "refresh": refresh, "user": user}


@pytest.fixture()
def child(client, parent):
    res = create_child(client, parent["token"])
    assert res.status_code == 201, res.get_json()
    return res.get_json()


@pytest.fixture()
def child_token(client, parent):
    child_data = create_child(client, parent["token"], name="Child Login", age=9).get_json()
    login_res = client.post("/api/auth/child-login", json={"access_code": child_data["access_code"]})
    assert login_res.status_code == 200, login_res.get_json()
    data = login_res.get_json()
    return {"token": data["access_token"], "refresh": data["refresh_token"], "child": data["child"], "access_code": child_data["access_code"]}


@pytest.fixture()
def task(client, parent, child):
    res = create_task(client, parent["token"], [child["id"]])
    assert res.status_code == 201, res.get_json()
    return res.get_json()


def auth_header(token):
    return {"Authorization": token}


def register_parent(client, full_name="Parent User", email="parent@example.com", password="StrongPass1!", **extra):
    payload = {"full_name": full_name, "email": email, "password": password}
    payload.update(extra)
    return client.post("/api/auth/register", json=payload)


def login_parent(client, email="parent@example.com", password="StrongPass1!", **extra):
    payload = {"email": email, "password": password}
    payload.update(extra)
    return client.post("/api/auth/login", json=payload)


def create_parent_and_tokens(client, full_name="Parent User", email="parent@example.com", password="StrongPass1!"):
    reg = register_parent(client, full_name=full_name, email=email, password=password)
    assert reg.status_code == 201, reg.get_json()
    res = login_parent(client, email=email, password=password)
    assert res.status_code == 200, res.get_json()
    data = res.get_json()
    return data["access_token"], data["refresh_token"], data["user"]


def create_child(client, parent_token, name="Ali", age=10, **extra):
    payload = {"name": name, "age": age}
    payload.update(extra)
    return client.post("/api/children/", headers=auth_header(parent_token), json=payload)


def create_task(client, parent_token, child_ids, **overrides):
    payload = {
        "child_ids": child_ids,
        "title": "Clean Room",
        "description": "Clean your room before dinner",
        "points": 10,
        "task_frequency": "ONCE",
        "category": "MORAL",
        "is_auto_verified": False,
    }
    payload.update(overrides)
    return client.post("/api/tasks/", headers=auth_header(parent_token), json=payload)


def make_access_token(app, identity, role="parent"):
    with app.app_context():
        return create_access_token(identity=str(identity), additional_claims={"role": role})


def make_refresh_token(app, identity, role="parent"):
    with app.app_context():
        return create_refresh_token(identity=str(identity), additional_claims={"role": role})


def count_rows(model):
    return db.session.query(model).count()


def assert_json_has_error_or_message(response):
    data = response.get_json(silent=True)
    assert response.status_code >= 400
    assert data is None or isinstance(data, (dict, list))
