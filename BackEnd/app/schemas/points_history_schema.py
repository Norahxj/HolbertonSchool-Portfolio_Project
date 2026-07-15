from marshmallow import Schema, fields

class PointsHistoryTaskDetailsSchema(Schema):
    id = fields.String()
    title = fields.String()
    description = fields.String()
    points = fields.Integer()
    category = fields.String()

class PointsHistoryTaskSchema(Schema):
    id = fields.String()
    status = fields.String()
    assigned_date = fields.Date()
    completed_at = fields.DateTime(allow_none=True)
    approved_at = fields.DateTime(allow_none=True)
    task = fields.Nested(PointsHistoryTaskDetailsSchema)

class PointsHistoryWishlistSchema(Schema):
    id = fields.String()
    name = fields.String()
    target_points = fields.Integer(allow_none=True)
    status = fields.String()
    approved_at = fields.DateTime(allow_none=True)

class PointsHistoryResponseSchema(Schema):
    id = fields.String()
    child_id = fields.String()
    points = fields.Integer()
    action = fields.String()
    task_assignment_id = fields.String(allow_none=True)
    wishlist_id = fields.String(allow_none=True)
    task_assignment = fields.Nested(PointsHistoryTaskSchema, allow_none=True)
    wishlist = fields.Nested(PointsHistoryWishlistSchema, allow_none=True)
    created_at = fields.DateTime()