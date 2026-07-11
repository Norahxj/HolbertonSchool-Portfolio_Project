from app.extensions import db
from app.models.base_model import BaseModel


class DailyFeedback(BaseModel):
    __tablename__ = "daily_feedback"

    child_id = db.Column(db.String(36), db.ForeignKey("children.id", ondelete="CASCADE"), nullable=False)
    created_by = db.Column(db.String(36), db.ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    mood = db.Column(db.String(20), nullable=False)