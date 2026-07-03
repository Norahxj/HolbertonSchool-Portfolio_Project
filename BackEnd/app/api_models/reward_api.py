from flask_restx import fields


def get_reward_models(api):

    reward_create_model = api.model("RewardCreate", {
        "child_id": fields.String(required=True, description="Child ID"),
        "reward_name": fields.String(required=True, description="Reward name"),
        "description": fields.String(description="Reward description"),
        "reward_type": fields.String(required=True, description="Reward type"),
        "unlock_day": fields.Integer(description="0=Monday ... 6=Sunday")
    })

    reward_update_model = api.model("RewardUpdate", {
        "reward_name": fields.String(description="Reward name"),
        "description": fields.String(description="Reward description"),
        "reward_type": fields.String(description="Reward type"),
        "unlock_day": fields.Integer(description="0=Monday ... 6=Sunday")
    })

    reward_response_model = api.model("RewardResponse", {
        "id": fields.String(),
        "child_id": fields.String(),
        "reward_name": fields.String(),
        "description": fields.String(),
        "reward_type": fields.String(),
        "status": fields.String(),
        "unlock_day": fields.Integer(),
        "assigned_by": fields.String(),
        "created_at": fields.DateTime()
    })

    return (
        reward_create_model,
        reward_update_model,
        reward_response_model
    )