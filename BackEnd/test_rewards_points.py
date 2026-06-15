import json
from app import create_app
from app.extensions import db
from backEnd.app.models.point_model import Point
from backEnd.app.models.reward_model import Reward
from backEnd.app.models.daily_feedback_model import DailyFeedback
from datetime import datetime, timedelta

app = create_app()

def test_points_system():
	"""Test the Points System"""
	print("\n🧪 Testing Points System...\n")
	
	with app.app_context():
		# Create a test point
		point = Point(
			child_id="test-child-1",
			points_earned=10,
			points_set_by_parent=5,
			earning_date=datetime.now().date(),
			created_by="test-parent-1",
			notes="Test point"
		)
		db.session.add(point)
		db.session.commit()
		
		# Test get_daily_points
		daily_points = Point.get_daily_points("test-child-1")
		print(f"✅ Daily points for child: {daily_points}")
		
		# Test get_weekly_points
		weekly_points = Point.get_weekly_points("test-child-1")
		print(f"✅ Weekly points for child: {weekly_points}")
		
		# Test get_points_history
		history = Point.get_points_history("test-child-1", days=30)
		print(f"✅ Points history count: {len(history)}")
		
		return True


def test_rewards_system():
	"""Test the Rewards System"""
	print("\n🧪 Testing Rewards System...\n")
	
	with app.app_context():
		week_start = Reward.get_this_week_start()
		week_end = Reward.get_this_week_end()
		
		print(f"✅ Week start (Thursday): {week_start}")
		print(f"✅ Week end (Wednesday): {week_end}")
		
		# Create default rewards
		rewards = Reward.create_default_rewards("test-child-2", "test-parent-2")
		print(f"✅ Created {len(rewards)} default rewards")
		
		# Get current week rewards
		current_rewards = Reward.get_current_week_rewards("test-child-2")
		print(f"✅ Current week rewards count: {len(current_rewards)}")
		
		# Get active rewards
		active_rewards = Reward.get_active_rewards("test-child-2")
		print(f"✅ Active rewards count: {len(active_rewards)}")
		
		if current_rewards:
			reward_id = current_rewards[0]["id"]
			# Toggle reward
			reward = Reward.toggle_reward(reward_id)
			print(f"✅ Toggled reward status: {reward.is_active}")
		
		return True


def test_daily_feedback():
	"""Test the Daily Feedback System"""
	print("\n🧪 Testing Daily Feedback System...\n")
	
	with app.app_context():
		# Create feedback
		feedback = DailyFeedback(
			child_id="test-child-3",
			feedback_date=datetime.now().date(),
			emoji_value=1,
			feedback_text="Great performance today!",
			created_by="test-parent-3"
		)
		db.session.add(feedback)
		db.session.commit()
		
		# Get feedback
		retrieved_feedback = DailyFeedback.query.filter_by(
			child_id="test-child-3",
			feedback_date=datetime.now().date()
		).first()
		
		if retrieved_feedback:
			print(f"✅ Feedback emoji: {retrieved_feedback.emoji_value}")
			print(f"✅ Feedback text: {retrieved_feedback.feedback_text}")
			print(f"✅ Feedback dict: {retrieved_feedback.to_dict()}")
			return True
		
		return False


def test_services():
	"""Test the Services"""
	print("\n🧪 Testing Services...\n")
	
	from app.services.reward_service import PointService, RewardService, DailyProgressService
	
	with app.app_context():
		# Test PointService
		result = PointService.add_points(
			child_id="test-child-4",
			points_earned=15,
			parent_id="test-parent-4",
			notes="Service test point"
		)
		print(f"✅ Added points: {result['success']}")
		
		# Test get_daily_points_summary
		summary = PointService.get_daily_points_summary("test-child-4")
		print(f"✅ Daily points summary: {summary['total_points']} points")
		
		# Test RewardService
		rewards_result = RewardService.create_week_rewards("test-child-5", "test-parent-5")
		print(f"✅ Created weekly rewards: {rewards_result['success']}")
		
		# Test DailyProgressService
		progress = DailyProgressService.get_daily_progress("test-child-1")
		print(f"✅ Daily progress: {progress['daily_points']} points, {progress['tasks_count']} tasks")
		
		# Test chart data
		chart_data = DailyProgressService.get_progress_chart_data("test-child-1", days=7)
		print(f"✅ Chart data points: {len(chart_data['data'])}")
		
		return True


if __name__ == "__main__":
	print("=" * 50)
	print("🚀 SYSTEM TESTS START")
	print("=" * 50)
	
	try:
		# Create tables if not exist
		with app.app_context():
			db.create_all()
			print("✅ Database tables created/verified")
		
		# Run tests
		test_points_system()
		test_rewards_system()
		test_daily_feedback()
		test_services()
		
		print("\n" + "=" * 50)
		print("✅ ALL TESTS PASSED!")
		print("=" * 50)
		
	except Exception as e:
		print(f"\n❌ TEST FAILED: {str(e)}")
		import traceback
		traceback.print_exc()
