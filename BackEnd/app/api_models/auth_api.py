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

    child_login_model = api.model("ChildLogin", {
        "access_code": fields.String(required=True, description="6-digit child access code")
    })

    user_response_model = api.model("UserResponse", {
        "id": fields.String(description="User ID"),
        "full_name": fields.String(description="Full name"),
        "email": fields.String(description="Email"),
        "role": fields.String(description="User role")
    })

    token_model = api.model("TokenResponse", {
        "access_token": fields.String(description="JWT access token"),
        "refresh_token": fields.String,
        "user": fields.Nested(user_response_model)
    })

    child_response_model = api.model("ChildAuthResponse", {
        "id": fields.String(description="Child ID"),
        "name": fields.String(description="Child name"),
        "age": fields.Integer(description="Child age"),
        "role": fields.String(description="Role")
    })

    child_token_model = api.model("ChildTokenResponse", {
        "access_token": fields.String(description="JWT access token"),
        "refresh_token": fields.String(description="JWT refresh token"),
        "child": fields.Nested(child_response_model)
    })

    return (register_model, login_model, child_login_model, token_model, user_response_model, child_token_model)