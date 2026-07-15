from marshmallow import Schema, fields, validate, ValidationError, validates_schema
TASK_FREQUENCIES = ["ONCE", "DAILY", "WEEKLY", "MONTHLY"]
TASK_CATEGORIES = ["RELIGIOUS", "FINANCIAL", "MORAL", "SOCIAL"]

def validate_task_title(value):
    cleaned_value = value.strip()
    if len(cleaned_value) < 2:
        raise ValidationError("Title must be at least 2 characters long.")
    if len(cleaned_value) > 100:
        raise ValidationError("Title must not exceed 100 characters.")

def validate_task_description(value):
    cleaned_value = value.strip()
    if len(cleaned_value) < 2:
        raise ValidationError("Description must be at least 2 characters long.")
    if len(cleaned_value) > 500:
        raise ValidationError("Description must not exceed 500 characters.")

class TaskResponseSchema(Schema):
    id = fields.String()
    title = fields.String()
    description = fields.String()
    points = fields.Integer()
    task_frequency = fields.String()
    recurrence_day = fields.Integer(allow_none=True)
    category = fields.String()
    is_auto_verified = fields.Boolean()
    created_by = fields.String()
    created_at = fields.DateTime()

class TaskCreateSchema(Schema):
    child_ids = fields.List(fields.String(), required=True, validate=validate.Length(min=1))
    title = fields.String(required=True, validate=validate_task_title)
    description = fields.String(required=True, validate=validate_task_description)
    points = fields.Integer(required=True, validate=validate.Range(min=1, max=100))
    task_frequency = fields.String(required=False, load_default="ONCE", validate=validate.OneOf(TASK_FREQUENCIES))
    recurrence_day = fields.Integer(required=False, allow_none=True)
    category = fields.String(required=True, validate=validate.OneOf(TASK_CATEGORIES))
    is_auto_verified = fields.Boolean(required=False, load_default=False)

    @validates_schema
    def validate_recurrence_day(self, data, **kwargs):
        task_frequency = data.get("task_frequency", "ONCE")
        recurrence_day = data.get("recurrence_day")
        if (task_frequency in {"ONCE", "DAILY"} and recurrence_day is not None):
            raise ValidationError({
                "recurrence_day": [
                    "recurrence_day is only allowed for "
                    "WEEKLY or MONTHLY tasks."
                ]
            })
        if task_frequency == "WEEKLY":
            if recurrence_day is None:
                raise ValidationError({
                    "recurrence_day": [
                        "recurrence_day is required for WEEKLY tasks."
                    ]
                })
            if not 0 <= recurrence_day <= 6:
                raise ValidationError({
                    "recurrence_day": [
                        "For WEEKLY tasks, recurrence_day "
                        "must be between 0 and 6."
                    ]
                })
        if task_frequency == "MONTHLY":
            if recurrence_day is None:
                raise ValidationError({
                    "recurrence_day": [
                        "recurrence_day is required for MONTHLY tasks."
                    ]
                })
            if not 1 <= recurrence_day <= 31:
                raise ValidationError({
                    "recurrence_day": [
                        "For MONTHLY tasks, recurrence_day "
                        "must be between 1 and 31."
                    ]
                })

class TaskUpdateSchema(Schema):
    title = fields.String(required=False, validate=validate_task_title)
    description = fields.String(required=False, validate=validate_task_description)
    points = fields.Integer(required=False, validate=validate.Range(min=1, max=100))
    task_frequency = fields.String(required=False, validate=validate.OneOf(TASK_FREQUENCIES))
    recurrence_day = fields.Integer(required=False, allow_none=True)
    category = fields.String(required=False, validate=validate.OneOf(TASK_CATEGORIES))
    is_auto_verified = fields.Boolean(required=False)
        
    @validates_schema
    def validate_at_least_one_field(self, data, **kwargs):
        if not data:
            raise ValidationError(
                "At least one field must be provided."
            )