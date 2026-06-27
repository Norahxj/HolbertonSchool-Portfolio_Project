from marshmallow import Schema, fields


class UserResponseSchema(Schema):
    id = fields.String()
    full_name = fields.String()
    email = fields.Email()
    role = fields.String()
    