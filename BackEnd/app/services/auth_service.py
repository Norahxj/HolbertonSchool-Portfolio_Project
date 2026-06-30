from flask_jwt_extended import create_access_token, create_refresh_token
from app.extensions import db, bcrypt
from app.models.user_model import User
from sqlalchemy.exc import IntegrityError
from app.schemas.user_schema import UserResponseSchema
from app.models.child_model import Child

user_response_schema = UserResponseSchema()

class AuthService:

    def register(self, user_data):
        full_name = user_data["full_name"].strip()
        email = user_data["email"].strip().lower()
        password = user_data["password"]
        existing_user = User.query.filter_by(email=email).first()
        if existing_user:
            return None, "Email already registered"
        user = User(
            full_name=full_name,
            email=email,
            password_hash=bcrypt.generate_password_hash(password).decode("utf-8"),
            role="parent"
        )

        try:
            db.session.add(user)
            db.session.commit()

        except IntegrityError:
            db.session.rollback()
            return None, "Email already registered"
        return user, None

    def login(self, email, password):
        email = email.strip().lower()
        user = User.query.filter_by(email=email).first()

        if not user:
            return None, "Invalid email or password"
        
        if not bcrypt.check_password_hash(user.password_hash, password):
            return None, "Invalid email or password"

        access_token = create_access_token(
            identity=str(user.id),
            additional_claims={"role": user.role}
        )

        refresh_token = create_refresh_token(
            identity=str(user.id),
            additional_claims={"role": user.role}
        )

        return {
            "access_token": access_token,
            "refresh_token": refresh_token,
            "user": user_response_schema.dump(user)
        }, None
    

    def child_login(self, access_code):
        child = Child.query.filter_by(access_code=access_code).first()

        if not child:
            return None, "Invalid access code"

        access_token = create_access_token(
            identity=str(child.id),
            additional_claims={"role": "child"}
        )

        refresh_token = create_refresh_token(
            identity=str(child.id),
            additional_claims={"role": "child"}
        )

        return {
            "access_token": access_token,
            "refresh_token": refresh_token,
            "child": {
                "id": child.id,
                "name": child.name,
                "age": child.age,
                "role": "child"
            }
        }, None