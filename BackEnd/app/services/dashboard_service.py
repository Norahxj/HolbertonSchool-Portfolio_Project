from app.repositories.user_repository import UserRepository
from app.repositories.child_repository import ChildRepository
from app.repositories.task_assignment_repository import TaskAssignmentRepository
from datetime import timedelta
from app.utils.datetime_utils import riyadh_today


class DashboardService:

    def __init__(self):
        self.child_repository = ChildRepository()
        self.assignment_repository = TaskAssignmentRepository()
        self.user_repository = UserRepository()

    def get_parent_dashboard(self, parent_id):
        parent = self.user_repository.get_user_by_id(parent_id)

        if not parent:
            return None, "parent_not_found"

        children = self.child_repository.get_children_by_guardian(parent)

        today = riyadh_today()
        days_since_sunday = (today.weekday() - 4) % 7

        week_start = today - timedelta(days=days_since_sunday)
        week_end = week_start + timedelta(days=6)

        dashboard = []

        for child in children:
            assignments = (
                self.assignment_repository
                .get_child_assignments_between_dates(
                    child.id,
                    week_start,
                    week_end
                )
            )

            total_tasks = len(assignments)

            approved_tasks = sum(
                1
                for assignment in assignments
                if assignment.status == "APPROVED"
            )

            pending_review_tasks = sum(
                1
                for assignment in assignments
                if assignment.status == "PENDING_REVIEW"
            )

            pending_tasks = sum(
                1
                for assignment in assignments
                if assignment.status == "PENDING"
            )

            rejected_tasks = sum(
                1
                for assignment in assignments
                if assignment.status == "REJECTED"
            )

            completed_tasks = approved_tasks

            remaining_tasks = total_tasks - approved_tasks

            if total_tasks == 0:
                progress_percentage = 0
            else:
                progress_percentage = round(
                    (approved_tasks / total_tasks) * 100,
                    1
                )

            dashboard.append({
                "child_id": str(child.id),
                "child_name": child.name,
                "child_age": child.age,
                "week_start": week_start,
                "week_end": week_end,
                "progress_percentage": progress_percentage,
                "completed_tasks": completed_tasks,
                "approved_tasks": approved_tasks,
                "pending_review_tasks": pending_review_tasks,
                "pending_tasks": pending_tasks,
                "rejected_tasks": rejected_tasks,
                "remaining_tasks": remaining_tasks,
                "total_tasks": total_tasks
            })

        return dashboard, None