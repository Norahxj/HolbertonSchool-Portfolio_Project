from sqlalchemy.exc import IntegrityError
from app.extensions import db
from app.models.family_invitation_model import FamilyInvitation
from app.models.user_model import User


class FamilyInvitationRepository:

    def create_invitation(self, invitation):
        try:
            db.session.add(invitation)
            db.session.commit()
            return invitation, None
        except IntegrityError as exc:
            db.session.rollback()
            constraint_name = getattr(
                getattr(exc.orig, "diag", None),
                "constraint_name",
                None
            )
            if constraint_name == "uq_pending_family_invitation":
                return None, "invitation_already_pending"
            return None, "integrity_error"

    def get_invitation_by_id(self, invitation_id):
        return db.session.get(FamilyInvitation, invitation_id)

    def get_pending_invitation_by_family_and_email(self, family_id, email):
        return FamilyInvitation.query.filter_by(
            family_id=family_id,
            invited_email=email,
            status="PENDING"
        ).first()

    def get_pending_invitations_for_email(self, email):
        return FamilyInvitation.query.filter_by(
            invited_email=email,
            status="PENDING"
        ).all()

    def get_guardian_by_family_and_type(self, family_id, guardian_type):
        return User.query.filter_by(
            family_id=family_id,
            guardian_type=guardian_type
        ).first()

    def update_invitation(self):
        try:
            db.session.commit()
            return True, None
        except IntegrityError:
            db.session.rollback()
            return False, "integrity_error"