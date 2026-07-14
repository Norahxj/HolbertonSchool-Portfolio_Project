from app.models.points_history_model import PointsHistory
from app.repositories.points_history_repository import PointsHistoryRepository
from app.repositories.child_repository import ChildRepository


class PointsHistoryService:
    def __init__(self):
        self.points_history_repository = PointsHistoryRepository()
        self.child_repository = ChildRepository()

    def create_history(self, child_id, points, action, task_assignment_id=None, wishlist_id=None, commit=True):
        child = self.child_repository.get_child_by_id(child_id)
        if not child:
            return None, "child_not_found"
        if task_assignment_id is not None and wishlist_id is not None:
            return None, "multiple_sources_not_allowed"
        if task_assignment_id is None and wishlist_id is None:
            return None, "source_required"

        history = PointsHistory(
            child_id=child_id,
            points=points,
            action=action,
            task_assignment_id=task_assignment_id,
            wishlist_id=wishlist_id
        )
        history, error = self.points_history_repository.create_history(history, commit=commit)
        if error:
            return None, "create_failed"
        return history, None

    def get_history_for_child(self, child_id):
        child = self.child_repository.get_child_by_id(child_id)
        if not child:
            return None, "child_not_found"
        return self.points_history_repository.get_history_by_child_id(child_id), None