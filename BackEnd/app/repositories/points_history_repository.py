from sqlalchemy.exc import IntegrityError
from app.extensions import db
from app.models.points_history_model import PointsHistory


class PointsHistoryRepository:

    def create_history(self, history):
        try:
            db.session.add(history)
            db.session.commit()
            return history, None

        except IntegrityError:
            db.session.rollback()
            return None, "integrity_error"

    def get_history_by_child_id(self, child_id):
        return (
            PointsHistory.query
            .filter_by(child_id=child_id)
            .order_by(PointsHistory.created_at.desc())
            .all()
        )