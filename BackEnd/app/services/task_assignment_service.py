from datetime import datetime
from app.extensions import db
from app.models.task_assignment_model import TaskAssignment
from app.models.task_model import Task

class TaskAssignmentService:
    def get_assignment(self, assignment_id):
        return db.session.get(TaskAssignment, assignment_id)

    def get_assignments_for_task(self, task_id, parent_id):
        task = Task.query.filter_by(
            id=task_id,
            created_by=parent_id
        ).first()
        if not task:
            return None
        return TaskAssignment.query.filter_by(task_id=task_id).all()

    def get_assignments_for_child(self, child_id):
        return TaskAssignment.query.filter_by(child_id=child_id).all()

    def complete_assignment(self, assignment_id, child_id):
        assignment = TaskAssignment.query.filter_by(
            id=assignment_id,
            child_id=child_id
        ).first()
        if not assignment:
            return None, "assignment_not_found"
        if assignment.status in ["PENDING_REVIEW", "APPROVED"]:
            return None, "assignment_already_completed"
        if assignment.task.is_auto_verified:
            assignment.status = "APPROVED"
            assignment.completed_at = datetime.now()
            assignment.approved_at = datetime.now()
        else:
            assignment.status = "PENDING_REVIEW"
            assignment.completed_at = datetime.now()
            assignment.approved_at = None
        db.session.commit()
        return assignment, None

    def approve_assignment(self, assignment_id, parent_id):
        assignment = (
            TaskAssignment.query
            .join(Task)
            .filter(
                TaskAssignment.id == assignment_id,
                Task.created_by == parent_id
            ).first()
        )

        if not assignment:
            return None, "assignment_not_found"
        if assignment.status != "PENDING_REVIEW":
            return None, "assignment_not_pending_review"
        assignment.status = "APPROVED"
        assignment.approved_at = datetime.now()
        db.session.commit()
        return assignment, None

    def reject_assignment(self, assignment_id, parent_id):
        assignment = (
            TaskAssignment.query
            .join(Task)
            .filter(
                TaskAssignment.id == assignment_id,
                Task.created_by == parent_id
            ).first()
        )
        if not assignment:
            return None, "assignment_not_found"
        if assignment.status != "PENDING_REVIEW":
            return None, "assignment_not_pending_review"
        assignment.status = "REJECTED"
        assignment.approved_at = None
        db.session.commit()
        return assignment, None