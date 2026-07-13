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
assignment_response_model = get_task_assignment_models(api)

@api.route("/task/<task_id>")
class AssignmentsByTaskResource(Resource):
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
    @api.doc(security="JWT")
    @jwt_required()
    def get(self):
        claims = get_jwt()
        if claims.get("role") != "child":
            return {"error": "Child access required"}, 403
        child_id = get_jwt_identity()
        assignments = assignment_service.get_assignments_for_child(child_id)
        return child_assignments_response_schema.dump(assignments), 200

@api.route("/<assignment_id>/complete")
class CompleteAssignmentResource(Resource):
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
        if error in ["update_failed", "points_failed"]:
            return {"error": "Failed to complete assignment"}, 500
        return child_assignment_response_schema.dump(assignment), 200

@api.route("/<assignment_id>/approve")
class ApproveAssignmentResource(Resource):
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
        if error in ["update_failed", "points_failed"]:
            return {"error": "Failed to approve assignment"}, 500
        return parent_assignment_response_schema.dump(assignment), 200

@api.route("/<assignment_id>/reject")
class RejectAssignmentResource(Resource):
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
        if error == "update_failed":
            return {"error": "Failed to reject assignment"}, 500
        return parent_assignment_response_schema.dump(assignment), 200