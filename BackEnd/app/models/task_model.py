from app.extensions import db
from app.models.base_model import BaseModel

class Task(BaseModel):
	__tablename__ = "tasks"

	title = db.Column(db.String(100), nullable=False)
	description = db.Column(db.String(500), nullable=False)
	points = db.Column(db.Integer, nullable=False)
	task_frequency = db.Column(db.String(20), default="ONCE", nullable=False)  
	recurrence_day = db.Column(db.Integer, nullable=True)  
	category = db.Column(db.String(50), nullable=True)  
	is_auto_verified = db.Column(db.Boolean, default=False, nullable=False)
	created_by = db.Column(db.String(36), db.ForeignKey("users.id", ondelete="CASCADE"), nullable=False)  
	assignments = db.relationship("TaskAssignment", backref="task", lazy=True, cascade="all, delete-orphan")