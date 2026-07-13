from flask_restx import fields


def get_family_models(api):
    family_invite_model = api.model(
        "FamilyInvite",
        {
            "email": fields.String(required=True, description="Invited parent email")
        }
    )

    family_update_model = api.model(
        "FamilyUpdate",
        {
            "name": fields.String(
                required=True,
                min_length=2,
                max_length=100,
                description="New family name"
            )
        }
    )

    family_response_model = api.model(
        "FamilyResponse",
        {
            "id": fields.String(
                description="Family ID"
            ),
            "name": fields.String(
                description="Family name"
            )
        }
    )

    family_invitation_response_model = api.model(
        "FamilyInvitationResponse",
        {
            "id": fields.String(),
            "family_id": fields.String(),
            "invited_email": fields.String(),
            "invited_by": fields.String(),
            "status": fields.String(),
            "created_at": fields.DateTime()
        }
    )

    return (
        family_invite_model,
        family_update_model,
        family_response_model,
        family_invitation_response_model
    )