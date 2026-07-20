from flask_restx import Namespace, Resource
from flask_jwt_extended import jwt_required, get_jwt
from app.services.reward_bank_service import RewardBankService
from app.api_models.reward_bank_api import get_reward_bank_models

api = Namespace("reward-bank", description="Suggested reward bank operations")
reward_bank_service = RewardBankService()
suggestion_request_model, suggestion_response_model = get_reward_bank_models(api)

def require_parent():
    claims = get_jwt()
    if claims.get("role") != "parent":
        return {"error": "Parent access required"}, 403
    return None

@api.route("/suggestions")
class RandomSuggestedRewardsResource(Resource):
    @api.response(400, "Invalid language or count")
    @api.response(401, "Missing or invalid access token")
    @api.response(403, "Parent access required")
    @api.response(500, "Failed to retrieve reward suggestions")
    @api.doc(security="JWT")
    @jwt_required()
    @api.expect(suggestion_request_model, validate=True)
    @api.response(200, "Reward suggestions returned successfully", suggestion_response_model)
    def post(self):
        error = require_parent()
        if error:
            return error
        data = api.payload or {}
        suggestions, service_error = (
            reward_bank_service.get_random_suggestions(lang=data.get("lang", "en"), count=data.get("count", 5))
        )
        if service_error == "invalid_language":
            return {"error": "Invalid language"}, 400
        if service_error == "invalid_count":
            return {"error": "Count must be greater than zero"}, 400
        if service_error:
            return {"error": "Failed to retrieve reward suggestions"}, 500
        return {"suggestions": suggestions}, 200