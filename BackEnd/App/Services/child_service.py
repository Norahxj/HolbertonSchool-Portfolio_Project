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
    
    def delete_child(self, child_id):
        child = Child.query.get(child_id)
        if not child:
            return None
        db.session.delete(child)
        db.session.commit()
        return child