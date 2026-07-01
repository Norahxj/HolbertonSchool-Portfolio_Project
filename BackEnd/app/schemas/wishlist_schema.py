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
    reviewed_by = fields.String(dump_only=True)
    reviewer_name = fields.Method("get_reviewer_name", dump_only=True)
    created_at = fields.DateTime()
    updated_at = fields.DateTime()
    