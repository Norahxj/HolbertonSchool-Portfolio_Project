from flask import request
from flask_restx import Namespace, Resource

from app.services.task_bank_service import TaskBankService
from app.schemas import SuggestedTaskResponseSchema
from app.api_models.task_bank_api import get_task_bank_models


api = Namespace("task-bank", description="Suggested task bank operations")

task_bank_service = TaskBankService()

suggested_task_schema = SuggestedTaskResponseSchema(many=True)
suggested_task_model = get_task_bank_models(api)


@api.route("/categories")
class TaskBankCategoriesResource(Resource):

    def get(self):
        categories = task_bank_service.get_categories()
        return {"categories": categories}, 200


@api.route("/tasks")
class SuggestedTasksResource(Resource):

    @api.param("category", "Filter tasks by category")
    def get(self):
        category = request.args.get("category")

        tasks = task_bank_service.get_tasks(category)

        return suggested_task_schema.dump(tasks), 200