from app.models.point import Point
from app.models.reward import Reward
from app.models.daily_feedback import DailyFeedback
from app.models.task import Task
from app.extensions import db
from datetime import datetime, timedelta


class PointService:
	"""Service for managing points"""

	@staticmethod
	def add_points(child_id, points_earned, task_id=None, parent_id=None, notes=None, points_set_by_parent=5):
		"""
		Add points to a child's account
		"""
		try:
			point = Point(
				child_id=child_id,
				task_id=task_id,
				points_earned=points_earned,
				points_set_by_parent=points_set_by_parent,
				earning_date=datetime.now().date(),
				created_by=parent_id,
				notes=notes
			)
			db.session.add(point)
			db.session.commit()
			return {
				"success": True,
				"message": "تم إضافة النقاط بنجاح",
				"point": point.to_dict()
			}
		except Exception as e:
			db.session.rollback()
			return {
				"success": False,
				"message": f"خطأ في إضافة النقاط: {str(e)}"
			}

	@staticmethod
	def get_daily_points_summary(child_id, date=None):
		"""Get daily points summary"""
		if date is None:
			date = datetime.now().date()
		
		daily_points = Point.get_daily_points(child_id, date)
		points_list = Point.query.filter_by(child_id=child_id, earning_date=date).all()
		
		return {
			"date": date.isoformat(),
			"total_points": daily_points,
			"points_count": len(points_list),
			"points": [p.to_dict() for p in points_list]
		}

	@staticmethod
	def get_weekly_points_summary(child_id):
		"""Get weekly points summary"""
		weekly_points = Point.get_weekly_points(child_id)
		
		# Get breakdown by day
		today = datetime.now().date()
		monday = today - timedelta(days=today.weekday())
		daily_breakdown = {}
		
		for i in range(7):
			day = monday + timedelta(days=i)
			daily_breakdown[day.isoformat()] = Point.get_daily_points(child_id, day)
		
		return {
			"week_start": monday.isoformat(),
			"total_points": weekly_points,
			"daily_breakdown": daily_breakdown
		}

	@staticmethod
	def get_points_history(child_id, days=30):
		"""Get points history"""
		history = Point.get_points_history(child_id, days)
		
		return {
			"child_id": child_id,
			"period_days": days,
			"points_history": history,
			"total_points": sum([p["points_earned"] for p in history])
		}

	@staticmethod
	def update_point_value(point_id, new_points_value):
		"""Update the points value for a specific point entry"""
		try:
			point = Point.query.get(point_id)
			if not point:
				return {"success": False, "message": "النقطة غير موجودة"}
			
			old_value = point.points_earned
			point.points_earned = new_points_value
			db.session.commit()
			
			return {
				"success": True,
				"message": "تم تحديث قيمة النقاط",
				"old_value": old_value,
				"new_value": new_points_value
			}
		except Exception as e:
			db.session.rollback()
			return {"success": False, "message": str(e)}


class RewardService:
	"""Service for managing rewards"""

	@staticmethod
	def get_week_rewards(child_id):
		"""Get all rewards for current week"""
		rewards = Reward.get_current_week_rewards(child_id)
		return {
			"child_id": child_id,
			"week_start": Reward.get_this_week_start().isoformat(),
			"week_end": Reward.get_this_week_end().isoformat(),
			"total_rewards": len(rewards),
			"active_rewards": len([r for r in rewards if r["is_active"]]),
			"rewards": rewards
		}

	@staticmethod
	def get_active_rewards(child_id):
		"""Get only active rewards"""
		rewards = Reward.get_active_rewards(child_id)
		return {
			"child_id": child_id,
			"active_rewards": rewards,
			"count": len(rewards)
		}

	@staticmethod
	def toggle_reward_status(reward_id):
		"""Toggle a reward on/off"""
		try:
			reward = Reward.toggle_reward(reward_id)
			if reward:
				return {
					"success": True,
					"message": f"تم تحديث حالة المكافأة: {reward.reward_name}",
					"is_active": reward.is_active,
					"reward": reward.to_dict()
				}
			return {
				"success": False,
				"message": "المكافأة غير موجودة"
			}
		except Exception as e:
			return {
				"success": False,
				"message": str(e)
			}

	@staticmethod
	def create_week_rewards(child_id, parent_id):
		"""Create default weekly rewards for a child"""
		try:
			rewards = Reward.create_default_rewards(child_id, parent_id)
			return {
				"success": True,
				"message": "تم إنشاء المكافآت الأسبوعية بنجاح",
				"rewards_count": len(rewards),
				"rewards": [r.to_dict() for r in rewards]
			}
		except Exception as e:
			db.session.rollback()
			return {
				"success": False,
				"message": str(e)
			}




class DailyProgressService:
	"""Service for daily progress tracking and feedback"""

	@staticmethod
	def get_daily_progress(child_id, date=None):
		"""Get daily progress including points, tasks, and feedback"""
		if date is None:
			date = datetime.now().date()
		
		# Get daily points
		daily_points = Point.get_daily_points(child_id, date)
		points_data = Point.query.filter_by(child_id=child_id, earning_date=date).all()
		
		# Get completed tasks
		tasks = Task.query.filter(
			Task.child_id == child_id,
			Task.status == "APPROVED",
			Task.approved_at.cast(db.Date) == date
		).all()
		
		# Get daily feedback
		feedback = DailyFeedback.query.filter_by(
			child_id=child_id,
			feedback_date=date
		).first()
		
		feedback_data = feedback.to_dict() if feedback else None
		
		return {
			"child_id": child_id,
			"date": date.isoformat(),
			"daily_points": daily_points,
			"points_breakdown": [p.to_dict() for p in points_data],
			"completed_tasks": [t.title for t in tasks],
			"tasks_count": len(tasks),
			"daily_feedback": feedback_data,
			"emoji_value": feedback.emoji_value if feedback else None
		}

	@staticmethod
	def get_progress_chart_data(child_id, days=30):
		"""Get data for daily progress chart"""
		chart_data = []
		start_date = datetime.now().date() - timedelta(days=days)
		
		for i in range(days):
			current_date = start_date + timedelta(days=i)
			points = Point.get_daily_points(child_id, current_date)
			
			feedback = DailyFeedback.query.filter_by(
				child_id=child_id,
				feedback_date=current_date
			).first()
			
			tasks_count = Task.query.filter(
				Task.child_id == child_id,
				Task.status == "APPROVED",
				Task.approved_at.cast(db.Date) == current_date
			).count()
			
			chart_data.append({
				"date": current_date.isoformat(),
				"points": points,
				"emoji": feedback.emoji_value if feedback else None,
				"tasks_completed": tasks_count
			})
		
		return {
			"child_id": child_id,
			"chart_title": "تقدمك اليومي",
			"period_days": days,
			"data": chart_data
		}

	@staticmethod
	def get_weekly_progress_report(child_id):
		"""Get complete weekly progress report"""
		today = datetime.now().date()
		monday = today - timedelta(days=today.weekday())
		
		daily_reports = []
		for i in range(7):
			day = monday + timedelta(days=i)
			daily_reports.append(
				DailyProgressService.get_daily_progress(child_id, day)
			)
		
		total_points = sum([r["daily_points"] for r in daily_reports])
		total_tasks = sum([r["tasks_count"] for r in daily_reports])
		
		return {
			"child_id": child_id,
			"week_start": monday.isoformat(),
			"total_points": total_points,
			"total_tasks_completed": total_tasks,
			"daily_reports": daily_reports,
			"average_points_per_day": total_points / 7 if total_points > 0 else 0
		}
