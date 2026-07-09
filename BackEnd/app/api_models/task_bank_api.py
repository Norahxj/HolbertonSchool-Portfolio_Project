from flask_restx import fields


def get_task_bank_models(api):
    suggestion_request_model = api.model("TaskSuggestionRequest", {
        "child_ids": fields.List(fields.String(), required=True),
        "category": fields.String(required=True, enum=["RELIGIOUS", "FINANCIAL", "MORAL", "SOCIAL"]),
        "lang": fields.String(required=False, enum=["ar", "en"])
    })

    suggestion_response_model = api.model("TaskSuggestionResponse", {
        "title": fields.String(),
        "description": fields.String(),
        "points": fields.Integer(),
        "category": fields.String(),
        "task_frequency": fields.String(),
        "recurrence_day": fields.Integer(),
        "is_auto_verified": fields.Boolean()
    })

    return suggestion_request_model, suggestion_response_model