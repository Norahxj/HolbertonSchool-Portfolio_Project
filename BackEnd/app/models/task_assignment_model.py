from app.extensions import db
from app.models.base_model import BaseModel


class TaskAssignment(BaseModel):
    __tablename__ = "task_assignments"

    task_id = db.Column(db.String(36), db.ForeignKey("tasks.id"), nullable=False)
    child_id = db.Column(db.String(36), db.ForeignKey("children.id"), nullable=False)
    status = db.Column(db.String(20), default="PENDING", nullable=False)
    completed_at = db.Column(db.DateTime, nullable=True)
    approved_at = db.Column(db.DateTime, nullable=True)
    child = db.relationship("Child", backref=db.backref("task_assignments", lazy=True))