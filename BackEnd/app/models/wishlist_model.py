from app.extensions import db
from app.models.base_model import BaseModel

class Wishlist(BaseModel):
    __tablename__ = "wishlists"
    child_id = db.Column(db.String(36), db.ForeignKey("children.id", ondelete="CASCADE"), nullable=False)
    name = db.Column(db.String(255), nullable=False)
    target_points = db.Column(db.Integer, nullable=True)
    status = db.Column(db.String(20), default="PENDING", nullable=False)
    reviewed_by = db.Column(db.String(36), db.ForeignKey("users.id", ondelete="SET NULL"), nullable=True)
    approved_at = db.Column(db.DateTime(timezone=True), nullable=True)
    child = db.relationship("Child", backref=db.backref("wishlists", lazy=True, passive_deletes=True))
    reviewer = db.relationship("User", backref=db.backref("reviewed_wishlists", lazy=True, passive_deletes=True))