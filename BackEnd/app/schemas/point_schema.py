from marshmallow import Schema, fields

class PointsResponseSchema(Schema):
    child_id = fields.String()
    total_points = fields.Integer()