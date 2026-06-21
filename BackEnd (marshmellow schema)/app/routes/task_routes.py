from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from app.services.task_service import TaskService
from app.schemas.task_schemas import TaskCategorySchema, SuggestedTaskSchema, ParentCustomTaskSchema
from app.schemas.gamification_schemas import ChildTaskSchema
from app.exceptions.api_exceptions import ValidationError, NotFoundError, ConflictError, ForbiddenError
from app.utils.decorators import parent_required

task_bp = Blueprint("task", __name__, url_prefix="/tasks")

task_category_schema = TaskCategorySchema()
suggested_task_schema = SuggestedTaskSchema()
parent_custom_task_schema = ParentCustomTaskSchema()
child_task_schema = ChildTaskSchema()

# Task Category Routes
@task_bp.route("/categories", methods=["POST"])
@jwt_required()
@parent_required
def create_task_category():
    """Create a new task category (admin/parent only)."""
    try:
        data = request.get_json()
        if not data:
            raise ValidationError("No input data provided.")
        category = TaskService.create_task_category(data)
        return jsonify(category), 201
    except ValidationError as e:
        return jsonify({"message": e.message, "errors": e.errors}), 400
    except ConflictError as e:
        return jsonify({"message": e.message}), 409
    except Exception as e:
        return jsonify({"message": str(e)}), 500

@task_bp.route("/categories", methods=["GET"])
def get_all_task_categories():
    """Get all task categories."""
    try:
        categories = TaskService.get_all_task_categories()
        return jsonify(categories), 200
    except Exception as e:
        return jsonify({"message": str(e)}), 500

@task_bp.route("/categories/<string:category_id>", methods=["GET"])
def get_task_category(category_id):
    """Get a specific task category by ID."""
    try:
        category = TaskService.get_task_category_by_id(category_id)
        return jsonify(category), 200
    except NotFoundError as e:
        return jsonify({"message": e.message}), 404
    except Exception as e:
        return jsonify({"message": str(e)}), 500

# Suggested Task Routes
@task_bp.route("/suggested", methods=["POST"])
@jwt_required()
@parent_required
def create_suggested_task():
    """Create a new suggested task (admin/parent only)."""
    try:
        data = request.get_json()
        if not data:
            raise ValidationError("No input data provided.")
        task = TaskService.create_suggested_task(data)
        return jsonify(task), 201
    except ValidationError as e:
        return jsonify({"message": e.message, "errors": e.errors}), 400
    except NotFoundError as e:
        return jsonify({"message": e.message}), 404
    except Exception as e:
        return jsonify({"message": str(e)}), 500

@task_bp.route("/suggested", methods=["GET"])
def get_suggested_tasks():
    """Get suggested tasks, with optional filters."""
    try:
        category_id = request.args.get("category_id")
        min_age = request.args.get("min_age", type=int)
        max_age = request.args.get("max_age", type=int)
        tasks = TaskService.get_suggested_tasks(category_id, min_age, max_age)
        return jsonify(tasks), 200
    except Exception as e:
        return jsonify({"message": str(e)}), 500

@task_bp.route("/suggested/<string:task_id>", methods=["GET"])
def get_suggested_task(task_id):
    """Get a specific suggested task by ID."""
    try:
        task = TaskService.get_suggested_task_by_id(task_id)
        return jsonify(task), 200
    except NotFoundError as e:
        return jsonify({"message": e.message}), 404
    except Exception as e:
        return jsonify({"message": str(e)}), 500

# Parent Custom Task Routes
@task_bp.route("/custom", methods=["POST"])
@jwt_required()
@parent_required
def create_parent_custom_task():
    """Create a new custom task for the authenticated parent."""
    try:
        parent_id = get_jwt_identity()
        data = request.get_json()
        if not data:
            raise ValidationError("No input data provided.")
        data["parent_id"] = parent_id
        task = TaskService.create_parent_custom_task(parent_id, data)
        return jsonify(task), 201
    except ValidationError as e:
        return jsonify({"message": e.message, "errors": e.errors}), 400
    except NotFoundError as e:
        return jsonify({"message": e.message}), 404
    except ForbiddenError as e:
        return jsonify({"message": e.message}), 403
    except Exception as e:
        return jsonify({"message": str(e)}), 500

@task_bp.route("/custom", methods=["GET"])
@jwt_required()
@parent_required
def get_parent_custom_tasks():
    """Get all custom tasks created by the authenticated parent."""
    try:
        parent_id = get_jwt_identity()
        tasks = TaskService.get_parent_custom_tasks(parent_id)
        return jsonify(tasks), 200
    except Exception as e:
        return jsonify({"message": str(e)}), 500

@task_bp.route("/custom/<string:task_id>", methods=["GET"])
@jwt_required()
@parent_required
def get_parent_custom_task(task_id):
    """Get a specific custom task by ID for the authenticated parent."""
    try:
        parent_id = get_jwt_identity()
        task = TaskService.get_parent_custom_task_by_id(parent_id, task_id)
        return jsonify(task), 200
    except NotFoundError as e:
        return jsonify({"message": e.message}), 404
    except ForbiddenError as e:
        return jsonify({"message": e.message}), 403
    except Exception as e:
        return jsonify({"message": str(e)}), 500

@task_bp.route("/custom/<string:task_id>", methods=["PUT"])
@jwt_required()
@parent_required
def update_parent_custom_task(task_id):
    """Update a specific custom task by ID for the authenticated parent."""
    try:
        parent_id = get_jwt_identity()
        data = request.get_json()
        if not data:
            raise ValidationError("No input data provided.")
        task = TaskService.update_parent_custom_task(parent_id, task_id, data)
        return jsonify(task), 200
    except ValidationError as e:
        return jsonify({"message": e.message, "errors": e.errors}), 400
    except NotFoundError as e:
        return jsonify({"message": e.message}), 404
    except ForbiddenError as e:
        return jsonify({"message": e.message}), 403
    except Exception as e:
        return jsonify({"message": str(e)}), 500

@task_bp.route("/custom/<string:task_id>", methods=["DELETE"])
@jwt_required()
@parent_required
def delete_parent_custom_task(task_id):
    """Delete a specific custom task by ID for the authenticated parent."""
    try:
        parent_id = get_jwt_identity()
        result = TaskService.delete_parent_custom_task(parent_id, task_id)
        return jsonify(result), 200
    except NotFoundError as e:
        return jsonify({"message": e.message}), 404
    except ForbiddenError as e:
        return jsonify({"message": e.message}), 403
    except Exception as e:
        return jsonify({"message": str(e)}), 500

# Child Task Assignment Routes
@task_bp.route("/child/<string:child_id>/assign", methods=["POST"])
@jwt_required()
@parent_required
def assign_task_to_child(child_id):
    """Assign a task (suggested or custom) to a specific child."""
    try:
        parent_id = get_jwt_identity()
        data = request.get_json()
        if not data:
            raise ValidationError("No input data provided.")
        child_task = TaskService.assign_task_to_child(parent_id, child_id, data)
        return jsonify(child_task), 201
    except ValidationError as e:
        return jsonify({"message": e.message, "errors": e.errors}), 400
    except NotFoundError as e:
        return jsonify({"message": e.message}), 404
    except ForbiddenError as e:
        return jsonify({"message": e.message}), 403
    except ConflictError as e:
        return jsonify({"message": e.message}), 409
    except Exception as e:
        return jsonify({"message": str(e)}), 500

@task_bp.route("/child/<string:child_id>", methods=["GET"])
@jwt_required()
@parent_required
def get_child_tasks(child_id):
    """Get all tasks assigned to a specific child, with optional status filter."""
    try:
        parent_id = get_jwt_identity()
        # Ensure child belongs
        status = request.args.get("status")
        tasks = TaskService.get_child_tasks(child_id, status)
        return jsonify(tasks), 200
    except NotFoundError as e:
        return jsonify({"message": e.message}), 404
    except ForbiddenError as e:
        return jsonify({"message": e.message}), 403
    except ValidationError as e:
        return jsonify({"message": e.message}), 400
    except Exception as e:
        return jsonify({"message": str(e)}), 500

@task_bp.route("/child/<string:child_id>/<string:task_id>", methods=["GET"])
@jwt_required()
@parent_required
def get_child_task(child_id, task_id):
    """Get a specific assigned task for a child."""
    try:
        parent_id = get_jwt_identity()
        # Ensure child belongs
        task = TaskService.get_child_task_by_id(child_id, task_id)
        return jsonify(task), 200
    except NotFoundError as e:
        return jsonify({"message": e.message}), 404
    except ForbiddenError as e:
        return jsonify({"message": e.message}), 403
    except Exception as e:
        return jsonify({"message": str(e)}), 500

@task_bp.route("/child/<string:child_id>/<string:task_id>/status", methods=["PUT"])
@jwt_required()
@parent_required
def update_child_task_status(child_id, task_id):
    """Update the status of a child's assigned task."""
    try:
        parent_id = get_jwt_identity()
        data = request.get_json()
        if not data or "status" not in data:
            raise ValidationError("Status field is required.")
        new_status = data["status"]
        task = TaskService.update_child_task_status(child_id, task_id, new_status)
        return jsonify(task), 200
    except ValidationError as e:
        return jsonify({"message": e.message, "errors": e.errors}), 400
    except NotFoundError as e:
        return jsonify({"message": e.message}), 404
    except ForbiddenError as e:
        return jsonify({"message": e.message}), 403
    except ConflictError as e:
        return jsonify({"message": e.message}), 409
    except Exception as e:
        return jsonify({"message": str(e)}), 500

@task_bp.route("/child/<string:child_id>/<string:task_id>", methods=["DELETE"])
@jwt_required()
@parent_required
def delete_child_task(child_id, task_id):
    """Delete a specific assigned task for a child."""
    try:
        parent_id = get_jwt_identity()
        result = TaskService.delete_child_task(parent_id, child_id, task_id)
        return jsonify(result), 200
    except NotFoundError as e:
        return jsonify({"message": e.message}), 404
    except ForbiddenError as e:
        return jsonify({"message": e.message}), 403
    except Exception as e:
        return jsonify({"message": str(e)}), 500
