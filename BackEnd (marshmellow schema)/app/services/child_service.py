# Import necessary modules
from app.extensions import db
from app.models.child_model import Child
from app.exceptions.api_exceptions import NotFoundError, ValidationError, ConflictError, ForbiddenError
from app.schemas.child_schema import ChildSchema
from uuid import uuid4

# Initialize Marshmallow schemas
# Ensure the parent_id in data matches the authenticated parent_id, then Retrieve all children belonging to a specific parent
# Create a new Child instance then Update child attributes
child_schema = ChildSchema()
children_schema = ChildSchema(many=True)

class ChildService:
    @staticmethod
    def create_child(parent_id, data):
      
        errors = child_schema.validate(data)
        if errors:
            raise ValidationError("Validation failed for child creation", errors)

        if data["parent_id"] != parent_id:
            raise ForbiddenError("Cannot create child for another parent.")

        if Child.query.filter_by(parent_id=parent_id, name=data["name"]).first():
            raise ConflictError("Child with this name already exists for this parent.")

        child = Child(id=str(uuid4()), **data)
        db.session.add(child)
        db.session.commit()
        return child_schema.dump(child)
      
    @staticmethod
    def get_parent_children(parent_id):
      
        children = Child.query.filter_by(parent_id=parent_id).all()
        return children_schema.dump(children)

    @staticmethod
    def get_child_by_id(parent_id, child_id):
      
        child = Child.query.filter_by(id=child_id, parent_id=parent_id).first()
        if not child:
            raise NotFoundError(f"Child with ID {child_id} not found or does not belong to parent.")
        return child_schema.dump(child)

    @staticmethod
    def update_child(parent_id, child_id, data):
    
        child = Child.query.filter_by(id=child_id, parent_id=parent_id).first()
        if not child:
            raise NotFoundError(f"Child with ID {child_id} not found or does not belong to parent.")

        errors = child_schema.validate(data, partial=True)
        if errors:
            raise ValidationError("Validation failed for child update", errors)

        for key, value in data.items():
            setattr(child, key, value)
        db.session.commit()
        return child_schema.dump(child)

    @staticmethod
    def delete_child(parent_id, child_id):

        child = Child.query.filter_by(id=child_id, parent_id=parent_id).first()
        if not child:
            raise NotFoundError(f"Child with ID {child_id} not found or does not belong to parent.")

        db.session.delete(child)
        db.session.commit()
        return {"message": "Child deleted successfully"}
