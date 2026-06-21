from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from app.services.reward_service import RewardService
from app.schemas.gamification_schemas import RewardSchema, ChildRewardSchema, WishSchema
from app.exceptions.api_exceptions import ValidationError, NotFoundError, ConflictError, ForbiddenError
from app.utils.decorators import parent_required

reward_bp = Blueprint("reward", __name__, url_prefix="/rewards")

reward_schema = RewardSchema()
child_reward_schema = ChildRewardSchema()
wish_schema = WishSchema()

# Reward Management -- (Parent-defined rewards)
@reward_bp.route("/", methods=["POST"])
@jwt_required()
@parent_required
def create_reward():
    """Create a new reward for the authenticated parent."""
    try:
        parent_id = get_jwt_identity()
        data = request.get_json()
        if not data:
            raise ValidationError("No input data provided.")
        data["parent_id"] = parent_id
        reward = RewardService.create_reward(parent_id, data)
        return jsonify(reward), 201
    except ValidationError as e:
        return jsonify({"message": e.message, "errors": e.errors}), 400
    except ForbiddenError as e:
        return jsonify({"message": e.message}), 403
    except Exception as e:
        return jsonify({"message": str(e)}), 500

@reward_bp.route("/", methods=["GET"])
@jwt_required()
@parent_required
def get_parent_rewards():
    """Get all rewards created by the authenticated parent, with optional active status filter."""
    try:
        parent_id = get_jwt_identity()
        is_active = request.args.get("is_active", type=lambda v: v.lower() == "true")
        rewards = RewardService.get_parent_rewards(parent_id, is_active)
        return jsonify(rewards), 200
    except Exception as e:
        return jsonify({"message": str(e)}), 500

@reward_bp.route("/<string:reward_id>", methods=["GET"])
@jwt_required()
@parent_required
def get_reward(reward_id):
    """Get a specific reward by ID for the authenticated parent."""
    try:
        parent_id = get_jwt_identity()
        reward = RewardService.get_reward_by_id(parent_id, reward_id)
        return jsonify(reward), 200
    except NotFoundError as e:
        return jsonify({"message": e.message}), 404
    except ForbiddenError as e:
        return jsonify({"message": e.message}), 403
    except Exception as e:
        return jsonify({"message": str(e)}), 500

@reward_bp.route("/<string:reward_id>", methods=["PUT"])
@jwt_required()
@parent_required
def update_reward(reward_id):
    """Update a specific reward by ID for the authenticated parent."""
    try:
        parent_id = get_jwt_identity()
        data = request.get_json()
        if not data:
            raise ValidationError("No input data provided.")
        reward = RewardService.update_reward(parent_id, reward_id, data)
        return jsonify(reward), 200
    except ValidationError as e:
        return jsonify({"message": e.message, "errors": e.errors}), 400
    except NotFoundError as e:
        return jsonify({"message": e.message}), 404
    except ForbiddenError as e:
        return jsonify({"message": e.message}), 403
    except Exception as e:
        return jsonify({"message": str(e)}), 500

@reward_bp.route("/<string:reward_id>", methods=["DELETE"])
@jwt_required()
@parent_required
def delete_reward(reward_id):
    """Delete a specific reward by ID for the authenticated parent."""
    try:
        parent_id = get_jwt_identity()
        result = RewardService.delete_reward(parent_id, reward_id)
        return jsonify(result), 200
    except NotFoundError as e:
        return jsonify({"message": e.message}), 404
    except ForbiddenError as e:
        return jsonify({"message": e.message}), 403
    except Exception as e:
        return jsonify({"message": str(e)}), 500

# --- Child Reward Redemption Routes ---
@reward_bp.route("/child/<string:child_id>/redeem", methods=["POST"])
@jwt_required()
def redeem_reward(child_id):
    """Child redeems a reward."""
    try:
#parent is initiating redemption for their child
        parent_id = get_jwt_identity() 
        if not data or "reward_id" not in data:
            raise ValidationError("Reward ID is required.")
        reward_id = data["reward_id"]

        #ensure the child belongs to the parent before redemption
        #checks child.parent_id
        redeemed_reward = RewardService.redeem_reward(child_id, reward_id)
        return jsonify(redeemed_reward), 200
    except ValidationError as e:
        return jsonify({"message": e.message, "errors": e.errors}), 400
    except NotFoundError as e:
        return jsonify({"message": e.message}), 404
    except ConflictError as e:
        return jsonify({"message": e.message}), 409
    except Exception as e:
        return jsonify({"message": str(e)}), 500

@reward_bp.route("/child/<string:child_id>/redeemed", methods=["GET"])
@jwt_required()
@parent_required
def get_child_redeemed_rewards(child_id):
    """Get all rewards redeemed by a specific child, with optional fulfillment status filter."""
    try:
        parent_id = get_jwt_identity()
        is_fulfilled = request.args.get("is_fulfilled", type=lambda v: v.lower() == "true")
        rewards = RewardService.get_child_redeemed_rewards(child_id, is_fulfilled)
        return jsonify(rewards), 200
    except NotFoundError as e:
        return jsonify({"message": e.message}), 404
    except ForbiddenError as e:
        return jsonify({"message": e.message}), 403
    except Exception as e:
        return jsonify({"message": str(e)}), 500

@reward_bp.route("/child/redeemed/<string:child_reward_id>/fulfill", methods=["PUT"])
@jwt_required()
@parent_required
def fulfill_child_reward(child_reward_id):
    """Mark a child's redeemed reward as fulfilled by the parent."""
    try:
        parent_id = get_jwt_identity()
        fulfilled_reward = RewardService.fulfill_child_reward(parent_id, child_reward_id)
        return jsonify(fulfilled_reward), 200
    except NotFoundError as e:
        return jsonify({"message": e.message}), 404
    except ForbiddenError as e:
        return jsonify({"message": e.message}), 403
    except ConflictError as e:
        return jsonify({"message": e.message}), 409
    except Exception as e:
        return jsonify({"message": str(e)}), 500

# --- Wish Management Routes ---
@reward_bp.route("/child/<string:child_id>/wishes", methods=["POST"])
@jwt_required()
def create_wish(child_id):
    """Child creates a new wish."""
    try:
        # differentiate between parent creating wish for child vs child creating own wish
        data = request.get_json()
        if not data:
            raise ValidationError("No input data provided.")
        data["child_id"] = child_id 
        new_wish = RewardService.create_wish(child_id, data)
        return jsonify(new_wish), 201
    except ValidationError as e:
        return jsonify({"message": e.message, "errors": e.errors}), 400
    except NotFoundError as e:
        return jsonify({"message": e.message}), 404
    except ForbiddenError as e:
        return jsonify({"message": e.message}), 403
    except Exception as e:
        return jsonify({"message": str(e)}), 500

@reward_bp.route("/child/<string:child_id>/wishes", methods=["GET"])
@jwt_required()
def get_child_wishes(child_id):
    """Get all wishes for a specific child, with optional achievement status filter."""
    try:
        #if parent is viewing wishes for child, parent_id would be used for authorization
        is_achieved = request.args.get("is_achieved", type=lambda v: v.lower() == "true")
        wishes = RewardService.get_child_wishes(child_id, is_achieved)
        return jsonify(wishes), 200
    except NotFoundError as e:
        return jsonify({"message": e.message}), 404
    except ForbiddenError as e:
        return jsonify({"message": e.message}), 403
    except Exception as e:
        return jsonify({"message": str(e)}), 500

@reward_bp.route("/child/<string:child_id>/wishes/<string:wish_id>", methods=["GET"])
@jwt_required()
def get_wish(child_id, wish_id):
    """Get a specific wish by ID for a given child."""
    try:
        wish = RewardService.get_wish_by_id(child_id, wish_id)
        return jsonify(wish), 200
    except NotFoundError as e:
        return jsonify({"message": e.message}), 404
    except ForbiddenError as e:
        return jsonify({"message": e.message}), 403
    except Exception as e:
        return jsonify({"message": str(e)}), 500

@reward_bp.route("/child/<string:child_id>/wishes/<string:wish_id>", methods=["PUT"])
@jwt_required()
def update_wish(child_id, wish_id):
    """Update a specific wish by ID for a given child."""
    try:
        data = request.get_json()
        if not data:
            raise ValidationError("No input data provided.")
        wish = RewardService.update_wish(child_id, wish_id, data)
        return jsonify(wish), 200
    except ValidationError as e:
        return jsonify({"message": e.message, "errors": e.errors}), 400
    except NotFoundError as e:
        return jsonify({"message": e.message}), 404
    except ForbiddenError as e:
        return jsonify({"message": e.message}), 403
    except Exception as e:
        return jsonify({"message": str(e)}), 500

@reward_bp.route("/child/<string:child_id>/wishes/<string:wish_id>", methods=["DELETE"])
@jwt_required()
def delete_wish(child_id, wish_id):
    """Delete a specific wish by ID for a given child."""
    try:
        result = RewardService.delete_wish(child_id, wish_id)
        return jsonify(result), 200
    except NotFoundError as e:
        return jsonify({"message": e.message}), 404
    except ForbiddenError as e:
        return jsonify({"message": e.message}), 403
    except Exception as e:
        return jsonify({"message": str(e)}), 500

@reward_bp.route("/wishes/<string:wish_id>/approve", methods=["PUT"])
@jwt_required()
@parent_required
def approve_wish(wish_id):
    """Parent approves a child's wish."""
    try:
        parent_id = get_jwt_identity()
        approved_wish = RewardService.approve_wish(parent_id, wish_id)
        return jsonify(approved_wish), 200
    except NotFoundError as e:
        return jsonify({"message": e.message}), 404
    except ForbiddenError as e:
        return jsonify({"message": e.message}), 403
    except ConflictError as e:
        return jsonify({"message": e.message}), 409
    except Exception as e:
        return jsonify({"message": str(e)}), 500
