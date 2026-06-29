from app.extensions import db
from app.model.wishlist_model import Wishlist
from app.model.child_model import Child


class WishlistService:

    @staticmethod
    def add_wish(child_id, name, target_points=0):
        """
        Create a new wish for a child.
        Rules:
        - Child can only have 5 wishes max.
        """

        child = Child.query.filter_by(id=child_id).first()
        if not child:
            return {"error": "Child not found"}, 404

        existing_wishes = Wishlist.query.filter_by(child_id=child_id).count()
        if existing_wishes >= 5:
            return {"error": "Child already has 5 wishes"}, 400

        new_wish = Wishlist(
            child_id=child_id,
            name=name,
            target_points=target_points,
            status="PENDING"
        )

        db.session.add(new_wish)
        db.session.commit()

        return new_wish.to_dict(), 201


    @staticmethod
    def approve_wish(wish_id):
        """
        Parent approves a wish.
        Rules:
        - Parent can approve between 1 to 3 wishes only.
        """

        wish = Wishlist.query.filter_by(id=wish_id).first()
        if not wish:
            return {"error": "Wish not found"}, 404

        approved_count = Wishlist.query.filter_by(
            child_id=wish.child_id,
            status="APPROVED"
        ).count()

        if approved_count >= 3:
            return {"error": "Child already has 3 approved wishes"}, 400

        wish.approve()
        return wish.to_dict(), 200


    @staticmethod
    def reject_wish(wish_id):
        """
        Parent rejects a wish.
        """

        wish = Wishlist.query.filter_by(id=wish_id).first()
        if not wish:
            return {"error": "Wish not found"}, 404

        wish.reject()
        return wish.to_dict(), 200


    @staticmethod
    def set_goal(child_id, goal_points):
        """
        Set a wishlist goal for the child.
        Example: 5000 points.
        """

        child = Child.query.filter_by(id=child_id).first()
        if not child:
            return {"error": "Child not found"}, 404

        Wishlist.query.filter_by(child_id=child_id).update({
            "target_points": goal_points
        })

        db.session.commit()

        return {"message": "Goal updated", "goal_points": goal_points}, 200


    @staticmethod
    def get_child_wishlist(child_id):
        """
        Get all wishes for a child.
        """

        wishes = Wishlist.query.filter_by(child_id=child_id).all()
        return [wish.to_dict() for wish in wishes], 200


    @staticmethod
    def get_progress(child_id, current_points):
        """
        Calculate progress toward the wishlist goal.
        - current_points: child's Noor Points
        - goal_points: target_points from wishlist
        """

        wish = Wishlist.query.filter_by(child_id=child_id).first()
        if not wish:
            return {"error": "No wishes found"}, 404

        goal = wish.target_points
        if goal == 0:
            return {"progress": 0}, 200

        progress = (current_points / goal) * 100

        return {
            "goal_points": goal,
            "current_points": current_points,
            "progress_percentage": round(progress, 2)
        }, 200
