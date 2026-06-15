from flask_restx import Namespace, Resource
from flask_jwt_extended import jwt_required, get_jwt_identity
from app.services.child_service import ChildService
from app.api_models.child_api import get_child_models


api = Namespace("children", description="Child operations")

child_service = ChildService()

child_model, child_update_model = get_child_models(api)


@api.route("/")
class ChildListResource(Resource):

    @jwt_required()
    @api.doc(security="JWT")
    @api.expect(child_model, validate=True)
    @api.response(201, "Child created successfully")
    @api.response(400, "Invalid input")
    def post(self):
        parent_id = get_jwt_identity()
        child_data = api.payload
        child_data["parent_id"] = parent_id

        child, error = child_service.create_child(child_data)

        if error:
            return {"error": error}, 400

        return {
            "id": child.id,
            "name": child.name,
            "age": child.age,
            "parent_id": child.parent_id
        }, 201


    @jwt_required()
    @api.doc(security="JWT")
    @api.response(200, "Children retrieved successfully")
    def get(self):
        parent_id = get_jwt_identity()
        children = child_service.get_children_by_parent(parent_id)

        return [
            {
                "id": child.id,
                "name": child.name,
                "age": child.age,
                "parent_id": child.parent_id
            }
            for child in children
        ], 200


@api.route("/<child_id>")
class ChildResource(Resource):

    @jwt_required()
    @api.doc(security="JWT")
    @api.response(200, "Child retrieved successfully")
    @api.response(404, "Child not found")
    def get(self, child_id):
        parent_id = get_jwt_identity()
        child = child_service.get_child_for_parent(child_id, parent_id)

        if not child:
            return {"error": "Child not found"}, 404

        return {
            "id": child.id,
            "name": child.name,
            "age": child.age,
            "parent_id": child.parent_id
        }, 200

    @jwt_required()
    @api.doc(security="JWT")
    @api.expect(child_update_model, validate=True)
    @api.response(200, "Child updated successfully")
    @api.response(404, "Child not found")
    def put(self, child_id):
        parent_id = get_jwt_identity()
        child_data = api.payload

        child, error = child_service.update_child_for_parent(child_id, parent_id, child_data)

        if error:
            return {"error": error}, 400

        if not child:
            return {"error": "Child not found"}, 404

        return {
            "id": child.id,
            "name": child.name,
            "age": child.age,
            "parent_id": child.parent_id
        }, 200

    @jwt_required()
    @api.doc(security="JWT")
    @api.response(204, "Child deleted successfully")
    @api.response(404, "Child not found")
    def delete(self, child_id):
        parent_id = get_jwt_identity()

        child = child_service.delete_child_for_parent(child_id, parent_id)

        if not child:
            return {"error": "Child not found"}, 404

        return "", 204