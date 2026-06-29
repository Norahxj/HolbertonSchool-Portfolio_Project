from flask_restx import fields


def get_wishlist_models(api):

    # Create Wishlist Model
    wishlist_create_model = api.model("WishlistCreate", {
        "child_id": fields.String(required=True, description="Child ID"),
        "name": fields.String(required=True, description="Wish name"),
        "target_points": fields.Integer(required=False, description="Target points for the wish")
    })

    # Update Wishlist Model
    wishlist_update_model = api.model("WishlistUpdate", {
        "name": fields.String(description="Wish name"),
        "target_points": fields.Integer(description="Target points for the wish")
    })

    # Approve Wishlist Model
    wishlist_approve_model = api.model("WishlistApprove", {
        "wish_id": fields.String(required=True, description="Wish ID to approve")
    })

    # Reject Wishlist Model
    wishlist_reject_model = api.model("WishlistReject", {
        "wish_id": fields.String(required=True, description="Wish ID to reject")
    })

    # Set Goal Model
    wishlist_goal_model = api.model("WishlistGoal", {
        "child_id": fields.String(required=True, description="Child ID"),
        "goal_points": fields.Integer(required=True, description="Wishlist goal points")
    })

    # Progress Model
    wishlist_progress_model = api.model("WishlistProgress", {
        "current_points": fields.Integer(required=True, description="Child's current points")
    })

    return (
        wishlist_create_model,
        wishlist_update_model,
        wishlist_approve_model,
        wishlist_reject_model,
        wishlist_goal_model,
        wishlist_progress_model
    )
