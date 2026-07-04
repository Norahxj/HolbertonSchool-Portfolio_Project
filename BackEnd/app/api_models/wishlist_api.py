from flask_restx import fields


def get_wishlist_models(api):
    wishlist_create_model = api.model("WishlistCreate", {
        "name": fields.String(required=True, description="Wish name")
    })

    wishlist_approve_model = api.model("WishlistApprove", {
        "target_points": fields.Integer(required=True, description="Target points required to achieve the wish")
    })

    wishlist_response_model = api.model("WishlistResponse", {
        "id": fields.String(),
        "child_id": fields.String(),
        "name": fields.String(),
        "target_points": fields.Integer(),
        "status": fields.String(),
        "reviewed_by": fields.String(),
        "approved_at": fields.DateTime(),
        "created_at": fields.DateTime()
    })

    return wishlist_create_model, wishlist_approve_model, wishlist_response_model