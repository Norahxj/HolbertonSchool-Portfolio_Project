from app.models.point_model import ChildPoints
from app.repositories.point_repository import PointRepository
from app.repositories.child_repository import ChildRepository
from app.services.points_history_service import PointsHistoryService
from app.extensions import db

class PointsService:
    def __init__(self):
        self.point_repository = PointRepository()
        self.child_repository = ChildRepository()
        self.points_history_service = PointsHistoryService()

    def get_child_points(self, child_id, commit=True):
        child = self.child_repository.get_child_by_id(child_id)
        if not child:
            return None, "child_not_found"
        points = self.point_repository.get_points_by_child_id(child_id)
        if not points:
            points = ChildPoints(child_id=child_id, total_points=0)
            points, error = self.point_repository.create_points_record(points, commit=commit)
            if error:
                return None, "create_failed"
        return points, None

    def add_points(self, child_id, amount, task_assignment_id, commit=True):
        if amount <= 0:
            return None, "invalid_points_amount"
        points, error = self.get_child_points(child_id, commit=False)
        if error:
            return None, error
        points.total_points += amount
        success, error = self.point_repository.update_points(commit=False)
        if not success:
            return None, "update_failed"
        history, error = self.points_history_service.create_history(
            child_id=child_id,
            points=amount,
            action="TASK_APPROVED",
            task_assignment_id=task_assignment_id,
            commit=False
        )
        if error:
            return None, "history_failed"
        if commit:
            try:
                db.session.commit()
            except Exception:
                db.session.rollback()
                return None, "commit_failed"
        return points, None