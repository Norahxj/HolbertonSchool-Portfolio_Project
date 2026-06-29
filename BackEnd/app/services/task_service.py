from datetime import datetime

from app.extensions import db
from app.models.task_model import Task
from app.models.child_model import Child


class TaskService:

    def create_task(self, parent_id, task_data):
        child = Child.query.filter_by(
            id=task_data["child_id"],
            parent_id=parent_id
        ).first()

        if not child:
            return None, "child_not_found"

        task = Task(
            title=task_data["title"].strip(),
            description=task_data["description"].strip(),
            child_id=task_data["child_id"],
            points=task_data["points"],
            task_type=task_data.get("task_type", "ONCE"),
            recurrence_day=task_data.get("recurrence_day"),
            category=task_data.get("category"),
            is_auto_verified=task_data.get("is_auto_verified", False),
            verification_type="AUTO" if task_data.get("is_auto_verified", False) else "MANUAL",
            created_by=parent_id,
            status="PENDING"
        )

        db.session.add(task)
        db.session.commit()
        return task, None

    def get_tasks_for_parent(self, parent_id):
        return (
            Task.query
            .join(Child, Task.child_id == Child.id)
            .filter(Child.parent_id == parent_id)
            .all()
        )

    def get_tasks_by_child_for_parent(self, child_id, parent_id):
        child = Child.query.filter_by(id=child_id, parent_id=parent_id).first()

        if not child:
            return None

        return Task.query.filter_by(child_id=child_id).all()

    def get_task_for_parent(self, task_id, parent_id):
        return (
            Task.query
            .join(Child, Task.child_id == Child.id)
            .filter(Task.id == task_id, Child.parent_id == parent_id)
            .first()
        )

    def update_task_for_parent(self, task_id, parent_id, task_data):
        task = self.get_task_for_parent(task_id, parent_id)

        if not task:
            return None

        if "title" in task_data:
            task.title = task_data["title"].strip()

        if "description" in task_data:
            task.description = task_data["description"].strip()

        if "points" in task_data:
            task.points = task_data["points"]

        if "task_type" in task_data:
            task.task_type = task_data["task_type"]

        if task.task_type == "WEEKLY":
            if "recurrence_day" in task_data:
                task.recurrence_day = task_data["recurrence_day"]
        else:
            task.recurrence_day = None

        if "category" in task_data:
            task.category = task_data["category"]

        if "is_auto_verified" in task_data:
            task.is_auto_verified = task_data["is_auto_verified"]
            task.verification_type = "AUTO" if task.is_auto_verified else "MANUAL"

        db.session.commit()
        return task

    def delete_task_for_parent(self, task_id, parent_id):
        task = self.get_task_for_parent(task_id, parent_id)

        if not task:
            return None

        db.session.delete(task)
        db.session.commit()
        return True

    def approve_task_for_parent(self, task_id, parent_id):
        task = self.get_task_for_parent(task_id, parent_id)

        if not task:
            return None, "task_not_found"
        if task.status != "PENDING_REVIEW":
            return None, "task_not_pending_review"

        task.status = "APPROVED"
        task.approved_at = datetime.now()
        db.session.commit()
        return task, None

    def reject_task_for_parent(self, task_id, parent_id):
        task = self.get_task_for_parent(task_id, parent_id)

        if not task:
            return None, "task_not_found"
        if task.status != "PENDING_REVIEW":
            return None, "task_not_pending_review"

        task.status = "REJECTED"
        task.approved_at = None
        db.session.commit()
        return task, None
    
    def complete_task_for_child(self, task_id, child_id):
        task = Task.query.filter_by(
            id=task_id,
            child_id=child_id
        ).first()

        if not task:
            return None, "task_not_found"

        if task.status in ["PENDING_REVIEW", "APPROVED"]:
            return None, "task_already_completed"

        if task.is_auto_verified:
            task.status = "APPROVED"
            task.approved_at = datetime.now()
        else:
            task.status = "PENDING_REVIEW"
            task.approved_at = None

        db.session.commit()
        return task, None