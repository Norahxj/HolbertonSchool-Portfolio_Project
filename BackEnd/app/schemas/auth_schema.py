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
    full_name = fields.String(
        required=True,
        validate=validate.Length(min=2, max=100)
    )

    email = fields.Email(required=True)

    password = fields.String(
        required=True,
        validate=validate_password
    )


class LoginSchema(Schema):
    email = fields.Email(required=True)

    password = fields.String(
        required=True
    )