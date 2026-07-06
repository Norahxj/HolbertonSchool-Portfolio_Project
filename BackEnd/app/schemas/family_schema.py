from marshmallow import Schema, fields


class FamilyInviteSchema(Schema):
    email = fields.Email(required=True)


class FamilyInvitationResponseSchema(Schema):
    id = fields.String()
    family_id = fields.String()
    invited_email = fields.Email()
    invited_by = fields.String()
    status = fields.String()
    created_at = fields.DateTime()