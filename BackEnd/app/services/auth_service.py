from flask_jwt_extended import create_access_token, create_refresh_token
from app.extensions import bcrypt
from app.models.user_model import User
from app.schemas.user_schema import UserResponseSchema
from app.schemas.child_schema import ChildResponseSchema
from app.repositories.auth_repository import AuthRepository

child_response_schema = ChildResponseSchema()
user_response_schema = UserResponseSchema()

class AuthService:
    def __init__(self):
        self.auth_repository = AuthRepository()

    def _create_tokens(self, identity, role):
        access_token = create_access_token(
            identity=str(identity),
            additional_claims={"role": role}
        )

        refresh_token = create_refresh_token(
            identity=str(identity),
            additional_claims={"role": role}
        )
        return access_token, refresh_token
    
    def create_access_token_only(self, identity, role):
        return create_access_token(
            identity=str(identity), additional_claims={"role": role}
        )
    
    def refresh_access_token(self, identity, role):
        if role == "parent":
            user = self.auth_repository.get_user_by_id(identity)
            if not user:
                return None, "User not found", 404
            return self.create_access_token_only(user.id, user.role), None, 200
        if role == "child":
            child = self.auth_repository.get_child_by_id(identity)
            if not child:
                return None, "Child not found", 404
            return self.create_access_token_only(child.id, "child"), None, 200
        return None, "Invalid role", 403

    def register(self, user_data):
        full_name = user_data["full_name"].strip()
        email = user_data["email"].strip().lower()
        password = user_data["password"]
        existing_user = self.auth_repository.get_user_by_email(email)
        if existing_user:
            return None, "Email already registered"
        user = User(
            full_name=full_name,
            email=email,
            password_hash=bcrypt.generate_password_hash(password).decode("utf-8"),
            role="parent"
        )
        user, error = self.auth_repository.create_user(user)
        if error:
            return None, error
        access_token, refresh_token = self._create_tokens(user.id, user.role)
        return {
            "access_token": access_token,
            "refresh_token": refresh_token,
            "user": user_response_schema.dump(user)
        }, None
    
    def login(self, email, password):
        email = email.strip().lower()
        user = self.auth_repository.get_user_by_email(email)
        if not user:
            return None, "Invalid email or password"
        if not bcrypt.check_password_hash(user.password_hash, password):
            return None, "Invalid email or password"
        access_token, refresh_token = self._create_tokens(user.id, user.role)
        return {
            "access_token": access_token,
            "refresh_token": refresh_token,
            "user": user_response_schema.dump(user)
        }, None
    

    def child_login(self, access_code):
        child = self.auth_repository.get_child_by_access_code(access_code)
        if not child:
            return None, "Invalid access code"
        access_token, refresh_token = self._create_tokens(child.id, "child")
        child_data = child_response_schema.dump(child)
        child_data["role"] = "child"
        return {
            "access_token": access_token,
            "refresh_token": refresh_token,
            "child": child_data
        }, None
    
    def get_current_account(self, identity, role):
        if role == "parent":
            user = self.auth_repository.get_user_by_id(identity)
            if not user:
                return None, "User not found", 404
            return user_response_schema.dump(user), None, 200
        if role == "child":
            child = self.auth_repository.get_child_by_id(identity)
            if not child:
                return None, "Child not found", 404
            child_data = child_response_schema.dump(child)
            child_data["role"] = "child"
            return child_data, None, 200

        return None, "Invalid role", 403
    
    def logout(self, jti):
        self.auth_repository.revoke_token(jti)
        return True