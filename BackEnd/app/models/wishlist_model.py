from app.extensions import db
from app.model.base_model import BaseModel


class Wishlist(BaseModel):
    """
    Wishlist model - represents a wish created by a child.
    Rules:
    - Each child can have up to 5 wishes.
    - Parent can approve between 1 to 3 wishes.
    - Each wish has a target point goal.
    """

    __tablename__ = "wishlists"

    child_id = db.Column(
        db.String(36),
        db.ForeignKey("children.id"),
        nullable=False
    )

    name = db.Column(db.String(100), nullable=False)
    target_points = db.Column(db.Integer, nullable=False, default=0)
    status = db.Column(db.String(20), nullable=False, default="PENDING")
    child = db.relationship("Child", backref="wishlist_items", lazy=True)

    def approve(self):
        """Mark the wish as approved."""
        self.status = "APPROVED"
        db.session.commit()

    def reject(self):
        """Mark the wish as rejected."""
        self.status = "REJECTED"
        db.session.commit()

    def to_dict(self):
        """Convert the wish to a dictionary for API responses."""
        return {
            "id": self.id,
            "child_id": self.child_id,
            "name": self.name,
            "description": self.description,
            "target_points": self.target_points,
            "status": self.status,
            "created_at": self.created_at
        }
