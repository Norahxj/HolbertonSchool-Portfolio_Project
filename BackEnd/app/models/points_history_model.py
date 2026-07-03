from app.extensions import db
from app.models.base_model import BaseModel


class PointsHistory(BaseModel):
    __tablename__ = "points_history"

    child_id = db.Column(db.String(36), db.ForeignKey("children.id"), nullable=False)
    points = db.Column(db.Integer, nullable=False)
    action = db.Column(db.String(30), nullable=False)
    source_id = db.Column(db.String(36), nullable=True)
    child = db.relationship("Child", backref=db.backref("points_history", lazy=True))