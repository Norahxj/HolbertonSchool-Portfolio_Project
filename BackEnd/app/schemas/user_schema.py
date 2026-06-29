from marshmallow import Schema, fields, validate


class UserResponseSchema(Schema):
    id = fields.String()
    full_name = fields.String()
    email = fields.Email()
    role = fields.String()


class UserUpdateSchema(Schema):
    full_name = fields.String(
        required=False,
        validate=validate.Length(min=2, max=100)
    )

    email = fields.Email(required=False)