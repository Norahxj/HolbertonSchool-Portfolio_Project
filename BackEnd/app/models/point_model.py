from app.extensions import db
from app.models.base_model import BaseModel

class ChildPoints(BaseModel):
    __tablename__ = "child_points"
    __table_args__ = (
        db.CheckConstraint(
            "total_points >= 0",
            name="ck_child_points_non_negative"
        ),
    )

    child_id = db.Column(db.String(36), db.ForeignKey("children.id", ondelete="CASCADE"), unique=True, nullable=False)
    total_points = db.Column(db.Integer, default=0, nullable=False)
    child = db.relationship("Child", backref=db.backref("points_record", uselist=False, passive_deletes=True), lazy=True)