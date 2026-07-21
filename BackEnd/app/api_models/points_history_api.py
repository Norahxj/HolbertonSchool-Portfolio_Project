from flask_restx import fields

def get_points_history_models(api):
    task_details_model = api.model("PointsHistoryTaskDetails", {
        "id": fields.String(description="Task ID"),
        "title": fields.String(description="Task title"),
        "description": fields.String(description="Task description"),
        "points": fields.Integer(description="Task points"),
        "category": fields.String(description="Task category")
    })
    task_assignment_model = api.model("PointsHistoryTaskAssignment", {
        "id": fields.String(description="Task assignment ID"),
        "status": fields.String(description="Assignment status"),
        "assigned_date": fields.Date(description="Assigned date"),
        "completed_at": fields.DateTime(description="Completed at"),
        "approved_at": fields.DateTime(description="Approved at"),
        "task": fields.Nested(task_details_model)
    })
    wishlist_model = api.model("PointsHistoryWishlist", {
        "id": fields.String(description="Wishlist ID"),
        "name": fields.String(description="Wish name"),
        "target_points": fields.Integer(description="Target points"),
        "status": fields.String(description="Wish status"),
        "approved_at": fields.DateTime(description="Approved at")
    })
    points_history_response_model = api.model("PointsHistoryResponse", {
        "id": fields.String(description="History ID"),
        "child_id": fields.String(description="Child ID"),
        "points": fields.Integer(description="Points added or deducted"),
        "action": fields.String(description="History action"),
        "task_assignment_id": fields.String(description="Task assignment ID"),
        "wishlist_id": fields.String(description="Wishlist ID"),
        "task_assignment": fields.Nested(task_assignment_model),
        "wishlist": fields.Nested(wishlist_model),
        "created_at": fields.DateTime(description="Created at")
    })
    
    return points_history_response_model