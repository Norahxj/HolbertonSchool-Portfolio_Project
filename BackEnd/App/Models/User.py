from app.extensions import db
from app.models.base_model import BaseModel


class User(BaseModel):
    __tablename__ = "users"
    full_name = db.Column(db.String(100), nullable=False)
    email = db.Column(db.String(120), unique=True, nullable=False)
    password_hash = db.Column(db.String(255), nullable=False)
    role = db.Column(db.String(20), default="parent")
    is_active = db.Column(db.Boolean, default=True)
    children = db.relationship("Child",backref="parent",lazy=True)
    tasks = db.relationship("Task", backref="creator", lazy=True)