from flask_restx import Namespace, Resource
from flask_jwt_extended import jwt_required, get_jwt_identity, get_jwt
from marshmallow import ValidationError

from app.services.family_service import FamilyService
from app.schemas import FamilyInviteSchema, FamilyInvitationResponseSchema
from app.api_models.family_api import get_family_models


api = Namespace("family", description="Family operations")

family_service = FamilyService()

family_invite_schema = FamilyInviteSchema()
family_invitation_response_schema = FamilyInvitationResponseSchema()
family_invitations_response_schema = FamilyInvitationResponseSchema(many=True)

family_invite_model, family_invitation_response_model = get_family_models(api)


@api.route("/invite")
class InviteParentResource(Resource):

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

        errors = {
            "invited_user_not_found": ("Invited email does not belong to an existing user", 404),
            "cannot_invite_self": ("You cannot invite yourself", 400),
            "invited_user_not_parent": ("Invited user is not a parent", 400),
            "already_in_same_family": ("User is already in your family", 400),
            "guardian_type_already_exists": ("This family already has this guardian type", 400),
            "invitation_already_pending": ("An invitation is already pending for this email", 400),
            "create_failed": ("Failed to create invitation", 500),
        }

        if error:
            message, status = errors.get(error, ("Something went wrong", 400))
            return {"error": message}, status

        return family_invitation_response_schema.dump(invitation), 201


@api.route("/invitations")
class MyFamilyInvitationsResource(Resource):

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

        return family_invitations_response_schema.dump(invitations), 200


@api.route("/invitations/<invitation_id>/accept")
class AcceptFamilyInvitationResource(Resource):

    @api.doc(security="JWT")
    @jwt_required()
    def put(self, invitation_id):
        claims = get_jwt()

        if claims.get("role") != "parent":
            return {"error": "Parent access required"}, 403

        user_id = get_jwt_identity()

        invitation, error = family_service.accept_invitation(user_id, invitation_id)

        errors = {
            "invitation_not_found": ("Invitation not found", 404),
            "invitation_not_pending": ("Invitation is not pending", 400),
            "guardian_type_already_exists": ("This family already has this guardian type", 400),
            "update_failed": ("Failed to accept invitation", 500),
            "already_in_family": ("User already belongs to a family", 400),
            "already_in_same_family": ("User is already in this family", 400),
        }

        if error:
            message, status = errors.get(error, ("Something went wrong", 400))
            return {"error": message}, status

        return family_invitation_response_schema.dump(invitation), 200


@api.route("/invitations/<invitation_id>/reject")
class RejectFamilyInvitationResource(Resource):

    @api.doc(security="JWT")
    @jwt_required()
    def put(self, invitation_id):
        claims = get_jwt()

        if claims.get("role") != "parent":
            return {"error": "Parent access required"}, 403

        user_id = get_jwt_identity()

        invitation, error = family_service.reject_invitation(user_id, invitation_id)

        if error == "invitation_not_found":
            return {"error": "Invitation not found"}, 404

        if error == "invitation_not_pending":
            return {"error": "Invitation is not pending"}, 400

        if error == "update_failed":
            return {"error": "Failed to reject invitation"}, 500

        return family_invitation_response_schema.dump(invitation), 200