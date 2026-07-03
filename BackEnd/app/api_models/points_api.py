from flask_restx import fields


def get_point_models(api):
    points_response_model = api.model("PointsResponse", {
        "child_id": fields.String(description="Child ID"),
        "total_points": fields.Integer(description="Total child points")
    })

    return points_response_model