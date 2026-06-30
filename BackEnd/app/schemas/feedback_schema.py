from marshmallow import Schema, fields, validate

ALLOWED_EMOJIS = [
    "⭐",
    "🎉",
    "💪",
    "😊",
    "❤️",
    "👏"
]


class DailyFeedbackResponseSchema(Schema):
    id = fields.String()
    task_id = fields.String()
    parent_id = fields.String()
    emoji = fields.String()
    created_at = fields.DateTime()


class DailyFeedbackCreateSchema(Schema):
    task_id = fields.String(required=True)

    emoji = fields.String(
        required=True,
        validate=validate.OneOf(ALLOWED_EMOJIS)
    )