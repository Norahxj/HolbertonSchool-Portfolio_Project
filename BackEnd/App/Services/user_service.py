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