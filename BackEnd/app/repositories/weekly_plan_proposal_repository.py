from sqlalchemy.exc import IntegrityError

from app.extensions import db
from app.models.weekly_plan_proposal_model import (
    WeeklyPlanProposal,
)


class WeeklyPlanProposalRepository:

    def get_by_id(self, proposal_id):
        return db.session.get(
            WeeklyPlanProposal,
            proposal_id,
        )

    def get_for_creator(
        self,
        proposal_id,
        parent_id,
    ):
        return (
            WeeklyPlanProposal.query
            .filter_by(
                id=proposal_id,
                created_by=parent_id,
            )
            .first()
        )

    def get_for_creator_and_child(
        self,
        proposal_id,
        parent_id,
        child_id,
    ):
        return (
            WeeklyPlanProposal.query
            .filter_by(
                id=proposal_id,
                created_by=parent_id,
                child_id=child_id,
            )
            .first()
        )

    def get_pending_for_child(
        self,
        child_id,
        parent_id,
    ):
        return (
            WeeklyPlanProposal.query
            .filter_by(
                child_id=child_id,
                created_by=parent_id,
                status="PENDING",
            )
            .order_by(
                WeeklyPlanProposal.created_at.desc()
            )
            .all()
        )

    def create_proposal(
        self,
        proposal,
        commit=True,
    ):
        try:
            db.session.add(proposal)

            if commit:
                db.session.commit()
            else:
                db.session.flush()

            return proposal, None

        except IntegrityError:
            db.session.rollback()
            return None, "integrity_error"

    def update_proposal(
        self,
        commit=True,
    ):
        try:
            if commit:
                db.session.commit()
            else:
                db.session.flush()

            return True, None

        except IntegrityError:
            db.session.rollback()
            return False, "integrity_error"

    def delete_proposal(
        self,
        proposal,
    ):
        try:
            db.session.delete(proposal)
            db.session.commit()

            return True, None

        except Exception:
            db.session.rollback()
            return False, "delete_error"