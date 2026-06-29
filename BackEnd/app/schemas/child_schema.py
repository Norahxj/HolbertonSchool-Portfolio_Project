from marshmallow import Schema, fields, validate, validates, ValidationError


class ChildResponseSchema(Schema):
    id = fields.String()
    name = fields.String()
    age = fields.Integer()
    


class ChildCreateSchema(Schema):
    name = fields.String(
        required=True,
        validate=validate.Length(min=2, max=100)
    )
    age = fields.Integer(
        required=True,
        validate=validate.Range(min=1, max=18)
    )

    @validates("name")
    def validate_name(self, value, **kwargs):
        if not value.strip():
            raise ValidationError("Child name cannot be empty.")


class ChildUpdateSchema(Schema):
    name = fields.String(
        required=False,
        validate=validate.Length(min=2, max=100)
    )
    age = fields.Integer(
        required=False,
        validate=validate.Range(min=1, max=18)
    )

    @validates("name")
    def validate_name(self, value, **kwargs):
        if not value.strip():
            raise ValidationError("Child name cannot be empty.")