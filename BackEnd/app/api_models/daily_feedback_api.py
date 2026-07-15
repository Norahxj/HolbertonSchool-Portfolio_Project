from flask_restx import fields

def get_daily_feedback_models(api):
    daily_feedback_create_model = api.model("DailyFeedbackCreate",
        {
            "child_id": fields.String(
                required=True,
                description="Child ID"
            ),
            "mood": fields.String(
                required=True,
                description=(
                    "HAPPY, PROUD, GREAT, LOVE, STRONG, or STAR"
                )
            )
        }
    )

    daily_feedback_update_model = api.model(
        "DailyFeedbackUpdate",
        {
            "mood": fields.String(
                required=True,
                description=(
                    "HAPPY, PROUD, GREAT, LOVE, STRONG, or STAR"
                )
            )
        }
    )
    daily_feedback_response_model = api.model(
        "DailyFeedbackResponse",
        {
            "id": fields.String(),
            "child_id": fields.String(),
            "created_by": fields.String(),
            "mood": fields.String(),
            "feedback_date": fields.Date(),
            "created_at": fields.DateTime()
        }
    )
    return (
        daily_feedback_create_model,
        daily_feedback_update_model,
        daily_feedback_response_model
    )