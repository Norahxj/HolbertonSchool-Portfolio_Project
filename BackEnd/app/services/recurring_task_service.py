from datetime import date
from app.models.task_assignment_model import TaskAssignment
from app.repositories.task_repository import TaskRepository
from app.repositories.task_assignment_repository import TaskAssignmentRepository


class RecurringTaskService:
    def __init__(self):
        self.task_repository = TaskRepository()
        self.assignment_repository = TaskAssignmentRepository()

    def generate_today_assignments(self):
        today = date.today()
        weekday = today.weekday()
        month_day = today.day

        tasks = self.task_repository.get_recurring_tasks()

        for task in tasks:
            if not self._should_generate_today(task, weekday, month_day):
                continue

            for task_child in task.task_children:
                existing = self.assignment_repository.get_assignment_for_date(
                    task.id,
                    task_child.child_id,
                    today
                )

                if existing:
                    continue

                new_assignment = TaskAssignment(
                    task_id=task.id,
                    child_id=task_child.child_id,
                    assigned_date=today,
                    status="PENDING"
                )

                self.assignment_repository.create_assignment(new_assignment)
                
    def _should_generate_today(self, task, weekday, month_day):
        if task.task_frequency == "DAILY":
            return True

        if task.task_frequency == "WEEKLY":
            return task.recurrence_day == weekday

        if task.task_frequency == "MONTHLY":
            return task.recurrence_day == month_day

        return False