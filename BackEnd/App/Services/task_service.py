# Task service layer - handles all business logic for task management
# This service acts as the bridge between Routes and Models
# All database operations go through this service

from App.Extensions import db
from App.Models.Task import Task


class TaskService:
	"""
	Service class for managing tasks.
	Handles all business logic and database operations for tasks.
	"""

	def create_task(self, task_data):
		"""
		Create a new task in the database.
		Args:
			task_data: Dictionary containing task details
		Returns:
			Created Task object or None if error
		"""
		try:
			task = Task(
				title=task_data.get("title"),
				description=task_data.get("description"),
				child_id=task_data.get("child_id"),
				points=task_data.get("points"),
				task_type=task_data.get("task_type", "ONCE"),
				recurrence_day=task_data.get("recurrence_day"),
				category=task_data.get("category"),
				is_auto_verified=task_data.get("is_auto_verified", False),
				verification_type=task_data.get("verification_type", "MANUAL"),
				created_by=task_data.get("created_by"),
				status="PENDING"  # Default status when created
			)
			db.session.add(task)
			db.session.commit()
			return task
		except Exception as e:
			db.session.rollback()
			print(f"Error creating task: {str(e)}")
			return None

	def get_task(self, task_id):
		"""
		Retrieve a single task by its ID.
		Args:
			task_id: UUID of the task
		Returns:
			Task object if found, None if not found or error
		"""
		try:
			return Task.query.get(task_id)
		except Exception as e:
			print(f"Error retrieving task: {str(e)}")
			return None

	def get_tasks_by_child(self, child_id):
		"""
		Retrieve all tasks assigned to a specific child.
		Args:
			child_id: UUID of the child
		Returns:
			List of Task objects for the child
		"""
		try:
			return Task.query.filter_by(child_id=child_id).all()
		except Exception as e:
			print(f"Error retrieving tasks for child: {str(e)}")
			return []

	def get_tasks_by_status(self, status):
		"""
		Retrieve all tasks with a specific status.
		Args:
			status: Status to filter by (PENDING, APPROVED, REJECTED)
		Returns:
			List of Task objects with the specified status
		"""
		try:
			return Task.query.filter_by(status=status).all()
		except Exception as e:
			print(f"Error retrieving tasks by status: {str(e)}")
			return []

	def get_daily_tasks(self):
		"""
		Retrieve all daily tasks.
		Returns:
			List of daily Task objects
		"""
		try:
			return Task.query.filter_by(task_type="DAILY").all()
		except Exception as e:
			print(f"Error retrieving daily tasks: {str(e)}")
			return []

	def get_weekly_tasks(self):
		"""
		Retrieve all weekly tasks.
		Returns:
			List of weekly Task objects
		"""
		try:
			return Task.query.filter_by(task_type="WEEKLY").all()
		except Exception as e:
			print(f"Error retrieving weekly tasks: {str(e)}")
			return []

	def get_weekly_tasks_by_day(self, day):
		"""
		Retrieve weekly tasks for a specific day.
		Args:
			day: Day of week (0-6, where 0=Monday, 4=Friday)
		Returns:
			List of Task objects for that day
		"""
		try:
			return Task.query.filter_by(task_type="WEEKLY", recurrence_day=day).all()
		except Exception as e:
			print(f"Error retrieving weekly tasks for day: {str(e)}")
			return []

	def update_task(self, task_id, task_data):
		"""
		Update a task's details.
		Args:
			task_id: UUID of the task to update
			task_data: Dictionary with updated fields
		Returns:
			Updated Task object or None if not found or error
		"""
		try:
			task = Task.query.get(task_id)
			if not task:
				return None

			if "title" in task_data:
				task.title = task_data["title"]
			if "description" in task_data:
				task.description = task_data["description"]
			if "points" in task_data:
				task.points = task_data["points"]
			if "task_type" in task_data:
				task.task_type = task_data["task_type"]
			if "recurrence_day" in task_data:
				task.recurrence_day = task_data["recurrence_day"]
			if "category" in task_data:
				task.category = task_data["category"]
			if "is_auto_verified" in task_data:
				task.is_auto_verified = task_data["is_auto_verified"]
			if "verification_type" in task_data:
				task.verification_type = task_data["verification_type"]

			db.session.commit()
			return task
		except Exception as e:
			db.session.rollback()
			print(f"Error updating task: {str(e)}")
			return None

	def approve_task(self, task_id):
		"""
		Approve a task by changing its status to APPROVED.
		Args:
			task_id: UUID of the task to approve
		Returns:
			Updated Task object or None if not found or error
		"""
		try:
			task = Task.query.get(task_id)
			if not task:
				return None
			task.approve()
			return task
		except Exception as e:
			db.session.rollback()
			print(f"Error approving task: {str(e)}")
			return None

	def reject_task(self, task_id):
		"""
		Reject a task by changing its status to REJECTED.
		Args:
			task_id: UUID of the task to reject
		Returns:
			Updated Task object or None if not found or error
		"""
		try:
			task = Task.query.get(task_id)
			if not task:
				return None
			task.reject()
			return task
		except Exception as e:
			db.session.rollback()
			print(f"Error rejecting task: {str(e)}")
			return None

	def delete_task(self, task_id):
		"""
		Delete a task from the database.
		Args:
			task_id: UUID of the task to delete
		Returns:
			True if deleted successfully, False otherwise
		"""
		try:
			task = Task.query.get(task_id)
			if not task:
				return False
			db.session.delete(task)
			db.session.commit()
			return True
		except Exception as e:
			db.session.rollback()
			print(f"Error deleting task: {str(e)}")
			return False


class DailyFeedbackService:
	"""
	Service class for managing daily feedback.
	Handles all business logic and database operations for daily feedback.
	"""

	def create_daily_feedback(self, feedback_data):
		"""
		Create daily feedback for a child.
		Args:
			feedback_data: Dictionary containing feedback details
		Returns:
			Created DailyFeedback object or None if error
		"""
		from App.Models.DailyFeedback import DailyFeedback
		from datetime import datetime as dt
		
		try:
			# Parse feedback_date if it's a string
			feedback_date = feedback_data.get("feedback_date")
			if isinstance(feedback_date, str):
				feedback_date = dt.strptime(feedback_date, "%Y-%m-%d").date()
			
			feedback = DailyFeedback(
				child_id=feedback_data.get("child_id"),
				feedback_date=feedback_date,
				emoji_value=feedback_data.get("emoji_value"),
				feedback_text=feedback_data.get("feedback_text"),
				created_by=feedback_data.get("created_by")
			)
			db.session.add(feedback)
			db.session.commit()
			return feedback
		except Exception as e:
			db.session.rollback()
			print(f"Error creating daily feedback: {str(e)}")
			return None

	def get_daily_feedback(self, feedback_id):
		"""
		Retrieve a daily feedback by its ID.
		Args:
			feedback_id: UUID of the feedback
		Returns:
			DailyFeedback object if found, None if not found or error
		"""
		from App.Models.DailyFeedback import DailyFeedback
		
		try:
			return DailyFeedback.query.get(feedback_id)
		except Exception as e:
			print(f"Error retrieving daily feedback: {str(e)}")
			return None

	def get_child_feedback(self, child_id):
		"""
		Retrieve all daily feedback for a specific child.
		Args:
			child_id: UUID of the child
		Returns:
			List of DailyFeedback objects for the child
		"""
		from App.Models.DailyFeedback import DailyFeedback
		
		try:
			return DailyFeedback.query.filter_by(child_id=child_id).order_by(DailyFeedback.feedback_date.desc()).all()
		except Exception as e:
			print(f"Error retrieving child feedback: {str(e)}")
			return []

	def get_feedback_by_date(self, child_id, feedback_date):
		"""
		Retrieve daily feedback for a child on a specific date.
		Args:
			child_id: UUID of the child
			feedback_date: Date for which to retrieve feedback
		Returns:
			DailyFeedback object if found, None if not found or error
		"""
		from App.Models.DailyFeedback import DailyFeedback
		from datetime import datetime as dt
		
		try:
			# Parse feedback_date if it's a string
			if isinstance(feedback_date, str):
				feedback_date = dt.strptime(feedback_date, "%Y-%m-%d").date()
			
			return DailyFeedback.query.filter_by(child_id=child_id, feedback_date=feedback_date).first()
		except Exception as e:
			print(f"Error retrieving feedback by date: {str(e)}")
			return None

	def update_daily_feedback(self, feedback_id, feedback_data):
		"""
		Update daily feedback.
		Args:
			feedback_id: UUID of the feedback to update
			feedback_data: Dictionary with updated fields
		Returns:
			Updated DailyFeedback object or None if not found or error
		"""
		from App.Models.DailyFeedback import DailyFeedback
		
		try:
			feedback = DailyFeedback.query.get(feedback_id)
			if not feedback:
				return None

			if "emoji_value" in feedback_data:
				feedback.emoji_value = feedback_data["emoji_value"]
			if "feedback_text" in feedback_data:
				feedback.feedback_text = feedback_data["feedback_text"]

			db.session.commit()
			return feedback
		except Exception as e:
			db.session.rollback()
			print(f"Error updating daily feedback: {str(e)}")
			return None

	def delete_daily_feedback(self, feedback_id):
		"""
		Delete daily feedback from the database.
		Args:
			feedback_id: UUID of the feedback to delete
		Returns:
			True if deleted successfully, False otherwise
		"""
		from App.Models.DailyFeedback import DailyFeedback
		
		try:
			feedback = DailyFeedback.query.get(feedback_id)
			if not feedback:
				return False
			db.session.delete(feedback)
			db.session.commit()
			return True
		except Exception as e:
			db.session.rollback()
			print(f"Error deleting daily feedback: {str(e)}")
			return False
