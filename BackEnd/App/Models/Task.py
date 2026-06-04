from App.Extensions import db
from App.Models.base_model import BaseModel
from datetime import datetime


class Task(BaseModel):
	"""
	Task model - represents a task assigned to a child.
	Fields:
	- title: Name of the task
	- description: Details about the task
	- child_id: ID of the child assigned to the task
	- points: Reward points for completing the task
	- status: Current status (PENDING, APPROVED, REJECTED)
	- task_type: Type of task (DAILY, WEEKLY, ONCE)
	- recurrence_day: Day of week for weekly tasks (0-6 where 0=Monday, 4=Friday)
	- category: Task category (Daily Chores, Culture, Financial, Religion)
	- is_auto_verified: Whether task is auto-verified or manually verified
	- verification_type: AUTO or MANUAL
	- created_by: ID of the user/parent who created the task
	- approved_at: Timestamp when the task was approved
	"""
	__tablename__ = "tasks"

	title = db.Column(db.String(100), nullable=False)
	description = db.Column(db.String(500), nullable=False)
	child_id = db.Column(db.String(36), nullable=False)  # UUID as string
	points = db.Column(db.Integer, nullable=False)
	status = db.Column(db.String(20), default="PENDING", nullable=False)  # PENDING, APPROVED, REJECTED
	task_type = db.Column(db.String(20), default="ONCE", nullable=False)  # ONCE, DAILY, WEEKLY
	recurrence_day = db.Column(db.Integer, nullable=True)  # 0-6 for weekly tasks (Monday=0, Friday=4)
	category = db.Column(db.String(50), nullable=True)  # Daily Chores, Culture, Financial, Religion
	is_auto_verified = db.Column(db.Boolean, default=False, nullable=False)
	verification_type = db.Column(db.String(20), default="MANUAL", nullable=False)  # AUTO or MANUAL
	created_by = db.Column(db.String(36), nullable=False)  # UUID as string
	approved_at = db.Column(db.DateTime, nullable=True)
	created_at = db.Column(db.DateTime, default=datetime.now, nullable=False)

	def approve(self):
		"""Mark the task as approved and set the approval timestamp"""
		self.status = "APPROVED"
		self.approved_at = datetime.now()
		db.session.commit()

	def reject(self):
		"""Mark the task as rejected and clear the approval timestamp"""
		self.status = "REJECTED"
		self.approved_at = None
		db.session.commit()

	def to_dict(self):
		"""Convert the task to a dictionary for API responses"""
		return {
			"id": self.id,
			"title": self.title,
			"description": self.description,
			"child_id": self.child_id,
			"points": self.points,
			"status": self.status,
			"task_type": self.task_type,
			"recurrence_day": self.recurrence_day,
			"category": self.category,
			"is_auto_verified": self.is_auto_verified,
			"verification_type": self.verification_type,
			"created_by": self.created_by,
			"approved_at": self.approved_at,
			"created_at": self.created_at
		}
