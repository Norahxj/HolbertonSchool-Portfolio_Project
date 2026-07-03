from marshmallow import Schema, fields


class PointsHistoryResponseSchema(Schema):
    id = fields.String()
    child_id = fields.String()
    points = fields.Integer()
    action = fields.String()
    source_id = fields.String(allow_none=True)
    created_at = fields.DateTime()