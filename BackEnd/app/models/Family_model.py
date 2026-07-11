from app.extensions import db
from app.models.base_model import BaseModel


class Family(BaseModel):
    __tablename__ = "families"

    name = db.Column(db.String(100), nullable=True)
    guardians = db.relationship("User", backref="family", lazy=True, passive_deletes=True)
    children = db.relationship("Child", backref="family", lazy=True, passive_deletes=True)
    invitations = db.relationship("FamilyInvitation", backref="family", lazy=True, passive_deletes=True)