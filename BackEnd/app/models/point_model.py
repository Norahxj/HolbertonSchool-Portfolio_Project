from app.extensions import db
from app.models.base_model import BaseModel


class ChildPoints(BaseModel):
    __tablename__ = "child_points"

    child_id = db.Column(db.String(36), db.ForeignKey("children.id"), nullable=False)
    total_points = db.Column(db.Integer, default=0, nullable=False)
    child = db.relationship("Child", backref="points", lazy=True)

    