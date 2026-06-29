from marshmallow import Schema, fields, validate, validates, ValidationError, validates_schema


class TaskResponseSchema(Schema):
    id = fields.String()
    title = fields.String()
    description = fields.String()
    child_id = fields.String()
    points = fields.Integer()
    status = fields.String()
    task_type = fields.String()
    recurrence_day = fields.Integer(allow_none=True)
    category = fields.String(allow_none=True)
    is_auto_verified = fields.Boolean()
    verification_type = fields.String()
    approved_at = fields.DateTime(allow_none=True)
    created_at = fields.DateTime()


class TaskCreateSchema(Schema):
    child_id = fields.String(required=True)

    title = fields.String(required=True, validate=validate.Length(min=2, max=100))
    description = fields.String(required=True, validate=validate.Length(min=2, max=500))
    points = fields.Integer(required=True, validate=validate.Range(min=1, max=100))

    task_type = fields.String(
        required=False,
        load_default="ONCE",
        validate=validate.OneOf(["ONCE", "DAILY", "WEEKLY"])
    )

    recurrence_day = fields.Integer(
        required=False,
        allow_none=True,
        validate=validate.Range(min=0, max=6)
    )

    category = fields.String(required=False, allow_none=True, validate=validate.Length(max=50))

    is_auto_verified = fields.Boolean(required=False, load_default=False)

    verification_type = fields.String(
        required=False,
        load_default="MANUAL",
        validate=validate.OneOf(["AUTO", "MANUAL"])
    )

    @validates("title")
    def validate_title(self, value, **kwargs):
        if not value.strip():
            raise ValidationError("Title cannot be empty.")

    @validates("description")
    def validate_description(self, value, **kwargs):
        if not value.strip():
            raise ValidationError("Description cannot be empty.")
        
    @validates_schema
    def validate_weekly_task(self, data, **kwargs):
        if data.get("task_type") == "WEEKLY" and data.get("recurrence_day") is None:
            raise ValidationError({
                "recurrence_day": ["recurrence_day is required for WEEKLY tasks."]
            })


class TaskUpdateSchema(Schema):
    title = fields.String(required=False, validate=validate.Length(min=2, max=100))
    description = fields.String(required=False, validate=validate.Length(min=2, max=500))
    points = fields.Integer(required=False, validate=validate.Range(min=1, max=100))

    task_type = fields.String(required=False, validate=validate.OneOf(["ONCE", "DAILY", "WEEKLY"]))
    recurrence_day = fields.Integer(required=False, allow_none=True, validate=validate.Range(min=0, max=6))
    category = fields.String(required=False, allow_none=True, validate=validate.Length(max=50))

    is_auto_verified = fields.Boolean(required=False)
    verification_type = fields.String(required=False, validate=validate.OneOf(["AUTO", "MANUAL"]))

    @validates("title")
    def validate_title(self, value, **kwargs):
        if not value.strip():
            raise ValidationError("Title cannot be empty.")

    @validates("description")
    def validate_description(self, value, **kwargs):
        if not value.strip():
            raise ValidationError("Description cannot be empty.")
        
    @validates_schema
    def validate_weekly_task(self, data, **kwargs):
        if data.get("task_type") == "WEEKLY" and data.get("recurrence_day") is None:
            raise ValidationError({
                "recurrence_day": ["recurrence_day is required for WEEKLY tasks."]
            })