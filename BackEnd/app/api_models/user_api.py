from flask_restx import fields


def get_user_models(api):
    user_response_model = api.model("UserResponse", {
        "id": fields.String(description="User ID"),
        "full_name": fields.String(description="Full name"),
        "email": fields.String(description="Email"),
        "role": fields.String(description="User role"),
        "guardian_type": fields.String(description="Guardian type")
    })

    user_update_model = api.model("UserUpdate", {
        "full_name": fields.String(description="Full name"),
        "email": fields.String(description="Email")
    })

    return user_response_model, user_update_model