from flask_restx import Namespace, Resource
from flask_jwt_extended import jwt_required, get_jwt, get_jwt_identity
from marshmallow import ValidationError
from app.services.reward_service import RewardService
from app.schemas import RewardCreateSchema, RewardUpdateSchema, RewardResponseSchema
from app.api_models.reward_api import get_reward_models

api = Namespace("rewards", description="Reward operations")
reward_service = RewardService()
reward_create_schema = RewardCreateSchema()
reward_update_schema = RewardUpdateSchema()
reward_response_schema = RewardResponseSchema()
rewards_response_schema = RewardResponseSchema(many=True)
reward_create_model, reward_update_model, reward_response_model = get_reward_models(api)

@api.route("/")
class RewardListResource(Resource):
    @api.response(201, "Reward created successfully", reward_response_model)
    @api.response(400, "Invalid input")
    @api.response(403, "Parent access required")
    @api.response(404, "Child not found")
    @api.response(500, "Failed to create reward")
    @api.doc(security="JWT")
    @jwt_required()
    @api.expect(reward_create_model, validate=True)
    def post(self):
        claims = get_jwt()
        if claims.get("role") != "parent":
            return {"error": "Parent access required"}, 403
        try:
            reward_data = reward_create_schema.load(api.payload)
        except ValidationError as err:
            return {"errors": err.messages}, 400
        parent_id = get_jwt_identity()
        reward, error = reward_service.create_reward(parent_id, reward_data)
        if error == "child_not_found":
            return {"error": "Child not found"}, 404
        if error:
            return {"error": "Failed to create reward"}, 500
        return reward_response_schema.dump(reward), 201

@api.route("/child/<child_id>")
class ChildRewardsResource(Resource):
    @api.response(200, "Rewards retrieved successfully")
    @api.response(403, "Parent access required")
    @api.response(404, "Child not found")
    @api.doc(security="JWT")
    @jwt_required()
    def get(self, child_id):
        claims = get_jwt()
        if claims.get("role") != "parent":
            return {"error": "Parent access required"}, 403
        parent_id = get_jwt_identity()
        rewards, error = reward_service.get_rewards_for_child_as_parent(child_id, parent_id)
        if error == "child_not_found":
            return {"error": "Child not found"}, 404
        if error:
            return {"error": "Failed to retrieve rewards"}, 500
        return rewards_response_schema.dump(rewards), 200

@api.route("/my")
class MyRewardsResource(Resource):
    @api.response(200, "Rewards retrieved successfully")
    @api.response(403, "Child access required")
    @api.doc(security="JWT")
    @jwt_required()
    def get(self):
        claims = get_jwt()
        if claims.get("role") != "child":
            return {"error": "Child access required"}, 403
        child_id = get_jwt_identity()
        rewards, error = reward_service.get_my_rewards(child_id)
        if error:
            return {"error": "Failed to retrieve rewards"}, 500
        return rewards_response_schema.dump(rewards), 200

@api.route("/<reward_id>")
class RewardResource(Resource):
    @api.response(200, "Reward updated successfully", reward_response_model)
    @api.response(400, "Invalid input")
    @api.response(403, "Parent access required")
    @api.response(404, "Reward not found")
    @api.response(500, "Failed to update reward")
    @api.doc(security="JWT")
    @jwt_required()
    @api.expect(reward_update_model, validate=True)
    def put(self, reward_id):
        claims = get_jwt()
        if claims.get("role") != "parent":
            return {"error": "Parent access required"}, 403
        try:
            reward_data = reward_update_schema.load(api.payload)
        except ValidationError as err:
            return {"errors": err.messages}, 400
        parent_id = get_jwt_identity()
        reward, error = reward_service.update_reward(reward_id, parent_id, reward_data)
        if error == "reward_not_found":
            return {"error": "Reward not found"}, 404
        if error:
            return {"error": "Failed to update reward"}, 500
        return reward_response_schema.dump(reward), 200
    
    @api.doc(security="JWT")
    @api.response(200, "Reward deleted successfully")
    @api.response(400, "Claimed rewards cannot be deleted")
    @api.response(403, "Parent access required")
    @api.response(404, "Reward not found")
    @api.response(500, "Failed to delete reward")
    @jwt_required()
    def delete(self, reward_id):
        claims = get_jwt()
        if claims.get("role") != "parent":
            return {"error": "Parent access required"}, 403
        parent_id = get_jwt_identity()
        _, delete_error = reward_service.delete_reward(reward_id, parent_id)
        if delete_error == "reward_not_found":
            return {"error": "Reward not found"}, 404
        if delete_error == "claimed_reward_cannot_be_deleted":
            return {"error": "Claimed rewards cannot be deleted"}, 400
        if delete_error:
            return {"error": "Failed to delete reward"}, 500
        return {"message": "Reward deleted successfully"}, 200

@api.route("/<reward_id>/claim")
class ClaimRewardResource(Resource):
    @api.response(200, "Reward claimed successfully", reward_response_model)
    @api.response(400, "Reward is not unlocked")
    @api.response(403, "Child access required")
    @api.response(404, "Reward not found")
    @api.response(500, "Failed to claim reward")
    @api.doc(security="JWT")
    @jwt_required()
    def put(self, reward_id):
        claims = get_jwt()
        if claims.get("role") != "child":
            return {"error": "Child access required"}, 403
        child_id = get_jwt_identity()
        reward, error = reward_service.claim_reward(reward_id, child_id)
        if error == "reward_not_found":
            return {"error": "Reward not found"}, 404
        if error == "reward_not_unlocked":
            return {"error": "Reward is not unlocked yet"}, 400
        if error:
            return {"error": "Failed to claim reward"}, 500
        return reward_response_schema.dump(reward), 200