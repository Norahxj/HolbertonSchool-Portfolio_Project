from app.extensions import db
from app.models.wishlist_model import Wishlist
from app.models.child_model import Child


class WishlistService:

    @staticmethod
    def add_wish(child_id, name, target_points=0):
        child = Child.query.filter_by(id=child_id).first()
        if not child:
            return None, 404

        existing_wishes = Wishlist.query.filter_by(child_id=child_id).count()
        if existing_wishes >= 5:
            return None, 400

        new_wish = Wishlist(
            child_id=child_id,
            name=name,
            target_points=target_points,
            status="PENDING"
        )

        db.session.add(new_wish)
        db.session.commit()
        return new_wish, 201

    @staticmethod
    def approve_wish(wish_id):
        wish = Wishlist.query.filter_by(id=wish_id).first()
        if not wish:
            return None, 404

        approved_count = Wishlist.query.filter_by(
            child_id=wish.child_id,
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

    @staticmethod
    def set_goal(child_id, goal_points):
        child = Child.query.filter_by(id=child_id).first()
        if not child:
            return None, 404

        Wishlist.query.filter_by(child_id=child_id).update({
            "target_points": goal_points
        })

        db.session.commit()
        return {"message": "Goal updated", "goal_points": goal_points}, 200

    @staticmethod
    def get_child_wishlist(child_id):
        wishes = Wishlist.query.filter_by(child_id=child_id).all()
        return wishes, 200

    @staticmethod
    def get_progress(child_id, current_points):
        wishes = Wishlist.query.filter_by(child_id=child_id).all()

        return {
            "child_id": child_id,
            "current_points": current_points,
            "wishes": [wish.to_dict() for wish in wishes]
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

    @staticmethod
    def delete_wish(wish_id):
        wish = Wishlist.query.filter_by(id=wish_id).first()
        if not wish:
            return None, 404

        db.session.delete(wish)
        db.session.commit()
        return True, 200
