from sqlalchemy.exc import IntegrityError
from app.extensions import db
from app.models.task_model import Task
from app.models.child_model import Child
from app.models.user_model import User
from app.models.task_assignment_model import TaskAssignment
from app.models.task_child_model import TaskChild


class TaskRepository:

    def get_task_by_id(self, task_id):
        return db.session.get(Task, task_id)

    def get_tasks_by_creator(self, parent_id):
        return Task.query.filter_by(created_by=parent_id).all()
    
    def get_task_for_creator(self, task_id, parent_id):
        return Task.query.filter_by(id=task_id, created_by=parent_id).first()

    def create_task(self, task, commit=True):
        try:
            db.session.add(task)
            if commit:
                db.session.commit()
            else:
                db.session.flush()
            return task, None

        except IntegrityError:
            db.session.rollback()
            return None, "integrity_error"

    def update_task(self):
        try:
            db.session.commit()
            return True, None
        except IntegrityError:
            db.session.rollback()
            return False, "integrity_error"

    def delete_task(self, task):
        try:
            db.session.delete(task)
            db.session.commit()
            return True, None
        except Exception:
            db.session.rollback()
            return False, "delete_error"
        
    def get_recurring_tasks(self):
        return Task.query.filter(
            Task.task_frequency.in_(["DAILY", "WEEKLY", "MONTHLY"])
        ).all()
    
    def get_tasks_for_guardian_children(self, parent_id):
        return (
            Task.query
            .join(TaskChild, TaskChild.task_id == Task.id)
            .join(Child, Child.id == TaskChild.child_id)
            .join(Child.guardians)
            .filter(User.id == parent_id)
            .distinct()
            .all()
        )
    
    def get_task_for_guardian_children(self, task_id, parent_id):
        return (
            Task.query
            .join(TaskChild, TaskChild.task_id == Task.id)
            .join(Child, Child.id == TaskChild.child_id)
            .join(Child.guardians)
            .filter(
                Task.id == task_id,
                User.id == parent_id
            )
            .first()
        )