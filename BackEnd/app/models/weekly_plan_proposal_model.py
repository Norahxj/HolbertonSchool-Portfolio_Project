import uuid
from datetime import datetime

from app.extensions import db


class WeeklyPlanProposal(db.Model):
    __tablename__ = "weekly_plan_proposals"

    id = db.Column(
        db.String(36),
        primary_key=True,
        default=lambda: str(uuid.uuid4()),
    )

    child_id = db.Column(
        db.String(36),
        db.ForeignKey(
            "children.id",
            ondelete="CASCADE",
        ),
        nullable=False,
        index=True,
    )

    created_by = db.Column(
        db.String(36),
        db.ForeignKey(
            "users.id",
            ondelete="CASCADE",
        ),
        nullable=False,
        index=True,
    )

    status = db.Column(
        db.String(20),
        nullable=False,
        default="PENDING",
        index=True,
    )

    plan_json = db.Column(
        db.JSON,
        nullable=False,
    )

    created_at = db.Column(
        db.DateTime,
        nullable=False,
        default=datetime.utcnow,
    )

    approved_at = db.Column(
        db.DateTime,
        nullable=True,
    )