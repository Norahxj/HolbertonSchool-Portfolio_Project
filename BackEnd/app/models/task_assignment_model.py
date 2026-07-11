from app.extensions import db
from app.models.base_model import BaseModel

class TaskAssignment(BaseModel):
    __tablename__ = "task_assignments"
    __table_args__ = (db.UniqueConstraint("task_id", "child_id", "assigned_date", name="unique_task_child_assignment_per_day"),)

    task_id = db.Column(db.String(36), db.ForeignKey("tasks.id", ondelete="CASCADE"), nullable=False)
    child_id = db.Column(db.String(36), db.ForeignKey("children.id", ondelete="CASCADE"), nullable=False)
    status = db.Column(db.String(20), default="PENDING", nullable=False)
    completed_at = db.Column(db.DateTime, nullable=True)
    approved_at = db.Column(db.DateTime, nullable=True)
    child = db.relationship("Child", backref=db.backref("task_assignments", lazy=True))
    assigned_date = db.Column(db.Date, nullable=False)