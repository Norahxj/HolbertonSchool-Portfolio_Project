from sqlalchemy.exc import IntegrityError
from app.extensions import db
from app.models.task_assignment_model import TaskAssignment
from app.models.task_model import Task
from sqlalchemy.orm import joinedload

class TaskAssignmentRepository:

    def get_assignment_by_id(self, assignment_id):
        return db.session.get(TaskAssignment, assignment_id)

    def create_assignment(self, assignment, commit=True):
        try:
            db.session.add(assignment)
            if commit:
                db.session.commit()
            else:
                db.session.flush()
            return assignment, None
        except IntegrityError:
            db.session.rollback()
            return None, "integrity_error"

    def update_assignment(self, commit=True):
        try:
            if commit:
                db.session.commit()
            else:
                db.session.flush()
            return True, None
        except IntegrityError:
            db.session.rollback()
            return False, "integrity_error"
        
    def get_assignment_for_child(self, assignment_id, child_id):
        return TaskAssignment.query.filter_by(id=assignment_id, child_id=child_id).first()

    def get_assignments_by_task_id(self, task_id):
        return (
            TaskAssignment.query
            .options(
                joinedload(TaskAssignment.task),
                joinedload(TaskAssignment.child),
            )
            .filter_by(task_id=task_id)
            .order_by(TaskAssignment.assigned_date.desc())
            .all()
        )
    def get_assignments_by_child_id(self, child_id):
        return (
            TaskAssignment.query
            .options(
                joinedload(TaskAssignment.task),
                joinedload(TaskAssignment.child),
            )
            .filter_by(child_id=child_id)
            .order_by(TaskAssignment.assigned_date.desc())
            .all()
        )
    def get_assignment_for_parent(self, assignment_id, parent_id):
        return (
            TaskAssignment.query.join(TaskAssignment.task)
            .filter(
                TaskAssignment.id == assignment_id, Task.created_by == parent_id
            ).first()
        )
    
    def get_assignment_for_date(self, task_id, child_id, assigned_date):
        return TaskAssignment.query.filter_by(task_id=task_id, child_id=child_id, assigned_date=assigned_date).first()
    
    def get_child_assignments_between_dates(self, child_id, start_date, end_date,):
        return (
            TaskAssignment.query
            .options(
                joinedload(TaskAssignment.task),
                joinedload(TaskAssignment.child),
            )
            .filter(
                TaskAssignment.child_id == child_id,
                TaskAssignment.assigned_date >= start_date,
                TaskAssignment.assigned_date <= end_date,
            )
            .order_by(TaskAssignment.assigned_date.desc())
            .all()
        )