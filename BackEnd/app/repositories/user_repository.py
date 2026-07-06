from sqlalchemy.exc import IntegrityError
from app.extensions import db
from app.models.user_model import User

class UserRepository:
    def get_user_by_id(self, user_id):
        return db.session.get(User, user_id)
    
    def get_user_by_email(self, email):
        return User.query.filter_by(email=email).first()
    
    def get_user_by_phone(self, phone):
        return User.query.filter_by(phone=phone).first()

    def create_user(self, user):
        try:
            db.session.add(user)
            db.session.commit()
            return user, None

        except IntegrityError:
            db.session.rollback()
            return None, "integrity_error"

    def update_user(self):
        try:
            db.session.commit()
            return True, None

        except IntegrityError:
            db.session.rollback()
            return False, "integrity_error"

    def delete_user(self, user):
        try:
            db.session.delete(user)
            db.session.commit()
            return True, None
        except Exception:
            db.session.rollback()
            return False, "delete_error"