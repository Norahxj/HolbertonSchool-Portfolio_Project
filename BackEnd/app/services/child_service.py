from app.extensions import db
from app.models.child_model import Child


class ChildService:

    def validate_child_data(self, child_data, partial=False):
        name = child_data.get("name")
        age = child_data.get("age")

        if not partial or name is not None:
            if not name or len(name.strip()) < 2:
                return "Child name must be at least 2 characters"

            if len(name.strip()) > 100:
                return "Child name must not exceed 100 characters"

            child_data["name"] = name.strip()

        if not partial or age is not None:
            if age is None:
                return "Child age is required"

            if not isinstance(age, int):
                return "Child age must be a number"

            if age < 1 or age > 18:
                return "Child age must be between 1 and 18"

        return None

    def create_child(self, child_data):
        error = self.validate_child_data(child_data)

        if error:
            return None, error

        child = Child(**child_data)
        db.session.add(child)
        db.session.commit()

        return child, None

    def get_children_by_parent(self, parent_id):
        return Child.query.filter_by(parent_id=parent_id).all()

    def get_child_for_parent(self, child_id, parent_id):
        return Child.query.filter_by(id=child_id, parent_id=parent_id).first()

    def update_child_for_parent(self, child_id, parent_id, child_data):
        child = self.get_child_for_parent(child_id, parent_id)

        if not child:
            return None, None

        error = self.validate_child_data(child_data, partial=True)

        if error:
            return None, error

        if "name" in child_data:
            child.name = child_data["name"]

        if "age" in child_data:
            child.age = child_data["age"]

        db.session.commit()
        return child, None

    def delete_child_for_parent(self, child_id, parent_id):
        child = self.get_child_for_parent(child_id, parent_id)

        if not child:
            return None

        db.session.delete(child)
        db.session.commit()
        return child