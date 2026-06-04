from App.Extensions import db
from App.Models.base_model import BaseModel
from datetime import datetime


class DailyFeedback(BaseModel):
	"""
	DailyFeedback model - represents daily feedback from parent to child.
	Fields:
	- child_id: ID of the child receiving the feedback
	- feedback_date: The date for which feedback is given
	- emoji_value: Emoji rating (1=Happy/😊, 2=Neutral/😐, 3=Sad/😢)
	- feedback_text: Optional text feedback from parent
	- created_by: ID of the parent who created the feedback
	"""
	__tablename__ = "daily_feedback"

	child_id = db.Column(db.String(36), nullable=False)  # UUID as string
	feedback_date = db.Column(db.Date, nullable=False)  # Date for which feedback is given
	emoji_value = db.Column(db.Integer, nullable=False)  # 1=Happy, 2=Neutral, 3=Sad
	feedback_text = db.Column(db.String(500), nullable=True)  # Optional text feedback
	created_by = db.Column(db.String(36), nullable=False)  # UUID as string (parent)
	created_at = db.Column(db.DateTime, default=datetime.now, nullable=False)

	def to_dict(self):
		"""Convert the feedback to a dictionary for API responses"""
		emoji_map = {
			1: "😊 سعيد",
			2: "😐 محايد",
			3: "😢 حزين"
		}
		return {
			"id": self.id,
			"child_id": self.child_id,
			"feedback_date": self.feedback_date.isoformat(),
			"emoji_value": self.emoji_value,
			"emoji_name": emoji_map.get(self.emoji_value, "Unknown"),
			"feedback_text": self.feedback_text,
			"created_by": self.created_by,
			"created_at": self.created_at
		}
