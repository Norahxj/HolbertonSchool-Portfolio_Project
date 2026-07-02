from app.extensions import db
from app.models.child_model import Child


class ChildRepository:

    def get_child_by_id(self, child_id):
        return db.session.get(Child, child_id)
    
    def get_child_by_access_code(self, access_code):
        return Child.query.filter_by(access_code=access_code).first()