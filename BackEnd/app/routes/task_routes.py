from flask_restx import Namespace, Resource
from flask_jwt_extended import jwt_required, get_jwt_identity, get_jwt
from marshmallow import ValidationError
from app.api_models.task_api import get_task_models
from app.services.task_service import TaskService
from app.schemas import TaskResponseSchema, TaskCreateSchema, TaskUpdateSchema

api = Namespace("tasks", description="Task operations")
task_service = TaskService()
task_response_schema = TaskResponseSchema()
tasks_response_schema = TaskResponseSchema(many=True)
task_create_schema = TaskCreateSchema()
task_update_schema = TaskUpdateSchema()
task_create_model, task_update_model, task_response_model = get_task_models(api)

def require_parent():
    claims = get_jwt()
    if claims.get("role") != "parent":
        return {"error": "Parent access required"}, 403
    return None

@api.route("/")
class TaskListResource(Resource):
    @api.doc(security="JWT")
    @jwt_required()
    @api.expect(task_create_model, validate=True)
    @api.response(201, "Task created successfully", task_response_model)
    @api.response(400, "Invalid input")
    @api.response(403, "Parent access required")
    @api.response(404, "Child not found")
    @api.response(500, "Failed to create task")
    def post(self):
        parent_id = get_jwt_identity()
        error = require_parent()
        if error:
            return error
        try:
            task_data = task_create_schema.load(api.payload)
        except ValidationError as err:
            return {"errors": err.messages}, 400
        task, error = task_service.create_task(parent_id, task_data)
        if error == "duplicate_child_ids":
            return {"error": "Duplicate child IDs are not allowed"}, 400
        if error == "child_ids_required":
            return {"error": "At least one child ID is required"}, 400
        if error == "child_not_found":
            return {"error": "Child not found"}, 404
        if error:
            return {"error": "Failed to create task"}, 500
        return task_response_schema.dump(task), 201

    @api.doc(security="JWT")
    @jwt_required()
    @api.response(200, "Tasks retrieved successfully")
    @api.response(403, "Parent access required")
    def get(self):
        parent_id = get_jwt_identity()
        error = require_parent()
        if error:
            return error
        tasks = task_service.get_tasks_for_parent(parent_id)
        return tasks_response_schema.dump(tasks), 200

@api.route("/<task_id>")
class TaskResource(Resource):
    @api.doc(security="JWT")
    @jwt_required()
    @api.response(200, "Task retrieved successfully", task_response_model)
    @api.response(403, "Parent access required")
    @api.response(404, "Task not found")
    def get(self, task_id):
        parent_id = get_jwt_identity()
        error = require_parent()
        if error:
            return error
        task = task_service.get_task_for_parent(task_id, parent_id)
        if not task:
            return {"error": "Task not found"}, 404
        return task_response_schema.dump(task), 200

    @api.doc(security="JWT")
    @jwt_required()
    @api.expect(task_update_model, validate=True)
    @api.response(200, "Task updated successfully", task_response_model)
    @api.response(400, "Invalid input")
    @api.response(403, "Parent access required")
    @api.response(404, "Task not found")
    @api.response(500, "Failed to update task")
    def put(self, task_id):
        parent_id = get_jwt_identity()
        error = require_parent()
        if error:
            return error
        try:
            task_data = task_update_schema.load(api.payload)
        except ValidationError as err:
            return {"errors": err.messages}, 400
        task, error = task_service.update_task_for_parent(task_id, parent_id, task_data)
        if error == "not_found":
            return {"error": "Task not found"}, 404
        if error == "invalid_recurrence_day":
            return {"error": "Invalid recurrence_day for selected task_frequency"}, 400
        if error == "invalid_frequency":
            return {"error": "Invalid task frequency"}, 400
        if error:
            return {"error": "Failed to update task"}, 500
        return task_response_schema.dump(task), 200

    @api.doc(security="JWT")
    @jwt_required()
    @api.response(200, "Task deleted successfully")
    @api.response(403, "Parent access required")
    @api.response(404, "Task not found")
    @api.response(500, "Failed to delete task")
    def delete(self, task_id):
        parent_id = get_jwt_identity()
        error = require_parent()
        if error:
            return error
        _, delete_error = task_service.delete_task_for_parent(task_id, parent_id)
        if delete_error == "task_not_found":
            return {"error": "Task not found"}, 404
        if delete_error == "delete_error":
            return {"error": "Failed to delete task"}, 500
        return {"message": "Task deleted successfully"}, 200


@api.route("/child/<child_id>")
class TasksByChildResource(Resource):
    @api.doc(security="JWT")
    @jwt_required()
    @api.response(200, "Child tasks retrieved successfully")
    @api.response(403, "Parent access required")
    @api.response(404, "Child not found")
    def get(self, child_id):
        parent_id = get_jwt_identity()
        error = require_parent()
        if error:
            return error
        tasks = task_service.get_tasks_by_child_for_parent(child_id, parent_id)
        if tasks is None:
            return {"error": "Child not found"}, 404
        return tasks_response_schema.dump(tasks), 200