from marshmallow import Schema, fields, validate
from app.schemas.auth_schema import validate_email_domin


class FamilyInviteSchema(Schema):
    email = fields.Email(required=True, validate=[validate.Length(max=120), validate_email_domin])


class FamilyInvitationResponseSchema(Schema):
    id = fields.String()
    family_id = fields.String()
    invited_email = fields.Email()
    invited_by = fields.String()
    status = fields.String()
    created_at = fields.DateTime()