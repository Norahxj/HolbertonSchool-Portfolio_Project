from app.extensions import db
from app.models.base_model import BaseModel


class Child(BaseModel):
    __tablename__ = "children"

    name = db.Column(db.String(100), nullable=False)
    age = db.Column(db.Integer, nullable=False)
    email = db.Column(db.String(120), unique=True, nullable=False)
    password_hash = db.Column(db.String(255), nullable=False)
    parent_id = db.Column(db.String(36), db.ForeignKey("users.id"), nullable=False)
    tasks = db.relationship("Task", backref="child", lazy=True, cascade="all, delete-orphan")