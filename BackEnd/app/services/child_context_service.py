from app.repositories.child_repository import ChildRepository
from app.repositories.task_assignment_repository import (
    TaskAssignmentRepository,
)
from app.repositories.points_history_repository import (
    PointsHistoryRepository,
)
from app.repositories.wishlist_repository import WishlistRepository


class ChildContextService:
    def __init__(self):
        self.child_repository = ChildRepository()
        self.task_assignment_repository = (
            TaskAssignmentRepository()
        )
        self.points_history_repository = (
            PointsHistoryRepository()
        )
        self.wishlist_repository = WishlistRepository()

    def get_child_context(
        self,
        child_id,
        guardian_id,
    ):
        child = (
            self.child_repository
            .get_child_for_guardian(
                child_id,
                guardian_id,
            )
        )

        if not child:
            return None, "child_not_found"

        assignments = (
            self.task_assignment_repository
            .get_assignments_by_child_id(child_id)
        )

        points_history = (
            self.points_history_repository
            .get_history_by_child_id(child_id)
        )

        wishes = (
            self.wishlist_repository
            .get_wishes_by_child_id(child_id)
        )

        current_points = (
            child.points_record.total_points
            if child.points_record
            else 0
        )

        task_history = []

        for assignment in assignments:
            task_history.append({
                "assignment_id": assignment.id,
                "task_id": assignment.task_id,
                "title": assignment.task.title,
                "description": assignment.task.description,
                "category": assignment.task.category,
                "points": assignment.task.points,
                "frequency": assignment.task.task_frequency,
                "status": assignment.status,
                "assigned_date": (
                    assignment.assigned_date.isoformat()
                    if assignment.assigned_date
                    else None
                ),
                "completed_at": (
                    assignment.completed_at.isoformat()
                    if assignment.completed_at
                    else None
                ),
                "approved_at": (
                    assignment.approved_at.isoformat()
                    if assignment.approved_at
                    else None
                ),
            })

        points_history_data = []

        for history in points_history:
            points_history_data.append({
                "points": history.points,
                "action": history.action,
                "created_at": (
                    history.created_at.isoformat()
                    if history.created_at
                    else None
                ),
            })

        wishlist_data = []

        for wish in wishes:
            wishlist_data.append({
                "id": wish.id,
                "name": wish.name,
                "target_points": wish.target_points,
                "status": wish.status,
                "created_at": (
                    wish.created_at.isoformat()
                    if wish.created_at
                    else None
                ),
            })

        history_summary = (
            self._build_history_summary(
                assignments
            )
        )

        points_summary = (
            self._build_points_summary(
                points_history,
                current_points,
            )
        )

        wishlist_summary = (
            self._build_wishlist_summary(
                wishes,
                current_points,
            )
        )

        context = {
            "child": {
                "id": child.id,
                "name": child.name,
                "age": child.age,
                "current_points": current_points,
            },
            "history_summary": history_summary,
            "task_history": task_history,
            "points_summary": points_summary,
            "wishlist_summary": wishlist_summary,
            "points_history": points_history_data,
            "wishlist": wishlist_data,
        }

        return context, None

    def _build_history_summary(
        self,
        assignments,
    ):
        total_tasks = len(assignments)

        approved_tasks = 0
        rejected_tasks = 0
        pending_tasks = 0
        pending_review_tasks = 0

        total_approved_points = 0

        categories = {
            "RELIGIOUS": {
                "total": 0,
                "approved": 0,
                "rejected": 0,
            },
            "FINANCIAL": {
                "total": 0,
                "approved": 0,
                "rejected": 0,
            },
            "MORAL": {
                "total": 0,
                "approved": 0,
                "rejected": 0,
            },
            "SOCIAL": {
                "total": 0,
                "approved": 0,
                "rejected": 0,
            },
        }

        for assignment in assignments:
            status = assignment.status
            task = assignment.task

            if status == "APPROVED":
                approved_tasks += 1
                total_approved_points += task.points

            elif status == "REJECTED":
                rejected_tasks += 1

            elif status == "PENDING":
                pending_tasks += 1

            elif status == "PENDING_REVIEW":
                pending_review_tasks += 1

            category = task.category

            if category in categories:
                categories[category]["total"] += 1

                if status == "APPROVED":
                    categories[
                        category
                    ]["approved"] += 1

                elif status == "REJECTED":
                    categories[
                        category
                    ]["rejected"] += 1

        decided_tasks = (
            approved_tasks
            + rejected_tasks
        )

        if decided_tasks > 0:
            completion_rate = round(
                approved_tasks / decided_tasks,
                2,
            )
        else:
            completion_rate = 0

        if approved_tasks > 0:
            average_completed_task_points = round(
                (
                    total_approved_points
                    / approved_tasks
                ),
                2,
            )
        else:
            average_completed_task_points = 0

        for category_data in categories.values():
            category_decided = (
                category_data["approved"]
                + category_data["rejected"]
            )

            if category_decided > 0:
                category_data[
                    "completion_rate"
                ] = round(
                    (
                        category_data["approved"]
                        / category_decided
                    ),
                    2,
                )
            else:
                category_data[
                    "completion_rate"
                ] = 0

        has_enough_history = (
            decided_tasks >= 5
        )

        return {
            "total_tasks": total_tasks,
            "approved_tasks": approved_tasks,
            "rejected_tasks": rejected_tasks,
            "pending_tasks": pending_tasks,
            "pending_review_tasks": (
                pending_review_tasks
            ),
            "completion_rate": completion_rate,
            "average_completed_task_points": (
                average_completed_task_points
            ),
            "categories": categories,
            "has_enough_history": (
                has_enough_history
            ),
        }

    def _build_points_summary(
        self,
        points_history,
        current_points,
    ):
        total_earned = 0
        total_spent = 0

        task_points_earned = 0
        wishes_achieved = 0

        for history in points_history:
            if history.points > 0:
                total_earned += history.points

            elif history.points < 0:
                total_spent += abs(
                    history.points
                )

            if (
                history.task_assignment_id
                and history.points > 0
            ):
                task_points_earned += (
                    history.points
                )

            if (
                history.action
                == "WISH_ACHIEVED"
            ):
                wishes_achieved += 1

        return {
            "current_points": current_points,
            "total_earned": total_earned,
            "total_spent": total_spent,
            "task_points_earned": (
                task_points_earned
            ),
            "wishes_achieved": wishes_achieved,
        }

    def _build_wishlist_summary(
        self,
        wishes,
        current_points,
    ):
        pending_wishes = 0
        approved_wishes = 0
        rejected_wishes = 0
        achieved_wishes = 0

        active_goals = []

        for wish in wishes:
            if wish.status == "PENDING":
                pending_wishes += 1

            elif wish.status == "APPROVED":
                approved_wishes += 1

                remaining_points = max(
                    (
                        wish.target_points
                        - current_points
                    ),
                    0,
                )

                progress_percentage = round(
                    min(
                        (
                            current_points
                            / wish.target_points
                        ),
                        1,
                    ),
                    2,
                )

                active_goals.append({
                    "id": wish.id,
                    "name": wish.name,
                    "target_points": (
                        wish.target_points
                    ),
                    "current_points": (
                        current_points
                    ),
                    "remaining_points": (
                        remaining_points
                    ),
                    "progress_percentage": (
                        progress_percentage
                    ),
                })

            elif wish.status == "REJECTED":
                rejected_wishes += 1

            elif wish.status == "ACHIEVED":
                achieved_wishes += 1

        return {
            "pending_wishes": pending_wishes,
            "approved_wishes": approved_wishes,
            "rejected_wishes": rejected_wishes,
            "achieved_wishes": achieved_wishes,
            "active_goals": active_goals,
        }