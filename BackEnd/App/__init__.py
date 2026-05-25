from flask import Flask
from app.extensions import db, jwt, bcrypt
from flask_restx import Api
from app.routes.user_routs import api as user_ns
from app.routes.child_routs import api as child_ns


def create_app():
    app = Flask(__name__)

    app.config["SQLALCHEMY_DATABASE_URI"] = "sqlite:///asalah.db"
    app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False
    app.config["JWT_SECRET_KEY"] = "super-secret-key"

    db.init_app(app)
    bcrypt.init_app(app)
    jwt.init_app(app)

    api = Api(app, title='Asalah API', version="1.0", doc='/swagger')
    api.add_namespace(user_ns, path='/api/users')
    api.add_namespace(child_ns, path='/api/children')

    return app