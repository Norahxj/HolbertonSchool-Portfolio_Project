from marshmallow import Schema, fields, validate, validates, ValidationError
from app.schemas.auth_schema import validate_email_domin, phone_validator, validate_password

class UserResponseSchema(Schema):
    id = fields.String()
    first_name = fields.String()
    last_name = fields.String()
    phone = fields.String()
    email = fields.Email()
    role = fields.String()
    guardian_type = fields.String()


class UserUpdateSchema(Schema):
    first_name = fields.String(required=False, validate=validate.Length(min=2, max=50))
    last_name = fields.String(required=False, validate=validate.Length(min=2, max=50))
    phone = fields.String(required=False, validate=phone_validator)
    email = fields.Email(required=False, validate=[validate.Length(max=120), validate_email_domin])
    password = fields.String(required=False, load_only=True, validate=validate_password)

    @validates("first_name")
    def validate_first_name(self, value, **kwargs):
        if not value.strip():
            raise ValidationError("First name cannot be empty.")
        
    @validates("last_name")
    def validate_last_name(self, value, **kwargs):
        if not value.strip():
            raise ValidationError("Last name cannot be empty.")