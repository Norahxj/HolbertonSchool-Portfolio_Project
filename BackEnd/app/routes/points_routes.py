from flask_restx import Namespace, Resource
from flask_jwt_extended import jwt_required, get_jwt_identity, get_jwt
from app.services.points_service import PointsService
from app.schemas import PointsResponseSchema
from app.api_models.points_api import get_point_models
from app.repositories.child_repository import ChildRepository


api = Namespace("points", description="Points operations")

points_service = PointsService()
points_response_schema = PointsResponseSchema()
child_repository = ChildRepository()

points_response_model = get_point_models(api)


@api.route("/child/<child_id>")
class ChildPointsResource(Resource):

    @api.doc(security="JWT")
    @jwt_required()
    def get(self, child_id):
        claims = get_jwt()

        if claims.get("role") != "parent":
            return {"error": "Parent access required"}, 403
        parent_id = get_jwt_identity()

        child = child_repository.get_child_for_guardian(child_id, parent_id)

        if not child:
            return {"error": "Child not found"}, 404

        points, error = points_service.get_child_points(child_id)

        if error == "child_not_found":
            return {"error": "Child not found"}, 404

        return points_response_schema.dump(points), 200


@api.route("/my")
class MyPointsResource(Resource):

    @api.doc(security="JWT")
    @jwt_required()
    def get(self):
        claims = get_jwt()

        if claims.get("role") != "child":
            return {"error": "Child access required"}, 403

        child_id = get_jwt_identity()

        points, error = points_service.get_child_points(child_id)

        if error == "child_not_found":
            return {"error": "Child not found"}, 404

        return points_response_schema.dump(points), 200