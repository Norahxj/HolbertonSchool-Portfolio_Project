from app.repositories.user_repository import UserRepository
from app.extensions import db, bcrypt
from app.models.Family_model import Family
from app.models.user_model import User

class UserService:
    def __init__(self):
        self.user_repository = UserRepository()

    def get_user(self, user_id):
        return self.user_repository.get_user_by_id(user_id)

    def update_user(self, user_id, user_data):
        user = self.user_repository.get_user_by_id(user_id)

        if not user:
            return None, "not_found"

        if "first_name" in user_data:
            user.first_name = user_data["first_name"].strip()
        
        if "last_name" in user_data:
            user.last_name = user_data["last_name"].strip()

        if "email" in user_data:
            email = user_data["email"].strip().lower()
            existing_user = self.user_repository.get_user_by_email(email)

            if existing_user and str(existing_user.id) != str(user_id):
                return None, "email_exists"
            user.email = email
            
        if "phone" in user_data:
            phone = user_data["phone"].strip()
            existing_phone = self.user_repository.get_user_by_phone(phone)
            if existing_phone and str(existing_phone.id) != str(user_id):
                return None, "phone_exists"
            user.phone = phone
        if "password" in user_data:
            user.password_hash = (
                bcrypt.generate_password_hash(user_data["password"]).decode("utf-8")
            )
        success, error = self.user_repository.update_user()

        if not success:
            return None, "integrity_error"

        return user, None

    def delete_user(self, user_id):
        user = self.user_repository.get_user_by_id(user_id)

        if not user:
            return False, "user_not_found"

        try:
            family_id = user.family_id
            children = list(user.children)

            for child in children:
                if user in child.guardians:
                    child.guardians.remove(user)

                if len(child.guardians) == 0:
                    db.session.delete(child)

            db.session.delete(user)

            db.session.flush()

            remaining_guardian = User.query.filter_by(
                family_id=family_id
            ).first()

            if family_id and not remaining_guardian:
                family = db.session.get(Family, family_id)

                if family:
                    db.session.delete(family)

            db.session.commit()

            return True, None

        except Exception:
            db.session.rollback()
            return False, "delete_error"