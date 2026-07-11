from app.extensions import db
from app.models.child_model import Child, child_guardians
from app.models.user_model import User
from sqlalchemy.exc import IntegrityError

class ChildRepository:

    def get_child_by_id(self, child_id):
        return db.session.get(Child, child_id)
    
    def get_child_by_access_code(self, access_code):
        return Child.query.filter_by(access_code=access_code).first()
    
    def create_child(self, child):
        try:
            db.session.add(child)
            db.session.commit()
            return child, None
        except IntegrityError:
            db.session.rollback()
            return None, "integrity_error"
    
    def update_child(self):
        try:
            db.session.commit()
            return True, None
        except IntegrityError:
            db.session.rollback()
            return False, "integrity_error"
    
    def delete_child(self, child):
        try:
            db.session.delete(child)
            db.session.commit()
            return True, None
        except Exception:
            db.session.rollback()
            return False, "delete_error"
    
    def get_children_by_guardian(self, guardian):
        return guardian.children
    
    def get_child_for_guardian(self, child_id, guardian_id):
        return (
            Child.query
            .join(Child.guardians)
            .filter(Child.id == child_id, User.id == guardian_id)
            .first()
        )