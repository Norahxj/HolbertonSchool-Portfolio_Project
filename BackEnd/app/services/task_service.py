from app.extensions import db
from app.models.task_model import Task
from app.models.child_model import Child
from app.models.user_model import User
from app.models.task_assignment_model import TaskAssignment

class TaskService:
    def _get_child_for_parent(self, child_id, parent_id):
        return (Child.query.join(Child.guardians).filter(Child.id == child_id, User.id == parent_id).first())

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
    
    def create_task(self, parent_id, task_data):
        child_ids = task_data["child_ids"]
        children = [
            self._get_child_for_parent(child_id, parent_id)
            for child_id in child_ids
        ]
        if any(child is None for child in children):
            return None, "child_not_found"
        task = self._build_task(parent_id, task_data)
        db.session.add(task)
        db.session.flush()
        for child in children:
            assignment = TaskAssignment(
                task_id=task.id, child_id=child.id,
                status="PENDING"
            )
            db.session.add(assignment)
        db.session.commit()
        return task, None

    def get_tasks_for_parent(self, parent_id):
        return Task.query.filter_by(created_by=parent_id).all()

    def get_tasks_by_child_for_parent(self, child_id, parent_id):
        child = self._get_child_for_parent(child_id, parent_id)
        if not child:
            return None
        return (
            Task.query.join(TaskAssignment).filter(
            TaskAssignment.child_id == child_id,
            Task.created_by == parent_id
            ).all()
        )
    
    def get_task_for_parent(self, task_id, parent_id):
        return Task.query.filter_by(id=task_id, created_by=parent_id).first()

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
        if "task_frequency" in task_data:
            task.task_frequency = task_data["task_frequency"]
        if task.task_frequency in ["WEEKLY", "MONTHLY"]:
            if "recurrence_day" in task_data:
                task.recurrence_day = task_data["recurrence_day"]
        else:
            task.recurrence_day = None
        if "category" in task_data:
            task.category = task_data["category"]
        if "is_auto_verified" in task_data:
            task.is_auto_verified = task_data["is_auto_verified"]
        db.session.commit()
        return task

    def delete_task_for_parent(self, task_id, parent_id):
        task = self.get_task_for_parent(task_id, parent_id)
        if not task:
            return None
        db.session.delete(task)
        db.session.commit()
        return True