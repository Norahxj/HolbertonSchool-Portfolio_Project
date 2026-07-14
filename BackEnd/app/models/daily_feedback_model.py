from app.extensions import db
from app.models.base_model import BaseModel


class DailyFeedback(BaseModel):
    __tablename__ = "daily_feedback"
    __table_args__ = (
        db.UniqueConstraint("child_id", "created_by", "feedback_date",
        name="uq_daily_feedback_per_creator_per_day"
        )
    )

    child_id = db.Column(db.String(36), db.ForeignKey("children.id", ondelete="CASCADE"), nullable=False)
    created_by = db.Column(db.String(36), db.ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    mood = db.Column(db.String(20), nullable=False)
    feedback_date = db.Column(db.Date, nullable=False)