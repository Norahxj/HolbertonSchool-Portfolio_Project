from app.extensions import db, bcrypt
from app.models.user_model import User


class UserService:

    def create_user(self, user_data):
        password = user_data.pop("password")
        user_data["password_hash"] = bcrypt.generate_password_hash(password).decode("utf-8")
        user = User(**user_data)
        db.session.add(user)
        db.session.commit()
        return user


    def get_user(self, user_id):
        return User.query.get(user_id)


    def get_user_by_email(self, email):
        return User.query.filter_by(email=email).first()


    def get_all_users(self):
        return User.query.all()
    
    def update_user(self, user_id, user_data):
        user = db.session.get(User, user_id)

        if not user:
            return None, "not_found"

        if "full_name" in user_data:
            user.full_name = user_data["full_name"].strip()

        if "email" in user_data:
            email = user_data["email"].strip().lower()

            existing_user = User.query.filter_by(email=email).first()

            if existing_user and existing_user.id != user_id:
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
