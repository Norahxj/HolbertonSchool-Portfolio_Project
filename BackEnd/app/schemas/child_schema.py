from marshmallow import Schema, fields, validate, validates, ValidationError
from app.schemas.auth_schema import validate_password


class ChildResponseSchema(Schema):
    id = fields.String()
    name = fields.String()
    age = fields.Integer()
    email = fields.Email()
    parent_id = fields.String()
    role = fields.Method("get_role")

    def get_role(self, obj):
        return "child"


class ChildCreateSchema(Schema):
    name = fields.String(required=True, validate=validate.Length(min=2, max=100))
    age = fields.Integer(required=True, validate=validate.Range(min=1, max=18))
    email = fields.Email(required=True)
    password = fields.String(required=True, validate=validate_password)

    @validates("name")
    def validate_name(self, value, **kwargs):
        if not value.strip():
            raise ValidationError("Child name cannot be empty.")


class ChildUpdateSchema(Schema):
    name = fields.String(required=False, validate=validate.Length(min=2, max=100))
    age = fields.Integer(required=False, validate=validate.Range(min=1, max=18))
    email = fields.Email(required=False)
    password = fields.String(required=False, validate=validate_password)

    @validates("name")
    def validate_name(self, value, **kwargs):
        if not value.strip():
            raise ValidationError("Child name cannot be empty.")