from App.Extensions import db
from App.Models.Child import Child

class ChildService:
    def create_child(self, child_data):
        child = Child(**child_data)
        db.session.add(child)
        db.session.commit()
        return child
    
    def get_child(self, child_id):
        return Child.query.get(child_id)


    def get_all_children(self):
        return Child.query.all()
    
    def get_children_by_parent(self, parent_id):
        return Child.query.filter_by(parent_id=parent_id).all()
    
    def update_child(self, child_id, child_data):
        child = Child.query.get(child_id)
        if not child:
            return None

        if "name" in child_data:
            child.name = child_data["name"]

        if "age" in child_data:
            child.age = child_data["age"]

        db.session.commit()
        return child

    
    def delete_child(self, child_id):
        child = Child.query.get(child_id)
        if not child:
            return None
        db.session.delete(child)
        db.session.commit()
        return child