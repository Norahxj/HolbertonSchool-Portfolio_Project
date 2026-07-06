from flask_restx import fields


def get_family_models(api):
    family_invite_model = api.model("FamilyInvite", {
        "email": fields.String(required=True, description="Invited parent email")
    })

    family_invitation_response_model = api.model("FamilyInvitationResponse", {
        "id": fields.String(),
        "family_id": fields.String(),
        "invited_email": fields.String(),
        "invited_by": fields.String(),
        "status": fields.String(),
        "created_at": fields.DateTime()
    })

    return family_invite_model, family_invitation_response_model