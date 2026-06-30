from flask_restx import Namespace, Resource
from flask_jwt_extended import jwt_required, get_jwt_identity, get_jwt
from marshmallow import ValidationError

from app.services.wishlist_service import WishlistService
from app.schemas.wishlist_schema import (
    WishlistCreateSchema,
    WishlistApproveSchema,
    WishlistResponseSchema
)

api = Namespace("wishlist", description="Wishlist operations")

wishlist_service = WishlistService()

wishlist_response_schema = WishlistResponseSchema()
wishlist_list_response_schema = WishlistResponseSchema(many=True)

wishlist_create_schema = WishlistCreateSchema()
wishlist_approve_schema = WishlistApproveSchema()


def require_parent():
    claims = get_jwt()
    if claims.get("role") != "parent":
        return {"error": "Parent access required"}, 403
    return None


def require_child():
    claims = get_jwt()
    if claims.get("role") != "child":
        return {"error": "Child access required"}, 403
    return None


@api.route("/")
class WishlistListResource(Resource):

    @jwt_required()
    def get(self):
        error = require_child()
        if error:
            return error

        child_id = get_jwt_identity()

        wishes, status = wishlist_service.get_child_wishlist(child_id)

        return wishlist_list_response_schema.dump(wishes), 200


@api.route("/add")
class WishlistCreateResource(Resource):

    @jwt_required()
    def post(self):
        error = require_child()
        if error:
            return error

        child_id = get_jwt_identity()

        try:
            data = wishlist_create_schema.load(api.payload)
        except ValidationError as err:
            return {"errors": err.messages}, 400

        wish, status = wishlist_service.add_wish(
            child_id,
            data["name"]
        )

        if not wish:
            return {"error": status}, 400

        return wishlist_response_schema.dump(wish), 201


@api.route("/<string:wish_id>/approve")
class WishlistApproveResource(Resource):

    @jwt_required()
    def put(self, wish_id):
        error = require_parent()
        if error:
            return error

        parent_id = get_jwt_identity()

        try:
            data = wishlist_approve_schema.load(api.payload)
        except ValidationError as err:
            return {"errors": err.messages}, 400

        wish, status = wishlist_service.approve_wish(
            parent_id,
            wish_id,
            data["target_points"]
        )

        if not wish:
            return {"error": status}, 400

        return wishlist_response_schema.dump(wish), 200


@api.route("/<string:wish_id>/reject")
class WishlistRejectResource(Resource):

    @jwt_required()
    def delete(self, wish_id):
        error = require_parent()
        if error:
            return error

        parent_id = get_jwt_identity()

        wish, status = wishlist_service.reject_wish(
            parent_id,
            wish_id
        )

        if not wish:
            return {"error": status}, 404

        return wishlist_response_schema.dump(wish), 200

@api.route("/status")
class WishlistStatusResource(Resource):

    @jwt_required()
    def get(self):
        error = require_child()
        if error:
            return error

        child_id = get_jwt_identity()

        result, status = wishlist_service.get_wishlist_status(child_id)

        return result, 200