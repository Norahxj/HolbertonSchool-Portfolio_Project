from flask_restx import fields


def get_dashboard_models(api):
    child_dashboard_response_model = api.model(
        "ChildDashboardResponse",
        {
            "child_id": fields.String(
                description="Child ID"
            ),
            "child_name": fields.String(
                description="Child name"
            ),
            "child_age": fields.Integer(
                description="Child age"
            ),
            "week_start": fields.Date(
                description="Start date of the current week"
            ),
            "week_end": fields.Date(
                description="End date of the current week"
            ),
            "progress_percentage": fields.Float(
                description=(
                    "Percentage calculated using approved tasks only"
                )
            ),
            "completed_tasks": fields.Integer(
                description="Number of approved tasks"
            ),
            "approved_tasks": fields.Integer(
                description="Number of approved tasks"
            ),
            "pending_review_tasks": fields.Integer(
                description="Tasks waiting for parent review"
            ),
            "pending_tasks": fields.Integer(
                description="Tasks not completed by the child"
            ),
            "rejected_tasks": fields.Integer(
                description="Rejected tasks"
            ),
            "remaining_tasks": fields.Integer(
                description="All tasks that are not approved"
            ),
            "total_tasks": fields.Integer(
                description="Total tasks assigned during the current week"
            )
        }
    )

    return child_dashboard_response_model