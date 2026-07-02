from flask_jwt_extended import create_access_token, create_refresh_token
from app.extensions import bcrypt
from app.models.user_model import User
from app.schemas.user_schema import UserResponseSchema
from app.schemas.child_schema import ChildResponseSchema
from app.repositories.auth_repository import AuthRepository
from app.repositories.user_repository import UserRepository
from app.repositories.child_repository import ChildRepository

child_response_schema = ChildResponseSchema()
user_response_schema = UserResponseSchema()
class AuthService:
    def __init__(self):
        self.auth_repository = AuthRepository()
        self.user_repository = UserRepository()
        self.child_repository = ChildRepository()

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
    
    def _create_access_token(self, identity, role):
        return create_access_token(
            identity=str(identity), additional_claims={"role": role}
        )
    
    def refresh_access_token(self, identity, role):
        if role == "parent":
            user = self.user_repository.get_user_by_id(identity)
            if not user:
                return None, "User not found", 404
            return self._create_access_token(user.id, user.role), None, 200
        if role == "child":
            child = self.child_repository.get_child_by_id(identity)
            if not child:
                return None, "Child not found", 404
            return self._create_access_token(child.id, "child"), None, 200
        return None, "Invalid role", 403

    def register(self, user_data):
        full_name = user_data["full_name"].strip()
        email = user_data["email"].strip().lower()
        password = user_data["password"]
        guardian_type = user_data["guardian_type"]
        existing_user = self.user_repository.get_user_by_email(email)
        if existing_user:
            return None, "Email already registered"
        user = User(
            full_name=full_name,
            email=email,
            password_hash=bcrypt.generate_password_hash(password).decode("utf-8"),
            role="parent",
            guardian_type=guardian_type
        )
        user, error = self.user_repository.create_user(user)
        if error == "integrity_error":
            return None, "Email already registered"
        access_token, refresh_token = self._create_tokens(user.id, user.role)
        return {
            "access_token": access_token,
            "refresh_token": refresh_token,
            "user": user_response_schema.dump(user)
        }, None
    
    def login(self, email, password):
        email = email.strip().lower()
        user = self.user_repository.get_user_by_email(email)
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
        child = self.child_repository.get_child_by_access_code(access_code)
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
    
    def logout(self, jti):
        self.auth_repository.revoke_token(jti)
        return True