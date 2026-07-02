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

        child = Child(
            name=child_data["name"].strip(),
            age=child_data["age"],
            access_code=self.generate_access_code()
        )

        child.guardians.append(parent)

        child, error = self.child_repository.create_child(child)

        if error:
            return None, "access_code_exists"

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

        if "age" in child_data:
            child.age = child_data["age"]

        success, error = self.child_repository.update_child()

        if not success:
            return None, "update_failed"

        return child, None

    def delete_child_for_parent(self, child_id, parent_id):
        child = self.child_repository.get_child_for_guardian(child_id, parent_id)

        if not child:
            return None

        parent = self.user_repository.get_user_by_id(parent_id)

        if not parent:
            return None

        if parent in child.guardians:
            child.guardians.remove(parent)

        success, error = self.child_repository.update_child()

        if not success:
            return None

        if len(child.guardians) == 0:
            success, error = self.child_repository.delete_child(child)

            if not success:
                return None

        return True