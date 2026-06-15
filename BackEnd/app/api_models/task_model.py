from flask_restx import fields

def get_task_models(api):
    """
    Define API request/response models for Task endpoints using Flask-RESTX.
    These models are used for request validation and documentation in Swagger.
    """
    
    task_model = api.model("Task", {
        "child_id": fields.String(required=True, description="ID of the child"),
        "title": fields.String(required=True, description="Task title"),
        "description": fields.String(required=True, description="Task description"),
        "points": fields.Integer(required=True, description="Points for completing the task"),
        "task_type": fields.String(required=True, enum=["ONCE", "DAILY", "WEEKLY"], description="Type of task"),
        "recurrence_day": fields.Integer(description="Day of week for weekly tasks (0-6, 0=Monday, 4=Friday)"),
        "category": fields.String(description="Task category (Daily Chores, Culture, Financial, Religion)"),
        "is_auto_verified": fields.Boolean(description="Is the task auto-verified or manually verified"),
        "verification_type": fields.String(enum=["AUTO", "MANUAL"], description="Verification type"),
        "created_by": fields.String(required=True, description="ID of the user who created the task")
    })

    task_update_model = api.model("TaskUpdate", {
        "title": fields.String(description="Task title"),
        "description": fields.String(description="Task description"),
        "points": fields.Integer(description="Points for completing the task"),
        "task_type": fields.String(enum=["ONCE", "DAILY", "WEEKLY"], description="Type of task"),
        "recurrence_day": fields.Integer(description="Day of week for weekly tasks"),
        "category": fields.String(description="Task category"),
        "is_auto_verified": fields.Boolean(description="Is the task auto-verified"),
        "verification_type": fields.String(enum=["AUTO", "MANUAL"], description="Verification type")
    })

    task_status_model = api.model("TaskStatus", {
        "status": fields.String(required=True, enum=["PENDING", "APPROVED", "REJECTED"], 
                               description="New status of the task")
    })

    # Daily Feedback models
    daily_feedback_model = api.model("DailyFeedback", {
        "child_id": fields.String(required=True, description="ID of the child"),
        "feedback_date": fields.String(required=True, description="Date for feedback (YYYY-MM-DD)"),
        "emoji_value": fields.Integer(required=True, enum=[1, 2, 3], 
                                     description="Emoji value (1=Happy😊, 2=Neutral😐, 3=Sad😢)"),
        "feedback_text": fields.String(description="Optional feedback text"),
        "created_by": fields.String(required=True, description="ID of the parent")
    })

    daily_feedback_update_model = api.model("DailyFeedbackUpdate", {
        "emoji_value": fields.Integer(enum=[1, 2, 3], description="Emoji value"),
        "feedback_text": fields.String(description="Feedback text")
    })
    
    return task_model, task_update_model, task_status_model, daily_feedback_model, daily_feedback_update_model
