from marshmallow import Schema, fields, ValidationError, validates_schema, pre_load
from app.utils.datetime_utils import riyadh_today
from app.schemas.auth_schema import phone_validator
import re

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
    if len(value) < 2:
        raise ValidationError("Child name must be at least 2 characters long.")
    if len(value) > 100:
        raise ValidationError("Child name must not exceed 100 characters.")
    if not re.fullmatch(r"[A-Za-z\u0621-\u063A\u0641-\u064A ]+", value):
        raise ValidationError("Child name must contain letters only.")

def validate_avatar_index(value):
    if value not in range(4):
        raise ValidationError("Avatar index must be between 0 and 3.")

class ChildResponseSchema(Schema):
    id = fields.String()
    name = fields.String()
    birth_date = fields.Date()
    phone = fields.String(allow_none=True)
    age = fields.Integer(dump_only=True)
    avatar_index = fields.Integer()
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
    avatar_index = fields.Integer()
    role = fields.Method("get_role")

    def get_role(self, obj):
        return "child"

class ChildCreateSchema(Schema):
    name = fields.String(required=True, validate=validate_child_name)
    birth_date = fields.Date(required=True, validate=birth_date_validator)
    phone = fields.String(required=False, allow_none=True, validate=phone_validator)
    avatar_index = fields.Integer(required=True, validate=validate_avatar_index,)
    @pre_load
    def clean_name(self, data, **kwargs):
        if not isinstance(data, dict):
            return data
        if isinstance(data.get("name"), str):
            data["name"] = " ".join(data["name"].split())
        if isinstance(data.get("phone"), str):
            data["phone"] = data["phone"].strip()
        return data



class ChildUpdateSchema(Schema):
    name = fields.String(required=False, validate=validate_child_name)
    birth_date = fields.Date(required=False, validate=birth_date_validator)
    phone = fields.String(required=False, allow_none=True, validate=phone_validator)
    avatar_index = fields.Integer(required=False, validate=validate_avatar_index,)
    @pre_load
    def clean_name(self, data, **kwargs):
        if not isinstance(data, dict):
            return data
        if isinstance(data.get("name"), str):
            data["name"] = " ".join(data["name"].split())
        return data

    @validates_schema
    def validate_at_least_one_field(self, data, **kwargs):
        if not data:
            raise ValidationError("At least one field must be provided.")