from App.Extensions import db
from App.Models.base_model import BaseModel
from datetime import datetime, timedelta


class Point(BaseModel):
	"""
	Point model - represents daily points earned by a child from completing tasks.
	
	Fields:
	- child_id: ID of the child earning points
	- task_id: ID of the completed task
	- points_earned: Number of points earned from this task
	- points_set_by_parent: Points value set by parent (1-5) for this specific task
	- earning_date: Date when points were earned
	- created_by: ID of the parent who assigned the points
	- notes: Optional notes about the points assignment
	"""
	__tablename__ = "points"

	child_id = db.Column(db.String(36), nullable=False)  # UUID as string
	task_id = db.Column(db.String(36), nullable=True)  # UUID as string (optional)
	points_earned = db.Column(db.Integer, nullable=False)  # Actual points earned
	points_set_by_parent = db.Column(db.Integer, default=5, nullable=False)  # 1-5 points set by parent
	earning_date = db.Column(db.Date, nullable=False, default=datetime.now().date)  # Date earned
	created_by = db.Column(db.String(36), nullable=False)  # UUID as string (parent)
	notes = db.Column(db.String(200), nullable=True)  # Optional notes
	created_at = db.Column(db.DateTime, default=datetime.now, nullable=False)

	def to_dict(self):
		"""Convert the point to a dictionary for API responses"""
		return {
			"id": self.id,
			"child_id": self.child_id,
			"task_id": self.task_id,
			"points_earned": self.points_earned,
			"points_set_by_parent": self.points_set_by_parent,
			"earning_date": self.earning_date.isoformat(),
			"notes": self.notes,
			"created_at": self.created_at
		}

	@staticmethod
	def get_daily_points(child_id, date=None):
		"""Get total points earned by a child on a specific date"""
		if date is None:
			date = datetime.now().date()
		
		points = Point.query.filter_by(
			child_id=child_id,
			earning_date=date
		).all()
		
		return sum([p.points_earned for p in points])

	@staticmethod
	def get_weekly_points(child_id, weeks_back=0):
		"""Get total points earned by a child in a specific week (0=current week)"""
		today = datetime.now().date()
		monday = today - timedelta(days=today.weekday() + (7 * weeks_back))
		sunday = monday + timedelta(days=6)
		
		points = Point.query.filter(
			Point.child_id == child_id,
			Point.earning_date >= monday,
			Point.earning_date <= sunday
		).all()
		
		return sum([p.points_earned for p in points])

	@staticmethod
	def get_points_history(child_id, days=30):
		"""Get points history for the past N days"""
		start_date = datetime.now().date() - timedelta(days=days)
		
		points = Point.query.filter(
			Point.child_id == child_id,
			Point.earning_date >= start_date
		).order_by(Point.earning_date.desc()).all()
		
		return [p.to_dict() for p in points]
