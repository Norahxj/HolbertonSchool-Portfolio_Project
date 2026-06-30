from app.extensions import db
from app.models.base_model import BaseModel

class Wishlist(BaseModel):
    __tablename__ = "wishlists"


    child_id = db.Column(
        db.String(36),
        db.ForeignKey("children.id"),
        nullable=False
    )

    name = db.Column(db.String(255), nullable=False)
    target_points = db.Column(db.Integer, default=0)
    status = db.Column(db.String(50), default="PENDING")
    
    child = db.relationship("Child", backref="wishlists", lazy=True)


    def to_dict(self):
        return {
            "id": self.id,
            "child_id": self.child_id,
            "name": self.name,
            "target_points": self.target_points,
            "status": self.status,
            "created_at": self.created_at,
            "updated_at": self.updated_at
        }
