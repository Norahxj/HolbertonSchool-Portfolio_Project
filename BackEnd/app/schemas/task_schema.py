from marshmallow import Schema, fields, validate, validates, ValidationError, validates_schema

class TaskResponseSchema(Schema):
    id = fields.String()
    title = fields.String()
    description = fields.String()
    points = fields.Integer()
    task_frequency = fields.String()
    recurrence_day = fields.Integer(allow_none=True)
    category = fields.String(allow_none=True)
    is_auto_verified = fields.Boolean()
    created_by = fields.String()
    created_at = fields.DateTime()

class TaskCreateSchema(Schema):
    child_ids = fields.List(
        fields.String(),
        required=True,
        validate=validate.Length(min=1)
    )
    title = fields.String(required=True, validate=validate.Length(min=2, max=100))
    description = fields.String(required=True, validate=validate.Length(min=2, max=500))
    points = fields.Integer(required=True, validate=validate.Range(min=1, max=100))
    task_frequency = fields.String(
        required=False,
        load_default="ONCE",
        validate=validate.OneOf(["ONCE", "DAILY", "WEEKLY", "MONTHLY"])
    )
    recurrence_day = fields.Integer(required=False, allow_none=True)
    category = fields.String(required=True,validate=validate.OneOf(["RELIGIOUS", "FINANCIAL", "MORAL", "SOCIAL"]))
    is_auto_verified = fields.Boolean(required=False, load_default=False)

    @validates("title")
    def validate_title(self, value, **kwargs):
        if not value.strip():
            raise ValidationError("Title cannot be empty.")

    @validates("description")
    def validate_description(self, value, **kwargs):
        if not value.strip():
            raise ValidationError("Description cannot be empty.")

    @validates_schema
    def validate_recurrence_day(self, data, **kwargs):
        task_frequency = data.get("task_frequency")
        recurrence_day = data.get("recurrence_day")
        if task_frequency in ["ONCE", "DAILY"] and recurrence_day is not None:
            raise ValidationError({"recurrence_day": ["recurrence_day is only allowed for WEEKLY or MONTHLY tasks."]})
        if task_frequency == "WEEKLY":
            if recurrence_day is None:
                raise ValidationError({"recurrence_day": ["recurrence_day is required for WEEKLY tasks."]})
            if recurrence_day < 0 or recurrence_day > 6:
                raise ValidationError({"recurrence_day": ["For WEEKLY tasks, recurrence_day must be between 0 and 6."]})
        if task_frequency == "MONTHLY":
            if recurrence_day is None:
                raise ValidationError({"recurrence_day": ["recurrence_day is required for MONTHLY tasks."]})
            if recurrence_day < 1 or recurrence_day > 31:
                raise ValidationError({"recurrence_day": ["For MONTHLY tasks, recurrence_day must be between 1 and 31."]})

class TaskUpdateSchema(Schema):
    title = fields.String(required=False, validate=validate.Length(min=2, max=100))
    description = fields.String(required=False, validate=validate.Length(min=2, max=500))
    points = fields.Integer(required=False, validate=validate.Range(min=1, max=100))
    task_frequency = fields.String(required=False, validate=validate.OneOf(["ONCE", "DAILY", "WEEKLY", "MONTHLY"]))
    recurrence_day = fields.Integer(required=False, allow_none=True)
    category = fields.String(required=False, validate=validate.OneOf(["RELIGIOUS", "FINANCIAL", "MORAL", "SOCIAL"]))
    is_auto_verified = fields.Boolean(required=False)

    @validates("title")
    def validate_title(self, value, **kwargs):
        if not value.strip():
            raise ValidationError("Title cannot be empty.")

    @validates("description")
    def validate_description(self, value, **kwargs):
        if not value.strip():
            raise ValidationError("Description cannot be empty.")
        
    @validates_schema
    def validate_recurrence_day(self, data, **kwargs):
        task_frequency = data.get("task_frequency")
        recurrence_day = data.get("recurrence_day")
        if task_frequency in ["ONCE", "DAILY"] and recurrence_day is not None:
            raise ValidationError({"recurrence_day": ["recurrence_day is only allowed for WEEKLY or MONTHLY tasks."]})
        if task_frequency == "WEEKLY":
            if recurrence_day is None:
                raise ValidationError({"recurrence_day": ["recurrence_day is required for WEEKLY tasks."]})
            if recurrence_day < 0 or recurrence_day > 6:
                raise ValidationError({"recurrence_day": ["For WEEKLY tasks, recurrence_day must be between 0 and 6."]})
        if task_frequency == "MONTHLY":
            if recurrence_day is None:
                raise ValidationError({"recurrence_day": ["recurrence_day is required for MONTHLY tasks."]})
            if recurrence_day < 1 or recurrence_day > 31:
                raise ValidationError({"recurrence_day": ["For MONTHLY tasks, recurrence_day must be between 1 and 31."]})