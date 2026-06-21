from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from app.services.user_service import UserService
from app.schemas.user_schema import UserSchema
from app.exceptions.api_exceptions import ValidationError, NotFoundError, ConflictError, ForbiddenError
from app.utils.decorators import parent_required

user_bp = Blueprint("user", __name__, url_prefix="/users")

user_schema = UserSchema()
users_schema = UserSchema(many=True)

@user_bp.route("/<string:user_id>", methods=["GET"])
@jwt_required()
def get_user(user_id):
    """Get user details by ID."""
    try:
        current_user_id = get_jwt_identity()
        if current_user_id != user_id:
            raise ForbiddenError("You are not authorized to view this user's profile.")

        user = UserService.get_user_by_id(user_id)
        return jsonify(user), 200
    except NotFoundError as e:
        return jsonify({"message": e.message}), 404
    except ForbiddenError as e:
        return jsonify({"message": e.message}), 403
    except Exception as e:
        return jsonify({"message": str(e)}), 500

@user_bp.route("/<string:user_id>", methods=["PUT"])
@jwt_required()
def update_user(user_id):
    """Update user details by ID."""
    try:
        current_user_id = get_jwt_identity()
        if current_user_id != user_id:
            raise ForbiddenError("You are not authorized to update this user's profile.")

        data = request.get_json()
        if not data:
            raise ValidationError("No input data provided.")

        updated_user = UserService.update_user(user_id, data)
        return jsonify(updated_user), 200
    except ValidationError as e:
        return jsonify({"message": e.message, "errors": e.errors}), 400
    except NotFoundError as e:
        return jsonify({"message": e.message}), 404
    except ForbiddenError as e:
        return jsonify({"message": e.message}), 403
    except Exception as e:
        return jsonify({"message": str(e)}), 500

@user_bp.route("/<string:user_id>", methods=["DELETE"])
@jwt_required()
def delete_user(user_id):
    """Delete a user by ID."""
    try:
        current_user_id = get_jwt_identity()
        if current_user_id != user_id:
            raise ForbiddenError("You are not authorized to delete this user's profile.")

        result = UserService.delete_user(user_id)
        return jsonify(result), 200
    except NotFoundError as e:
        return jsonify({"message": e.message}), 404
    except ForbiddenError as e:
        return jsonify({"message": e.message}), 403
    except Exception as e:
        return jsonify({"message": str(e)}), 500

# Admin-only route to get all users
@user_bp.route("/", methods=["GET"])
@jwt_required()
@parent_required
def get_all_users():
    """Get all users (admin/parent only)."""
    try:
        users = UserService.get_all_users()
        return jsonify(users), 200
    except Exception as e:
        return jsonify({"message": str(e)}), 500
