from sqlalchemy.exc import IntegrityError
from app.extensions import db
from app.models.point_model import ChildPoints


class PointRepository:

    def get_points_by_child_id(self, child_id):
        return ChildPoints.query.filter_by(child_id=child_id).first()

    def create_points_record(self, points_record):
        try:
            db.session.add(points_record)
            db.session.commit()
            return points_record, None
        except IntegrityError:
            db.session.rollback()
            return None, "integrity_error"

    def update_points(self):
        try:
            db.session.commit()
            return True, None
        except IntegrityError:
            db.session.rollback()
            return False, "integrity_error"