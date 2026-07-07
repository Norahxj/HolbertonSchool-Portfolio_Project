from flask_restx import Namespace, Resource
from flask_jwt_extended import jwt_required, get_jwt, get_jwt_identity
from app.services.points_history_service import PointsHistoryService
from app.schemas import PointsHistoryResponseSchema
from app.api_models.points_history_api import get_points_history_models
from app.repositories.child_repository import ChildRepository


api = Namespace("points-history", description="Points history operations")
points_history_service = PointsHistoryService()
child_repository = ChildRepository()
history_response_schema = PointsHistoryResponseSchema(many=True)
history_response_model = get_points_history_models(api)

@api.route("/my")
class MyPointsHistoryResource(Resource):

    @api.doc(security="JWT")
    @jwt_required()
    @api.marshal_list_with(history_response_model, code=200)
    def get(self):
        claims = get_jwt()

        if claims.get("role") != "child":
            return {"error": "Child access required"}, 403

        child_id = get_jwt_identity()

        history, error = points_history_service.get_history_for_child(child_id)

        if error == "child_not_found":
            return {"error": "Child not found"}, 404

        return history_response_schema.dump(history), 200


@api.route("/child/<child_id>")
class ChildPointsHistoryResource(Resource):

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

        history, error = points_history_service.get_history_for_child(child_id)

        if error == "child_not_found":
            return {"error": "Child not found"}, 404

        return history_response_schema.dump(history), 200