from app.extensions import db, bcrypt
from app.models.user_model import User
from app.exceptions.api_exceptions import NotFoundError, ValidationError, ConflictError
from app.schemas.user_schema import UserSchema
from uuid import uuid4

# Initialize Marshmallow schemas
user_schema = UserSchema()
users_schema = UserSchema(many=True)

class UserService:
    @staticmethod
    def create_user(data):
        errors = user_schema.validate(data)
        if errors:
            raise ValidationError("Validation failed for user creation", errors)
          
        if User.query.filter_by(email=data["email"]).first():
            raise ConflictError("User with this email already exists.")

        # Hash the password before store it
        hashed_password = bcrypt.generate_password_hash(data["password"]).decode("utf-8")

        # Create a new User instance
        user = User(id=str(uuid4()),
                    email=data["email"],
                    password=hashed_password,
                    full_name=data["full_name"],
                    is_parent=data.get("is_parent", True))
        db.session.add(user)
        db.session.commit()
        return user_schema.dump(user)

    @staticmethod
    def get_all_users():
        users = User.query.all()
        return users_schema.dump(users)

    @staticmethod
    def get_user_by_id(user_id):
        user = User.query.get(user_id)
        if not user:
            raise NotFoundError(f"User with ID {user_id} not found.")
        return user_schema.dump(user)

    @staticmethod
    def get_user_by_email(email):
        # Retrieve a user by their email
        user = User.query.filter_by(email=email).first()
        if not user:
            raise NotFoundError(f"User with email {email} not found.")
        return user_schema.dump(user)

    @staticmethod
    def update_user(user_id, data):
        user = User.query.get(user_id)
        if not user:
            raise NotFoundError(f"User with ID {user_id} not found.")

        errors = user_schema.validate(data, partial=True)
        if errors:
            raise ValidationError("Validation failed for user update", errors)


        for key, value in data.items():
            if key == "password": # Hash new password
                setattr(user, key, bcrypt.generate_password_hash(value).decode("utf-8"))
            else:
                setattr(user, key, value)
        db.session.commit()
        return user_schema.dump(user)

    @staticmethod
    def delete_user(user_id):
        # Retrieve the user
        user = User.query.get(user_id)
        if not user: # If user not found,
            raise NotFoundError(f"User with ID {user_id} not found.")

        db.session.delete(user) # Delete the user from the database session
        db.session.commit()
        return {"message": "User deleted successfully"}

