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

task_create_model, task_update_model = get_task_models(api)

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

        if error == "child_not_found":
            return {"error": "Child not found"}, 404

        return task_response_schema.dump(task), 201

    @api.doc(security="JWT")
    @jwt_required()
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
    def put(self, task_id):
        parent_id = get_jwt_identity()
        error = require_parent()
        if error:
            return error

        try:
            task_data = task_update_schema.load(api.payload)
        except ValidationError as err:
            return {"errors": err.messages}, 400

        if not task_data:
            return {"error": "No fields provided for update"}, 400

        task = task_service.update_task_for_parent(task_id, parent_id, task_data)

        if not task:
            return {"error": "Task not found"}, 404

        return task_response_schema.dump(task), 200

    @api.doc(security="JWT")
    @jwt_required()
    def delete(self, task_id):
        parent_id = get_jwt_identity()
        error = require_parent()
        if error:
            return error

        deleted = task_service.delete_task_for_parent(task_id, parent_id)

        if not deleted:
            return {"error": "Task not found"}, 404

        return {"message": "Task deleted successfully"}, 200


@api.route("/child/<child_id>")
class TasksByChildResource(Resource):

    @api.doc(security="JWT")
    @jwt_required()
    def get(self, child_id):
        parent_id = get_jwt_identity()
        error = require_parent()
        if error:
            return error

        tasks = task_service.get_tasks_by_child_for_parent(child_id, parent_id)

        if tasks is None:
            return {"error": "Child not found"}, 404

        return tasks_response_schema.dump(tasks), 200


@api.route("/<task_id>/approve")
class TaskApproveResource(Resource):

    @api.doc(security="JWT")
    @jwt_required()
    def put(self, task_id):
        parent_id = get_jwt_identity()
        error = require_parent()
        if error:
            return error

        task, error = task_service.approve_task_for_parent(task_id, parent_id)

        if error == "task_not_found":
            return {"error": "Task not found"}, 404

        if error == "task_not_pending_review":
            return {"error": "Task is not waiting for review"}, 400

        return task_response_schema.dump(task), 200


@api.route("/<task_id>/reject")
class TaskRejectResource(Resource):

    @api.doc(security="JWT")
    @jwt_required()
    def put(self, task_id):
        parent_id = get_jwt_identity()
        error = require_parent()
        if error:
            return error

        task, error = task_service.reject_task_for_parent(task_id, parent_id)

        if error == "task_not_found":
            return {"error": "Task not found"}, 404

        if error == "task_not_pending_review":
            return {"error": "Task is not waiting for review"}, 400
        return task_response_schema.dump(task), 200
    
@api.route("/<task_id>/complete")
class TaskCompleteResource(Resource):

    @api.doc(security="JWT")
    @jwt_required()
    def put(self, task_id):
        claims = get_jwt()

        if claims.get("role") != "child":
            return {"error": "Child access required"}, 403

        child_id = get_jwt_identity()

        task, error = task_service.complete_task_for_child(task_id, child_id)

        if error == "task_not_found":
            return {"error": "Task not found"}, 404

        if error == "task_already_completed":
            return {"error": "Task already completed or waiting for review"}, 400

        return task_response_schema.dump(task), 200
    
@api.route("/my-tasks")
class ChildTasksResource(Resource):

    @api.doc(security="JWT")
    @jwt_required()
    def get(self):
        claims = get_jwt()

        if claims.get("role") != "child":
            return {"error": "Child access required"}, 403

        child_id = get_jwt_identity()

        tasks = task_service.get_tasks_for_child(child_id)

        return tasks_response_schema.dump(tasks), 200