import pytest

from app import create_app
from app.extensions import db


@pytest.fixture()
def app(tmp_path):
    test_database = tmp_path / "test.db"

    app = create_app(
        {
            "TESTING": True,
            "SQLALCHEMY_DATABASE_URI": f"sqlite:///{test_database}",
            "SQLALCHEMY_TRACK_MODIFICATIONS": False,
            "JWT_SECRET_KEY": "test-secret-key-for-pytest-2026-minimum-32-bytes",
        }
    )

    with app.app_context():
        db.create_all()

        yield app

        db.session.remove()
        db.drop_all()


@pytest.fixture()
def client(app):
    return app.test_client()