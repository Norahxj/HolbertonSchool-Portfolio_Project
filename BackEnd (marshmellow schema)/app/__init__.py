from flask import Flask
from app.extensions import db, bcrypt, jwt
from app.error_handlers import register_error_handlers
from config import Config

# Function to create and configure the Flask application. then start those three using flask: SQLAlchemy,Bcrypt,JWTManager.
# start error handlers for the application.
# import and register blueprints (API routes) and models. 
def create_app(config_class=Config):
    app = Flask(__name__)
    app.config.from_object(config_class)


    db.init_app(app)
    bcrypt.init_app(app)
    jwt.init_app(app)

  
    register_error_handlers(app)

    from app.routes.auth_routes import auth_bp
    from app.routes.user_routes import user_bp
    from app.routes.child_routes import child_bp
    from app.routes.task_routes import task_bp
    from app.routes.reward_routes import reward_bp
    from app.routes.points_routes import points_bp

    app.register_blueprint(auth_bp, url_prefix="/api/auth")
    app.register_blueprint(user_bp, url_prefix="/api/users")
    app.register_blueprint(child_bp, url_prefix="/api/children")
    app.register_blueprint(task_bp, url_prefix="/api/tasks")
    app.register_blueprint(reward_bp, url_prefix="/api/rewards")
    app.register_blueprint(points_bp, url_prefix="/api/points")

    from app.models import user_model, child_model, task_models, gamification_models

    with app.app_context():
        db.create_all()

    return app 
