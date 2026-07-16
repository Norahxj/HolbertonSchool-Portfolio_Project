from marshmallow import Schema, fields, ValidationError, validates_schema
from app.utils.datetime_utils import riyadh_today
from app.schemas.auth_schema import phone_validator

def birth_date_validator(value):
    today = riyadh_today()
    if value > today:
        raise ValidationError("Birth date cannot be in the future.")
    age = (
        today.year - value.year
        - ((today.month, today.day) < (value.month, value.day))
    )
    if age < 6 or age > 18:
        raise ValidationError("Child age must be between 6 and 18.")
    
def validate_child_name(value):
    cleaned_value = value.strip()
    if len(cleaned_value) < 2:
        raise ValidationError("Child name must be at least 2 characters long.")
    if len(cleaned_value) > 100:
        raise ValidationError("Child name must not exceed 100 characters.")

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
    name = fields.String(required=True, validate=validate_child_name)
    birth_date = fields.Date(required=True, validate=birth_date_validator)
    phone = fields.String(required=False, allow_none=True, validate=phone_validator)

class ChildUpdateSchema(Schema):
    name = fields.String(required=False, validate=validate_child_name)
    birth_date = fields.Date(required=False, validate=birth_date_validator)
    phone = fields.String(required=False, allow_none=True, validate=phone_validator)
    @validates_schema
    def validate_at_least_one_field(self, data, **kwargs):
        if not data:
            raise ValidationError("At least one field must be provided.")