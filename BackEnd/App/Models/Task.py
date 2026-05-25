from app.extensions import db
from app.models.base_model import BaseModel
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
	- created_by: ID of the user/parent who created the task
	- approved_at: Timestamp when the task was approved
	"""
	__tablename__ = "tasks"

	title = db.Column(db.String(100), nullable=False)
	description = db.Column(db.String(500), nullable=False)
	child_id = db.Column(db.String(36), db.ForeignKey("children.id"), nullable=False)  
	points = db.Column(db.Integer, nullable=False)
	status = db.Column(db.String(20), default="PENDING", nullable=False)  # PENDING, APPROVED, REJECTED
	created_by = db.Column(db.String(36), db.ForeignKey("users.id"), nullable=False)  
	approved_at = db.Column(db.DateTime, nullable=True)

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
			"created_by": self.created_by,
			"approved_at": self.approved_at,
			"created_at": self.created_at
		}
