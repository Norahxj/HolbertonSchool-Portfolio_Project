from app.models.daily_feedback_model import DailyFeedback
from app.repositories.daily_feedback_repository import DailyFeedbackRepository
from app.repositories.child_repository import ChildRepository
from app.utils.datetime_utils import riyadh_today

class DailyFeedbackService:
    def __init__(self):
        self.daily_feedback_repository = (
            DailyFeedbackRepository()
        )
        self.child_repository = ChildRepository()

    def create_feedback(self, parent_id, feedback_data):
        child = (
            self.child_repository
            .get_child_for_guardian(feedback_data["child_id"], parent_id)
        )
        if not child:
            return None, "child_not_found"
        existing_feedback = (
            self.daily_feedback_repository
            .get_feedback_for_child_today_by_parent(child.id, parent_id)
        )
        if existing_feedback:
            return None, "feedback_already_exists_today"
        feedback = DailyFeedback(
            child_id=child.id,
            created_by=parent_id,
            mood=feedback_data["mood"],
            feedback_date=riyadh_today()
        )
        feedback, error = (
            self.daily_feedback_repository
            .create_feedback(feedback)
        )
        if error:
            return None, "create_failed"
        return feedback, None

    def get_feedback_for_child_as_parent(self, child_id, parent_id):
        child = (
            self.child_repository
            .get_child_for_guardian(child_id, parent_id)
        )
        if not child:
            return None, "child_not_found"
        feedback = (
            self.daily_feedback_repository
            .get_feedback_by_child_id(child_id)
        )
        return feedback, None

    def get_my_feedback(self, child_id):
        child = self.child_repository.get_child_by_id(child_id)
        if not child:
            return None, "child_not_found"
        feedback = (
            self.daily_feedback_repository
            .get_feedback_by_child_id(child_id)
        )
        return feedback, None

    def update_feedback(self, feedback_id, parent_id, feedback_data):
        feedback = (
            self.daily_feedback_repository
            .get_feedback_for_creator(feedback_id,parent_id)
        )
        if not feedback:
            return None, "feedback_not_found"
        if "mood" not in feedback_data:
            return None, "no_data_provided"
        feedback.mood = feedback_data["mood"]
        success, error = (self.daily_feedback_repository.update_feedback())
        if not success:
            return None, "update_failed"
        return feedback, None