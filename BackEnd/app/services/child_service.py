import random
from app.models.child_model import Child
from app.repositories.child_repository import ChildRepository
from app.repositories.user_repository import UserRepository

class ChildService:
    def __init__(self):
        self.child_repository = ChildRepository()
        self.user_repository = UserRepository()

    def generate_access_code(self):
        while True:
            access_code = str(random.randint(100000, 999999))
            existing_child = self.child_repository.get_child_by_access_code(access_code)

            if not existing_child:
                return access_code

    def create_child(self, parent_id, child_data):
        parent = self.user_repository.get_user_by_id(parent_id)

        if not parent:
            return None, "parent_not_found"
        if not parent.family:
            return None, "family_not_found"

        child = Child(
            name=child_data["name"].strip(),
            birth_date=child_data["birth_date"],
            phone=child_data.get("phone"),
            access_code=self.generate_access_code(),
            family_id=parent.family_id
        )
        for guardian in parent.family.guardians:
            child.guardians.append(guardian)
        child, error = self.child_repository.create_child(child)
        if error:
            return None, error
        return child, None

    def get_children_by_parent(self, parent_id):
        parent = self.user_repository.get_user_by_id(parent_id)
        if not parent:
            return []
        return self.child_repository.get_children_by_guardian(parent)

    def get_child_for_parent(self, child_id, parent_id):
        return self.child_repository.get_child_for_guardian(child_id, parent_id)

    def update_child_for_parent(self, child_id, parent_id, child_data):
        child = self.child_repository.get_child_for_guardian(child_id, parent_id)
        if not child:
            return None, "not_found"
        if "name" in child_data:
            child.name = child_data["name"].strip()
        if "birth_date" in child_data:
            child.birth_date = child_data["birth_date"]
        if "phone" in child_data:
            child.phone = child_data["phone"]
        success, error = self.child_repository.update_child()
        if not success:
            return None, "update_failed"
        return child, None

    def delete_child_for_parent(self, child_id, parent_id):
        parent = self.user_repository.get_user_by_id(parent_id)
        if not parent:
            return False, "parent_not_found"
        child = self.child_repository.get_child_for_guardian(child_id, parent_id)
        if not child:
            return False, "child_not_found"
        success, error = self.child_repository.delete_child(child)
        if not success:
            return False, error
        return True, None