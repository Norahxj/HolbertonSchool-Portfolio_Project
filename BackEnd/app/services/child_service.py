import random
from sqlalchemy.exc import IntegrityError
from app.extensions import db
from app.models.child_model import Child
from app.models.user_model import User


class ChildService:

    def generate_access_code(self):
        while True:
            access_code = str(random.randint(100000, 999999))
            existing_child = Child.query.filter_by(access_code=access_code).first()
            if not existing_child:
                return access_code

    def create_child(self, parent_id, child_data):
        parent = db.session.get(User, parent_id)
        if not parent:
            return None, "parent_not_found"
        child = Child(
            name=child_data["name"].strip(),
            age=child_data["age"],
            access_code=self.generate_access_code()
        )
        child.guardians.append(parent)
        try:
            db.session.add(child)
            db.session.commit()
        except IntegrityError:
            db.session.rollback()
            return None, "access_code_exists"
        return child, None

    def get_children_by_parent(self, parent_id):
        parent = db.session.get(User, parent_id)
        if not parent:
            return []
        return parent.children
    
    def get_child_for_parent(self, child_id, parent_id):
        return (
            Child.query
            .join(Child.guardians)
            .filter(Child.id == child_id, User.id == parent_id)
            .first()
        )

    def update_child_for_parent(self, child_id, parent_id, child_data):
        child = self.get_child_for_parent(child_id, parent_id)
        if not child:
            return None, "not_found"
        if "name" in child_data:
            child.name = child_data["name"].strip()
        if "age" in child_data:
            child.age = child_data["age"]
        try:
            db.session.commit()
        except IntegrityError:
            db.session.rollback()
            return None, "update_failed"
        return child, None

    def delete_child_for_parent(self, child_id, parent_id):
        child = self.get_child_for_parent(child_id, parent_id)
        if not child:
            return None
        db.session.delete(child)
        db.session.commit()
        return True