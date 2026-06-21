from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from app.services.child_service import ChildService
from app.schemas.child_schema import ChildSchema
from app.exceptions.api_exceptions import ValidationError, NotFoundError, ConflictError, ForbiddenError
from app.utils.decorators import parent_required

child_bp = Blueprint("child", __name__, url_prefix="/children")

child_schema = ChildSchema()
children_schema = ChildSchema(many=True)

@child_bp.route("/", methods=["POST"])
@jwt_required()
@parent_required
def create_child():
    """Create a new child for the authenticated parent."""
    try:
        parent_id = get_jwt_identity()
        data = request.get_json()
        if not data:
            raise ValidationError("No input data provided.")

        data["parent_id"] = parent_id # parent_id from authenticated user
        new_child = ChildService.create_child(parent_id, data)
        return jsonify(new_child), 201
    except ValidationError as e:
        return jsonify({"message": e.message, "errors": e.errors}), 400
    except ConflictError as e:
        return jsonify({"message": e.message}), 409
    except ForbiddenError as e:
        return jsonify({"message": e.message}), 403
    except Exception as e:
        return jsonify({"message": str(e)}), 500

@child_bp.route("/", methods=["GET"])
@jwt_required()
@parent_required
def get_children():
    """Get all children for the authenticated parent."""
    try:
        parent_id = get_jwt_identity()
        children = ChildService.get_parent_children(parent_id)
        return jsonify(children), 200
    except Exception as e:
        return jsonify({"message": str(e)}), 500

@child_bp.route("/<string:child_id>", methods=["GET"])
@jwt_required()
@parent_required
def get_child(child_id):
    """Get details of a specific child belonging to the authenticated parent."""
    try:
        parent_id = get_jwt_identity()
        child = ChildService.get_child_by_id(parent_id, child_id)
        return jsonify(child), 200
    except NotFoundError as e:
        return jsonify({"message": e.message}), 404
    except ForbiddenError as e:
        return jsonify({"message": e.message}), 403
    except Exception as e:
        return jsonify({"message": str(e)}), 500

@child_bp.route("/<string:child_id>", methods=["PUT"])
@jwt_required()
@parent_required
def update_child(child_id):
    """Update details of a specific child belonging to the authenticated parent."""
    try:
        parent_id = get_jwt_identity()
        data = request.get_json()
        if not data:
            raise ValidationError("No input data provided.")

        updated_child = ChildService.update_child(parent_id, child_id, data)
        return jsonify(updated_child), 200
    except ValidationError as e:
        return jsonify({"message": e.message, "errors": e.errors}), 400
    except NotFoundError as e:
        return jsonify({"message": e.message}), 404
    except ForbiddenError as e:
        return jsonify({"message": e.message}), 403
    except Exception as e:
        return jsonify({"message": str(e)}), 500

@child_bp.route("/<string:child_id>", methods=["DELETE"])
@jwt_required()
@parent_required
def delete_child(child_id):
    """Delete a specific child belonging to the authenticated parent."""
    try:
        parent_id = get_jwt_identity()
        result = ChildService.delete_child(parent_id, child_id)
        return jsonify(result), 200
    except NotFoundError as e:
        return jsonify({"message": e.message}), 404
    except ForbiddenError as e:
        return jsonify({"message": e.message}), 403
    except Exception as e:
        return jsonify({"message": str(e)}), 500
