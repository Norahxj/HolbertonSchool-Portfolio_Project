from flask_restx import Namespace, Resource
from App.api_models.user_model import get_user_models
from App.Services.user_service import UserService


api = Namespace("users", description="User operations")
user_service = UserService()
user_model, user_update_model = get_user_models(api)


@api.route("/")
class UserListResource(Resource):

    @api.expect(user_model, validate=True)
    @api.response(201, "User created successfully")
    @api.response(400, "Email already registered")
    def post(self):
        user_data = api.payload
        existing_user = user_service.get_user_by_email(user_data["email"])
        if existing_user:
            return {"error": "Email already registered"}, 400
        user = user_service.create_user(user_data)
        return {
            "id": user.id,
            "full_name": user.full_name,
            "email": user.email,
            "role": user.role,
            "is_active": user.is_active
        }, 201


    @api.response(200, "Users retrieved successfully")
    def get(self):
        users = user_service.get_all_users()
        return [
            {
                "id": user.id,
                "full_name": user.full_name,
                "email": user.email,
                "role": user.role,
                "is_active": user.is_active
            }
            for user in users
        ], 200


@api.route("/<user_id>")
class UserResource(Resource):

    @api.response(200, "User retrieved successfully")
    @api.response(404, "User not found")
    def get(self, user_id):
        user = user_service.get_user(user_id)
        if not user:
            return {"error": "User not found"}, 404
        return {
            "id": user.id,
            "full_name": user.full_name,
            "email": user.email,
            "role": user.role,
            "is_active": user.is_active
        }, 200
    
    @api.expect(user_update_model, validate=True)
    @api.response(200, "User updated successfully")
    @api.response(400, "Email already registered")
    @api.response(404, "User not found")
    def put(self, user_id):
        user_data = api.payload
        user = user_service.update_user(user_id, user_data)

        if user == "email_exists":
            return {"error": "Email already registered"}, 400

        if not user:
            return {"error": "User not found"}, 404

        return {
            "id": user.id,
            "full_name": user.full_name,
            "email": user.email,
            "role": user.role,
            "is_active": user.is_active
        }, 200
    
    @api.response(200, "User deactivated successfully")
    @api.response(404, "User not found")
    def delete(self, user_id):
        user = user_service.deactivate_user(user_id)

        if not user:
            return {"error": "User not found"}, 404

        return {
            "message": "User deactivated successfully",
            "id": user.id,
            "is_active": user.is_active
        }, 200
    
    

@api.route("/<user_id>/children")
class UserChildrenResource(Resource):

    @api.response(200, "User children retrieved successfully")
    @api.response(404, "User not found")
    def get(self, user_id):
        user = user_service.get_user(user_id)

        if not user:
            return {"error": "User not found"}, 404

        return [
            {
                "id": child.id,
                "name": child.name,
                "age": child.age,
                "parent_id": child.parent_id
            }
            for child in user.children
        ], 200
