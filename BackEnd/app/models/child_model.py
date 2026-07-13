from app.extensions import db
from app.models.base_model import BaseModel
from datetime import date

child_guardians = db.Table(
    "child_guardians",
    db.Column("user_id", db.String(36), db.ForeignKey("users.id", ondelete="CASCADE"), primary_key=True),
    db.Column("child_id", db.String(36), db.ForeignKey("children.id", ondelete="CASCADE"), primary_key=True),
    db.Column("relation_type", db.String(20), nullable=True)
)


class Child(BaseModel):
    __tablename__ = "children"

    name = db.Column(db.String(100), nullable=False)
    birth_date = db.Column(db.Date, nullable=False)
    phone = db.Column(db.String(10), nullable=True, unique=True)    
    access_code = db.Column(db.String(6), unique=True, nullable=False)
    guardians = db.relationship("User", secondary=child_guardians, backref=db.backref("children", lazy=True), lazy=True, passive_deletes=True)
    daily_feedbacks = db.relationship("DailyFeedback", backref="child", lazy=True, passive_deletes=True)
    family_id = db.Column(db.String(36), db.ForeignKey("families.id", ondelete="CASCADE"), nullable=False)

    @property
    def age(self):
        today = date.today()
        return (
            today.year
            - self.birth_date.year
            - (
                (today.month, today.day)
                < (self.birth_date.month, self.birth_date.day)
            )
        )