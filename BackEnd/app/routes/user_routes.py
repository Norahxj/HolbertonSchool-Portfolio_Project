from flask_restx import Namespace, Resource
from flask_jwt_extended import jwt_required, get_jwt_identity, get_jwt
from marshmallow import ValidationError
from app.api_models.user_api import get_user_models
from app.services.user_service import UserService
from app.schemas import UserResponseSchema, UserUpdateSchema

api = Namespace("users", description="User operations")
user_service = UserService()
user_response_schema = UserResponseSchema()
user_update_schema = UserUpdateSchema()
user_response_model, user_update_model = get_user_models(api)

@api.route("/me")
class CurrentUserResource(Resource):
    @api.doc(security="JWT")
    @jwt_required()
    @api.response(200, "User retrieved successfully", user_response_model)
    @api.response(401, "Missing or invalid access token")
    @api.response(403, "Parent access only")
    @api.response(404, "User not found")
    def get(self):
        claims = get_jwt()
        user_id = get_jwt_identity()
        if claims.get("role") != "parent":
            return {"error": "Parent access only"}, 403
        user = user_service.get_user(user_id)
        if not user:
            return {"error": "User not found"}, 404
        return user_response_schema.dump(user), 200

    @api.doc(security="JWT")
    @jwt_required()
    @api.expect(user_update_model)
    @api.response(200, "User updated successfully", user_response_model)
    @api.response(400, "Invalid input")
    @api.response(401, "Missing or invalid access token")
    @api.response(403, "Parent access only")
    @api.response(404, "User not found")
    @api.response(409, "Email or phone already exists")
    @api.response(500, "Failed to update user")
    def put(self):
        claims = get_jwt()
        user_id = get_jwt_identity()
        if claims.get("role") != "parent":
            return {"error": "Parent access only"}, 403
        try:
            user_data = user_update_schema.load(api.payload)
        except ValidationError as err:
            return {"errors": err.messages}, 400
        user, error = user_service.update_user(user_id, user_data)
        if error == "email_exists":
            return {"error": "Email already registered"}, 409
        if error == "phone_exists":
            return {"error": "Phone number already used"}, 409
        if error == "not_found":
            return {"error": "User not found"}, 404
        if error == "integrity_error":
            return {"error": "Email or phone already exists"}, 409
        if error:
            return {"error": "Failed to update user"}, 500
        return user_response_schema.dump(user), 200

    @api.doc(security="JWT")
    @jwt_required()
    @api.response(200, "User deleted successfully")
    @api.response(401, "Missing or invalid access token")
    @api.response(403, "Parent access only")
    @api.response(404, "User not found")
    @api.response(500, "Failed to delete user")
    def delete(self):
        claims = get_jwt()
        user_id = get_jwt_identity()
        if claims.get("role") != "parent":
            return {"error": "Parent access only"}, 403
        _, delete_error = user_service.delete_user(user_id)
        if delete_error == "user_not_found":
            return {"error": "User not found"}, 404
        if delete_error == "delete_error":
            return {"error": "Failed to delete user and related data"}, 500
        return {"message": "User deleted successfully"}, 200