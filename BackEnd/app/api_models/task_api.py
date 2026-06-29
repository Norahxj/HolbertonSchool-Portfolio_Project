from flask_restx import fields


def get_task_models(api):
    task_create_model = api.model("TaskCreate", {
        "child_id": fields.String(required=True, description="Child ID"),
        "title": fields.String(required=True, description="Task title"),
        "description": fields.String(required=True, description="Task description"),
        "points": fields.Integer(required=True, description="Points"),
        "task_type": fields.String(description="ONCE, DAILY, or WEEKLY"),
        "recurrence_day": fields.Integer(description="0-6 for weekly tasks"),
        "category": fields.String(description="Task category"),
        "is_auto_verified": fields.Boolean(description="Auto verified")
        })

    task_update_model = api.model("TaskUpdate", {
        "title": fields.String(description="Task title"),
        "description": fields.String(description="Task description"),
        "points": fields.Integer(description="Points"),
        "task_type": fields.String(description="ONCE, DAILY, or WEEKLY"),
        "recurrence_day": fields.Integer(description="0-6 for weekly tasks"),
        "category": fields.String(description="Task category"),
        "is_auto_verified": fields.Boolean(description="Auto verified")
    })

    return task_create_model, task_update_model