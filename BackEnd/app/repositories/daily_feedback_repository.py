from sqlalchemy.exc import IntegrityError
from app.extensions import db
from app.models.daily_feedback_model import DailyFeedback
from datetime import date
from datetime import datetime, time, timedelta
from app.utils.datetime_utils import (RIYADH_TIMEZONE, UTC, riyadh_today)


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
            .order_by(DailyFeedback.created_at.desc())
            .all()
        )

    def get_feedback_by_id(self, feedback_id):
        return db.session.get(DailyFeedback, feedback_id)

    def delete_feedback(self, feedback):
        try:
            db.session.delete(feedback)
            db.session.commit()
            return True, None
        except Exception:
            db.session.rollback()
            return False, "delete_error"
        
    def get_feedback_for_creator(self, feedback_id, creator_id):
        return DailyFeedback.query.filter_by(
            id=feedback_id,
            created_by=creator_id
        ).first()

    def get_feedback_for_child_today_by_parent(self, child_id, parent_id):
        today = riyadh_today()

        riyadh_day_start = datetime.combine(today, time.min, tzinfo=RIYADH_TIMEZONE)

        riyadh_day_end = (riyadh_day_start + timedelta(days=1))

        utc_day_start = riyadh_day_start.astimezone(UTC)
        utc_day_end = riyadh_day_end.astimezone(UTC)

        return (
            DailyFeedback.query
            .filter(
                DailyFeedback.child_id == child_id,
                DailyFeedback.created_by == parent_id,
                DailyFeedback.created_at >= utc_day_start,
                DailyFeedback.created_at < utc_day_end
            )
            .first()
        )