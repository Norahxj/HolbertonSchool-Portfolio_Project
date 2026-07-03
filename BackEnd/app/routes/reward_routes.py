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

        if error == "create_failed":
            return {"error": "Failed to create reward"}, 500

        return reward_response_schema.dump(reward), 201


@api.route("/child/<child_id>")
class ChildRewardsResource(Resource):

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

        return rewards_response_schema.dump(rewards), 200


@api.route("/my")
class MyRewardsResource(Resource):

    @api.doc(security="JWT")
    @jwt_required()
    def get(self):
        claims = get_jwt()

        if claims.get("role") != "child":
            return {"error": "Child access required"}, 403

        child_id = get_jwt_identity()

        rewards, error = reward_service.get_my_rewards(child_id)

        return rewards_response_schema.dump(rewards), 200


@api.route("/<reward_id>")
class RewardResource(Resource):

    @api.doc(security="JWT")
    @jwt_required()
    @api.expect(reward_update_model, validate=True)
    def put(self, reward_id):
        claims = get_jwt()

        if claims.get("role") != "parent":
            return {"error": "Parent access required"}, 403

        try:
            reward_data = reward_update_schema.load(api.payload)

            if not reward_data:
                return {"error": "No fields provided for update"}, 400

        except ValidationError as err:
            return {"errors": err.messages}, 400

        parent_id = get_jwt_identity()

        reward, error = reward_service.update_reward(
            reward_id,
            parent_id,
            reward_data
        )

        if error == "reward_not_found":
            return {"error": "Reward not found"}, 404

        if error == "update_failed":
            return {"error": "Failed to update reward"}, 500

        return reward_response_schema.dump(reward), 200

    @api.doc(security="JWT")
    @jwt_required()
    def delete(self, reward_id):
        claims = get_jwt()

        if claims.get("role") != "parent":
            return {"error": "Parent access required"}, 403

        parent_id = get_jwt_identity()

        deleted = reward_service.delete_reward(reward_id, parent_id)

        if not deleted:
            return {"error": "Reward not found"}, 404

        return {"message": "Reward deleted successfully"}, 200


@api.route("/<reward_id>/claim")
class ClaimRewardResource(Resource):

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

        if error == "update_failed":
            return {"error": "Failed to claim reward"}, 500

        return reward_response_schema.dump(reward), 200


# Temporary endpoint for testing reward unlocking.
# Delete it after testing.
@api.route("/unlock-today")
class UnlockTodayRewardsResource(Resource):

    @api.doc(security="JWT")
    @jwt_required()
    def post(self):
        claims = get_jwt()

        if claims.get("role") != "parent":
            return {"error": "Parent access required"}, 403

        unlocked_count, error = reward_service.unlock_today_rewards()

        if error == "update_failed":
            return {"error": "Failed to unlock rewards"}, 500

        return {"unlocked_rewards": unlocked_count}, 200