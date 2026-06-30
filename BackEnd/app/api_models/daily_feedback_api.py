from flask_restx import fields


def get_daily_feedback_models(api):
    daily_feedback_create_model = api.model("DailyFeedbackCreate", {
        "task_id": fields.String(
            required=True,
            description="Task ID"
        ),
        "emoji": fields.String(
            required=True,
            description="One of: ⭐, 🎉, 💪, 😊, ❤️, 👏"
        )
    })

    return daily_feedback_create_model