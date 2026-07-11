from flask import Flask
from dotenv import load_dotenv

load_dotenv()

from flask_cors import CORS
from flask_restx import Api
from app.extensions import db, jwt, bcrypt
from app.config import Config
from flask_jwt_extended.exceptions import NoAuthorizationError
from app.routes.auth_routes import api as auth_ns
from app.routes.user_routes import api as user_ns
from app.routes.child_routes import api as child_ns
from app.routes.task_routes import api as task_ns
from app.routes.wishlist_routes import api as wishlist_ns 
from app.routes.task_assignment_routes import api as task_assignment_ns
from app.routes.points_routes import api as point_ns
from app.routes.points_history_routes import api as points_history_ns
from app.routes.reward_routes import api as reward_ns
from app.routes.daily_feedback_routes import api as daily_feedback_ns
from app.routes.task_bank_routes import api as task_bank_ns
from app.routes.family_routes import api as family_ns
from app.routes.cron_routes import api as cron_ns
from app.routes.dashboard_routes import api as dashboard_ns


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
    
    CORS(
        app,
        resources={r"/api/*": {"origins": "*"}},
        supports_credentials=True,
    )
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
    @api.errorhandler(NoAuthorizationError)
    def handle_missing_authorization(error):
        return {"error": "Authorization token is required"}, 401
    
    @api.errorhandler(DecodeError)
    def handle_jwt_decode_error(error):
        return {"error": "Invalid token"}, 401


    api.add_namespace(auth_ns, path="/api/auth")
    api.add_namespace(user_ns, path="/api/users")
    api.add_namespace(child_ns, path="/api/children")
    api.add_namespace(task_ns, path="/api/tasks")
    api.add_namespace(wishlist_ns, path="/api/wishlists")
    api.add_namespace(task_assignment_ns, path="/api/task-assignments")
    api.add_namespace(point_ns, path="/api/points")
    api.add_namespace(points_history_ns, path="/api/points-history")
    api.add_namespace(reward_ns, path="/api/rewards")
    api.add_namespace(daily_feedback_ns, path="/api/daily-feedback")
    api.add_namespace(task_bank_ns, path="/api/task-bank")
    api.add_namespace(family_ns, path="/api/family")
    api.add_namespace(cron_ns, path="/api/cron")
    api.add_namespace(dashboard_ns, path="/api/dashboard")
    return app
