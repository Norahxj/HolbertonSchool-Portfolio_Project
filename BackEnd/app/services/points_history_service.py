from app.models.points_history_model import PointsHistory
from app.repositories.points_history_repository import PointsHistoryRepository
from app.repositories.child_repository import ChildRepository


class PointsHistoryService:
    def __init__(self):
        self.points_history_repository = PointsHistoryRepository()
        self.child_repository = ChildRepository()

    def create_history(self, child_id, points, action, source_id=None):
        child = self.child_repository.get_child_by_id(child_id)

        if not child:
            return None, "child_not_found"

        history = PointsHistory(
            child_id=child_id,
            points=points,
            action=action,
            source_id=source_id
        )

        history, error = self.points_history_repository.create_history(history)

        if error:
            return None, "create_failed"

        return history, None

    def get_history_for_child(self, child_id):
        child = self.child_repository.get_child_by_id(child_id)

        if not child:
            return None, "child_not_found"

        return self.points_history_repository.get_history_by_child_id(child_id), None