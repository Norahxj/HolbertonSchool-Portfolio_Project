from app.extensions import db
from app.models.base_model import BaseModel

class TaskChild(BaseModel):
    __tablename__ = "task_children"
    __table_args__ = (
        db.UniqueConstraint(
            "task_id", "child_id",
            name="unique_task_child"
        ),
    )

    task_id = db.Column(db.String(36), db.ForeignKey("tasks.id", ondelete="CASCADE"), nullable=False)
    child_id = db.Column(db.String(36), db.ForeignKey("children.id", ondelete="CASCADE"), nullable=False)
    task = db.relationship("Task", backref=db.backref("task_children", lazy=True, passive_deletes=True))
    child = db.relationship("Child", backref=db.backref("task_children", lazy=True, passive_deletes=True))