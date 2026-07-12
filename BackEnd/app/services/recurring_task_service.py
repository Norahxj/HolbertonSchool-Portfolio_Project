from datetime import datetime
from zoneinfo import ZoneInfo
from app.models.task_assignment_model import TaskAssignment
from app.repositories.task_repository import TaskRepository
from app.repositories.task_assignment_repository import TaskAssignmentRepository
from app.utils.recurrence_utils import is_task_due_on_date
RIYADH_TIMEZONE = ZoneInfo("Asia/Riyadh")

class RecurringTaskService:
    def __init__(self):
        self.task_repository = TaskRepository()
        self.assignment_repository = TaskAssignmentRepository()

    def generate_today_assignments(self):
        today = datetime.now(RIYADH_TIMEZONE).date()

        tasks = self.task_repository.get_recurring_tasks()

        created_count = 0

        for task in tasks:
            if not is_task_due_on_date(
                task.task_frequency,
                task.recurrence_day,
                today
            ):
                continue

            for task_child in task.task_children:
                existing = (
                    self.assignment_repository
                    .get_assignment_for_date(
                        task.id,
                        task_child.child_id,
                        today
                    )
                )

                if existing:
                    continue

                new_assignment = TaskAssignment(
                    task_id=task.id,
                    child_id=task_child.child_id,
                    assigned_date=today,
                    status="PENDING"
                )

                assignment, error = (
                    self.assignment_repository
                    .create_assignment(new_assignment)
                )

                if error:
                    return None, "assignment_failed"

                created_count += 1

        return created_count, None