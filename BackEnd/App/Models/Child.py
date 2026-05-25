from app.extensions import db
from app.models.base_model import BaseModel

class Child(BaseModel):
    __tablename__ = "children"
    name = db.Column(db.String(100), nullable=False)
    age = db.Column(db.Integer, nullable=False)
    parent_id = db.Column(
        db.String(36),
        db.ForeignKey("users.id"),
        nullable=False
    )
