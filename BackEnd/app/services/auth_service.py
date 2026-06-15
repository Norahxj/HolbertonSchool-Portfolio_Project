from flask_jwt_extended import create_access_token
from app.extensions import db, bcrypt
from app.models.user_model import User
from sqlalchemy.exc import IntegrityError
import re


class AuthService:

    def validate_register_data(self, full_name, email, password):
        full_name = full_name.strip()
        email = email.strip().lower()

        if len(full_name) < 2:
            return None, None, None, "Name must be at least 2 characters"

        if len(full_name) > 100:
            return None, None, None, "Name must not exceed 100 characters"

        email_regex = r"^[^@]+@[^@]+\.[^@]+$"
        if not re.match(email_regex, email):
            return None, None, None, "Invalid email format"

        if len(password) < 8:
            return None, None, None, "Password must be at least 8 characters"

        if not any(char.isupper() for char in password):
            return None, None, None, "Password must contain at least one uppercase letter"

        if not any(char.islower() for char in password):
            return None, None, None, "Password must contain at least one lowercase letter"

        if not any(char.isdigit() for char in password):
            return None, None, None, "Password must contain at least one number"

        return full_name, email, password, None

    def register(self, user_data):
        full_name, email, password, error = self.validate_register_data(
            user_data["full_name"],
            user_data["email"],
            user_data["password"]
        )

        if error:
            return None, error

        existing_user = User.query.filter_by(email=email).first()

        if existing_user:
            return None, "Email already registered"

        user = User(
            full_name=full_name,
            email=email,
            password_hash=bcrypt.generate_password_hash(password).decode("utf-8"),
            role="parent",
            is_active=True
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

        if not user.is_active:
            return None, "User account is inactive"

        if not bcrypt.check_password_hash(user.password_hash, password):
            return None, "Invalid email or password"

        access_token = create_access_token(identity=user.id)

        return {
            "access_token": access_token,
            "user": {
                "id": user.id,
                "full_name": user.full_name,
                "email": user.email,
                "role": user.role,
                "is_active": user.is_active
            }
        }, None
