from marshmallow import Schema, fields, validate, validates, ValidationError
from app.utils.datetime_utils import riyadh_today

phone_validator = [
    validate.Length(equal=10, error="Phone number must be exactly 10 digits."),
    validate.Regexp(r"^05\d{8}$", error="Phone number must start with 05 and contain 10 digits.")
]

def birth_date_validator(value):
    today = riyadh_today()

    if value > today:
        raise ValidationError(
            "Birth date cannot be in the future."
        )

    age = (
        today.year
        - value.year
        - (
            (today.month, today.day)
            < (value.month, value.day)
        )
    )

    if age < 1 or age > 18:
        raise ValidationError(
            "Child age must be between 1 and 18."
        )

class ChildResponseSchema(Schema):
    id = fields.String()
    name = fields.String()
    birth_date = fields.Date()
    phone = fields.String(allow_none=True)
    age = fields.Integer(dump_only=True)
    role = fields.Method("get_role")
    def get_role(self, obj):
        return "child"

class ChildWithAccessCodeSchema(Schema):
    id = fields.String()
    name = fields.String()
    birth_date = fields.Date()
    phone = fields.String(allow_none=True)
    age = fields.Integer(dump_only=True)
    access_code = fields.String()
    role = fields.Method("get_role")

    def get_role(self, obj):
        return "child"

class ChildCreateSchema(Schema):
    name = fields.String(required=True, validate=validate.Length(min=2, max=100))
    birth_date = fields.Date(required=True, validate=birth_date_validator)
    phone = fields.String(required=False, allow_none=True, validate=phone_validator)
    @validates("name")
    def validate_name(self, value, **kwargs):
        if not value.strip():
            raise ValidationError("Child name cannot be empty.")


class ChildUpdateSchema(Schema):
    name = fields.String(required=False, validate=validate.Length(min=2, max=100))
    birth_date = fields.Date(required=False, validate=birth_date_validator)
    phone = fields.String(required=False, allow_none=True, validate=phone_validator)
    @validates("name")
    def validate_name(self, value, **kwargs):
        if not value.strip():
            raise ValidationError("Child name cannot be empty.")