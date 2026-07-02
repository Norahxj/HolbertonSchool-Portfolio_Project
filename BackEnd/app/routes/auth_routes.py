from flask_restx import Namespace, Resource
from app.api_models.auth_api import get_auth_models
from app.services.auth_service import AuthService
from marshmallow import ValidationError
from app.schemas import RegisterSchema, LoginSchema, ChildLoginSchema
from flask_jwt_extended import jwt_required, get_jwt, get_jwt_identity

api = Namespace("auth", description="Authentication operations")
register_schema = RegisterSchema()
login_schema = LoginSchema()
child_login_schema = ChildLoginSchema()
auth_service = AuthService()
register_model, login_model, child_login_model, refresh_response_model, message_response_model = get_auth_models(api)

@api.route("/register")
class RegisterResource(Resource):
    @api.expect(register_model, validate=True)
    @api.response(201, "User registered successfully")
    @api.response(400, "Invalid input")
    @api.response(409, "Email already registered")
    def post(self):
        try:
            data = register_schema.load(api.payload)
        except ValidationError as err:
            return {"errors": err.messages}, 400
        result, error = auth_service.register(data)
        if error:
            status_code = 409 if error == "Email already registered" else 400
            return {"error": error}, status_code
        return result, 201

@api.route("/login")
class LoginResource(Resource):
    @api.expect(login_model, validate=True)
    @api.response(200, "User logged in successfully")
    @api.response(400, "Invalid input")
    @api.response(401, "Invalid email or password")
    def post(self):
        try:
            data = login_schema.load(api.payload)
        except ValidationError as err:
            return {"errors": err.messages}, 400
        result, error = auth_service.login(data["email"], data["password"])
        if error:
            return {"error": error}, 401
        return result, 200
    
@api.route("/child-login")
class ChildLoginResource(Resource):
    @api.expect(child_login_model, validate=True)
    @api.response(200, "Child logged in successfully")
    @api.response(400, "Invalid input")
    @api.response(401, "Invalid access code")
    def post(self):
        try:
            data = child_login_schema.load(api.payload)
        except ValidationError as err:
            return {"errors": err.messages}, 400
        result, error = auth_service.child_login(data["access_code"])
        if error:
            return {"error": error}, 401
        return result, 200
    
@api.route("/refresh")
class RefreshResource(Resource):
    @api.response(200, "Access token refreshed successfully")
    @api.response(401, "Invalid or expired refresh token")
    @api.response(403, "Invalid role")
    @api.doc(security="JWT")
    @jwt_required(refresh=True)
    @api.marshal_with(refresh_response_model, code=200)
    def post(self):
        identity = get_jwt_identity()
        role = get_jwt().get("role")
        token, error, status_code = auth_service.refresh_access_token(identity, role)
        if error:
            return {"error": error}, status_code
        return {"access_token": token}, 200

@api.route("/logout")
class Logout(Resource):
    @api.response(200, "Logged out successfully")
    @api.response(401, "Missing or invalid token")
    @api.doc(security="JWT")
    @jwt_required()
    @api.marshal_with(message_response_model, code=200)
    def post(self):
        jti = get_jwt()["jti"]
        success, error = auth_service.logout(jti)
        if not success:
            return {"error": error}, 500
        return {"message": "Logged out successfully"}, 200
    
@api.route("/logout-refresh")
class LogoutRefresh(Resource):
    @api.response(200, "Refresh token logged out successfully")
    @api.response(401, "Missing or invalid refresh token")
    @api.doc(security="JWT")
    @jwt_required(refresh=True)
    @api.marshal_with(message_response_model, code=200)
    def post(self):
        jti = get_jwt()["jti"]
        success, error = auth_service.logout(jti)
        if not success:
            return {"error": error}, 500
        return {"message": "Refresh token logged out successfully"}, 200