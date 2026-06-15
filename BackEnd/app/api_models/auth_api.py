from flask_restx import fields


def get_auth_models(api):
    register_model = api.model("Register", {
        "full_name": fields.String(required=True, description="Full name"),
        "email": fields.String(required=True, description="Email"),
        "password": fields.String(required=True, description="Password")
    })

    login_model = api.model("Login", {
        "email": fields.String(required=True, description="Email"),
        "password": fields.String(required=True, description="Password")
    })

    user_response_model = api.model("UserResponse", {
        "id": fields.String(description="User ID"),
        "full_name": fields.String(description="Full name"),
        "email": fields.String(description="Email"),
        "role": fields.String(description="User role"),
        "is_active": fields.Boolean(description="User status")
    })

    token_model = api.model("TokenResponse", {
        "access_token": fields.String(description="JWT access token"),
        "user": fields.Nested(user_response_model)
    })

    return register_model, login_model, token_model, user_response_model