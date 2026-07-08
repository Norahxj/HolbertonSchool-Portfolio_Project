from flask import request
from flask_restx import Namespace, Resource
import os

from app.services.recurring_task_service import RecurringTaskService

api = Namespace("cron", description="Internal scheduled jobs")

recurring_task_service = RecurringTaskService()


@api.route("/generate-today-assignments")
class GenerateTodayAssignments(Resource):
    def post(self):
        secret = request.headers.get("X-Cron-Secret")

        if secret != os.getenv("CRON_SECRET"):
            return {"message": "Unauthorized"}, 401

        recurring_task_service.generate_today_assignments()

        return {
            "message": "Today's recurring tasks generated successfully"
        }, 200