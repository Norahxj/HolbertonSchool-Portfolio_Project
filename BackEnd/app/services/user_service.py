from App.Extensions import db, bcrypt
from App.Models.User import User


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
        user = User.query.get(user_id)

        if not user:
            return None

        if "full_name" in user_data:
            user.full_name = user_data["full_name"]

        if "email" in user_data:
            existing_user = User.query.filter_by(email=user_data["email"]).first()
            if existing_user and existing_user.id != user_id:
                return "email_exists"

            user.email = user_data["email"]

        if "is_active" in user_data:
            user.is_active = user_data["is_active"]

        db.session.commit()
        return user
    
    def deactivate_user(self, user_id):
        user = User.query.get(user_id)

        if not user:
            return None

        user.is_active = False
        db.session.commit()
        return user