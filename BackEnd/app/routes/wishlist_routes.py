from flask_restx import Namespace, Resource
from flask_jwt_extended import jwt_required, get_jwt, get_jwt_identity
from marshmallow import ValidationError
from app.services.wishlist_service import WishlistService
from app.schemas import WishlistResponseSchema, WishlistCreateSchema, WishlistApproveSchema
from app.api_models.wishlist_api import get_wishlist_models


api = Namespace("wishlist", description="Wishlist operations")

wishlist_service = WishlistService()

wishlist_create_schema = WishlistCreateSchema()
wishlist_approve_schema = WishlistApproveSchema()
wishlist_response_schema = WishlistResponseSchema()
wishlists_response_schema = WishlistResponseSchema(many=True)

wishlist_create_model, wishlist_approve_model, wishlist_response_model = get_wishlist_models(api)


@api.route("/")
class WishlistListResource(Resource):

    @api.doc(security="JWT")
    @jwt_required()
    @api.expect(wishlist_create_model, validate=True)
    def post(self):
        claims = get_jwt()

        if claims.get("role") != "child":
            return {"error": "Child access required"}, 403

        try:
            wish_data = wishlist_create_schema.load(api.payload)
        except ValidationError as err:
            return {"errors": err.messages}, 400

        child_id = get_jwt_identity()

        wish, error = wishlist_service.create_wish(child_id, wish_data)

        if error == "wishlist_limit_reached":
            return {"error": "Wishlist limit reached. Maximum 5 pending wishes allowed."}, 400

        if error == "create_failed":
            return {"error": "Failed to create wish"}, 500

        return wishlist_response_schema.dump(wish), 201


@api.route("/my")
class MyWishlistResource(Resource):

    @api.doc(security="JWT")
    @jwt_required()
    def get(self):
        claims = get_jwt()

        if claims.get("role") != "child":
            return {"error": "Child access required"}, 403

        child_id = get_jwt_identity()

        wishes, error = wishlist_service.get_my_wishes(child_id)

        return wishlists_response_schema.dump(wishes), 200


@api.route("/child/<child_id>")
class ChildWishlistResource(Resource):

    @api.doc(security="JWT")
    @jwt_required()
    def get(self, child_id):
        claims = get_jwt()

        if claims.get("role") != "parent":
            return {"error": "Parent access required"}, 403

        parent_id = get_jwt_identity()

        wishes, error = wishlist_service.get_child_wishes(child_id, parent_id)

        if error == "child_not_found":
            return {"error": "Child not found"}, 404

        return wishlists_response_schema.dump(wishes), 200


@api.route("/<wish_id>/approve")
class ApproveWishResource(Resource):

    @api.doc(security="JWT")
    @jwt_required()
    @api.expect(wishlist_approve_model, validate=True)
    def put(self, wish_id):
        claims = get_jwt()

        if claims.get("role") != "parent":
            return {"error": "Parent access required"}, 403

        try:
            data = wishlist_approve_schema.load(api.payload)
        except ValidationError as err:
            return {"errors": err.messages}, 400

        parent_id = get_jwt_identity()

        wish, error = wishlist_service.approve_wish(
            wish_id,
            parent_id,
            data["target_points"]
        )

        if error == "wish_not_found":
            return {"error": "Wish not found"}, 404

        if error == "child_not_found":
            return {"error": "Child not found"}, 404

        if error == "approved_limit_reached":
            return {"error": "Approved wishlist limit reached. Maximum 3 approved wishes allowed."}, 400

        if error == "update_failed":
            return {"error": "Failed to approve wish"}, 500
        if error == "wish_already_reviewed":
            return {"error": "Wish has already been reviewed"}, 400

        return wishlist_response_schema.dump(wish), 200


@api.route("/<wish_id>/reject")
class RejectWishResource(Resource):

    @api.doc(security="JWT")
    @jwt_required()
    def put(self, wish_id):
        claims = get_jwt()

        if claims.get("role") != "parent":
            return {"error": "Parent access required"}, 403

        parent_id = get_jwt_identity()

        wish, error = wishlist_service.reject_wish(wish_id, parent_id)

        if error == "wish_not_found":
            return {"error": "Wish not found"}, 404

        if error == "child_not_found":
            return {"error": "Child not found"}, 404

        if error == "update_failed":
            return {"error": "Failed to reject wish"}, 500
        if error == "wish_already_reviewed":
            return {"error": "Wish has already been reviewed"}, 400

        return wishlist_response_schema.dump(wish), 200


@api.route("/<wish_id>/achieve")
class AchieveWishResource(Resource):

    @api.doc(security="JWT")
    @jwt_required()
    def put(self, wish_id):
        claims = get_jwt()

        if claims.get("role") != "child":
            return {"error": "Child access required"}, 403

        child_id = get_jwt_identity()

        wish, error = wishlist_service.achieve_wish(wish_id, child_id)

        if error == "wish_not_found":
            return {"error": "Wish not found"}, 404

        if error == "wish_already_achieved":
            return {
                "error": "This wish has already been achieved"
            }, 400
        
        if error == "invalid_target_points":
            return {
                "error": "Wish target points are invalid"
            }, 400

        if error == "wish_not_approved":
            return {"error": "Wish is not approved"}, 400

        if error == "not_enough_points":
            return {"error": "Not enough points to achieve this wish"}, 400

        if error == "achieve_failed":
            return {"error": "Failed to achieve wish"}, 500

        return wishlist_response_schema.dump(wish), 200


@api.route("/<wish_id>")
class WishlistResource(Resource):

    @api.doc(security="JWT")
    @jwt_required()
    def delete(self, wish_id):
        claims = get_jwt()

        if claims.get("role") != "child":
            return {"error": "Child access required"}, 403

        child_id = get_jwt_identity()

        deleted, delete_error  = wishlist_service.delete_wish(wish_id, child_id)

        if delete_error == "wish_not_found":
            return {"error": "Wish not found"}, 404

        if delete_error == "wish_cannot_be_deleted":
            return {"error": (
                    "Only pending or rejected wishes "
                    "can be deleted"
                )
            }, 400

        if delete_error == "delete_error":
            return {"error": "Failed to delete wish"}, 500

        return {
            "message": "Wish deleted successfully"
        }, 200