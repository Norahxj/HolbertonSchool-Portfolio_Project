from marshmallow import Schema, fields, validate, validates, ValidationError


class RewardResponseSchema(Schema):
    id = fields.String()
    child_id = fields.String()
    reward_name = fields.String()
    description = fields.String(allow_none=True)
    status = fields.String()
    unlock_day = fields.Integer()
    assigned_by = fields.String()
    created_at = fields.DateTime()


class RewardCreateSchema(Schema):
    child_id = fields.String(required=True)
    reward_name = fields.String(required=True, validate=validate.Length(min=2, max=100))
    description = fields.String(required=False, allow_none=True, validate=validate.Length(max=500))
    unlock_day = fields.Integer(required=False, load_default=3, validate=validate.Range(min=0, max=6))

    @validates("reward_name")
    def validate_reward_name(self, value, **kwargs):
        if not value.strip():
            raise ValidationError("Reward name cannot be empty.")


class RewardUpdateSchema(Schema):
    reward_name = fields.String(required=False, validate=validate.Length(min=2, max=100))
    description = fields.String(required=False, allow_none=True, validate=validate.Length(max=500))
    unlock_day = fields.Integer(required=False, validate=validate.Range(min=0, max=6))

    @validates("reward_name")
    def validate_reward_name(self, value, **kwargs):
        if not value.strip():
            raise ValidationError("Reward name cannot be empty.")