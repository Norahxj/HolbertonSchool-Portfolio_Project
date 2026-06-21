from marshmallow import Schema, fields, validate

# Define the UserSchema for validating
class UserSchema(Schema):
    id = fields.String(dump_only=True)
    full_name = fields.String(required=True, validate=validate.Length(min=3, max=120))
    email = fields.Email(required=True)
    password = fields.String(required=True, load_only=True, validate=validate.Length(min=6))
    is_parent = fields.Boolean(dump_default=True)
    created_at = fields.DateTime(dump_only=True)
    updated_at = fields.DateTime(dump_only=True)

# Define the UserLoginSchema for validating
class UserLoginSchema(Schema):
    # must be a valid email format
    email = fields.Email(required=True)
    # password required 
    password = fields.String(required=True, load_only=True)
