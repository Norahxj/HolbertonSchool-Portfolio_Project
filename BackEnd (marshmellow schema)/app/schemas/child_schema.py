from marshmallow import Schema, fields, validate

# Define the ChildSchema for validating and serializing Child data
class ChildSchema(Schema):
    id = fields.String(dump_only=True)
    #string (UUID)
    parent_id = fields.String(required=True)
    full_name = fields.String(required=True, validate=validate.Length(min=3, max=120))
    date_of_birth = fields.Date(required=True)
    gender = fields.String(allow_none=True, validate=validate.OneOf(["male", "female"]))
    avatar_url = fields.URL(allow_none=True)
    current_noor_points = fields.Integer(dump_only=True)
    created_at = fields.DateTime(dump_only=True)
    updated_at = fields.DateTime(dump_only=True)
