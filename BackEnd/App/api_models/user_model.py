from flask_restx import fields

def get_user_models(api):

    user_model = api.model("User", {
        "full_name": fields.String(required=True, description="Full name of the user"),
        "email": fields.String(required=True, description="User email"),
        "password": fields.String(required=True, description="User password")
    })

    user_update_model = api.model("UserUpdate", {
        "full_name": fields.String(description="Full name of the user"),
        "email": fields.String(description="User email"),
        "is_active": fields.Boolean(description="User account status")
    })
    
    return user_model, user_update_model