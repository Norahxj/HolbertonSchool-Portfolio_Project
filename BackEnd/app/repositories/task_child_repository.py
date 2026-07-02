from sqlalchemy.exc import IntegrityError
from app.extensions import db
from app.models.task_child_model import TaskChild


class TaskChildRepository:

    def create_task_child(self, task_child):
        try:
            db.session.add(task_child)
            db.session.commit()
            return task_child, None
        except IntegrityError:
            db.session.rollback()
            return None, "integrity_error"

    def get_task_children_by_task(self, task_id):
        return TaskChild.query.filter_by(task_id=task_id).all()