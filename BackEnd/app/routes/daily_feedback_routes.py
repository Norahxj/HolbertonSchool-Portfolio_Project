from flask_restx import Namespace, Resource
from flask_jwt_extended import jwt_required, get_jwt, get_jwt_identity
from marshmallow import ValidationError
from app.services.daily_feedback_service import DailyFeedbackService
from app.schemas import DailyFeedbackCreateSchema, DailyFeedbackUpdateSchema, DailyFeedbackResponseSchema
from app.api_models.daily_feedback_api import get_daily_feedback_models

api = Namespace("daily-feedback", description="Daily feedback operations")
daily_feedback_service = DailyFeedbackService()
daily_feedback_create_schema = DailyFeedbackCreateSchema()
daily_feedback_response_schema = DailyFeedbackResponseSchema()
daily_feedback_update_schema = DailyFeedbackUpdateSchema()
daily_feedback_list_schema = DailyFeedbackResponseSchema(many=True)
daily_feedback_create_model, daily_feedback_update_model, daily_feedback_response_model = get_daily_feedback_models(api)

@api.route("/")
class DailyFeedbackListResource(Resource):
    @api.response(201, "Feedback created successfully", daily_feedback_response_model)
    @api.response(400, "Invalid input or feedback already exists today")
    @api.response(403, "Parent access required")
    @api.response(404, "Child not found")
    @api.response(500, "Failed to create feedback")
    @api.doc(security="JWT")
    @jwt_required()
    @api.expect(daily_feedback_create_model, validate=True)
    def post(self):
        claims = get_jwt()
        if claims.get("role") != "parent":
            return {"error": "Parent access required"}, 403
        try:
            feedback_data = daily_feedback_create_schema.load(api.payload)
        except ValidationError as err:
            return {"errors": err.messages}, 400
        parent_id = get_jwt_identity()
        feedback, error = daily_feedback_service.create_feedback(parent_id, feedback_data)
        if error == "child_not_found":
            return {"error": "Child not found"}, 404
        if error == "feedback_already_exists_today":
            return {"error": "You already created feedback for this child today"}, 400
        if error:
            return {"error": "Failed to create feedback"}, 500
        return daily_feedback_response_schema.dump(feedback), 201

@api.route("/child/<child_id>")
class ChildDailyFeedbackResource(Resource):
    @api.response(200, "Feedback retrieved successfully")
    @api.response(403, "Parent access required")
    @api.response(404, "Child not found")
    @api.response(500, "Failed to retrieve feedback")
    @api.doc(security="JWT")
    @jwt_required()
    def get(self, child_id):
        claims = get_jwt()
        if claims.get("role") != "parent":
            return {"error": "Parent access required"}, 403
        parent_id = get_jwt_identity()
        feedback, error = daily_feedback_service.get_feedback_for_child_as_parent(child_id, parent_id)
        if error == "child_not_found":
            return {"error": "Child not found"}, 404
        if error:
            return {"error": "Failed to retrieve feedback"}, 500
        return daily_feedback_list_schema.dump(feedback), 200

@api.route("/my")
class MyDailyFeedbackResource(Resource):
    @api.response(200, "Feedback retrieved successfully")
    @api.response(403, "Child access required")
    @api.response(500, "Failed to retrieve feedback")
    @api.doc(security="JWT")
    @jwt_required()
    def get(self):
        claims = get_jwt()
        if claims.get("role") != "child":
            return {"error": "Child access required"}, 403
        child_id = get_jwt_identity()
        feedback, error = daily_feedback_service.get_my_feedback(child_id)
        if error:
            return {"error": "Failed to retrieve feedback"}, 500
        return daily_feedback_list_schema.dump(feedback), 200
    
@api.route("/<feedback_id>")
class DailyFeedbackResource(Resource):
    @api.response(200, "Feedback updated successfully", daily_feedback_response_model)
    @api.response(400, "Invalid input")
    @api.response(403, "Parent access required")
    @api.response(404, "Feedback not found")
    @api.response(500, "Failed to update feedback")
    @api.doc(security="JWT")
    @jwt_required()
    @api.expect(daily_feedback_update_model, validate=True)
    def put(self, feedback_id):
        claims = get_jwt()
        if claims.get("role") != "parent":
            return {"error": "Parent access required"}, 403
        try:
            feedback_data = daily_feedback_update_schema.load(api.payload)
        except ValidationError as err:
            return {"errors": err.messages}, 400
        parent_id = get_jwt_identity()
        feedback, error = (
            daily_feedback_service.update_feedback(feedback_id, parent_id, feedback_data)
        )
        if error == "feedback_not_found":
            return {"error": "Feedback not found"}, 404
        if error == "no_data_provided":
            return {"error": "No fields provided for update"}, 400
        if error:
            return {"error": "Failed to update feedback"}, 500
        return daily_feedback_response_schema.dump(feedback), 200