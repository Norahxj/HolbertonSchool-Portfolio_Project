from marshmallow import Schema, fields, validate, validates, ValidationError, validates_schema
from app.schemas.auth_schema import validate_email_domain, phone_validator, validate_password
import re

class UserResponseSchema(Schema):
    id = fields.String()
    first_name = fields.String()
    last_name = fields.String()
    phone = fields.String()
    email = fields.Email()
    role = fields.String()
    guardian_type = fields.String()


class UserUpdateSchema(Schema):
    first_name = fields.String(required=False)
    last_name = fields.String(required=False)
    phone = fields.String(required=False, validate=phone_validator)
    email = fields.Email(required=False, validate=[validate.Length(max=120), validate_email_domain])
    password = fields.String(required=False, load_only=True, validate=validate_password)

    @validates("first_name")
    def validate_first_name(self, value, **kwargs):
        cleaned_value = value.strip()
        if len(cleaned_value) < 2:
            raise ValidationError("First name must be at least 2 characters long.")
        if len(cleaned_value) > 50:
            raise ValidationError("First name must not exceed 50 characters.")
        if not re.fullmatch(r"[A-Za-z\u0600-\u06FF ]+", cleaned_value):
            raise ValidationError("First name must contain letters only.")
        
    @validates("last_name")
    def validate_last_name(self, value, **kwargs):
        cleaned_value = value.strip()
        if len(cleaned_value) < 2:
            raise ValidationError("Last name must be at least 2 characters long.")
        if len(cleaned_value) > 50:
            raise ValidationError("Last name must not exceed 50 characters.")
        if not re.fullmatch(r"[A-Za-z\u0600-\u06FF ]+", cleaned_value):
            raise ValidationError("Last name must contain letters only.")
        
    @validates_schema
    def validate_at_least_one_field(self, data, **kwargs):
        if not data:
            raise ValidationError("At least one field must be provided.")