from flask_restx import fields


def get_wishlist_models(api):

    wishlist_create_model = api.model("WishlistCreate", {
        "name": fields.String(required=True, description="Wish name")
    })

    wishlist_update_model = api.model("WishlistUpdate", {
        "name": fields.String(description="Wish name"),
        "target_points": fields.Integer(description="Target points for the wish")
    })

    wishlist_approve_model = api.model("WishlistApprove", {
        "target_points": fields.Integer(required=True, description="Target points assigned by parent")
    })

    wishlist_reject_model = api.model("WishlistReject", {})

    wishlist_progress_model = api.model("WishlistProgress", {})

    return (
        wishlist_create_model,
        wishlist_update_model,
        wishlist_approve_model,
        wishlist_reject_model,
        wishlist_progress_model
    )