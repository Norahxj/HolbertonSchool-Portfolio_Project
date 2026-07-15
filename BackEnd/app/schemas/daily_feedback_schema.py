from marshmallow import Schema, fields, validate, ValidationError, validates_schema
MOOD_VALUES = ["HAPPY", "PROUD", "GREAT", "LOVE", "STRONG", "STAR"]

class DailyFeedbackResponseSchema(Schema):
    id = fields.String()
    child_id = fields.String()
    created_by = fields.String()
    mood = fields.String()
    feedback_date = fields.Date()
    created_at = fields.DateTime()


class DailyFeedbackCreateSchema(Schema):
    child_id = fields.String(required=True)
    mood = fields.String(required=True, validate=validate.OneOf(MOOD_VALUES))

class DailyFeedbackUpdateSchema(Schema):
    mood = fields.String(required=True, validate=validate.OneOf(MOOD_VALUES))

    @validates_schema
    def validate_at_least_one_field(self, data, **kwargs):
        if not data:
            raise ValidationError("At least one field must be provided.")