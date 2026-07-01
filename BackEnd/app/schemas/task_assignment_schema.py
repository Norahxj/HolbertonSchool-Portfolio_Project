from marshmallow import Schema, fields

class AssignmentTaskSchema(Schema):
    id = fields.String()
    title = fields.String()
    description = fields.String()
    points = fields.Integer()
    task_frequency = fields.String()
    recurrence_day = fields.Integer(allow_none=True)
    category = fields.String(allow_none=True)
    is_auto_verified = fields.Boolean()

class AssignmentChildSchema(Schema):
    id = fields.String()
    name = fields.String()
    age = fields.Integer()

class TaskAssignmentResponseSchema(Schema):
    id = fields.String()
    task_id = fields.String()
    child_id = fields.String()
    status = fields.String()
    completed_at = fields.DateTime(allow_none=True)
    approved_at = fields.DateTime(allow_none=True)
    task = fields.Nested(AssignmentTaskSchema)
    child = fields.Nested(AssignmentChildSchema)