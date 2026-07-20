from flask_restx import Namespace, Resource
from flask_jwt_extended import jwt_required, get_jwt_identity, get_jwt
from app.api_models.task_assignment_api import get_task_assignment_models
from app.services.task_assignment_service import TaskAssignmentService
from app.schemas import ChildTaskAssignmentResponseSchema, ParentTaskAssignmentResponseSchema

api = Namespace("task-assignments", description="Task assignment operations")
assignment_service = TaskAssignmentService()
child_assignment_response_schema = ChildTaskAssignmentResponseSchema()
child_assignments_response_schema = ChildTaskAssignmentResponseSchema(many=True)
parent_assignment_response_schema = ParentTaskAssignmentResponseSchema()
parent_assignments_response_schema = ParentTaskAssignmentResponseSchema(many=True)

@api.route("/task/<task_id>")
class AssignmentsByTaskResource(Resource):
    @api.response(200, "Assignments retrieved successfully")
    @api.response(401, "Missing or invalid access token")
    @api.response(403, "Parent access required")
    @api.response(404, "Task not found")
    @api.doc(security="JWT")
    @jwt_required()
    def get(self, task_id):
        claims = get_jwt()
        if claims.get("role") != "parent":
            return {"error": "Parent access required"}, 403
        parent_id = get_jwt_identity()
        assignments = assignment_service.get_assignments_for_task(task_id, parent_id)
        if assignments is None:
            return {"error": "Task not found"}, 404
        return parent_assignments_response_schema.dump(assignments), 200

@api.route("/my")
class MyAssignmentsResource(Resource):
    @api.response(200, "Assignments retrieved successfully")
    @api.response(401, "Missing or invalid access token")
    @api.response(403, "Child access required")
    @api.doc(security="JWT")
    @jwt_required()
    def get(self):
        claims = get_jwt()
        if claims.get("role") != "child":
            return {"error": "Child access required"}, 403
        child_id = get_jwt_identity()
        assignments = assignment_service.get_assignments_for_child(child_id)
        return child_assignments_response_schema.dump(assignments), 200

@api.route("/child/<child_id>")
class AssignmentsByChildResource(Resource):
    @api.response(200, "Assignments retrieved successfully")
    @api.response(401, "Missing or invalid access token")
    @api.response(403, "Parent access required")
    @api.response(404, "Child not found or access denied")
    @api.doc(security="JWT")
    @jwt_required()
    def get(self, child_id):
        claims = get_jwt()
        if claims.get("role") != "parent":
            return {"error": "Parent access required"}, 403
        parent_id = get_jwt_identity()
        assignments = assignment_service.get_assignments_for_child_by_parent(
            child_id,
            parent_id
        )
        if assignments is None:
            return {"error": "Child not found or access denied"}, 404
        return parent_assignments_response_schema.dump(assignments), 200

@api.route("/<assignment_id>/complete")
class CompleteAssignmentResource(Resource):
    @api.response(200, "Assignment completed successfully")
    @api.response(400, "Assignment already completed or waiting for review")
    @api.response(401, "Missing or invalid access token")
    @api.response(403, "Child access required")
    @api.response(404, "Assignment not found")
    @api.response(500, "Failed to complete assignment")
    @api.doc(security="JWT")
    @jwt_required()
    def put(self, assignment_id):
        claims = get_jwt()
        if claims.get("role") != "child":
            return {"error": "Child access required"}, 403
        child_id = get_jwt_identity()
        assignment, error = assignment_service.complete_assignment(assignment_id, child_id)
        if error == "assignment_not_found":
            return {"error": "Assignment not found"}, 404
        if error == "assignment_already_completed":
            return {"error": "Assignment already completed or waiting for review"}, 400
        if error:
            return {"error": "Failed to complete assignment"}, 500
        return child_assignment_response_schema.dump(assignment), 200

@api.route("/<assignment_id>/approve")
class ApproveAssignmentResource(Resource):
    @api.response(200, "Assignment approved successfully")
    @api.response(400, "Assignment is not waiting for review")
    @api.response(401, "Missing or invalid access token")
    @api.response(403, "Parent access required")
    @api.response(404, "Assignment not found")
    @api.response(500, "Failed to approve assignment")
    @api.doc(security="JWT")
    @jwt_required()
    def put(self, assignment_id):
        claims = get_jwt()
        if claims.get("role") != "parent":
            return {"error": "Parent access required"}, 403
        parent_id = get_jwt_identity()
        assignment, error = assignment_service.approve_assignment(assignment_id, parent_id)
        if error == "assignment_not_found":
            return {"error": "Assignment not found"}, 404
        if error == "assignment_not_pending_review":
            return {"error": "Assignment is not waiting for review"}, 400
        if error:
            return {"error": "Failed to approve assignment"}, 500
        return parent_assignment_response_schema.dump(assignment), 200

@api.route("/<assignment_id>/reject")
class RejectAssignmentResource(Resource):
    @api.response(200, "Assignment rejected successfully")
    @api.response(400, "Assignment is not waiting for review")
    @api.response(401, "Missing or invalid access token")
    @api.response(403, "Parent access required")
    @api.response(404, "Assignment not found")
    @api.response(500, "Failed to reject assignment")
    @api.doc(security="JWT")
    @jwt_required()
    def put(self, assignment_id):
        claims = get_jwt()
        if claims.get("role") != "parent":
            return {"error": "Parent access required"}, 403
        parent_id = get_jwt_identity()
        assignment, error = assignment_service.reject_assignment(assignment_id, parent_id)
        if error == "assignment_not_found":
            return {"error": "Assignment not found"}, 404
        if error == "assignment_not_pending_review":
            return {"error": "Assignment is not waiting for review"}, 400
        if error:
            return {"error": "Failed to reject assignment"}, 500
        return parent_assignment_response_schema.dump(assignment), 200
