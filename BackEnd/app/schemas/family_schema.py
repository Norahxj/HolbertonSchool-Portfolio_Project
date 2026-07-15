from marshmallow import Schema, fields, validate, ValidationError
from app.schemas.auth_schema import validate_email_domain

def validate_family_name(value):
    cleaned_value = value.strip()
    if len(cleaned_value) < 2:
        raise ValidationError("Family name must be at least 2 characters long.")
    if len(cleaned_value) > 100:
        raise ValidationError("Family name must not exceed 100 characters.")

class FamilyInviteSchema(Schema):
    email = fields.Email(required=True, validate=[validate.Length(max=120), validate_email_domain])

class FamilyUpdateSchema(Schema):
    name = fields.String(required=True, validate=validate_family_name)

class FamilyResponseSchema(Schema):
    id = fields.String()
    name = fields.String(allow_none=True)


class FamilyInvitationResponseSchema(Schema):
    id = fields.String()
    family_id = fields.String()
    invited_email = fields.Email()
    invited_by = fields.String()
    status = fields.String()
    created_at = fields.DateTime()