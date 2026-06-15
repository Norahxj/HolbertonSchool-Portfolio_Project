from flask_restx import Namespace, Resource

from App.Services.child_service import ChildService
from App.api_models.child_model import get_child_models


api = Namespace("children", description="Child operations")

child_service = ChildService()

child_model, child_update_model = get_child_models(api)


@api.route("/")
class ChildListResource(Resource):

    @api.expect(child_model, validate=True)
    @api.response(201, "Child created successfully")
    @api.response(400, "Invalid input")
    def post(self):

        child_data = api.payload
        child = child_service.create_child(child_data)
        return {
            "id": child.id,
            "name": child.name,
            "age": child.age,
            "parent_id": child.parent_id
        }, 201


    @api.response(200, "Children retrieved successfully")
    def get(self):

        children = child_service.get_all_children()
        return [
            {
                "id": child.id,
                "name": child.name,
                "age": child.age
            }
            for child in children
        ], 200


@api.route("/<child_id>")
class ChildResource(Resource):

    @api.response(200, "Child retrieved successfully")
    @api.response(404, "Child not found")
    def get(self, child_id):

        child = child_service.get_child(child_id)

        if not child:
            return {"error": "Child not found"}, 404

        return {
            "id": child.id,
            "name": child.name,
            "age": child.age,
            "parent_id": child.parent_id
        }, 200
    
    @api.expect(child_update_model, validate=True)
    @api.response(200, "Child updated successfully")
    @api.response(404, "Child not found")
    def put(self, child_id):
        child_data = api.payload
        child = child_service.update_child(child_id, child_data)

        if not child:
            return {"error": "Child not found"}, 404

        return {
            "id": child.id,
            "name": child.name,
            "age": child.age,
            "parent_id": child.parent_id
        }, 200

    @api.response(204, "Child deleted successfully")
    @api.response(404, "Child not found")
    def delete(self, child_id):
        child = child_service.delete_child(child_id)

        if not child:
            return {"error": "Child not found"}, 404

        return "", 204
    
@api.route("/parent/<parent_id>")
class ChildrenByParentResource(Resource):

    @api.response(200, "Children retrieved successfully")
    def get(self, parent_id):
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
