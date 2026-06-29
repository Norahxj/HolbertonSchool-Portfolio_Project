from app.extensions import db
from app.models.user_model import User


class UserService:

    def get_user(self, user_id):
        return db.session.get(User, user_id)    
    
    def update_user(self, user_id, user_data):
        user = db.session.get(User, user_id)

        if not user:
            return None, "not_found"

        if "full_name" in user_data:
            user.full_name = user_data["full_name"].strip()

        if "email" in user_data:
            email = user_data["email"].strip().lower()

            existing_user = User.query.filter_by(email=email).first()

            if existing_user and str(existing_user.id) != str(user_id):
                return None, "email_exists"

            user.email = email

        db.session.commit()
        return user, None
    
    def delete_user(self, user_id):
        user = db.session.get(User, user_id)

        if not user:
            return None

        db.session.delete(user)
        db.session.commit()
        return True
