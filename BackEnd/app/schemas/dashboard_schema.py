from marshmallow import Schema, fields

class ChildDashboardResponseSchema(Schema):
    child_id = fields.String()
    child_name = fields.String()
    child_age = fields.Integer()
    week_start = fields.Date()
    week_end = fields.Date()
    progress_percentage = fields.Float()
    completed_tasks = fields.Integer()
    approved_tasks = fields.Integer()
    pending_review_tasks = fields.Integer()
    pending_tasks = fields.Integer()
    rejected_tasks = fields.Integer()
    remaining_tasks = fields.Integer()
    total_tasks = fields.Integer()