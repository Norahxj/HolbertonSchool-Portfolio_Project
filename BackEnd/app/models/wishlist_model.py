from app.extensions import db
from app.models.base_model import BaseModel

class Wishlist(BaseModel):
    __tablename__ = "wishlists"


    child_id = db.Column(db.String(36), db.ForeignKey("children.id"), nullable=False)
    name = db.Column(db.String(255), nullable=False)
    target_points = db.Column(db.Integer, default=0)
    status = db.Column(db.String(20), default="PENDING", nullable=False)
    reviewed_by = db.Column(db.String(36), db.ForeignKey("users.id"), nullable=True)
    child = db.relationship("Child", backref=db.backref("wishlists", lazy=True))
    reviewer = db.relationship("User", backref=db.backref("reviewed_wishlists", lazy=True))