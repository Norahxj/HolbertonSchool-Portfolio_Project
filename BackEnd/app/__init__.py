from flask import Flask
from App.Extensions import db, jwt, bcrypt
from App.Routes.task_routs import task_ns
from flask_restx import Api 
 
def create_app():
    app = Flask(__name__)

    app.config["SQLALCHEMY_DATABASE_URI"] = "sqlite:///asalah.db"
    app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False
    app.config["JWT_SECRET_KEY"] = "super-secret-key"

    db.init_app(app)
    bcrypt.init_app(app)
    jwt.init_app(app)

    api = Api(app, title='Asalah API', version="1.0", doc='/swagger')
    api.add_namespace(task_ns, path='/api/tasks')

    return app