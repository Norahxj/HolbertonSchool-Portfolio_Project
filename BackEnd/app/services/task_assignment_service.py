from datetime import datetime
from app.repositories.task_repository import TaskRepository
from app.repositories.task_assignment_repository import TaskAssignmentRepository


class TaskAssignmentService:
    def __init__(self):
        self.task_repository = TaskRepository()
        self.task_assignment_repository = TaskAssignmentRepository()

    def get_assignment(self, assignment_id):
        return self.task_assignment_repository.get_assignment_by_id(assignment_id)

    def get_assignments_for_task(self, task_id, parent_id):
        task = self.task_repository.get_task_for_creator(task_id, parent_id)

        if not task:
            return None

        return self.task_assignment_repository.get_assignments_by_task_id(task_id)

    def get_assignments_for_child(self, child_id):
        return self.task_assignment_repository.get_assignments_by_child_id(child_id)

    def complete_assignment(self, assignment_id, child_id):
        assignment = self.task_assignment_repository.get_assignment_for_child(
            assignment_id,
            child_id
        )

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

        success, error = self.task_assignment_repository.update_assignment()

        if not success:
            return None, "update_failed"

        return assignment, None

    def approve_assignment(self, assignment_id, parent_id):
        assignment = self.task_assignment_repository.get_assignment_for_parent(
            assignment_id,
            parent_id
        )

        if not assignment:
            return None, "assignment_not_found"

        if assignment.status != "PENDING_REVIEW":
            return None, "assignment_not_pending_review"

        assignment.status = "APPROVED"
        assignment.approved_at = datetime.now()

        success, error = self.task_assignment_repository.update_assignment()

        if not success:
            return None, "update_failed"

        return assignment, None

    def reject_assignment(self, assignment_id, parent_id):
        assignment = self.task_assignment_repository.get_assignment_for_parent(
            assignment_id,
            parent_id
        )

        if not assignment:
            return None, "assignment_not_found"

        if assignment.status != "PENDING_REVIEW":
            return None, "assignment_not_pending_review"

        assignment.status = "REJECTED"
        assignment.approved_at = None

        success, error = self.task_assignment_repository.update_assignment()

        if not success:
            return None, "update_failed"

        return assignment, None