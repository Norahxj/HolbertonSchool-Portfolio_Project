from app.extensions import db
from app.models.base_model import BaseModel


class DailyFeedback(BaseModel):
    __tablename__ = "daily_feedback"

    task_id = db.Column(db.String(36), db.ForeignKey("tasks.id"), nullable=False)
    emoji = db.Column(db.String(20), nullable=False)

    def to_dict(self):
        return {
            "id": self.id,
            "task_id": self.task_id,
            "emoji": self.emoji,
            "created_at": self.created_at
        }