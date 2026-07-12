from sqlalchemy.exc import IntegrityError
from app.extensions import db
from app.models.wishlist_model import Wishlist
from app.models.points_history_model import PointsHistory


class WishlistRepository:

    def create_wish(self, wish):
        try:
            db.session.add(wish)
            db.session.commit()
            return wish, None
        except IntegrityError:
            db.session.rollback()
            return None, "integrity_error"

    def get_wish_by_id(self, wish_id):
        return db.session.get(Wishlist, wish_id)

    def get_wishes_by_child_id(self, child_id):
        return (
            Wishlist.query
            .filter_by(child_id=child_id)
            .order_by(Wishlist.created_at.desc())
            .all()
        )

    def get_wish_for_child(self, wish_id, child_id):
        return Wishlist.query.filter_by(
            id=wish_id,
            child_id=child_id
        ).first()

    def get_pending_count_by_child_id(self, child_id):
        return Wishlist.query.filter_by(
            child_id=child_id,
            status="PENDING"
        ).count()

    def get_approved_count_by_child_id(self, child_id):
        return Wishlist.query.filter_by(
            child_id=child_id,
            status="APPROVED"
        ).count()

    def update_wish(self):
        try:
            db.session.commit()
            return True, None
        except IntegrityError:
            db.session.rollback()
            return False, "integrity_error"

    def delete_wish(self, wish):
        try:
            db.session.delete(wish)
            db.session.commit()
            return True, None
        except Exception:
            db.session.rollback()
            return False, "delete_error"
        
    def achieve_wish(self, wish, points_record):
        try:
            points_record.total_points -= wish.target_points
            wish.status = "ACHIEVED"

            history = PointsHistory(
                child_id=wish.child_id,
                points=-wish.target_points,
                action="WISH_ACHIEVED",
                source_id=wish.id
            )

            db.session.add(history)
            db.session.commit()

            return wish, None

        except Exception:
            db.session.rollback()
            return None, "achieve_error"