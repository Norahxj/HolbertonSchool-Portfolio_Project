from app.extensions import db
from app.models.base_model import BaseModel

class Task(BaseModel):
	__tablename__ = "tasks"
	__table_args__ = (
    	db.CheckConstraint(
        	"points > 0",
        	name="ck_tasks_points_positive"
    	),
    	db.CheckConstraint(
        	"task_frequency IN " "('ONCE', 'DAILY', 'WEEKLY', 'MONTHLY')",
        	name="ck_tasks_frequency"
    	),
    	db.CheckConstraint(
        	"category IN " "('RELIGIOUS', 'FINANCIAL', 'MORAL', 'SOCIAL')",
        	name="ck_tasks_category"
    	),
    	db.CheckConstraint(
        	"""
        	(task_frequency IN ('ONCE', 'DAILY') AND recurrence_day IS NULL)
        	OR
        	(task_frequency = 'WEEKLY' AND recurrence_day BETWEEN 0 AND 6)
        	OR
        	(task_frequency = 'MONTHLY' AND recurrence_day BETWEEN 1 AND 31)
        	""",
        	name="ck_tasks_recurrence_day"
    	),
	)

	title = db.Column(db.String(100), nullable=False)
	description = db.Column(db.String(500), nullable=False)
	points = db.Column(db.Integer, nullable=False)
	task_frequency = db.Column(db.String(20), default="ONCE", nullable=False)  
	recurrence_day = db.Column(db.Integer, nullable=True)  
	category = db.Column(db.String(50), nullable=False)  
	is_auto_verified = db.Column(db.Boolean, default=False, nullable=False)
	created_by = db.Column(db.String(36), db.ForeignKey("users.id", ondelete="CASCADE"), nullable=False)  
	assignments = db.relationship("TaskAssignment", backref="task", lazy=True, passive_deletes=True)