from app.repositories.user_repository import UserRepository
from app.repositories.child_repository import ChildRepository
from app.repositories.task_assignment_repository import TaskAssignmentRepository
from datetime import timedelta
from app.utils.datetime_utils import riyadh_today
from app.repositories.point_repository import PointRepository

class DashboardService:
    def __init__(self):
        self.child_repository = ChildRepository()
        self.assignment_repository = TaskAssignmentRepository()
        self.user_repository = UserRepository()
        self.point_repository = PointRepository()

    def get_dashboard(self, user_id, role):
        if role == "parent":
            parent = self.user_repository.get_user_by_id(user_id)
            if not parent:
                return None, "parent_not_found"
            children = (
                self.child_repository
                .get_children_by_guardian(parent)
            )
        elif role == "child":
            child = self.child_repository.get_child_by_id(user_id)
            if not child:
                return None, "child_not_found"
            children = [child]
        else:
            return None, "invalid_role"
        today = riyadh_today()
        days_since_friday = (today.weekday() - 4) % 7
        week_start = today - timedelta(days=days_since_friday)
        week_end = week_start + timedelta(days=6)
        dashboard = []
        for child in children:
            points_record = self.point_repository.get_points_by_child_id(child.id)
            total_points = points_record.total_points if points_record else 0
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
                "total_tasks": total_tasks,
                "total_points": total_points
            })
        return dashboard, None