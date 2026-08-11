from flask_jwt_extended import (
    get_jwt,
    get_jwt_identity,
    jwt_required,
)
from flask_restx import Namespace, Resource

from app.services.weekly_plan_service import WeeklyPlanService


api = Namespace(
    "weekly-plan",
    description="AI weekly plan operations",
)


def require_parent():
    claims = get_jwt()

    if claims.get("role") != "parent":
        return {
            "error": "Parent access required"
        }, 403

    return None


@api.route("/children/<child_id>")
class WeeklyPlanResource(Resource):

    @jwt_required()
    @api.doc(security="JWT")
    @api.response(
        200,
        "Weekly plan generated successfully",
    )
    @api.response(
        401,
        "Missing or invalid access token",
    )
    @api.response(
        403,
        "Parent access required",
    )
    @api.response(
        404,
        "Child not found",
    )
    @api.response(
        422,
        "Unable to generate a suitable weekly plan",
    )
    @api.response(
        503,
        "AI service temporarily unavailable",
    )
    @api.response(
        500,
        "Failed to generate weekly plan",
    )
    def post(self, child_id):
        parent_id = get_jwt_identity()

        error = require_parent()

        if error:
            return error

        weekly_plan_service = WeeklyPlanService()

        result, service_error = (
            weekly_plan_service
            .generate_weekly_plan(
                child_id=child_id,
                guardian_id=parent_id,
                max_revisions=3,
            )
        )

        if service_error == "child_not_found":
            return {
                "error": "Child not found"
            }, 404

        if service_error == "child_context_not_found":
            return {
                "error": "Child context not found"
            }, 404

        if service_error == "ai_rate_limit":
            return {
                "error": (
                    "AI service usage limit has been reached. "
                    "Please try again later."
                )
            }, 503

        if service_error == "ai_service_unavailable":
            return {
                "error": (
                    "AI service is temporarily unavailable. "
                    "Please try again later."
                )
            }, 503

        if service_error == "evaluation_missing":
            return {
                "error": (
                    "Weekly plan evaluation "
                    "was not generated"
                )
            }, 500

        if service_error == "plan_missing":
            return {
                "error": (
                    "Weekly plan was not generated"
                )
            }, 500

        if service_error == "proposal_create_failed":
            return {
                "error": (
                    "Weekly plan was generated, "
                    "but could not be saved"
                )
            }, 500

        if service_error:
            return {
                "error": (
                    "Failed to generate weekly plan"
                )
            }, 500

        if not result["approved"]:
            return {
                "error": (
                    "Unable to generate a suitable "
                    "weekly plan at this time"
                ),
                "revision_count": result.get(
                    "revision_count",
                    0,
                ),
            }, 422

        plan = result["plan"]

        return {
            "message": (
                "Weekly plan generated successfully"
            ),
            "proposal_id": result["proposal_id"],
            "proposal_status": result[
                "proposal_status"
            ],
            "child_id": child_id,
            "plan": plan.model_dump(
                mode="json"
            ),
            "revision_count": result.get(
                "revision_count",
                0,
            ),
        }, 200


@api.route("/<proposal_id>/approve")
class WeeklyPlanApprovalResource(Resource):

    @jwt_required()
    @api.doc(security="JWT")
    @api.response(
        200,
        "Weekly plan approved successfully",
    )
    @api.response(
        400,
        "Invalid request",
    )
    @api.response(
        401,
        "Missing or invalid access token",
    )
    @api.response(
        403,
        "Parent access required",
    )
    @api.response(
        404,
        "Weekly plan proposal not found",
    )
    @api.response(
        409,
        "Weekly plan already approved",
    )
    @api.response(
        500,
        "Failed to approve weekly plan",
    )
    def post(self, proposal_id):
        parent_id = get_jwt_identity()

        error = require_parent()

        if error:
            return error

        payload = api.payload or {}

        language = payload.get(
            "language",
            "ar",
        )

        if language not in {
            "ar",
            "en",
        }:
            return {
                "error": (
                    "Language must be either "
                    "'ar' or 'en'"
                )
            }, 400

        weekly_plan_service = WeeklyPlanService()

        result, service_error = (
            weekly_plan_service
            .approve_weekly_plan(
                proposal_id=proposal_id,
                guardian_id=parent_id,
                language=language,
            )
        )

        if service_error == "proposal_not_found":
            return {
                "error": (
                    "Weekly plan proposal not found"
                )
            }, 404

        if service_error == "proposal_already_approved":
            return {
                "error": (
                    "Weekly plan has already been approved"
                )
            }, 409

        if service_error == "proposal_not_pending":
            return {
                "error": (
                    "Weekly plan is no longer pending"
                )
            }, 409

        if service_error == "child_not_found":
            return {
                "error": "Child not found"
            }, 404

        if service_error == "tasks_required":
            return {
                "error": (
                    "Weekly plan does not contain tasks"
                )
            }, 400

        if service_error == "invalid_plan_data":
            return {
                "error": (
                    "Weekly plan data is invalid"
                )
            }, 400

        if service_error == "invalid_language":
            return {
                "error": (
                    "Invalid task language"
                )
            }, 400

        if service_error == "invalid_frequency":
            return {
                "error": (
                    "Weekly plan contains an invalid "
                    "task frequency"
                )
            }, 400

        if service_error == "invalid_task_data":
            return {
                "error": (
                    "Weekly plan contains invalid "
                    "task data"
                )
            }, 400

        if service_error in {
            "create_failed",
            "task_child_failed",
            "assignment_failed",
            "proposal_update_failed",
            "approval_failed",
        }:
            return {
                "error": (
                    "Failed to approve weekly plan"
                )
            }, 500

        if service_error:
            return {
                "error": (
                    "Failed to approve weekly plan"
                )
            }, 500

        return {
            "message": (
                "Weekly plan approved successfully"
            ),
            "proposal_id": result[
                "proposal_id"
            ],
            "proposal_status": result[
                "proposal_status"
            ],
            "child_id": result[
                "child_id"
            ],
            "created_tasks_count": result[
                "created_tasks_count"
            ],
            "created_task_ids": result[
                "created_task_ids"
            ],
        }, 200