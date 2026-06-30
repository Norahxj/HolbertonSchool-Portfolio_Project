from flask_restx import Namespace, Resource
from flask_jwt_extended import jwt_required, get_jwt_identity, get_jwt
from marshmallow import ValidationError

from app.services.wishlist_service import WishlistService
from app.schemas.wishlist_schema import (
    WishlistResponseSchema,
    WishlistCreateSchema,
    WishlistUpdateSchema,
    WishlistApproveSchema,
    WishlistRejectSchema,
    WishlistProgressSchema
)
from app.api_models.wishlist_api import get_wishlist_models


api = Namespace("wishlist", description="Wishlist operations")

wishlist_service = WishlistService()

wishlist_response_schema = WishlistResponseSchema()
wishlist_list_response_schema = WishlistResponseSchema(many=True)

wishlist_create_schema = WishlistCreateSchema()
wishlist_update_schema = WishlistUpdateSchema()
wishlist_approve_schema = WishlistApproveSchema()
wishlist_reject_schema = WishlistRejectSchema()
wishlist_progress_schema = WishlistProgressSchema()

(
    wishlist_create_model,
    wishlist_update_model,
    wishlist_approve_model,
    wishlist_reject_model,
    wishlist_progress_model
) = get_wishlist_models(api)


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

    @api.doc(security="JWT")
    @jwt_required()
    def get(self):
        error = require_child()
        if error:
            return error

        child_id = get_jwt_identity()
        wishes, status = wishlist_service.get_child_wishlist(child_id)
        return wishlist_list_response_schema.dump(wishes), status


@api.route("/add")
class WishlistCreateResource(Resource):

    @api.doc(security="JWT")
    @jwt_required()
    @api.expect(wishlist_create_model, validate=True)
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
            child_id=child_id,
            name=data["name"],
            target_points=data.get("target_points", 0)
        )

        return wishlist_response_schema.dump(wish), status


@api.route("/<wish_id>")
class WishlistResource(Resource):

    @api.doc(security="JWT")
    @jwt_required()
    @api.expect(wishlist_update_model, validate=True)
    def put(self, wish_id): ##
        error = require_parent()
        if error:
            return error

        try:
            data = wishlist_update_schema.load(api.payload)
        except ValidationError as err:
            return {"errors": err.messages}, 400

        wish, status = wishlist_service.update_wish(wish_id, data)
        if not wish:
            return {"error": "Wish not found"}, 404

        return wishlist_response_schema.dump(wish), status

    @api.doc(security="JWT")
    @jwt_required()
    def delete(self, wish_id):
        error = require_child()
        if error:
            return error

        deleted, status = wishlist_service.delete_wish(wish_id)
        if not deleted:
            return {"error": "Wish not found"}, 404

        return {"message": "Wish deleted successfully"}, status


@api.route("/approve")
class WishlistApproveResource(Resource):

    @api.doc(security="JWT")
    @jwt_required()
    @api.expect(wishlist_approve_model, validate=True)
    def put(self):
        error = require_parent()
        if error:
            return error

        try:
            data = wishlist_approve_schema.load(api.payload)
        except ValidationError as err:
            return {"errors": err.messages}, 400

        wish, status = wishlist_service.approve_wish(data["wish_id"])
        return wishlist_response_schema.dump(wish), status


@api.route("/reject")
class WishlistRejectResource(Resource):

    @api.doc(security="JWT")
    @jwt_required()
    @api.expect(wishlist_reject_model, validate=True)
    def put(self):
        error = require_parent()
        if error:
            return error

        try:
            data = wishlist_reject_schema.load(api.payload)
        except ValidationError as err:
            return {"errors": err.messages}, 400

        wish, status = wishlist_service.reject_wish(data["wish_id"])
        return wishlist_response_schema.dump(wish), status



@api.route("/progress")
class WishlistProgressResource(Resource):

    @api.doc(security="JWT")
    @jwt_required()
    @api.expect(wishlist_progress_model, validate=True)
    def post(self):
        error = require_child()
        if error:
            return error

        child_id = get_jwt_identity()

        try:
            data = wishlist_progress_schema.load(api.payload)
        except ValidationError as err:
            return {"errors": err.messages}, 400

        result, status = wishlist_service.get_progress(
            child_id=child_id,
            current_points=data["current_points"]
        )

        return result, status
