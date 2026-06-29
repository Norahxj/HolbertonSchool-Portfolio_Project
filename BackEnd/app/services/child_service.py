from sqlalchemy.exc import IntegrityError
from app.extensions import db, bcrypt
from app.models.child_model import Child


class ChildService:

    def create_child(self, parent_id, child_data):
        child = Child(
            name=child_data["name"].strip(),
            age=child_data["age"],
            email=child_data["email"].strip().lower(),
            password_hash=bcrypt.generate_password_hash(child_data["password"]).decode("utf-8"),
            parent_id=parent_id
        )

        try:
            db.session.add(child)
            db.session.commit()
        except IntegrityError:
            db.session.rollback()
            return None, "email_exists"

        return child, None

    def get_children_by_parent(self, parent_id):
        return Child.query.filter_by(parent_id=parent_id).all()

    def get_child_for_parent(self, child_id, parent_id):
        return Child.query.filter_by(id=child_id, parent_id=parent_id).first()

    def update_child_for_parent(self, child_id, parent_id, child_data):
        child = self.get_child_for_parent(child_id, parent_id)

        if not child:
            return None, "not_found"

        if "name" in child_data:
            child.name = child_data["name"].strip()

        if "age" in child_data:
            child.age = child_data["age"]

        if "email" in child_data:
            email = child_data["email"].strip().lower()

            existing_child = Child.query.filter_by(email=email).first()

            if existing_child and str(existing_child.id) != str(child_id):
                return None, "email_exists"

            child.email = email
            
        if "password" in child_data:
            child.password_hash = bcrypt.generate_password_hash(
                child_data["password"]
            ).decode("utf-8")

        try:
            db.session.commit()
        except IntegrityError:
            db.session.rollback()
            return None, "email_exists"

        return child, None

    def delete_child_for_parent(self, child_id, parent_id):
        child = self.get_child_for_parent(child_id, parent_id)

        if not child:
            return None

        db.session.delete(child)
        db.session.commit()
        return True