from flask_restx import fields

def get_task_models(api):
    task_create_model = api.model("TaskCreate", {
        "child_ids": fields.List(
            fields.String,
            required=True,
            description="List of child IDs"
        ),
        "title": fields.String(required=True, description="Task title"),
        "description": fields.String(required=True, description="Task description"),
        "points": fields.Integer(required=True, description="Points"),
        "task_frequency": fields.String(description="ONCE, DAILY, WEEKLY, or MONTHLY"),
        "recurrence_day": fields.Raw(description="0-6 for weekly, 1-31 for monthly"),
        "category": fields.String(description="RELIGIOUS, FINANCIAL, MORAL, or SOCIAL"),
        "is_auto_verified": fields.Boolean(description="Auto verified")
    })

    task_update_model = api.model("TaskUpdate", {
        "title": fields.String(description="Task title"),
        "description": fields.String(description="Task description"),
        "points": fields.Integer(description="Points"),
        "task_frequency": fields.String(description="ONCE, DAILY, WEEKLY, or MONTHLY"),
        "recurrence_day": fields.Raw(description="0-6 for weekly, 1-31 for monthly"),
        "category": fields.String(description="RELIGIOUS, FINANCIAL, MORAL, or SOCIAL"),
        "is_auto_verified": fields.Boolean(description="Auto verified")
    })

    return task_create_model, task_update_model