from flask_restx import fields


def get_task_bank_models(api):
    suggested_task_response_model = api.model("SuggestedTaskResponse", {
        "id": fields.String(),
        "category": fields.String(),
        "title_en": fields.String(),
        "title_ar": fields.String()
    })

    return suggested_task_response_model