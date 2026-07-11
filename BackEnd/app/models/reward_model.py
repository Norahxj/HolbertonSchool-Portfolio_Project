from app.extensions import db
from app.models.base_model import BaseModel


class Reward(BaseModel):
    __tablename__ = "rewards"

    child_id = db.Column(db.String(36), db.ForeignKey("children.id", ondelete="CASCADE"), nullable=False)
    reward_name = db.Column(db.String(100), nullable=False)
    description = db.Column(db.String(500), nullable=True)
    status = db.Column(db.String(20), default="LOCKED", nullable=False)
    unlock_day = db.Column(db.Integer, default=3, nullable=False)
    assigned_by = db.Column(db.String(36), db.ForeignKey("users.id"), nullable=False)
    child = db.relationship("Child", backref=db.backref("rewards", lazy=True))
    assigner = db.relationship("User", backref=db.backref("assigned_rewards", lazy=True))