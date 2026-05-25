# API Routes for task management
# This file handles HTTP endpoints and delegates business logic to the service layer
# Routes follow the Flask-RESTX pattern for consistency with the rest of the application

from flask_restx import Namespace, Resource
from app.api_models.task_model import get_task_models
from app.services.task_service import TaskService


api = Namespace("tasks", description="Task operations")
task_service = TaskService()
task_model, task_update_model, task_status_model = get_task_models(api)


@api.route("/")
class TaskListResource(Resource):
	"""Resource for managing all tasks (GET all, POST create)"""

	@api.expect(task_model, validate=True)
	@api.response(201, "Task created successfully")
	@api.response(400, "Invalid input")
	def post(self):
		"""
		Create a new task.
		Calls the service layer to add the task to the database.
		"""
		task_data = api.payload
		task = task_service.create_task(task_data)
		
		if task is None:
			return {"error": "Failed to create task"}, 400
		
		return {
			"id": task.id,
			"title": task.title,
			"description": task.description,
			"child_id": task.child_id,
			"points": task.points,
			"status": task.status,
			"created_by": task.created_by,
			"created_at": task.created_at
		}, 201

	@api.response(200, "Tasks retrieved successfully")
	def get(self):
		"""
		Retrieve all tasks.
		Calls the service layer to fetch all tasks from the database.
		"""
		tasks = task_service.get_tasks()
		return [
			{
				"id": task.id,
				"title": task.title,
				"description": task.description,
				"child_id": task.child_id,
				"points": task.points,
				"status": task.status,
				"created_by": task.created_by,
				"created_at": task.created_at
			}
			for task in tasks
		], 200


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
		
		return {
			"id": task.id,
			"title": task.title,
			"description": task.description,
			"child_id": task.child_id,
			"points": task.points,
			"status": task.status,
			"created_by": task.created_by,
			"approved_at": task.approved_at,
			"created_at": task.created_at
		}, 200

	@api.expect(task_update_model, validate=True)
	@api.response(200, "Task updated successfully")
	@api.response(404, "Task not found")
	@api.response(400, "Invalid input")
	def put(self, task_id):
		"""
		Update a task's details (title, description, points).
		Calls the service layer and returns 404 if not found.
		"""
		task_data = api.payload
		task = task_service.update_task(task_id, task_data)
		
		if task is None:
			return {"error": "Task not found"}, 404
		
		return {
			"id": task.id,
			"title": task.title,
			"description": task.description,
			"child_id": task.child_id,
			"points": task.points,
			"status": task.status,
			"created_by": task.created_by,
			"created_at": task.created_at
		}, 200

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
		
		return {
			"id": task.id,
			"title": task.title,
			"status": task.status,
			"approved_at": task.approved_at
		}, 200


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
		
		return {
			"id": task.id,
			"title": task.title,
			"status": task.status
		}, 200


@api.route("/child/<child_id>")
class TaskByChildResource(Resource):
	"""Resource for retrieving tasks by child ID"""

	@api.response(200, "Tasks retrieved successfully")
	def get(self, child_id):
		"""
		Retrieve all tasks assigned to a specific child.
		"""
		tasks = task_service.get_tasks_by_child(child_id)
		return [
			{
				"id": task.id,
				"title": task.title,
				"description": task.description,
				"points": task.points,
				"status": task.status,
				"created_at": task.created_at
			}
			for task in tasks
		], 200


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
