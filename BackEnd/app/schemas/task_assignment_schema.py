from marshmallow import Schema, fields

class AssignmentTaskSchema(Schema):
    id = fields.String()
    title = fields.String()
    description = fields.String()
    points = fields.Integer()
    task_frequency = fields.String()
    recurrence_day = fields.Integer(allow_none=True)
    category = fields.String()
    is_auto_verified = fields.Boolean()

class AssignmentChildSchema(Schema):
    id = fields.String()
    name = fields.String()
    age = fields.Integer()

class ChildTaskAssignmentResponseSchema(Schema):
    id = fields.String()
    status = fields.String()
    completed_at = fields.DateTime(allow_none=True)
    approved_at = fields.DateTime(allow_none=True)
    task = fields.Nested(AssignmentTaskSchema)
    assigned_date = fields.Date()

class ParentTaskAssignmentResponseSchema(Schema):
    id = fields.String()
    status = fields.String()
    completed_at = fields.DateTime(allow_none=True)
    approved_at = fields.DateTime(allow_none=True)
    task = fields.Nested(AssignmentTaskSchema)
    child = fields.Nested(AssignmentChildSchema)
    assigned_date = fields.Date()