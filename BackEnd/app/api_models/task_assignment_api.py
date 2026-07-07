from flask_restx import fields


def get_task_assignment_models(api):
    task_model = api.model("TaskAssignmentTask", {
        "id": fields.String(description="Task ID"),
        "title": fields.String(description="Task title"),
        "description": fields.String(description="Task description"),
        "points": fields.Integer(description="Task points"),
        "task_frequency": fields.String(description="ONCE, DAILY, WEEKLY, or MONTHLY"),
        "recurrence_day": fields.Integer(description="Recurrence day"),
        "category": fields.String(description="Task category"),
        "is_auto_verified": fields.Boolean(description="Auto verified")
    })

    child_model = api.model("TaskAssignmentChild", {
        "id": fields.String(description="Child ID"),
        "name": fields.String(description="Child name"),
        "age": fields.Integer(description="Child age")
    })

    assignment_response_model = api.model("TaskAssignmentResponse", {
        "id": fields.String(description="Assignment ID"),
        "status": fields.String(description="PENDING, PENDING_REVIEW, APPROVED, or REJECTED"),
        "completed_at": fields.DateTime(description="Completed date"),
        "approved_at": fields.DateTime(description="Approved date"),
        "assigned_date": fields.Date(description="Assigned date"),
        "task": fields.Nested(task_model),
        "child": fields.Nested(child_model)
    })

    return assignment_response_model