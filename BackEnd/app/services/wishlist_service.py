from app.extensions import db
from app.models.wishlist_model import Wishlist
from app.models.child_model import Child
from app.models.points_model import ChildPoints
from app.models.points_history_model import PointsHistory


class WishlistService:

    @staticmethod
    def add_wish(child_id, name):
        child = Child.query.filter_by(id=child_id).first()
        if not child:
            return None, 404

        existing_wishes = Wishlist.query.filter_by(child_id=child_id).count()
        if existing_wishes >= 5:
            return None, 400

        new_wish = Wishlist(
            child_id=child_id,
            name=name,
            status="PENDING"
        )

        db.session.add(new_wish)
        db.session.commit()
        return new_wish, 201

    @staticmethod
    def approve_wish(wish_id, target_points):
        wish = Wishlist.query.filter_by(id=wish_id).first()
        if not wish:
            return None, 404

        approved_count = Wishlist.query.filter_by(
            child_id=wish.child_id,
            target_points=target_points,
            status="APPROVED"
        ).count()

        if approved_count >= 3:
            return None, 400

        wish.approve()
        return wish, 200

    @staticmethod
    def reject_wish(wish_id):
        wish = Wishlist.query.filter_by(id=wish_id).first()
        if not wish:
            return None, 404

        wish.reject()
        return wish, 200

        db.session.delete(wish)
        db.session.commit()
        return {"message":" wish rejected"}, 200

    @staticmethod
    def get_child_wishlist(child_id):
        wishes = Wishlist.query.filter_by(child_id=child_id).all()
        return wishes, 200
   
    @staticmethod
    def get_progress(child_id):
    # Get child's current points
    child_points = ChildPoints.query.filter_by(child_id=child_id).first()
    current_points = child_points.total_points if child_points else 0

    # Get all wishes for the child
    wishes = Wishlist.query.filter_by(child_id=child_id).all()

    # Build progress list
    wishes_progress = []
    for wish in wishes:
        target = wish.target_points or 0

        if target == 0:
            progress = 0
        else:
            progress = round((current_points / target) * 100, 2)

        wishes_progress.append({
            "id": wish.id,
            "name": wish.name,
            "target_points": target,
            "status": wish.status,
            "progress_percentage": progress,
            "created_at": wish.created_at,
            "updated_at": wish.updated_at
        })

    # Final response
    return {
        "child_id": child_id,
        "current_points": current_points,
        "wishes": wishes_progress
    }, 200

    @staticmethod
    def update_wish(wish_id, data):
        wish = Wishlist.query.filter_by(id=wish_id).first()
        if not wish:
            return None, 404

        if "name" in data:
            wish.name = data["name"]

        if "target_points" in data:
            wish.target_points = data["target_points"]

        db.session.commit()
        return wish, 200