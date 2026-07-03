from flask_restx import fields


def get_points_history_models(api):
    points_history_response_model = api.model("PointsHistoryResponse", {
        "id": fields.String(description="History ID"),
        "child_id": fields.String(description="Child ID"),
        "points": fields.Integer(description="Points added or deducted"),
        "action": fields.String(description="Action"),
        "source_id": fields.String(description="Related task or reward ID"),
        "created_at": fields.DateTime(description="Created at")
    })

    return points_history_response_model