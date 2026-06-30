from app.extensions import db
from app.models.base_model import BaseModel


class ChildPoints(BaseModel):
    __tablename__ = "child_points"

    child_id = db.Column(db.String(36), db.ForeignKey("children.id"), nullable=False)
    total_points = db.Column(db.Integer, default=0, nullable=False)

    child = db.relationship("Child", backref="points", lazy=True)

    def add_points(self, amount):
        self.total_points += amount
        db.session.commit()

    def deduct_points(self, amount):
        self.total_points = max(0, self.total_points - amount)
        db.session.commit()

    def to_dict(self):
        return {
            "id": self.id,
            "child_id": self.child_id,
            "total_points": self.total_points,
            "created_at": self.created_at,
            "updated_at": self.updated_at
        }
