from app.extensions import db
from app.models.daily_feedback_model import DailyFeedback
from app.models.task_model import Task
from app.models.child_model import Child


class DailyFeedbackService:

    def create_feedback(self, parent_id, feedback_data):
        task = (
            Task.query
            .join(Child, Task.child_id == Child.id)
            .filter(
                Task.id == feedback_data["task_id"],
                Child.parent_id == parent_id
            )
            .first()
        )

        if not task:
            return None, "task_not_found"

        if task.status != "APPROVED":
            return None, "task_not_approved"

        feedback = DailyFeedback.query.filter_by(task_id=task.id).first()

        if feedback:
            return None, "feedback_already_exists"

        feedback = DailyFeedback(
            task_id=task.id,
            emoji=feedback_data["emoji"]
        )

        db.session.add(feedback)
        db.session.commit()

        return feedback, None