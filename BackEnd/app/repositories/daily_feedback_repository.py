from sqlalchemy.exc import IntegrityError
from app.extensions import db
from app.models.daily_feedback_model import DailyFeedback
from datetime import datetime, time, timedelta
from app.utils.datetime_utils import riyadh_today


class DailyFeedbackRepository:
    def create_feedback(self, feedback):
        try:
            db.session.add(feedback)
            db.session.commit()
            return feedback, None
        except IntegrityError:
            db.session.rollback()
            return None, "integrity_error"

    def get_feedback_by_child_id(self, child_id):
        return (
            DailyFeedback.query
            .filter_by(child_id=child_id)
            .order_by(DailyFeedback.created_at.desc()).all()
        )

    def get_feedback_by_id(self, feedback_id):
        return db.session.get(DailyFeedback, feedback_id)
        
    def get_feedback_for_creator(self, feedback_id, creator_id):
        return DailyFeedback.query.filter_by(
            id=feedback_id,
            created_by=creator_id
        ).first()

    def get_feedback_for_child_today_by_parent(self, child_id, parent_id):
        today = riyadh_today()
        return DailyFeedback.query.filter_by(
            child_id=child_id,
            created_by=parent_id,
            feedback_date=today
        ).first()