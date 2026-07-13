from datetime import datetime
from app.extensions import db
from app.models.wishlist_model import Wishlist
from app.repositories.wishlist_repository import WishlistRepository
from app.repositories.child_repository import ChildRepository
from app.repositories.point_repository import PointRepository


class WishlistService:
    def __init__(self):
        self.wishlist_repository = WishlistRepository()
        self.child_repository = ChildRepository()
        self.points_repository = PointRepository()

    def create_wish(self, child_id, wish_data):
        try:
            child = self.child_repository.get_child_by_id_for_update(child_id)

            if not child:
                db.session.rollback()
                return None, "child_not_found"

            pending_count = (
                self.wishlist_repository
                .get_pending_count_by_child_id(child_id)
            )

            if pending_count >= 5:
                db.session.rollback()
                return None, "wishlist_limit_reached"

            wish = Wishlist(
                child_id=child_id,
                name=wish_data["name"].strip(),
                status="PENDING"
            )

            wish, error = self.wishlist_repository.create_wish(wish)

            if error:
                return None, "create_failed"

            return wish, None

        except Exception:
            db.session.rollback()
            return None, "create_failed"

    def get_my_wishes(self, child_id):
        wishes = self.wishlist_repository.get_wishes_by_child_id(child_id)
        return wishes, None

    def get_child_wishes(self, child_id, parent_id):
        child = self.child_repository.get_child_for_guardian(
            child_id,
            parent_id
        )

        if not child:
            return None, "child_not_found"

        wishes = self.wishlist_repository.get_wishes_by_child_id(child_id)

        return wishes, None

    def approve_wish(self, wish_id, parent_id, target_points):
        try:
            wish = self.wishlist_repository.get_wish_by_id(wish_id)

            if not wish:
                db.session.rollback()
                return None, "wish_not_found"

            child = self.child_repository.get_child_for_guardian(
                wish.child_id,
                parent_id
            )

            if not child:
                db.session.rollback()
                return None, "child_not_found"

            locked_child = (
                self.child_repository
                .get_child_by_id_for_update(wish.child_id)
            )

            if not locked_child:
                db.session.rollback()
                return None, "child_not_found"

            wish = (
                self.wishlist_repository
                .get_wish_by_id_for_update(wish_id)
            )

            if not wish:
                db.session.rollback()
                return None, "wish_not_found"

            if wish.status != "PENDING":
                db.session.rollback()
                return None, "wish_already_reviewed"

            approved_count = (
                self.wishlist_repository
                .get_approved_count_by_child_id(wish.child_id)
            )

            if approved_count >= 3:
                db.session.rollback()
                return None, "approved_limit_reached"

            wish.status = "APPROVED"
            wish.target_points = target_points
            wish.reviewed_by = parent_id
            wish.approved_at = datetime.now()

            success, error = self.wishlist_repository.update_wish()

            if not success:
                return None, "update_failed"

            return wish, None

        except Exception:
            db.session.rollback()
            return None, "update_failed"

    def reject_wish(self, wish_id, parent_id):
        wish = self.wishlist_repository.get_wish_by_id(wish_id)

        if not wish:
            return None, "wish_not_found"

        child = self.child_repository.get_child_for_guardian(
            wish.child_id,
            parent_id
        )

        if not child:
            return None, "child_not_found"
        if wish.status != "PENDING":
            return None, "wish_already_reviewed"

        wish.status = "REJECTED"
        wish.reviewed_by = parent_id

        success, error = self.wishlist_repository.update_wish()

        if not success:
            return None, "update_failed"

        return wish, None

    def achieve_wish(self, wish_id, child_id):
        try:
            wish = (
                self.wishlist_repository
                .get_wish_for_child_for_update(wish_id, child_id)
            )

            if not wish:
                db.session.rollback()
                return None, "wish_not_found"

            if wish.status == "ACHIEVED":
                db.session.rollback()
                return None, "wish_already_achieved"

            if wish.status != "APPROVED":
                db.session.rollback()
                return None, "wish_not_approved"

            if (
                wish.target_points is None
                or wish.target_points <= 0
            ):
                db.session.rollback()
                return None, "invalid_target_points"

            points_record = (
                self.points_repository
                .get_points_by_child_id_for_update(child_id)
            )

            if not points_record:
                db.session.rollback()
                return None, "not_enough_points"

            if points_record.total_points < wish.target_points:
                db.session.rollback()
                return None, "not_enough_points"

            wish, error = (
                self.wishlist_repository
                .achieve_wish(wish, points_record)
            )

            if error:
                return None, "achieve_failed"

            return wish, None

        except Exception:
            db.session.rollback()
            return None, "achieve_failed"

    def delete_wish(self, wish_id, child_id):
        try:
            wish = (
                self.wishlist_repository
                .get_wish_for_child_for_update(wish_id, child_id)
            )

            if not wish:
                db.session.rollback()
                return False, "wish_not_found"

            allowed_statuses = {
                "PENDING",
                "REJECTED"
            }

            if wish.status not in allowed_statuses:
                db.session.rollback()
                return False, "wish_cannot_be_deleted"

            success, error = (
                self.wishlist_repository.delete_wish(wish)
            )

            if not success:
                return False, "delete_error"

            return True, None

        except Exception:
            db.session.rollback()
            return False, "delete_error"
    