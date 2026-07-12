from app.models.family_invitation_model import FamilyInvitation
from app.repositories.family_invitation_repository import FamilyInvitationRepository
from app.repositories.user_repository import UserRepository
from sqlalchemy.exc import IntegrityError
from app.extensions import db
from app.models.Family_model import Family
from app.models.user_model import User
from app.models.child_model import Child

class FamilyService:
    def __init__(self):
        self.family_invitation_repository = FamilyInvitationRepository()
        self.user_repository = UserRepository()

    def invite_parent(self, current_user_id, invited_email):
        current_user = self.user_repository.get_user_by_id(current_user_id)

        if not current_user:
            return None, "user_not_found"

        invited_email = invited_email.strip().lower()
        invited_user = self.user_repository.get_user_by_email(invited_email)

        if not invited_user:
            return None, "invited_user_not_found"

        if str(invited_user.id) == str(current_user.id):
            return None, "cannot_invite_self"

        if invited_user.role != "parent":
            return None, "invited_user_not_parent"

        if invited_user.family_id == current_user.family_id:
            return None, "already_in_same_family"

        existing_type = self.family_invitation_repository.get_guardian_by_family_and_type(
            current_user.family_id,
            invited_user.guardian_type
        )

        if existing_type:
            return None, "guardian_type_already_exists"

        existing_invitation = (
            self.family_invitation_repository
            .get_pending_invitation_by_family_and_email(
                current_user.family_id,
                invited_email
            )
        )

        if existing_invitation:
            return None, "invitation_already_pending"

        invitation = FamilyInvitation(
            family_id=current_user.family_id,
            invited_email=invited_email,
            invited_by=current_user.id,
            status="PENDING"
        )

        invitation, error = self.family_invitation_repository.create_invitation(invitation)

        if error == "invitation_already_pending":
            return None, "invitation_already_pending"

        if error:
            return None, "create_failed"

        return invitation, None

    def get_my_invitations(self, user_id):
        user = self.user_repository.get_user_by_id(user_id)

        if not user:
            return None, "user_not_found"

        invitations = self.family_invitation_repository.get_pending_invitations_for_email(
            user.email
        )

        return invitations, None

    def accept_invitation(self, user_id, invitation_id):
        user = self.user_repository.get_user_by_id(user_id)
        invitation = (self.family_invitation_repository.get_invitation_by_id(invitation_id))
        if not user:
            return None, "user_not_found"

        if not invitation or invitation.invited_email != user.email:
            return None, "invitation_not_found"

        if user.family_id == invitation.family_id:
            return None, "already_in_same_family"

        if user.family_id is not None and user.family.children:
            return None, "already_in_family"

        if invitation.status != "PENDING":
            return None, "invitation_not_pending"

        existing_type = (
            self.family_invitation_repository
            .get_guardian_by_family_and_type(invitation.family_id,user.guardian_type)
        )

        if existing_type:
            return None, "guardian_type_already_exists"

        old_family_id = user.family_id

        try:
            user.family_id = invitation.family_id

            for child in invitation.family.children:
                if user not in child.guardians:
                    child.guardians.append(user)

            invitation.status = "ACCEPTED"

            db.session.flush()

            if old_family_id:
                remaining_guardian = User.query.filter_by(
                    family_id=old_family_id
                ).first()

                remaining_child = Child.query.filter_by(
                    family_id=old_family_id
                ).first()

                if not remaining_guardian and not remaining_child:
                    old_family = db.session.get(Family, old_family_id)

                    if old_family:
                        db.session.delete(old_family)

            db.session.commit()

            return invitation, None

        except IntegrityError as exc:
            db.session.rollback()

            constraint_name = getattr(
                getattr(exc.orig, "diag", None),
                "constraint_name",
                None
            )

            if constraint_name == "uq_users_family_guardian_type":
                return None, "guardian_type_already_exists"

            return None, "update_failed"

        except Exception:
            db.session.rollback()
            return None, "update_failed"

    def reject_invitation(self, user_id, invitation_id):
        user = self.user_repository.get_user_by_id(user_id)
        invitation = self.family_invitation_repository.get_invitation_by_id(invitation_id)

        if not user:
            return None, "user_not_found"

        if not invitation or invitation.invited_email != user.email:
            return None, "invitation_not_found"

        if invitation.status != "PENDING":
            return None, "invitation_not_pending"

        invitation.status = "REJECTED"

        success, error = self.family_invitation_repository.update_invitation()

        if not success:
            return None, "update_failed"

        return invitation, None