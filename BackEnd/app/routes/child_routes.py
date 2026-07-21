from flask_restx import Namespace, Resource
from flask_jwt_extended import jwt_required, get_jwt_identity,  get_jwt
from marshmallow import ValidationError
from app.services.child_service import ChildService
from app.api_models.child_api import get_child_models
from app.schemas import ChildResponseSchema, ChildCreateSchema, ChildUpdateSchema, ChildWithAccessCodeSchema

api = Namespace("children", description="Child operations")
child_service = ChildService()
child_response_schema = ChildResponseSchema()
children_response_schema = ChildWithAccessCodeSchema(many=True)
child_create_schema = ChildCreateSchema()
child_update_schema = ChildUpdateSchema()
child_with_access_code_schema = ChildWithAccessCodeSchema()
child_model, child_update_model, child_response_model, child_with_access_code_model = get_child_models(api)

def require_parent():
    claims = get_jwt()
    if claims.get("role") != "parent":
        return {"error": "Parent access required"}, 403
    return None

@api.route("/")
class ChildListResource(Resource):
    @jwt_required()
    @api.doc(security="JWT")
    @api.expect(child_model)
    @api.response(201, "Child created successfully", child_with_access_code_model)
    @api.response(400, "Invalid input")
    @api.response(401, "Missing or invalid access token")
    @api.response(403, "Parent access required")
    @api.response(404, "Parent not found")
    @api.response(409, "Phone number already used")
    @api.response(500, "Failed to create child")
    def post(self):
        parent_id = get_jwt_identity()
        error = require_parent()
        if error:
            return error
        try:
            child_data = child_create_schema.load(api.payload)
        except ValidationError as err:
            return {"errors": err.messages}, 400
        child, error = child_service.create_child(parent_id, child_data)
        if error == "parent_not_found":
            return {"error": "Parent not found"}, 404
        if error == "family_not_found":
            return {"error": "Parent is not assigned to a family"}, 400
        if error == "phone_exists":
            return {"error": "Phone number already used"}, 409
        if error == "access_code_exists":
            return {"error": "Failed to generate child access code"}, 500
        if error == "integrity_error":
            return {"error": "Could not create child due to invalid related data"}, 500
        if error:
            return {"error": "Could not create child"}, 500
        return child_with_access_code_schema.dump(child), 201

    @jwt_required()
    @api.doc(security="JWT")
    @api.response(200, "Children retrieved successfully")
    @api.response(401, "Missing or invalid access token")
    @api.response(403, "Parent access required")
    def get(self):
        parent_id = get_jwt_identity()
        error = require_parent()
        if error:
            return error
        children = child_service.get_children_by_parent(parent_id)
        return children_response_schema.dump(children), 200

@api.route("/<child_id>")
class ChildResource(Resource):
    @jwt_required()
    @api.doc(security="JWT")
    @api.response(200, "Child retrieved successfully", child_with_access_code_model)
    @api.response(403, "Parent access required")
    @api.response(404, "Child not found")
    def get(self, child_id):
        parent_id = get_jwt_identity()
        error = require_parent()
        if error:
            return error
        child = child_service.get_child_for_parent(child_id, parent_id)
        if not child:
            return {"error": "Child not found"}, 404
        return child_with_access_code_schema.dump(child), 200

    @jwt_required()
    @api.doc(security="JWT")
    @api.expect(child_update_model)
    @api.response(200, "Child updated successfully", child_with_access_code_model)
    @api.response(400, "Invalid input")
    @api.response(401, "Missing or invalid access token")
    @api.response(403, "Parent access required")
    @api.response(404, "Child not found")
    @api.response(409, "Phone number already used")
    @api.response(500, "Failed to update child")
    def put(self, child_id):
        parent_id = get_jwt_identity()
        error = require_parent()
        if error:
            return error
        try:
            child_data = child_update_schema.load(api.payload)
        except ValidationError as err:
            return {"errors": err.messages}, 400
        child, error = child_service.update_child_for_parent(child_id, parent_id, child_data)
        if error == "not_found":
            return {"error": "Child not found"}, 404
        if error == "phone_exists":
            return {"error": "Phone number already used"}, 409
        if error:
            return {"error": "Failed to update child"}, 500
        return child_with_access_code_schema.dump(child), 200

    @jwt_required()
    @api.doc(security="JWT")
    @api.response(200, "Child deleted successfully")
    @api.response(401, "Missing or invalid access token")
    @api.response(403, "Parent access required")
    @api.response(404, "Parent or child not found")
    @api.response(500, "Failed to delete child")
    def delete(self, child_id):
        parent_id = get_jwt_identity()
        error = require_parent()
        if error:
            return error
        _, delete_error  = child_service.delete_child_for_parent(child_id, parent_id)
        if delete_error == "parent_not_found":
            return {"error": "Parent not found"}, 404
        if delete_error == "child_not_found":
            return {"error": "Child not found"}, 404
        if delete_error == "delete_error":
            return {"error": "Failed to delete child and related data"}, 500
        return {"message": "Child and related data deleted successfully"}, 200
