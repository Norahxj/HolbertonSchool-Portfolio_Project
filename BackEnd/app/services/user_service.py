from app.repositories.user_repository import UserRepository


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
            phone = user_data["phone"]
            existing_phone = self.user_repository.get_user_by_phone(phone)
            if existing_phone:
                return None, "Phone number already used"
            user.phone = user_data["phone"]

        success, error = self.user_repository.update_user()

        if not success:
            return None, "email_exists"

        return user, None

    def delete_user(self, user_id):
        user = self.user_repository.get_user_by_id(user_id)

        if not user:
            return None

        success, error = self.user_repository.delete_user(user)

        if not success:
            return None

        return True