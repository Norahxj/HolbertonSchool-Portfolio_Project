from app.extensions import db
from app.models.base_model import BaseModel


class PointsHistory(BaseModel):
    __tablename__ = "points_history"
    __table_args__ = (
        db.CheckConstraint(
            """
            NOT (task_assignment_id IS NOT NULL AND wishlist_id IS NOT NULL)
            """,
            name="ck_points_history_single_source"
        ),
    )

    child_id = db.Column(db.String(36), db.ForeignKey("children.id", ondelete="CASCADE"), nullable=False)
    points = db.Column(db.Integer, nullable=False)
    action = db.Column(db.String(30), nullable=False)
    task_assignment_id = db.Column(db.String(36), db.ForeignKey("task_assignments.id", ondelete="SET NULL"), nullable=True)
    wishlist_id = db.Column(db.String(36), db.ForeignKey("wishlists.id", ondelete="SET NULL"), nullable=True)
    child = db.relationship("Child", backref=db.backref("points_history", lazy=True, passive_deletes=True))
    task_assignment = db.relationship("TaskAssignment", backref=db.backref("points_history", lazy=True, passive_deletes=True))
    wishlist = db.relationship("Wishlist", backref=db.backref("points_history", lazy=True, passive_deletes=True))