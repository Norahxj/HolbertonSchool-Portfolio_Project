from flask_restx import Namespace, Resource
from flask_jwt_extended import jwt_required, get_jwt_identity, get_jwt
from app.services.dashboard_service import DashboardService
from app.schemas import ChildDashboardResponseSchema
from app.api_models.dashboard_api import get_dashboard_models

api = Namespace("dashboard", description="Parent dashboard operations")
dashboard_service = DashboardService()
dashboard_response_schema = ChildDashboardResponseSchema(many=True)
dashboard_response_model = get_dashboard_models(api)

@api.route("/")
class ParentDashboardResource(Resource):
    @api.response(403, "Parent access required")
    @api.response(404, "Parent not found")
    @api.response(500, "Failed to retrieve dashboard")
    @api.doc(security="JWT")
    @api.response(200, "Dashboard retrieved successfully", [dashboard_response_model])
    @jwt_required()
    def get(self):
        claims = get_jwt()
        if claims.get("role") != "parent":
            return {"error": "Parent access required"}, 403
        parent_id = get_jwt_identity()
        dashboard, error = dashboard_service.get_dashboard(parent_id, claims.get("role"))
        if error == "parent_not_found":
            return {"error": "Parent not found"}, 404
        if error:
            return {"error": "Failed to retrieve dashboard"}, 500
        return dashboard_response_schema.dump(dashboard), 200