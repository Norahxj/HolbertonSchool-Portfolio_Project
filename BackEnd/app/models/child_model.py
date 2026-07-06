from app.extensions import db
from app.models.base_model import BaseModel

child_guardians = db.Table(
    "child_guardians",
    db.Column("user_id", db.String(36), db.ForeignKey("users.id"), primary_key=True),
    db.Column("child_id", db.String(36), db.ForeignKey("children.id"), primary_key=True),
    db.Column("relation_type", db.String(20), nullable=True)
)


class Child(BaseModel):
    __tablename__ = "children"

    name = db.Column(db.String(100), nullable=False)
    age = db.Column(db.Integer, nullable=False)
    access_code = db.Column(db.String(6), unique=True, nullable=False)
    guardians = db.relationship("User", secondary=child_guardians, backref=db.backref("children", lazy=True), lazy=True)
    daily_feedbacks = db.relationship("DailyFeedback", backref="child", lazy=True, cascade="all, delete-orphan")
    family_id = db.Column(db.String(36), db.ForeignKey("families.id"), nullable=False)
    family = db.relationship("Family", backref=db.backref("children", lazy=True))