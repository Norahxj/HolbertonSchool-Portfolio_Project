from app.extensions import db
from app.models.points_model import ChildPoints
from app.models.points_history_model import PointsHistory


class PointsService:

    @staticmethod
    def get_child_points(child_id):
        points = ChildPoints.query.filter_by(child_id=child_id).first()
        if not points:
            return {"child_id": child_id, "total_points": 0}, 200

        return {
            "child_id": child_id,
            "total_points": points.total_points
        }, 200

    @staticmethod
    def get_points_history(child_id):
        history = PointsHistory.query.filter_by(child_id=child_id).order_by(
            PointsHistory.created_at.desc()
        ).all()

        return [h.to_dict() for h in history], 200

    @staticmethod
    def add_points(child_id, amount, source_id=None, note=None):
        points = ChildPoints.query.filter_by(child_id=child_id).first()

        if not points:
            points = ChildPoints(child_id=child_id, total_points=0)
            db.session.add(points)
            db.session.commit()

        points.total_points += amount
        db.session.commit()

        history = PointsHistory(
            child_id=child_id,
            points=amount,
            action="TASK_APPROVED",
            source_id=source_id,
            note=note
        )
        db.session.add(history)
        db.session.commit()

        return points.total_points

    @staticmethod
    def deduct_points(child_id, amount, source_id=None, note=None):
        points = ChildPoints.query.filter_by(child_id=child_id).first()

        if not points:
            return None

        points.total_points = max(0, points.total_points - amount)
        db.session.commit()

        history = PointsHistory(
            child_id=child_id,
            points=-amount,
            action="WISH_REDEEMED",
            source_id=source_id,
            note=note
        )
        db.session.add(history)
        db.session.commit()

        return points.total_points
