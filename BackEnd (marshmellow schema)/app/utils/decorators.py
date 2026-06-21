from functools import wraps
from flask import jsonify
from flask_jwt_extended import verify_jwt_in_request, get_jwt_identity
from app.exceptions.api_exceptions import UnauthorizedError, ForbiddenError
from app.models.user_model import User

# Decorator to ensure a JWT is present in the request, fetch the user from the database.
# nsure the authenticated user is a child
def jwt_required_custom(fn):
    @wraps(fn)
    def wrapper(*args, **kwargs):
        try:
            verify_jwt_in_request()
        except Exception as e:
            raise UnauthorizedError(str(e))
        return fn(*args, **kwargs)
    return wrapper

def parent_required(fn):
    @wraps(fn)
    @jwt_required_custom
    def wrapper(*args, **kwargs):
        current_user_id = get_jwt_identity()
        user = User.query.get(current_user_id)

        if not user or not user.is_parent:
            raise ForbiddenError("Parent access required")
        return fn(*args, **kwargs)
    return wrapper

def child_required(fn):
    @wraps(fn)
    @jwt_required_custom
    def wrapper(*args, **kwargs):
        current_user_id = get_jwt_identity()
        user = User.query.get(current_user_id)
      
    
        if not user or user.is_parent:
    
            raise ForbiddenError("Child access required")
        return fn(*args, **kwargs)
    return wrapper
