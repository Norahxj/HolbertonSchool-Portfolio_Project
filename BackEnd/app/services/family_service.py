from app.models.family_invitation_model import FamilyInvitation
from app.repositories.family_invitation_repository import FamilyInvitationRepository
from app.repositories.user_repository import UserRepository


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

        existing_invitation = self.family_invitation_repository.get_pending_invitation_by_email(
            invited_email
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
        invitation = self.family_invitation_repository.get_invitation_by_id(invitation_id)

        if not user:
            return None, "user_not_found"

        if not invitation or invitation.invited_email != user.email:
            return None, "invitation_not_found"

        if invitation.status != "PENDING":
            return None, "invitation_not_pending"

        existing_type = self.family_invitation_repository.get_guardian_by_family_and_type(
            invitation.family_id,
            user.guardian_type
        )

        if existing_type:
            return None, "guardian_type_already_exists"

        user.family_id = invitation.family_id

        for child in invitation.family.children:
            if user not in child.guardians:
                child.guardians.append(user)

        invitation.status = "ACCEPTED"

        success, error = self.family_invitation_repository.update_invitation()

        if not success:
            return None, "update_failed"

        return invitation, None

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