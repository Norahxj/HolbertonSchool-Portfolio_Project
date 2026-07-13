from flask_restx import fields


def get_reward_bank_models(api):

    suggestion_request_model = api.model(
        "RewardSuggestionRequest",
        {
            "lang": fields.String(
                required=False,
                enum=["ar", "en"],
                description="Suggestion language"
            )
        }
    )

    suggestion_response_model = api.model(
        "RewardSuggestionResponse",
        {
            "reward_name": fields.String(),
            "description": fields.String(),
            "unlock_day": fields.Integer(
                description="0=Monday ... 6=Sunday"
            )
        }
    )

    return (
        suggestion_request_model,
        suggestion_response_model
    )