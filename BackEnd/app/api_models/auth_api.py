from flask_restx import fields

def get_auth_models(api):
    register_model = api.model("Register", {
        "first_name": fields.String(required=True, description="First name"),
        "last_name": fields.String(required=True, description="Last name"),
        "phone": fields.String(required=True, description="Phone number"),
        "email": fields.String(required=True, description="Email"),
        "password": fields.String(required=True, description="Password"),
        "guardian_type": fields.String(required=True, enum=["father", "mother", "guardian"], description="Guardian type")
    })

    login_model = api.model("Login", {
        "email": fields.String(required=True, description="Email"),
        "password": fields.String(required=True, description="Password")
    })

    child_login_model = api.model("ChildLogin", {
        "access_code": fields.String(required=True, description="6-digit child access code")
    })

    refresh_response_model = api.model("RefreshResponse", {
        "access_token": fields.String(description="New JWT access token")
    })

    message_response_model = api.model("MessageResponse", {
        "message": fields.String(description="Response message")
    })

    return (register_model, login_model, child_login_model, refresh_response_model, message_response_model)