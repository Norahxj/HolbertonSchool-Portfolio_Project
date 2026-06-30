from app.extensions import db
from app.models.base_model import BaseModel
from datetime import datetime, timedelta


class Reward(BaseModel):
	__tablename__ = "rewards"

	child_id = db.Column(db.String(36), nullable=False)  
	reward_name = db.Column(db.String(100), nullable=False)  
	description = db.Column(db.String(500), nullable=True)  
	cost_in_points = db.Column(db.Integer, nullable=True)  
	reward_value = db.Column(db.String(100), nullable=True)  
	reward_type = db.Column(db.String(50), nullable=False) 
	is_active = db.Column(db.Boolean, default=True, nullable=False)  
	week_start_date = db.Column(db.Date, nullable=False)  
	week_end_date = db.Column(db.Date, nullable=False)  
	assigned_by = db.Column(db.String(36), nullable=False)  
	notes = db.Column(db.String(300), nullable=True)  
	created_at = db.Column(db.DateTime, default=datetime.now, nullable=False)