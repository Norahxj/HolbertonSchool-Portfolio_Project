from app.extensions import db
from app.models.child_model import Child


class ChildService:

    def create_child(self, parent_id, child_data):
        child = Child(
            name=child_data["name"].strip(),
            age=child_data["age"],
            parent_id=parent_id
        )

        db.session.add(child)
        db.session.commit()

        return child

    def get_children_by_parent(self, parent_id):
        return Child.query.filter_by(parent_id=parent_id).all()

    def get_child_for_parent(self, child_id, parent_id):
        return Child.query.filter_by(id=child_id, parent_id=parent_id).first()

    def update_child_for_parent(self, child_id, parent_id, child_data):
        child = self.get_child_for_parent(child_id, parent_id)

        if not child:
            return None

        if "name" in child_data:
            child.name = child_data["name"].strip()

        if "age" in child_data:
            child.age = child_data["age"]

        db.session.commit()
        return child

    def delete_child_for_parent(self, child_id, parent_id):
        child = self.get_child_for_parent(child_id, parent_id)

        if not child:
            return None

        db.session.delete(child)
        db.session.commit()
        return True