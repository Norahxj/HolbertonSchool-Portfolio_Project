import os
from flask import request
from flask_restx import Namespace, Resource
from app.services.recurring_task_service import RecurringTaskService
from app.services.reward_service import RewardService

api = Namespace("cron", description="Internal scheduled jobs")
recurring_task_service = RecurringTaskService()
reward_service = RewardService()

def is_valid_cron_request():
    secret = request.headers.get("X-Cron-Secret")
    return (secret and secret == os.getenv("CRON_SECRET"))

@api.route("/run-daily-jobs")
class RunDailyJobs(Resource):
    @api.response(200, "Daily jobs completed successfully")
    @api.response(401, "Unauthorized cron request")
    @api.response(500, "Daily jobs completed with errors")
    def post(self):
        if not is_valid_cron_request():
            return {"error": "Unauthorized"}, 401
        assignment_result, assignment_error = (
            recurring_task_service.generate_today_assignments()
        )
        unlocked_rewards_count, reward_error = (
            reward_service.unlock_today_rewards()
        )
        assignments_succeeded = assignment_error is None
        rewards_succeeded = reward_error is None
        response = {
            "status": (
                "success"
                if assignments_succeeded and rewards_succeeded
                else "partial_failure"
            ),
            "jobs": {
                "task_assignments": {
                    "success": assignments_succeeded,
                    "created": assignment_result["created"],
                    "failed": assignment_result["failed"],
                    "error": assignment_error
                },
                "rewards": {
                    "success": rewards_succeeded,
                    "unlocked": (
                        unlocked_rewards_count
                        if rewards_succeeded
                        else 0
                    ),
                    "error": reward_error
                }
            }
        }
        if not assignments_succeeded or not rewards_succeeded:
            response["message"] = (
                "Daily jobs completed with one or more errors"
            )
            return response, 500
        response["message"] = ("Daily jobs completed successfully")
        return response, 200