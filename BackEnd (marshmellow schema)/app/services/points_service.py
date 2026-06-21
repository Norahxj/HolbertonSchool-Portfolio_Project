from app.extensions import db
from app.models.child_model import Child
from app.models.gamification_models import ChildTask, TaskStatus, DailyFeedback
from app.exceptions.api_exceptions import NotFoundError, ValidationError, ConflictError
from app.schemas.gamification_schemas import DailyFeedbackSchema
from uuid import uuid4
from datetime import datetime, date

##Initialize Marshmallow schema by retrieving the child task then ensure task is completed and verified
## prevent double-awarding points for the same task. 
## determine points to award in both from suggested task extracted from the bank or custom task by parents
## if feedback for today already exists, ot create feedback intry
daily_feedback_schema = DailyFeedbackSchema()

class PointsService:
    @staticmethod
    def add_points_for_task_completion(child_id, task_id):

        child_task = ChildTask.query.filter_by(id=task_id, child_id=child_id).first()
        if not child_task:
            raise NotFoundError(f"Child task with ID {task_id} not found for child {child_id}.")

        if child_task.status != TaskStatus.VERIFIED:
            raise ConflictError(f"Task {task_id} is not yet verified. Points can only be added for verified tasks.")

        if child_task.points_awarded:
            raise ConflictError(f"Points for task {task_id} have already been awarded.")

## the points rewarded by each task, then update their points
        points_to_award = 0
        if child_task.suggested_task:
            points_to_award = child_task.suggested_task.points_earned
        elif child_task.parent_custom_task:
            points_to_award = child_task.parent_custom_task.points_earned

        if points_to_award <= 0:
            raise ValidationError(f"Task {task_id} has no points defined to be awarded.")


        child = Child.query.get(child_id)
        if not child:
            raise NotFoundError(f"Child with ID {child_id} not found.")

        child.current_noor_points += points_to_award
        child_task.points_awarded = True
        db.session.commit()
        return {"message": f"Successfully awarded {points_to_award} points to child {child_id} for task {task_id}.",
                "new_total_points": child.current_noor_points}

    @staticmethod
    def deduct_points_for_reward_redemption(child_id, points_to_deduct):

        child = Child.query.get(child_id)
        if not child:
            raise NotFoundError(f"Child with ID {child_id} not found.")

        if points_to_deduct <= 0:
            raise ValidationError("Points to deduct must be a positive number.")

        if child.current_noor_points < points_to_deduct:
            raise ConflictError(f"Child {child_id} does not have enough points. Current: {child.current_noor_points}, Needed: {points_to_deduct}.")

        child.current_noor_points -= points_to_deduct
        db.session.commit()
        return {"message": f"Successfully deducted {points_to_deduct} points from child {child_id}.",
                "new_total_points": child.current_noor_points}

    @staticmethod
    def record_daily_feedback(child_id, data):

        errors = daily_feedback_schema.validate(data)
        if errors:
            raise ValidationError("Validation failed for daily feedback", errors)


        child = Child.query.get(child_id)
        if not child:
            raise NotFoundError(f"Child with ID {child_id} not found.")

        today = date.today()
        existing_feedback = DailyFeedback.query.filter_by(child_id=child_id, feedback_date=today).first()
        if existing_feedback:
            raise ConflictError(f"Daily feedback for child {child_id} already recorded for today.")


        feedback = DailyFeedback(id=str(uuid4()), child_id=child_id, feedback_date=today, **data)
        db.session.add(feedback)

      ## number of points based on feedback, by the end of the day if the child got a good feedback from the parents,
      ## the child get extra points based on the feedback (i suggest this extra points reward on last minutis) need team vote either to
      ## keep or remove
        points_awarded = 0
        if feedback.feedback_type == "happy":
            points_awarded = 10 #10 points for happy
        elif feedback.feedback_type == "satisfied":
            points_awarded = 5  #5 points for satisfied
                                 # No points for "not_satisfied"

        if points_awarded > 0:
            child.current_noor_points += points_awarded

        db.session.commit()
        return {"message": f"Daily feedback recorded and {points_awarded} points awarded.",
                "new_total_points": child.current_noor_points}

    @staticmethod
    def get_daily_feedback(child_id, feedback_date=None):
        # retrieve daily feedback for a child, optionally filtered by date(i am not sure of this code, my goal is to help us create dashbored for parants to track activity)
        query = DailyFeedback.query.filter_by(child_id=child_id)
        if feedback_date:
            query = query.filter_by(feedback_date=feedback_date)
        feedback_entries = query.all()
        return daily_feedback_schema.dump(feedback_entries, many=True)

    @staticmethod
    def get_child_current_points(child_id):
      
        child = Child.query.get(child_id)
        if not child:
            raise NotFoundError(f"Child with ID {child_id} not found.")
        return {"child_id": child_id, "current_noor_points": child.current_noor_points}
