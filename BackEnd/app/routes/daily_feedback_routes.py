from flask_restx import Namespace, Resource
from flask_jwt_extended import jwt_required, get_jwt_identity, get_jwt
from marshmallow import ValidationError

from app.api_models.dailyfeedback_api import get_daily_feedback_models
from app.services.dailyfeedback_service import DailyFeedbackService
from app.schemas import (
    DailyFeedbackCreateSchema,
    DailyFeedbackResponseSchema
)


api = Namespace("daily-feedback", description="Daily feedback operations")

daily_feedback_service = DailyFeedbackService()

daily_feedback_create_schema = DailyFeedbackCreateSchema()
daily_feedback_response_schema = DailyFeedbackResponseSchema()

daily_feedback_create_model = get_daily_feedback_models(api)


@api.route("/")
class DailyFeedbackResource(Resource):

    @api.doc(security="JWT")
    @jwt_required()
    @api.expect(daily_feedback_create_model, validate=True)
    def post(self):
        claims = get_jwt()
        parent_id = get_jwt_identity()

        if claims.get("role") != "parent":
            return {"error": "Parent access only"}, 403

        try:
            feedback_data = daily_feedback_create_schema.load(api.payload)
        except ValidationError as err:
            return {"errors": err.messages}, 400

        feedback, error = daily_feedback_service.create_feedback(
            parent_id,
            feedback_data
        )

        if error == "task_not_found":
            return {"error": "Task not found"}, 404

        if error == "task_not_approved":
            return {"error": "Task must be approved first"}, 400

        if error == "feedback_already_exists":
            return {"error": "Feedback already exists for this task"}, 409

        return daily_feedback_response_schema.dump(feedback), 201