from app.models.task_model import Task
from app.models.task_assignment_model import TaskAssignment
from app.repositories.task_repository import TaskRepository
from app.repositories.task_assignment_repository import TaskAssignmentRepository
from app.repositories.child_repository import ChildRepository
from app.models.task_child_model import TaskChild
from app.repositories.task_child_repository import TaskChildRepository
from datetime import date


class TaskService:
    def __init__(self):
        self.task_repository = TaskRepository()
        self.task_assignment_repository = TaskAssignmentRepository()
        self.child_repository = ChildRepository()
        self.task_child_repository = TaskChildRepository()

    def _build_task(self, parent_id, task_data):
        return Task(
            title=task_data["title"].strip(),
            description=task_data["description"].strip(),
            points=task_data["points"],
            task_frequency=task_data.get("task_frequency", "ONCE"),
            recurrence_day=task_data.get("recurrence_day"),
            category=task_data.get("category"),
            is_auto_verified=task_data.get("is_auto_verified", False),
            created_by=parent_id
        )

    def _validate_recurrence_for_update(self, task, task_data):
        new_frequency = task_data.get("task_frequency", task.task_frequency)
        new_recurrence_day = task_data.get("recurrence_day", task.recurrence_day)

        if new_frequency in ["ONCE", "DAILY"]:
            return new_frequency, None, None

        if new_frequency == "WEEKLY":
            if new_recurrence_day is None or new_recurrence_day < 0 or new_recurrence_day > 6:
                return None, None, "invalid_recurrence_day"

        if new_frequency == "MONTHLY":
            if new_recurrence_day is None or new_recurrence_day < 1 or new_recurrence_day > 31:
                return None, None, "invalid_recurrence_day"

        return new_frequency, new_recurrence_day, None

    def create_task(self, parent_id, task_data):
        child_ids = task_data["child_ids"]

        if len(child_ids) != len(set(child_ids)):
            return None, "duplicate_child_ids"

        children = [
            self.child_repository.get_child_for_guardian(child_id, parent_id)
            for child_id in child_ids
        ]

        if any(child is None for child in children):
            return None, "child_not_found"

        task = self._build_task(parent_id, task_data)
        task, error = self.task_repository.create_task(task)

        if error:
            return None, "create_failed"
        for child in children:
            task_child = TaskChild(
                task_id=task.id,
                child_id=child.id
            )

            _, error = self.task_child_repository.create_task_child(task_child)

            if error:
                return None, "task_child_failed"

            assignment = TaskAssignment(
                task_id=task.id,
                child_id=child.id,
                assigned_date=date.today(),
                status="PENDING"
            )

            _, error = self.task_assignment_repository.create_assignment(assignment)

            if error:
                return None, "assignment_failed"

        return task, None

    def get_tasks_for_parent(self, parent_id):
         return self.task_repository.get_tasks_for_guardian_children(parent_id)

    def get_task_for_parent(self, task_id, parent_id):
        return self.task_repository.get_task_for_guardian_children(task_id, parent_id)
    
    def get_tasks_by_child_for_parent(self, child_id, parent_id):
        child = self.child_repository.get_child_for_guardian(child_id, parent_id)

        if not child:
            return None

        return [assignment.task for assignment in child.task_assignments]

    def update_task_for_parent(self, task_id, parent_id, task_data):
        task = self.task_repository.get_task_for_creator(task_id, parent_id)

        if not task:
            return None, "not_found"

        new_frequency, new_recurrence_day, error = self._validate_recurrence_for_update(task, task_data)

        if error:
            return None, error

        if "title" in task_data:
            task.title = task_data["title"].strip()

        if "description" in task_data:
            task.description = task_data["description"].strip()

        if "points" in task_data:
            task.points = task_data["points"]

        if "category" in task_data:
            task.category = task_data["category"]

        if "is_auto_verified" in task_data:
            task.is_auto_verified = task_data["is_auto_verified"]

        task.task_frequency = new_frequency
        task.recurrence_day = new_recurrence_day

        success, error = self.task_repository.update_task()

        if not success:
            return None, "update_failed"

        return task, None

    def delete_task_for_parent(self, task_id, parent_id):
        task = self.task_repository.get_task_for_creator(task_id, parent_id)

        if not task:
            return False, "task_not_found"

        success, error = self.task_repository.delete_task(task)

        if not success:
            return False, "delete_error"

        return True, None