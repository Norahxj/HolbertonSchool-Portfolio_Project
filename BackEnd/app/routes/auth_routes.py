from flask_restx import Namespace, Resource
from app.extensions import db
from app.api_models.auth_api import get_auth_models
from app.services.auth_service import AuthService
from app.models.user_model import User
from marshmallow import ValidationError
from app.schemas import RegisterSchema, LoginSchema, ChildLoginSchema, UserResponseSchema
from flask_jwt_extended import jwt_required, get_jwt,  get_jwt_identity, create_access_token
from app.models.revoked_token_model import RevokedToken
from app.models.child_model import Child
from app.extensions import bcrypt
from flask_jwt_extended import create_refresh_token


api = Namespace("auth", description="Authentication operations")
register_schema = RegisterSchema()
login_schema = LoginSchema()
user_response_schema = UserResponseSchema()
auth_service = AuthService()
register_model, login_model, token_model, user_response_model, child_token_model = get_auth_models(api)

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

        user, error = auth_service.register(data)

        if error:
            status_code = 409 if error == "Email already registered" else 400
            return {"error": error}, status_code

        return user_response_schema.dump(user), 201


@api.route("/login")
class LoginResource(Resource):

    @api.expect(login_model, validate=True)
    @api.marshal_with(token_model, code=200)
    @api.response(401, "Invalid email or password")
    def post(self):
        try:
            data = login_schema.load(api.payload)
        except ValidationError as err:
            return {"errors": err.messages}, 400

        result, error = auth_service.login(
            data["email"],
            data["password"]
        )

        if error:
            return {"error": error}, 401

        return result, 200
    
@api.route("/child-login")
class ChildLoginResource(Resource):

    @api.expect(login_model, validate=True)
    @api.marshal_with(child_token_model, code=200)
    def post(self):
        schema = ChildLoginSchema()

        try:
            data = schema.load(api.payload)
        except ValidationError as err:
            return {"errors": err.messages}, 400

        email = data["email"].strip().lower()
        password = data["password"]

        child = Child.query.filter_by(email=email).first()

        if not child:
            return {"error": "Invalid email or password"}, 401

        if not bcrypt.check_password_hash(child.password_hash, password):
            return {"error": "Invalid email or password"}, 401

        access_token = create_access_token(
            identity=str(child.id),
            additional_claims={
                "role": "child",
                "parent_id": child.parent_id
            }
        )

        refresh_token = create_refresh_token(
            identity=str(child.id),
            additional_claims={
                "role": "child",
                "parent_id": child.parent_id
            }
        )

        return {
            "access_token": access_token,
            "refresh_token": refresh_token,
            "child": {
                "id": child.id,
                "name": child.name,
                "email": child.email,
                "parent_id": child.parent_id,
                "role": "child"
            }
        }, 200
    

@api.route("/refresh")
class RefreshResource(Resource):

    @api.doc(security="JWT")
    @jwt_required(refresh=True)
    def post(self):
        claims = get_jwt()

        if claims.get("role") != "parent":
            return {"error": "Parent refresh only"}, 403

        user_id = get_jwt_identity()

        user = db.session.get(User, user_id)

        if not user:
            return {"error": "User not found"}, 404

        new_access_token = create_access_token(
            identity=str(user.id),
            additional_claims={
                "role": user.role
            }
        )

        return {
            "access_token": new_access_token
        }, 200


@api.route("/me")
class MeResource(Resource):

    @jwt_required()
    @api.doc(security="JWT")
    @api.response(200, "Current user retrieved successfully")
    @api.response(401, "Missing or invalid token")
    @api.response(404, "User not found")
    def get(self):
        user_id = get_jwt_identity()
        user = db.session.get(User, user_id)

        if not user:
            return {"error": "User not found"}, 404

        return user_response_schema.dump(user), 200
    


@api.route("/logout")
class Logout(Resource):
    @api.doc(security="JWT")
    @jwt_required()
    def post(self):
        jti = get_jwt()["jti"]

        existing_token = RevokedToken.query.filter_by(jti=jti).first()

        if not existing_token:
            revoked_token = RevokedToken(jti=jti)
            db.session.add(revoked_token)
            db.session.commit()

        return {
            "message": "Logged out successfully"
        }, 200
    

@api.route("/logout-refresh")
class LogoutRefresh(Resource):
    @api.doc(security="JWT")
    @jwt_required(refresh=True)
    def post(self):
        jti = get_jwt()["jti"]

        existing_token = RevokedToken.query.filter_by(jti=jti).first()

        if not existing_token:
            revoked_token = RevokedToken(jti=jti)
            db.session.add(revoked_token)
            db.session.commit()

        return {
            "message": "Refresh token logged out successfully"
        }, 200