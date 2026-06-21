from flask import Blueprint, request, jsonify
from flask_jwt_extended import create_access_token, jwt_required, get_jwt_identity
from app.services.user_service import UserService
from app.schemas.user_schema import UserSchema
from app.exceptions.api_exceptions import ValidationError, NotFoundError, ConflictError, UnauthorizedError
from app.extensions import bcrypt

auth_bp = Blueprint('auth', __name__, url_prefix='/auth')

user_schema = UserSchema()

@auth_bp.route('/register', methods=['POST'])
def register_user():
    """Register a new user (parent)."""
    try:
        data = request.get_json()
        if not data:
            raise ValidationError("No input data provided.")

        # Ensure is_parent is True for registration via this route
        data['is_parent'] = True
        new_user = UserService.create_user(data)
        return jsonify(new_user), 201
    except ValidationError as e:
        return jsonify({"message": e.message, "errors": e.errors}), 400
    except ConflictError as e:
        return jsonify({"message": e.message}), 409
    except Exception as e:
        return jsonify({"message": str(e)}), 500

@auth_bp.route('/login', methods=['POST'])
def login_user():
    """Log in an existing user and return an access token."""
    try:
        data = request.get_json()
        if not data:
            raise ValidationError("No input data provided.")

        email = data.get('email')
        password = data.get('password')

        if not email or not password:
            raise ValidationError("Email and password are required.")

        user_data = UserService.get_user_by_email(email) # get_user_by_email 
        if not user_data:
            raise UnauthorizedError("Invalid credentials.")

        # Verify password
        if not bcrypt.check_password_hash(user_data['password'], password):
            raise UnauthorizedError("Invalid credentials.")

        access_token = create_access_token(identity=user_data['id'])
        return jsonify(access_token=access_token), 200
    except ValidationError as e:
        return jsonify({"message": e.message, "errors": e.errors}), 400
    except UnauthorizedError as e:
        return jsonify({"message": e.message}), 401
    except NotFoundError as e:
        return jsonify({"message": e.message}), 401 # Treat user not found as unauthorized for security
    except Exception as e:
        return jsonify({"message": str(e)}), 500

@auth_bp.route('/protected', methods=['GET'])
@jwt_required()
def protected():
    """A protected route to test JWT authentication."""
    current_user_id = get_jwt_identity()
    return jsonify(logged_in_as=current_user_id), 200
