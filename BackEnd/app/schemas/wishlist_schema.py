from marshmallow import Schema, fields, validate


class WishlistCreateSchema(Schema):
    name = fields.String(required=True, validate=validate.Length(min=2, max=255))


class WishlistApproveSchema(Schema):
    target_points = fields.Integer(required=True, validate=validate.Range(min=1))


class WishlistResponseSchema(Schema):
    id = fields.String()
    child_id = fields.String()
    name = fields.String()
    target_points = fields.Integer(allow_none=True)
    status = fields.String()
    created_at = fields.DateTime()
    updated_at = fields.DateTime()
    