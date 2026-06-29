from dotenv import load_dotenv

load_dotenv()

from flask import Flask
from flask_restx import Api
from app.extensions import db, jwt, bcrypt
from app.config import Config

from app.routes.auth_routes import api as auth_ns
from app.routes.user_routes import api as user_ns
from app.routes.child_routes import api as child_ns
from app.routes.task_routes import api as task_ns



authorizations = {
    "JWT": {
        "type": "apiKey",
        "in": "header",
        "name": "Authorization",
        "description": "Paste the JWT token"
    }
}


def create_app():
    app = Flask(__name__)

    app.config.from_object(Config)

    app.config["JWT_HEADER_TYPE"] = ""

    db.init_app(app)
    bcrypt.init_app(app)
    jwt.init_app(app)

    from app.models.revoked_token_model import RevokedToken

    @jwt.token_in_blocklist_loader
    def check_if_token_revoked(jwt_header, jwt_payload):
        jti = jwt_payload["jti"]
        token = RevokedToken.query.filter_by(jti=jti).first()
        return token is not None

    @jwt.expired_token_loader
    def expired_token_callback(jwt_header, jwt_payload):
        return {"error": "Token has expired"}, 401


    @jwt.invalid_token_loader
    def invalid_token_callback(error):
        return {"error": "Invalid token"}, 401


    @jwt.unauthorized_loader
    def missing_token_callback(error):
        return {"error": "Authorization token is required"}, 401


    @jwt.revoked_token_loader
    def revoked_token_callback(jwt_header, jwt_payload):
        return {"error": "Token has been revoked"}, 401
    
    api = Api(
        app,
        title="Asalah API",
        version="1.0",
        doc="/swagger",
        authorizations=authorizations
    )

    api.add_namespace(auth_ns, path="/api/auth")
    api.add_namespace(user_ns, path="/api/users")
    api.add_namespace(child_ns, path="/api/children")
    api.add_namespace(task_ns, path="/api/tasks")

    return app
