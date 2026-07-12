from sqlalchemy.exc import IntegrityError
from app.extensions import db
from app.models.point_model import ChildPoints


class PointRepository:
    def get_points_by_child_id(self, child_id):
        return ChildPoints.query.filter_by(child_id=child_id).first()

    def create_points_record(self, points_record, commit=True):
        try:
            db.session.add(points_record)
            if commit:
                db.session.commit()
            else:
                db.session.flush()
            return points_record, None
        except IntegrityError:
            db.session.rollback()
            return None, "integrity_error"

    def update_points(self, commit=True):
        try:
            if commit:
                db.session.commit()
            else:
                db.session.flush()

            return True, None
        except IntegrityError:
            db.session.rollback()
            return False, "integrity_error"