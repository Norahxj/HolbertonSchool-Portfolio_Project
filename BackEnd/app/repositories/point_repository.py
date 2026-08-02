from sqlalchemy.exc import IntegrityError
from app.extensions import db
from app.models.point_model import ChildPoints

class PointRepository:
    def get_points_by_child_id(self, child_id):
        return ChildPoints.query.filter_by(child_id=child_id).first()

    def get_points_by_child_ids(self, child_ids):
        if not child_ids:
            return {}

        records = (
        ChildPoints.query
        .filter(ChildPoints.child_id.in_(child_ids))
        .all()
        )

        return {
        str(record.child_id): record.total_points
        for record in records
        }
    
    def get_points_by_child_id_for_update(self, child_id):
        return (ChildPoints.query.filter_by(child_id=child_id).with_for_update().first())

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