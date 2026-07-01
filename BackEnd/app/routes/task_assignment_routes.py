from flask_restx import Namespace, Resource
from flask_jwt_extended import jwt_required, get_jwt_identity, get_jwt
from app.api_models.task_assignment_api import get_task_assignment_models
from app.services.task_assignment_service import TaskAssignmentService
from app.schemas import TaskAssignmentResponseSchema

api = Namespace("task-assignments", description="Task assignment operations")
assignment_service = TaskAssignmentService()
assignment_response_schema = TaskAssignmentResponseSchema()
assignments_response_schema = TaskAssignmentResponseSchema(many=True)
assignment_response_model = get_task_assignment_models(api)

@api.route("/task/<task_id>")
class AssignmentsByTaskResource(Resource):
    @api.doc(security="JWT")
    @jwt_required()
    @api.marshal_list_with(assignment_response_model, code=200)
    def get(self, task_id):
        claims = get_jwt()
        if claims.get("role") != "parent":
            return {"error": "Parent access required"}, 403
        parent_id = get_jwt_identity()
        assignments = assignment_service.get_assignments_for_task(task_id, parent_id)
        if assignments is None:
            return {"error": "Task not found"}, 404
        return assignments_response_schema.dump(assignments), 200

@api.route("/my")
class MyAssignmentsResource(Resource):
    @api.doc(security="JWT")
    @jwt_required()
    @api.marshal_list_with(assignment_response_model, code=200)
    def get(self):
        claims = get_jwt()
        if claims.get("role") != "child":
            return {"error": "Child access required"}, 403
        child_id = get_jwt_identity()
        assignments = assignment_service.get_assignments_for_child(child_id)
        return assignments_response_schema.dump(assignments), 200

@api.route("/<assignment_id>/complete")
class CompleteAssignmentResource(Resource):
    @api.doc(security="JWT")
    @jwt_required()
    @api.marshal_with(assignment_response_model, code=200)
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
        return assignment_response_schema.dump(assignment), 200

@api.route("/<assignment_id>/approve")
class ApproveAssignmentResource(Resource):
    @api.doc(security="JWT")
    @jwt_required()
    @api.marshal_with(assignment_response_model, code=200)
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
        return assignment_response_schema.dump(assignment), 200

@api.route("/<assignment_id>/reject")
class RejectAssignmentResource(Resource):
    @api.doc(security="JWT")
    @jwt_required()
    @api.marshal_with(assignment_response_model, code=200)
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
        return assignment_response_schema.dump(assignment), 200