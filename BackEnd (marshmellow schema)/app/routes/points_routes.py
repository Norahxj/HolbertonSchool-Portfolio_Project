from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from app.services.points_service import PointsService
from app.schemas.gamification_schemas import DailyFeedbackSchema
from app.exceptions.api_exceptions import ValidationError, NotFoundError, ConflictError, ForbiddenError
from app.utils.decorators import parent_required

points_bp = Blueprint("points", __name__, url_prefix="/points")

daily_feedback_schema = DailyFeedbackSchema()

@points_bp.route("/child/<string:child_id>/award-task-points", methods=["POST"])
@jwt_required()
@parent_required
def award_task_points(child_id):
    """Award points to a child for a verified task completion."""
    try:
        parent_id = get_jwt_identity()
        # Ensure child belongs to parent
        data = request.get_json()
        if not data or "task_id" not in data:
            raise ValidationError("Task ID is required.")
        task_id = data["task_id"]

        result = PointsService.add_points_for_task_completion(child_id, task_id)
        return jsonify(result), 200
    except ValidationError as e:
        return jsonify({"message": e.message, "errors": e.errors}), 400
    except NotFoundError as e:
        return jsonify({"message": e.message}), 404
    except ConflictError as e:
        return jsonify({"message": e.message}), 409
    except ForbiddenError as e:
        return jsonify({"message": e.message}), 403
    except Exception as e:
        return jsonify({"message": str(e)}), 500

@points_bp.route("/child/<string:child_id>/deduct-reward-points", methods=["POST"])
@jwt_required()
@parent_required
def deduct_reward_points(child_id):
    """Deduct points from a child for reward redemption."""
    try:
        parent_id = get_jwt_identity()
        data = request.get_json()
        if not data or "points_to_deduct" not in data:
            raise ValidationError("Points to deduct is required.")
        points_to_deduct = data["points_to_deduct"]

        result = PointsService.deduct_points_for_reward_redemption(child_id, points_to_deduct)
        return jsonify(result), 200
    except ValidationError as e:
        return jsonify({"message": e.message, "errors": e.errors}), 400
    except NotFoundError as e:
        return jsonify({"message": e.message}), 404
    except ConflictError as e:
        return jsonify({"message": e.message}), 409
    except ForbiddenError as e:
        return jsonify({"message": e.message}), 403
    except Exception as e:
        return jsonify({"message": str(e)}), 500

@points_bp.route("/child/<string:child_id>/feedback", methods=["POST"])
@jwt_required()
@parent_required
def record_daily_feedback(child_id):
    """Record daily feedback for a child and award points accordingly."""
    try:
        parent_id = get_jwt_identity()
        data = request.get_json()
        if not data:
            raise ValidationError("No input data provided.")

        result = PointsService.record_daily_feedback(child_id, data)
        return jsonify(result), 201
    except ValidationError as e:
        return jsonify({"message": e.message, "errors": e.errors}), 400
    except NotFoundError as e:
        return jsonify({"message": e.message}), 404
    except ConflictError as e:
        return jsonify({"message": e.message}), 409
    except ForbiddenError as e:
        return jsonify({"message": e.message}), 403
    except Exception as e:
        return jsonify({"message": str(e)}), 500

@points_bp.route("/child/<string:child_id>/feedback", methods=["GET"])
@jwt_required()
@parent_required
def get_daily_feedback(child_id):
    """Get daily feedback entries for a child, with optional date filter."""
    try:
        parent_id = get_jwt_identity()
        feedback_date_str = request.args.get("date")
        feedback_date = None
        if feedback_date_str:
            from datetime import datetime
            try:
                feedback_date = datetime.strptime(feedback_date_str, "%Y-%m-%d").date()
            except ValueError:
                raise ValidationError("Invalid date format. Use YYYY-MM-DD.")

        feedback_entries = PointsService.get_daily_feedback(child_id, feedback_date)
        return jsonify(feedback_entries), 200
    except ValidationError as e:
        return jsonify({"message": e.message}), 400
    except NotFoundError as e:
        return jsonify({"message": e.message}), 404
    except ForbiddenError as e:
        return jsonify({"message": e.message}), 403
    except Exception as e:
        return jsonify({"message": str(e)}), 500

@points_bp.route("/child/<string:child_id>/current-points", methods=["GET"])
@jwt_required()
def get_child_current_points(child_id):
    """Get the current Noor points for a specific child."""
    try:
        #if parent is viewing points for child, parent_id would be used for authorization
        points_data = PointsService.get_child_current_points(child_id)
        return jsonify(points_data), 200
    except NotFoundError as e:
        return jsonify({"message": e.message}), 404
    except ForbiddenError as e:
        return jsonify({"message": e.message}), 403
    except Exception as e:
        return jsonify({"message": str(e)}), 500
