from datetime import date, timedelta
from app.repositories.user_repository import UserRepository
from app.repositories.child_repository import ChildRepository
from app.repositories.task_assignment_repository import TaskAssignmentRepository


class DashboardService:

    def __init__(self):
        self.child_repository = ChildRepository()
        self.assignment_repository = TaskAssignmentRepository()
        self.user_repository = UserRepository()

    def get_parent_dashboard(self, parent_id):
        guardian = self.user_repository.get_by_id(parent_id)
        if not guardian:
            return None
        children = self.child_repository.get_children_by_guardian(guardian)

        today = date.today()

        days_since_sunday = (today.weekday() + 1) % 7

        week_start = today - timedelta(days=days_since_sunday)
        week_end = week_start + timedelta(days=6)

        dashboard = []

        for child in children:

            assignments = self.assignment_repository.get_child_assignments_between_dates(
                child.id,
                week_start,
                week_end
            )

            total = len(assignments)

            approved = sum(
                1
                for assignment in assignments
                if assignment.status == "APPROVED"
            )

            pending_review = sum(
                1
                for assignment in assignments
                if assignment.status == "PENDING_REVIEW"
            )

            remaining = total - approved - pending_review

            progress = 0

            if total > 0:
                progress = round((approved / total) * 100, 1)

            dashboard.append({
                "child_id": str(child.id),
                "child_name": child.name,
                "week_start": week_start.isoformat(),
                "week_end": week_end.isoformat(),
                "progress_percentage": progress,
                "completed_tasks": approved,
                "pending_review_tasks": pending_review,
                "remaining_tasks": remaining,
                "total_tasks": total
            })

        return dashboard