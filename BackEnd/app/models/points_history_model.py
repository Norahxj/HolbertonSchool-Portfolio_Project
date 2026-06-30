from app.extensions import db
from app.models.base_model import BaseModel


class PointsHistory(BaseModel):
    __tablename__ = "points_history"

    child_id = db.Column(db.String(36), db.ForeignKey("children.id"), nullable=False)
    points = db.Column(db.Integer, nullable=False)
    action = db.Column(db.String(100), nullable=False)  # TASK_APPROVED, BONUS, DEDUCTION, WISH_REDEEMED
    source_id = db.Column(db.String(36), nullable=True)  # task_id or wish_id
    note = db.Column(db.String(255), nullable=True)

    child = db.relationship("Child", backref="points_history", lazy=True)

    def to_dict(self):
        return {
            "id": self.id,
            "child_id": self.child_id,
            "points": self.points,
            "action": self.action,
            "source_id": self.source_id,
            "note": self.note,
            "created_at": self.created_at
        }
