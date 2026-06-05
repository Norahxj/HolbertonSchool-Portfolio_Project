# API Routes for task management
# This file handles HTTP endpoints and delegates business logic to the service layer
# Routes follow the Flask-RESTX pattern for consistency with the rest of the application

from flask_restx import Namespace, Resource
from App.api_models.task_model import get_task_models
from App.Services.task_service import TaskService, DailyFeedbackService


api = Namespace("tasks", description="Task operations")
task_service = TaskService()
feedback_service = DailyFeedbackService()
task_model, task_update_model, task_status_model, daily_feedback_model, daily_feedback_update_model = get_task_models(api)


@api.route("/")
class TaskListResource(Resource):
	"""Resource for creating tasks"""

	@api.expect(task_model, validate=True)
	@api.response(201, "Task created successfully")
	@api.response(400, "Invalid input")
	def post(self):
		"""
		Create a new task (ONCE, DAILY, or WEEKLY).
		Calls the service layer to add the task to the database.
		For WEEKLY tasks, provide recurrence_day (0=Monday to 6=Sunday, 4=Friday).
		"""
		task_data = api.payload
		task = task_service.create_task(task_data)
		
		if task is None:
			return {"error": "Failed to create task"}, 400
		
		return task.to_dict(), 201


@api.route("/<task_id>")
class TaskResource(Resource):
	"""Resource for managing a specific task"""

	@api.response(200, "Task retrieved successfully")
	@api.response(404, "Task not found")
	def get(self, task_id):
		"""
		Retrieve a single task by its ID.
		Calls the service layer and returns 404 if not found.
		"""
		task = task_service.get_task(task_id)
		if task is None:
			return {"error": "Task not found"}, 404
		
		return task.to_dict(), 200

	@api.expect(task_update_model, validate=True)
	@api.response(200, "Task updated successfully")
	@api.response(404, "Task not found")
	@api.response(400, "Invalid input")
	def put(self, task_id):
		"""
		Update a task's details (title, description, points, task_type, recurrence_day).
		Calls the service layer and returns 404 if not found.
		"""
		task_data = api.payload
		task = task_service.update_task(task_id, task_data)
		
		if task is None:
			return {"error": "Task not found"}, 404
		
		return task.to_dict(), 200

	@api.response(204, "Task deleted successfully")
	@api.response(404, "Task not found")
	def delete(self, task_id):
		"""
		Delete a task from the database.
		Returns 204 if successful, 404 if not found.
		"""
		success = task_service.delete_task(task_id)
		
		if not success:
			return {"error": "Task not found"}, 404
		
		return "", 204


@api.route("/<task_id>/approve")
class TaskApproveResource(Resource):
	"""Resource for approving tasks"""

	@api.response(200, "Task approved successfully")
	@api.response(404, "Task not found")
	def put(self, task_id):
		"""
		Approve a task by changing its status to APPROVED.
		Calls the service layer and returns 404 if task not found.
		"""
		task = task_service.approve_task(task_id)
		if task is None:
			return {"error": "Task not found"}, 404
		
		return task.to_dict(), 200


@api.route("/<task_id>/reject")
class TaskRejectResource(Resource):
	"""Resource for rejecting tasks"""

	@api.response(200, "Task rejected successfully")
	@api.response(404, "Task not found")
	def put(self, task_id):
		"""
		Reject a task by changing its status to REJECTED.
		Calls the service layer and returns 404 if task not found.
		"""
		task = task_service.reject_task(task_id)
		if task is None:
			return {"error": "Task not found"}, 404
		
		return task.to_dict(), 200


@api.route("/child/<child_id>")
class TaskByChildResource(Resource):
	"""Resource for retrieving tasks by child ID"""

	@api.response(200, "Tasks retrieved successfully")
	def get(self, child_id):
		"""
		Retrieve all tasks assigned to a specific child.
		"""
		tasks = task_service.get_tasks_by_child(child_id)
		return [task.to_dict() for task in tasks], 200


@api.route("/status/<status>")
class TaskByStatusResource(Resource):
	"""Resource for retrieving tasks by status"""

	@api.response(200, "Tasks retrieved successfully")
	def get(self, status):
		"""
		Retrieve all tasks with a specific status (PENDING, APPROVED, REJECTED).
		"""
		if status not in ["PENDING", "APPROVED", "REJECTED"]:
			return {"error": "Invalid status"}, 400
		
		tasks = task_service.get_tasks_by_status(status)
		return [task.to_dict() for task in tasks], 200


@api.route("/daily/all")
class DailyTasksResource(Resource):
	"""Resource for retrieving all daily tasks"""

	@api.response(200, "Daily tasks retrieved successfully")
	def get(self):
		"""
		Retrieve all daily recurring tasks.
		"""
		tasks = task_service.get_daily_tasks()
		return [task.to_dict() for task in tasks], 200


@api.route("/weekly/all")
class WeeklyTasksResource(Resource):
	"""Resource for retrieving all weekly tasks"""

	@api.response(200, "Weekly tasks retrieved successfully")
	def get(self):
		"""
		Retrieve all weekly recurring tasks.
		"""
		tasks = task_service.get_weekly_tasks()
		return [task.to_dict() for task in tasks], 200


@api.route("/weekly/day/<int:day>")
class WeeklyTasksByDayResource(Resource):
	"""Resource for retrieving weekly tasks by specific day"""

	@api.response(200, "Weekly tasks for day retrieved successfully")
	@api.response(400, "Invalid day")
	def get(self, day):
		"""
		Retrieve weekly tasks for a specific day of the week.
		day: 0=Monday, 1=Tuesday, 2=Wednesday, 3=Thursday, 4=Friday, 5=Saturday, 6=Sunday
		"""
		if day < 0 or day > 6:
			return {"error": "Invalid day. Must be between 0-6 (0=Monday, 6=Sunday)"}, 400
		
		tasks = task_service.get_weekly_tasks_by_day(day)
		return [task.to_dict() for task in tasks], 200


# Daily Feedback Routes
بشيلها 
@api.route("/feedback/")
class DailyFeedbackListResource(Resource):
	"""Resource for creating daily feedback"""

	@api.expect(daily_feedback_model, validate=True)
	@api.response(201, "Daily feedback created successfully")
	@api.response(400, "Invalid input")
	def post(self):
		"""
		Create daily feedback for a child.
		Feedback includes emoji rating (1=Happy😊, 2=Neutral😐, 3=Sad😢) and optional text.
		"""
		feedback_data = api.payload
		feedback = feedback_service.create_daily_feedback(feedback_data)
		
		if feedback is None:
			return {"error": "Failed to create daily feedback"}, 400
		
		return feedback.to_dict(), 201


@api.route("/feedback/<feedback_id>")
class DailyFeedbackResource(Resource):
	"""Resource for managing a specific daily feedback"""

	@api.response(200, "Daily feedback retrieved successfully")
	@api.response(404, "Daily feedback not found")
	def get(self, feedback_id):
		"""
		Retrieve a specific daily feedback by its ID.
		"""
		feedback = feedback_service.get_daily_feedback(feedback_id)
		if feedback is None:
			return {"error": "Daily feedback not found"}, 404
		
		return feedback.to_dict(), 200

	@api.expect(daily_feedback_update_model, validate=True)
	@api.response(200, "Daily feedback updated successfully")
	@api.response(404, "Daily feedback not found")
	def put(self, feedback_id):
		"""
		Update daily feedback (emoji and/or text).
		"""
		feedback_data = api.payload
		feedback = feedback_service.update_daily_feedback(feedback_id, feedback_data)
		
		if feedback is None:
			return {"error": "Daily feedback not found"}, 404
		
		return feedback.to_dict(), 200

	@api.response(204, "Daily feedback deleted successfully")
	@api.response(404, "Daily feedback not found")
	def delete(self, feedback_id):
		"""
		Delete daily feedback from the database.
		"""
		success = feedback_service.delete_daily_feedback(feedback_id)
		
		if not success:
			return {"error": "Daily feedback not found"}, 404
		
		return "", 204


@api.route("/feedback/child/<child_id>")
class ChildFeedbackResource(Resource):
	"""Resource for retrieving all feedback for a child"""

	@api.response(200, "Child feedback retrieved successfully")
	def get(self, child_id):
		"""
		Retrieve all daily feedback for a specific child.
		Results are ordered by date (newest first).
		"""
		feedbacks = feedback_service.get_child_feedback(child_id)
		return [feedback.to_dict() for feedback in feedbacks], 200


@api.route("/feedback/child/<child_id>/<date>")
class ChildFeedbackByDateResource(Resource):
	"""Resource for retrieving feedback for a child on a specific date"""

	@api.response(200, "Feedback retrieved successfully")
	@api.response(404, "Feedback not found for this date")
	def get(self, child_id, date):
		"""
		Retrieve daily feedback for a specific child on a specific date.
		Date format: YYYY-MM-DD
		"""
		feedback = feedback_service.get_feedback_by_date(child_id, date)
		if feedback is None:
			return {"error": "No feedback found for this date"}, 404
		
		return feedback.to_dict(), 200


@api.route("/status/<status>")
class TaskByStatusResource(Resource):
	"""Resource for retrieving tasks by status"""

	@api.response(200, "Tasks retrieved successfully")
	@api.response(400, "Invalid status")
	def get(self, status):
		"""
		Retrieve all tasks with a specific status.
		Valid statuses: PENDING, APPROVED, REJECTED
		"""
		valid_statuses = ["PENDING", "APPROVED", "REJECTED"]
		if status.upper() not in valid_statuses:
			return {"error": f"Invalid status. Must be one of: {', '.join(valid_statuses)}"}, 400
		
		tasks = task_service.get_tasks_by_status(status.upper())
		return [
			{
				"id": task.id,
				"title": task.title,
				"child_id": task.child_id,
				"status": task.status,
				"created_at": task.created_at
			}
			for task in tasks
		], 200
