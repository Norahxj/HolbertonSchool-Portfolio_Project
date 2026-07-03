from marshmallow import Schema, fields, validate


class DailyFeedbackResponseSchema(Schema):
    id = fields.String()
    child_id = fields.String()
    created_by = fields.String()
    mood = fields.String()
    created_at = fields.DateTime()


class DailyFeedbackCreateSchema(Schema):
    child_id = fields.String(required=True)
    mood = fields.String(
        required=True,
        validate=validate.OneOf([
            "HAPPY",
            "PROUD",
            "GREAT",
            "LOVE",
            "STRONG",
            "STAR"
        ])
    )