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
    @api.expect(user_update_model, validate=True)
    def put(self):
        claims = get_jwt()
        user_id = get_jwt_identity()
        if claims.get("role") != "parent":
            return {"error": "Parent access only"}, 403

        try:
            user_data = user_update_schema.load(api.payload)
            if not user_data:
                return {"error": "No fields provided for update"}, 400
        except ValidationError as err:
            return {"errors": err.messages}, 400

        user, error = user_service.update_user(user_id, user_data)

        if error == "email_exists":
            return {"error": "Email already registered"}, 409

        if error == "not_found":
            return {"error": "User not found"}, 404

        return user_response_schema.dump(user), 200


    @api.doc(security="JWT")
    @jwt_required()
    def delete(self):
        claims = get_jwt()
        user_id = get_jwt_identity()
        if claims.get("role") != "parent":
            return {"error": "Parent access only"}, 403

        deleted = user_service.delete_user(user_id)

        if not deleted:
            return {"error": "User not found"}, 404

        return {"message": "User deleted successfully"}, 200