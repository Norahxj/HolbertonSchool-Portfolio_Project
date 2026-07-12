import os

from flask import request
from flask_restx import Namespace, Resource

from app.services.recurring_task_service import (
    RecurringTaskService
)
from app.services.reward_service import RewardService


api = Namespace(
    "cron",
    description="Internal scheduled jobs"
)

recurring_task_service = RecurringTaskService()
reward_service = RewardService()


def is_valid_cron_request():
    secret = request.headers.get("X-Cron-Secret")

    return (
        secret
        and secret == os.getenv("CRON_SECRET")
    )


@api.route("/run-daily-jobs")
class RunDailyJobs(Resource):

    def post(self):
        if not is_valid_cron_request():
            return {"error": "Unauthorized"}, 401

        assignments_count, assignment_error = (
            recurring_task_service
            .generate_today_assignments()
        )

        if assignment_error == "assignment_failed":
            return {
                "error": (
                    "Failed to generate today's "
                    "task assignments"
                )
            }, 500

        unlocked_rewards_count, reward_error = (
            reward_service.unlock_today_rewards()
        )

        if reward_error == "update_failed":
            return {
                "error": (
                    "Failed to unlock today's rewards"
                )
            }, 500

        return {
            "message": "Daily jobs completed successfully",
            "created_assignments": assignments_count,
            "unlocked_rewards": unlocked_rewards_count
        }, 200