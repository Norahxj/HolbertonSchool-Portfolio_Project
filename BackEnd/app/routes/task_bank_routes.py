from flask_restx import Namespace, Resource
from flask_jwt_extended import jwt_required, get_jwt_identity, get_jwt

from app.services.task_bank_service import TaskBankService
from app.api_models.task_bank_api import get_task_bank_models


api = Namespace("task-bank", description="Suggested task bank operations")

task_bank_service = TaskBankService()

suggestion_request_model, suggestion_response_model = get_task_bank_models(api)


def require_parent():
    claims = get_jwt()
    if claims.get("role") != "parent":
        return {"error": "Parent access required"}, 403
    return None


@api.route("/categories")
class TaskBankCategoriesResource(Resource):
    @api.doc(security="JWT")
    @jwt_required()
    def get(self):
        error = require_parent()
        if error:
            return error

        categories = task_bank_service.get_categories()
        return {"categories": categories}, 200


@api.route("/suggestions")
class RandomSuggestedTasksResource(Resource):
    @api.doc(security="JWT")
    @jwt_required()
    @api.expect(suggestion_request_model)
    def post(self):
        parent_id = get_jwt_identity()

        error = require_parent()
        if error:
            return error

        data = api.payload or {}

        suggestions, error = task_bank_service.get_random_suggestions(
            parent_id=parent_id,
            child_ids=data.get("child_ids", []),
            category=data.get("category", ""),
            lang=data.get("lang", "en"),
            count=5
        )

        if error == "missing_child_ids":
            return {"error": "child_ids is required"}, 400

        if error == "duplicate_child_ids":
            return {"error": "Duplicate child IDs are not allowed"}, 400

        if error == "invalid_category":
            return {"error": "Invalid category"}, 400

        if error == "child_not_found":
            return {"error": "Child not found"}, 404

        return suggestions, 200