from app.extensions import db
from app.models.base_model import BaseModel


class FamilyInvitation(BaseModel):
    __tablename__ = "family_invitations"

    family_id = db.Column(db.String(36), db.ForeignKey("families.id", ondelete="CASCADE"), nullable=False)
    invited_email = db.Column(db.String(120), nullable=False)
    invited_by = db.Column(db.String(36), db.ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    status = db.Column(db.String(20), default="PENDING", nullable=False)
    inviter = db.relationship("User", backref=db.backref("sent_family_invitations", lazy=True, passive_deletes=True))