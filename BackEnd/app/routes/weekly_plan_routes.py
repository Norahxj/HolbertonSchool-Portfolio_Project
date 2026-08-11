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

weekly_plan_service = WeeklyPlanService()


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
        500,
        "Failed to generate weekly plan",
    )
    def post(self, child_id):
        parent_id = get_jwt_identity()

        error = require_parent()

        if error:
            return error

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
            "child_id": child_id,
            "plan": plan.model_dump(),
            "revision_count": result.get(
                "revision_count",
                0,
            ),
        }, 200