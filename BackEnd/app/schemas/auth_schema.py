import re
from marshmallow import Schema, ValidationError, fields, validate

def validate_password(password):
    if len(password) < 8:
        raise ValidationError("Password must be at least 8 characters long.")
    if not re.search(r"[A-Z]", password):
        raise ValidationError("Password must contain at least one uppercase letter.")
    if not re.search(r"[a-z]", password):
        raise ValidationError("Password must contain at least one lowercase letter.")
    if not re.search(r"\d", password):
        raise ValidationError("Password must contain at least one number.")
    if not re.search(r"[!@#$%^&*(),.?\":{}|<>_\-+=/\\[\]]", password):
        raise ValidationError("Password must contain at least one special character.")

class RegisterSchema(Schema):
    first_name = fields.String(required=True, validate=validate.Length(min=2, max=50))
    last_name = fields.String(required=True, validate=validate.Length(min=2, max=50))
    phone = fields.String(required=True, validate=[validate.Length(equal=10), validate.Regexp(r"^05\d{8}$")])
    email = fields.Email(required=True)
    password = fields.String(required=True, validate=validate_password)
    guardian_type = fields.String(required=True, validate=validate.OneOf(["father", "mother"]))

class LoginSchema(Schema):
    email = fields.Email(required=True)
    password = fields.String(required=True)

class ChildLoginSchema(Schema):
    access_code = fields.String(required=True, validate=[
            validate.Length(equal=6),
            validate.Regexp(r"^\d{6}$", error="Access code must be exactly 6 digits.")
        ])