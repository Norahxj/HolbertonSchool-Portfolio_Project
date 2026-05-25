# Task service layer - handles all business logic for task management
# This service acts as the bridge between Routes and Models
# All database operations go through this service

from app.extensions import db
from app.models.task import Task


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

	def get_tasks(self):
		"""
		Retrieve all tasks from the database.
		Returns:
			List of all Task objects
		"""
		try:
			return Task.query.all()
		except Exception as e:
			print(f"Error retrieving tasks: {str(e)}")
			return []

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
			task.approve()  # This calls the Task model's approve method
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
			task.reject()  # This calls the Task model's reject method
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
