from flask_restx import Namespace, Resource
from flask_jwt_extended import jwt_required, get_jwt_identity, get_jwt
from marshmallow import ValidationError
from app.services.family_service import FamilyService
from app.schemas import  FamilyInviteSchema, FamilyUpdateSchema, FamilyResponseSchema, FamilyInvitationResponseSchema
from app.api_models.family_api import get_family_models

api = Namespace("family", description="Family operations")
family_service = FamilyService()
family_invite_schema = FamilyInviteSchema()
family_invitation_response_schema = FamilyInvitationResponseSchema()
family_update_schema = FamilyUpdateSchema()
family_response_schema = FamilyResponseSchema()
family_invitations_response_schema = FamilyInvitationResponseSchema(many=True)
family_invite_model, family_update_model, family_response_model, family_invitation_response_model = get_family_models(api)

@api.route("/invite")
class InviteParentResource(Resource):
    @api.response(201, "Invitation created successfully", family_invitation_response_model)
    @api.response(400, "Invalid invitation request")
    @api.response(401, "Missing or invalid access token")
    @api.response(403, "Parent access required")
    @api.response(404, "User not found")
    @api.response(500, "Failed to create invitation")
    @api.doc(security="JWT")
    @jwt_required()
    @api.expect(family_invite_model, validate=True)
    def post(self):
        claims = get_jwt()
        if claims.get("role") != "parent":
            return {"error": "Parent access required"}, 403
        try:
            data = family_invite_schema.load(api.payload)
        except ValidationError as err:
            return {"errors": err.messages}, 400
        user_id = get_jwt_identity()
        invitation, error = family_service.invite_parent(user_id, data["email"])
        if error == "user_not_found":
            return {"error": "Current user not found"}, 404
        if error == "family_not_found":
            return {"error": "Current user is not assigned to a family"}, 400
        if error == "invited_user_not_found":
            return {"error": "Invited email does not belong to an existing user"}, 404
        if error == "cannot_invite_self":
            return {"error": "You cannot invite yourself"}, 400
        if error == "invited_user_not_parent":
            return {"error": "Invited user is not a parent"}, 400
        if error == "already_in_same_family":
            return {"error": "User is already in your family"}, 400
        if error == "guardian_type_already_exists":
            return {"error": "This family already has this guardian type"}, 400
        if error == "invitation_already_pending":
            return {"error": "An invitation is already pending for this email"}, 400
        if error:
            return {"error": "Failed to create invitation"}, 500
        return family_invitation_response_schema.dump(invitation), 201

@api.route("/me")
class MyFamilyResource(Resource):
    @api.response(200, "Family name updated successfully", family_response_model)
    @api.response(400, "Invalid input")
    @api.response(401, "Missing or invalid access token")
    @api.response(403, "Parent access required")
    @api.response(404, "User or family not found")
    @api.response(500, "Failed to update family")
    @api.doc(security="JWT")
    @jwt_required()
    @api.expect(family_update_model, validate=True)
    def put(self):
        claims = get_jwt()
        if claims.get("role") != "parent":
            return {"error": "Parent access required"}, 403
        try:
            data = family_update_schema.load(api.payload or {})
        except ValidationError as err:
            return {"errors": err.messages}, 400
        user_id = get_jwt_identity()
        family, error = family_service.update_family_name(user_id, data)
        if error == "user_not_found":
            return {"error": "User not found"}, 404
        if error == "family_not_found":
            return {"error": "Family not found"}, 404
        if error:
            return {"error": "Failed to update family"}, 500
        return family_response_schema.dump(family), 200
    
@api.route("/invitations")
class MyFamilyInvitationsResource(Resource):
    @api.response(200, "Invitations retrieved successfully")
    @api.response(401, "Missing or invalid access token")
    @api.response(403, "Parent access required")
    @api.response(404, "User not found")
    @api.response(500, "Failed to retrieve invitations")
    @api.doc(security="JWT")
    @jwt_required()
    def get(self):
        claims = get_jwt()
        if claims.get("role") != "parent":
            return {"error": "Parent access required"}, 403
        user_id = get_jwt_identity()
        invitations, error = family_service.get_my_invitations(user_id)
        if error == "user_not_found":
            return {"error": "User not found"}, 404
        if error:
            return {"error": "Failed to retrieve invitations"}, 500
        return family_invitations_response_schema.dump(invitations), 200

@api.route("/invitations/<invitation_id>/accept")
class AcceptFamilyInvitationResource(Resource):
    @api.response(200, "Invitation accepted successfully", family_invitation_response_model)
    @api.response(400, "Invitation cannot be accepted")
    @api.response(401, "Missing or invalid access token")
    @api.response(403, "Parent access required")
    @api.response(404, "User or invitation not found")
    @api.response(500, "Failed to accept invitation")
    @api.doc(security="JWT")
    @jwt_required()
    def put(self, invitation_id):
        claims = get_jwt()
        if claims.get("role") != "parent":
            return {"error": "Parent access required"}, 403
        user_id = get_jwt_identity()
        invitation, error = family_service.accept_invitation(user_id, invitation_id)
        if error == "user_not_found":
            return {"error": "User not found"}, 404
        if error == "invitation_not_found":
            return {"error": "Invitation not found"}, 404
        if error == "invitation_not_pending":
            return {"error": "Invitation is not pending"}, 400
        if error == "guardian_type_already_exists":
            return {"error": "This family already has this guardian type"}, 400
        if error == "current_family_has_children":
            return {"error": "User cannot leave a family that has children"}, 400
        if error == "already_in_same_family":
            return {"error": "User is already in this family"}, 400
        if error == "update_failed":
            return {"error": "Failed to accept invitation"}, 500
        if error:
            return {"error": "Failed to accept invitation"}, 500
        return family_invitation_response_schema.dump(invitation), 200

@api.route("/invitations/<invitation_id>/reject")
class RejectFamilyInvitationResource(Resource):
    @api.response(200, "Invitation rejected successfully", family_invitation_response_model)
    @api.response(400, "Invitation is not pending")
    @api.response(401, "Missing or invalid access token")
    @api.response(403, "Parent access required")
    @api.response(404, "User or invitation not found")
    @api.response(500, "Failed to reject invitation")
    @api.doc(security="JWT")
    @jwt_required()
    def put(self, invitation_id):
        claims = get_jwt()
        if claims.get("role") != "parent":
            return {"error": "Parent access required"}, 403
        user_id = get_jwt_identity()
        invitation, error = family_service.reject_invitation(user_id, invitation_id)
        if error == "user_not_found":
            return {"error": "User not found"}, 404
        if error == "invitation_not_found":
            return {"error": "Invitation not found"}, 404
        if error == "invitation_not_pending":
            return {"error": "Invitation is not pending"}, 400
        if error:
            return {"error": "Failed to reject invitation"}, 500
        return family_invitation_response_schema.dump(invitation), 200