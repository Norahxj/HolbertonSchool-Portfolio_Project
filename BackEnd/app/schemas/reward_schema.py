from marshmallow import Schema, fields, validate, ValidationError, validates_schema

def validate_reward_name(value):
    cleaned_value = value.strip()
    if len(cleaned_value) < 2:
        raise ValidationError("Reward name must be at least 2 characters long.")
    if len(cleaned_value) > 100:
        raise ValidationError("Reward name must not exceed 100 characters.")

class RewardResponseSchema(Schema):
    id = fields.String()
    child_id = fields.String()
    reward_name = fields.String()
    description = fields.String(allow_none=True)
    status = fields.String()
    unlock_day = fields.Integer()
    assigned_by = fields.String(allow_none=True)
    created_at = fields.DateTime()


class RewardCreateSchema(Schema):
    child_id = fields.String(required=True)
    reward_name = fields.String(required=True, validate=validate_reward_name)
    description = fields.String(required=False, allow_none=True, validate=validate.Length(max=500))
    unlock_day = fields.Integer(required=False, load_default=3, validate=validate.Range(min=0, max=6))


class RewardUpdateSchema(Schema):
    reward_name = fields.String(required=False, validate=validate_reward_name)
    description = fields.String(required=False, allow_none=True, validate=validate.Length(max=500))
    unlock_day = fields.Integer(required=False, validate=validate.Range(min=0, max=6))

    @validates_schema
    def validate_at_least_one_field(self, data, **kwargs):
        if not data:
            raise ValidationError("At least one field must be provided.")