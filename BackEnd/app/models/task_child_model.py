from app.extensions import db
from app.models.base_model import BaseModel


class TaskChild(BaseModel):
    __tablename__ = "task_children"
    __table_args__ = (
        db.UniqueConstraint(
            "task_id",
            "child_id",
            name="unique_task_child"
        ),
    )

    task_id = db.Column(db.String(36), db.ForeignKey("tasks.id"), nullable=False)
    child_id = db.Column(db.String(36), db.ForeignKey("children.id"), nullable=False)
    task = db.relationship("Task", backref=db.backref("task_children", lazy=True, cascade="all, delete-orphan"))
    child = db.relationship("Child", backref=db.backref("task_children", lazy=True, cascade="all, delete-orphan"))