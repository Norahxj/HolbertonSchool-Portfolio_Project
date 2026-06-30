from flask_restx import fields

def get_child_models(api):
    child_model = api.model("Child", {
        "name": fields.String(required=True, description="Child name"),
        "age": fields.Integer(required=True, description="Child age")
    })

    child_update_model = api.model("ChildUpdate", {
        "name": fields.String(required=False, description="Child name"),
        "age": fields.Integer(required=False, description="Child age")
    })

    child_response_model = api.model("ChildResponse", {
        "id": fields.String(description="Child ID"),
        "name": fields.String(description="Child name"),
        "age": fields.Integer(description="Child age"),
        "role": fields.String(description="Role")
    })

    child_with_access_code_model = api.model("ChildWithAccessCodeResponse", {
        "id": fields.String(description="Child ID"),
        "name": fields.String(description="Child name"),
        "age": fields.Integer(description="Child age"),
        "access_code": fields.String(description="6-digit access code"),
        "role": fields.String(description="Role")
    })

    return child_model, child_update_model, child_response_model, child_with_access_code_model