from marshmallow import Schema, fields, validate
from marshmallow_enum import EnumField
from app.models.gamification_models import TaskStatus, FeedbackMood # Import Enums from models

# Define the ChildTaskSchema for validating and serializing ChildTask data
class ChildTaskSchema(Schema):
    id = fields.String(dump_only=True)
    child_id = fields.String(required=True) #UUID
    suggested_task_id = fields.Integer(allow_none=True)
    parent_custom_task_id = fields.Integer(allow_none=True)
    assigned_points = fields.Integer(required=True, validate=validate.Range(min=0))
    status = EnumField(TaskStatus, dump_default=TaskStatus.PENDING, by_value=True)
    due_date = fields.DateTime(allow_none=True)
    completion_date = fields.DateTime(dump_only=True)
    verification_date = fields.DateTime(dump_only=True)
    parent_feedback_id = fields.String(allow_none=True)
    created_at = fields.DateTime(dump_only=True)
    updated_at = fields.DateTime(dump_only=True)

# Define the RewardSchema
class RewardSchema(Schema):
    id = fields.Integer(dump_only=True)
    parent_id = fields.String(required=True)
    name_en = fields.String(required=True, validate=validate.Length(min=3, max=255))
    name_ar = fields.String(required=True, validate=validate.Length(min=3, max=255))
    description_en = fields.String(allow_none=True)
    description_ar = fields.String(allow_none=True)
    cost_points = fields.Integer(required=True, validate=validate.Range(min=0))
    is_active = fields.Boolean(dump_default=True)
    is_approved_by_parent = fields.Boolean(dump_default=True)
    created_at = fields.DateTime(dump_only=True)
    updated_at = fields.DateTime(dump_only=True)

# Define the ChildRewardSchema
class ChildRewardSchema(Schema):
    id = fields.Integer(dump_only=True)
    child_id = fields.String(required=True)
    reward_id = fields.Integer(required=True)
    redemption_date = fields.DateTime(dump_only=True)
    is_fulfilled = fields.Boolean(dump_default=False)
    fulfilled_date = fields.DateTime(allow_none=True)
    created_at = fields.DateTime(dump_only=True)
    updated_at = fields.DateTime(dump_only=True)

# Define the WishSchema
class WishSchema(Schema):
    id = fields.Integer(dump_only=True)
    child_id = fields.String(required=True)
    name_en = fields.String(required=True, validate=validate.Length(min=3, max=255))
    name_ar = fields.String(required=True, validate=validate.Length(min=3, max=255))
    description_en = fields.String(allow_none=True)
    description_ar = fields.String(allow_none=True)
    target_points = fields.Integer(required=True, validate=validate.Range(min=0))
    current_points = fields.Integer(dump_default=0, validate=validate.Range(min=0))
    is_achieved = fields.Boolean(dump_default=False)
    achievement_date = fields.DateTime(allow_none=True)
    is_approved_by_parent = fields.Boolean(dump_default=False)
    created_at = fields.DateTime(dump_only=True)
    updated_at = fields.DateTime(dump_only=True)

# Define the DailyFeedbackSchema
class DailyFeedbackSchema(Schema):
    id = fields.String(dump_only=True)
    parent_id = fields.String(required=True)
    child_id = fields.String(required=True)
    feedback_date = fields.DateTime(dump_only=True)
    mood = EnumField(FeedbackMood, required=True, by_value=True)
    notes = fields.String(allow_none=True)
    created_at = fields.DateTime(dump_only=True)
    # 'updated_at' field, read-only
    updated_at = fields.DateTime(dump_only=True)
