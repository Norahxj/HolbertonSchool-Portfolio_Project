from marshmallow import Schema, fields, validate, validates, ValidationError
from app.schemas.auth_schema import validate_email_domain


class FamilyInviteSchema(Schema):
    email = fields.Email(
        required=True,
        validate=[validate.Length(max=120), validate_email_domain]
    )


class FamilyUpdateSchema(Schema):
    name = fields.String(
        required=True,
        validate=validate.Length(min=2, max=100)
    )

    @validates("name")
    def validate_name(self, value, **kwargs):
        if not value.strip():
            raise ValidationError("Family name cannot be empty.")


class FamilyResponseSchema(Schema):
    id = fields.String()
    name = fields.String()


class FamilyInvitationResponseSchema(Schema):
    id = fields.String()
    family_id = fields.String()
    invited_email = fields.Email()
    invited_by = fields.String()
    status = fields.String()
    created_at = fields.DateTime()