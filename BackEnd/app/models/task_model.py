from app.extensions import db
from app.models.base_model import BaseModel
from datetime import datetime


class Task(BaseModel):
	__tablename__ = "tasks"

	title = db.Column(db.String(100), nullable=False)
	description = db.Column(db.String(500), nullable=False)
	child_id = db.Column(db.String(36), db.ForeignKey("children.id"), nullable=False)  
	points = db.Column(db.Integer, nullable=False)
	status = db.Column(db.String(20), default="PENDING", nullable=False)  
	task_type = db.Column(db.String(20), default="ONCE", nullable=False)  
	recurrence_day = db.Column(db.Integer, nullable=True)  
	category = db.Column(db.String(50), nullable=True)  
	is_auto_verified = db.Column(db.Boolean, default=False, nullable=False)
	verification_type = db.Column(db.String(20), default="MANUAL", nullable=False)  
	created_by = db.Column(db.String(36), db.ForeignKey("users.id"), nullable=False)  
	approved_at = db.Column(db.DateTime, nullable=True)