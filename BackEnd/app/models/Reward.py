from App.Extensions import db
from App.Models.base_model import BaseModel
from datetime import datetime, timedelta


class Reward(BaseModel):
	"""
	Reward model - represents weekly rewards available to a child.
	
	Fields:
	- child_id: ID of the child
	- reward_name: Name of the reward (e.g., PlayStation Time, Cinema, Friend Visit, Cash Reward)
	- description: Description of the reward
	- cost_in_points: How many points needed to get this reward (if applicable)
	- reward_value: Additional value (e.g., amount of money, hours of playtime)
	- reward_type: Type of reward (ENTERTAINMENT, OUTING, CASH, TIME_BASED, EXPERIENCE)
	- is_active: Whether this reward is available this week (on/off)
	- week_start_date: Starting date of the week (Thursday)
	- week_end_date: Ending date of the week (Wednesday)
	- assigned_by: ID of the parent who created/assigned this reward
	- notes: Optional notes about the reward
	
	The rewards reset every Thursday.
	"""
	__tablename__ = "rewards"

	child_id = db.Column(db.String(36), nullable=False)  # UUID as string
	reward_name = db.Column(db.String(100), nullable=False)  # e.g., "PlayStation Time"
	description = db.Column(db.String(500), nullable=True)  # Description of reward
	cost_in_points = db.Column(db.Integer, nullable=True)  # Points cost (if applicable)
	reward_value = db.Column(db.String(100), nullable=True)  # e.g., "2 hours", "$10"
	reward_type = db.Column(db.String(50), nullable=False)  # ENTERTAINMENT, OUTING, CASH, TIME_BASED, EXPERIENCE
	is_active = db.Column(db.Boolean, default=True, nullable=False)  # on/off toggle
	week_start_date = db.Column(db.Date, nullable=False)  # Thursday (week start)
	week_end_date = db.Column(db.Date, nullable=False)  # Wednesday (week end)
	assigned_by = db.Column(db.String(36), nullable=False)  # UUID as string (parent)
	notes = db.Column(db.String(300), nullable=True)  # Additional notes
	created_at = db.Column(db.DateTime, default=datetime.now, nullable=False)

	def to_dict(self):
		"""Convert the reward to a dictionary for API responses"""
		return {
			"id": self.id,
			"child_id": self.child_id,
			"reward_name": self.reward_name,
			"description": self.description,
			"cost_in_points": self.cost_in_points,
			"reward_value": self.reward_value,
			"reward_type": self.reward_type,
			"is_active": self.is_active,
			"week_start_date": self.week_start_date.isoformat(),
			"week_end_date": self.week_end_date.isoformat(),
			"notes": self.notes,
			"created_at": self.created_at
		}

	@staticmethod
	def get_this_week_start():
		"""Get Thursday of this week (week start)"""
		today = datetime.now().date()
		# Thursday = 3
		days_to_thursday = (3 - today.weekday()) % 7
		if days_to_thursday == 0 and today.weekday() != 3:
			days_to_thursday = 7
		return today + timedelta(days=days_to_thursday)

	@staticmethod
	def get_this_week_end():
		"""Get Wednesday of this week (week end)"""
		week_start = Reward.get_this_week_start()
		return week_start + timedelta(days=6)

	@staticmethod
	def get_current_week_rewards(child_id):
		"""Get all rewards for current week"""
		week_start = Reward.get_this_week_start()
		
		rewards = Reward.query.filter(
			Reward.child_id == child_id,
			Reward.week_start_date == week_start
		).all()
		
		return [r.to_dict() for r in rewards]

	@staticmethod
	def get_active_rewards(child_id):
		"""Get only active (on) rewards for current week"""
		week_start = Reward.get_this_week_start()
		
		rewards = Reward.query.filter(
			Reward.child_id == child_id,
			Reward.week_start_date == week_start,
			Reward.is_active == True
		).all()
		
		return [r.to_dict() for r in rewards]

	@staticmethod
	def toggle_reward(reward_id):
		"""Toggle reward status (on/off)"""
		reward = Reward.query.get(reward_id)
		if reward:
			reward.is_active = not reward.is_active
			db.session.commit()
			return reward
		return None

	@staticmethod
	def create_default_rewards(child_id, parent_id):
		"""Create default rewards for a child at week start"""
		week_start = Reward.get_this_week_start()
		week_end = Reward.get_this_week_end()
		
		# Default rewards options
		default_rewards = [
			{
				"name": "وقت إضافي - بلايستيشن",
				"type": "TIME_BASED",
				"description": "وقت إضافي للعب البلايستيشن",
				"value": "ساعة واحدة"
			},
			{
				"name": "وقت إضافي - ألعاب",
				"type": "TIME_BASED",
				"description": "وقت إضافي في اللعب بشكل عام",
				"value": "30 دقيقة"
			},
			{
				"name": "سينما",
				"type": "OUTING",
				"description": "زيارة السينما",
				"value": "تذكرتان"
			},
			{
				"name": "زيارة أصدقاء",
				"type": "OUTING",
				"description": "زيارة الأصدقاء",
				"value": "ساعتان"
			},
			{
				"name": "مكافأة مالية",
				"type": "CASH",
				"description": "مكافأة نقدية",
				"value": "20 ريال"
			},
			{
				"name": "أخرى",
				"type": "EXPERIENCE",
				"description": "مكافأة أخرى من اختيار الوالد",
				"value": "حسب الاختيار"
			}
		]
		
		created_rewards = []
		for reward_data in default_rewards:
			reward = Reward(
				child_id=child_id,
				reward_name=reward_data["name"],
				description=reward_data["description"],
				reward_value=reward_data["value"],
				reward_type=reward_data["type"],
				is_active=True,
				week_start_date=week_start,
				week_end_date=week_end,
				assigned_by=parent_id
			)
			db.session.add(reward)
			created_rewards.append(reward)
		
		db.session.commit()
		return created_rewards
