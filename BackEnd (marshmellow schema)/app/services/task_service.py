from app.extensions import db
from app.models.task_models import TaskCategory, SuggestedTask, ParentCustomTask
from app.models.gamification_models import ChildTask, TaskStatus
from app.models.child_model import Child
from app.exceptions.api_exceptions import NotFoundError, ValidationError, ConflictError, ForbiddenError
from app.schemas.task_schemas import TaskCategorySchema, SuggestedTaskSchema, ParentCustomTaskSchema
from app.schemas.gamification_schemas import ChildTaskSchema
from uuid import uuid4
from datetime import datetime

#schema
task_category_schema = TaskCategorySchema()
task_categories_schema = TaskCategorySchema(many=True)
suggested_task_schema = SuggestedTaskSchema()
suggested_tasks_schema = SuggestedTaskSchema(many=True)
parent_custom_task_schema = ParentCustomTaskSchema()
parent_custom_tasks_schema = ParentCustomTaskSchema(many=True)
child_task_schema = ChildTaskSchema()
child_tasks_schema = ChildTaskSchema(many=True)

class TaskService:
   # Task Category Management, validate input by checking if a category with same language ar en exist
  # Create a new TaskCategory instance. then retrive all task categories from the database, then retrive by id 

    @staticmethod
    def create_task_category(data):

        errors = task_category_schema.validate(data)
        if errors:
            raise ValidationError("Validation failed for task category creation", errors)

        if TaskCategory.query.filter((TaskCategory.name_en == data["name_en"]) | (TaskCategory.name_ar == data["name_ar"])).first():
            raise ConflictError("Task category with this name already exists.")

        category = TaskCategory(id=str(uuid4()), **data)
        db.session.add(category)
        db.session.commit()
        return task_category_schema.dump(category)

    @staticmethod
    def get_all_task_categories():
    
        categories = TaskCategory.query.all()
        return task_categories_schema.dump(categories)

    @staticmethod
    def get_task_category_by_id(category_id):
   
        category = TaskCategory.query.get(category_id)
        if not category:
            raise NotFoundError(f"Task category with ID {category_id} not found.")
        return task_category_schema.dump(category)

    # Suggested Task Management: Validate input then check if the category exists, if not create a new SuggestedTask instance and add it to the database

    @staticmethod
    def create_suggested_task(data):
    
        errors = suggested_task_schema.validate(data)
        if errors:
            raise ValidationError("Validation failed for suggested task creation", errors)

    
        if not TaskCategory.query.get(data["category_id"]):
            raise NotFoundError(f"Task category with ID {data['category_id']} not found.")

    
        task = SuggestedTask(id=str(uuid4()), **data)
        db.session.add(task)
        db.session.commit()
        return suggested_task_schema.dump(task)

    @staticmethod
    def get_suggested_tasks(category_id=None, min_age=None, max_age=None):
        # Build query for suggested tasks, optionally filtering by category and age #### need to vote on this one
        query = SuggestedTask.query
        if category_id:
            query = query.filter_by(category_id=category_id)
        if min_age is not None:
            query = query.filter(SuggestedTask.min_age <= max_age)
        if max_age is not None:
            query = query.filter(SuggestedTask.max_age >= min_age)
        tasks = query.all()
        return suggested_tasks_schema.dump(tasks)

    @staticmethod
    def get_suggested_task_by_id(task_id):
  
        task = SuggestedTask.query.get(task_id)
        if not task:
            raise NotFoundError(f"Suggested task with ID {task_id} not found.")
        return suggested_task_schema.dump(task)
      
    # --- Parent Custom Task Management ---

    @staticmethod
    def create_parent_custom_task(parent_id, data):
    
        errors = parent_custom_task_schema.validate(data)
        if errors:
            raise ValidationError("Validation failed for custom task creation", errors)

    
        if data["parent_id"] != parent_id:
            raise ForbiddenError("Cannot create custom task for another parent.")

     
        if not TaskCategory.query.get(data["category_id"]):
            raise NotFoundError(f"Task category with ID {data['category_id']} not found.")

      
        task = ParentCustomTask(id=str(uuid4()), **data)
        db.session.add(task)
        db.session.commit()
        return parent_custom_task_schema.dump(task)

    @staticmethod
    def get_parent_custom_tasks(parent_id):
    
        tasks = ParentCustomTask.query.filter_by(parent_id=parent_id).all()
        return parent_custom_tasks_schema.dump(tasks)

    @staticmethod
    def get_parent_custom_task_by_id(parent_id, task_id):
    
        task = ParentCustomTask.query.filter_by(id=task_id, parent_id=parent_id).first()
        if not task:
            raise NotFoundError(f"Custom task with ID {task_id} not found or does not belong to parent.")
        return parent_custom_task_schema.dump(task)

    @staticmethod
    def update_parent_custom_task(parent_id, task_id, data):
    
        task = ParentCustomTask.query.filter_by(id=task_id, parent_id=parent_id).first()
        if not task:
            raise NotFoundError(f"Custom task with ID {task_id} not found or does not belong to parent.")

    
        errors = parent_custom_task_schema.validate(data, partial=True)
        if errors:
            raise ValidationError("Validation failed for custom task update", errors)

        # Update task attributes
        for key, value in data.items():
            setattr(task, key, value)
        db.session.commit() 
        return parent_custom_task_schema.dump(task)

    @staticmethod
    def delete_parent_custom_task(parent_id, task_id):

        task = ParentCustomTask.query.filter_by(id=task_id, parent_id=parent_id).first()
        if not task:
            raise NotFoundError(f"Custom task with ID {task_id} not found or does not belong to parent.")

        db.session.delete(task)
        db.session.commit()
        return {"message": "Custom task deleted successfully"}

  ## Child Task Assignment and Management: making sure only ONE of those two is provided(suggested_task_id or parent_custom_task_id)
  ## then make sure that the suggested task belong to the parent 
  ## status_enum: is the daily feedback if satusfied or not

    @staticmethod
    def assign_task_to_child(parent_id, child_id, data):
    
        errors = child_task_schema.validate(data)
        if errors:
            raise ValidationError("Validation failed for child task assignment", errors)

    
        child = Child.query.filter_by(id=child_id, parent_id=parent_id).first()
        if not child:
            raise NotFoundError(f"Child with ID {child_id} not found or does not belong to parent.")

    
        if not (data.get("suggested_task_id") or data.get("parent_custom_task_id")):
            raise ValidationError("Either suggested_task_id or parent_custom_task_id must be provided.")
        if data.get("suggested_task_id") and data.get("parent_custom_task_id"):
            raise ValidationError("Cannot assign both a suggested and a custom task simultaneously.")

      
        if data.get("suggested_task_id") and not SuggestedTask.query.get(data["suggested_task_id"]):
            raise NotFoundError(f"Suggested task with ID {data['suggested_task_id']} not found.")

     
        if data.get("parent_custom_task_id"):
            custom_task = ParentCustomTask.query.filter_by(id=data["parent_custom_task_id"], parent_id=parent_id).first()
            if not custom_task:
                raise NotFoundError(f"Custom task with ID {data['parent_custom_task_id']} not found or does not belong to parent.")

        child_task = ChildTask(id=str(uuid4()), child_id=child_id, **data)
        db.session.add(child_task)
        db.session.commit()
        return child_task_schema.dump(child_task)

    @staticmethod
    def get_child_tasks(child_id, status=None):
    
        query = ChildTask.query.filter_by(child_id=child_id)
        if status:
            try:
                task_status = TaskStatus[status.upper()]
                query = query.filter_by(status=task_status)
            except KeyError:
                raise ValidationError(f"Invalid task status: {status}")
        tasks = query.all()
        return child_tasks_schema.dump(tasks)

    @staticmethod
    def get_child_task_by_id(child_id, task_id):
    
        task = ChildTask.query.filter_by(id=task_id, child_id=child_id).first()
        if not task:
            raise NotFoundError(f"Task with ID {task_id} not found for child {child_id}.")
        return child_task_schema.dump(task)

    @staticmethod
    def update_child_task_status(child_id, task_id, new_status):

        task = ChildTask.query.filter_by(id=task_id, child_id=child_id).first()
        if not task:
            raise NotFoundError(f"Task with ID {task_id} not found for child {child_id}.")


        try:
            status_enum = TaskStatus[new_status.upper()]
        except KeyError:
            raise ValidationError(f"Invalid status: {new_status}. Must be one of {', '.join([s.value for s in TaskStatus])}")

    
        task.status = status_enum
        if status_enum == TaskStatus.COMPLETED:
            task.completion_date = datetime.utcnow()
        elif status_enum == TaskStatus.VERIFIED:
            task.verification_date = datetime.utcnow()
      

        db.session.commit()
        return child_task_schema.dump(task)

    @staticmethod
    def delete_child_task(parent_id, child_id, task_id):
 
        child = Child.query.filter_by(id=child_id, parent_id=parent_id).first()
        if not child:
            raise NotFoundError(f"Child with ID {child_id} not found or does not belong to parent.")

  
        task = ChildTask.query.filter_by(id=task_id, child_id=child_id).first()
        if not task:
            raise NotFoundError(f"Task with ID {task_id} not found for child {child_id}.")

        db.session.delete(task)
        db.session.commit()
        return {"message": "Child task deleted successfully"}
