from marshmallow import Schema, fields, validate

# Define the TaskCategorySchema
class TaskCategorySchema(Schema):
    id = fields.Integer(dump_only=True)
    name_en = fields.String(
        required=True, validate=validate.Length(min=3, max=100))
    name_ar = fields.String(
        required=True, validate=validate.Length(min=3, max=100))
    description_en = fields.String(allow_none=True)
    description_ar = fields.String(allow_none=True)
    created_at = fields.DateTime(dump_only=True)
    updated_at = fields.DateTime(dump_only=True)

# Define the SuggestedTaskSchema
class SuggestedTaskSchema(Schema):
    id = fields.Integer(dump_only=True)
    category_id = fields.Integer(required=True)
    name_en = fields.String(
        required=True, validate=validate.Length(min=3, max=255))
    name_ar = fields.String(
        required=True, validate=validate.Length(min=3, max=255))
    description_en = fields.String(allow_none=True)
    description_ar = fields.String(allow_none=True)
    min_age = fields.Integer(
        dump_default=6, validate=validate.Range(min=0, max=18))
    max_age = fields.Integer(
        dump_default=16, validate=validate.Range(min=0, max=18))
    default_points = fields.Integer(
        dump_default=10, validate=validate.Range(min=0))
    created_at = fields.DateTime(dump_only=True)
    updated_at = fields.DateTime(dump_only=True)

# Define the ParentCustomTaskSchema for validating and serializing ParentCustomTask data
class ParentCustomTaskSchema(Schema):
    id = fields.Integer(dump_only=True)
    parent_id = fields.String(required=True)
    category_id = fields.Integer(required=True)
    name_en = fields.String(
        required=True, validate=validate.Length(min=3, max=255))
    name_ar = fields.String(
        required=True, validate=validate.Length(min=3, max=255))
    description_en = fields.String(allow_none=True)
    description_ar = fields.String(allow_none=True)
    points = fields.Integer(required=True, validate=validate.Range(min=0))
    is_recurring = fields.Boolean(dump_default=False)
    recurrence_type = fields.String(
        allow_none=True, validate=validate.OneOf(["daily", "weekly", "monthly"]))
    requires_verification = fields.Boolean(dump_default=True)
    created_at = fields.DateTime(dump_only=True)
    updated_at = fields.DateTime(dump_only=True)
