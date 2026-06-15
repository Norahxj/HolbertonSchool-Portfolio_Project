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

    return child_model, child_update_model