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
        "created_by": fields.String(required=True, description="ID of the user who created the task")
    })

    task_update_model = api.model("TaskUpdate", {
        "title": fields.String(description="Task title"),
        "description": fields.String(description="Task description"),
        "points": fields.Integer(description="Points for completing the task")
    })

    task_status_model = api.model("TaskStatus", {
        "status": fields.String(required=True, enum=["PENDING", "APPROVED", "REJECTED"], 
                               description="New status of the task")
    })
    
    return task_model, task_update_model, task_status_model
