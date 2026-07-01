from app.extensions import db
from app.models.wishlist_model import Wishlist
from app.models.child_model import Child
from app.models.point_model import ChildPoints


class WishlistService:
    
    def add_wish(self, child_id, name):
        child = Child.query.filter_by(id=child_id).first()
    
        if not child:
            return None, "child_not_found"
        
        wishes_count = Wishlist.query.filter_by(child_id=child_id).count()
        if wishes_count >= 5:
            return None, "wishlist_limit_reached"

    name = name.strip()
    if not name:
        return None, "invalid_name"

    existing_wish = Wishlist.query.filter_by(child_id=child_id,name=name).first()
    if existing_wish:
        return None, "wish_already_exists"

    wish = Wishlist(child_id=child_id,name=name,status="PENDING")
    db.session.add(wish)
    db.session.commit()
     return wish, None


    def get_child_wishlist(self, child_id):
        wishes = Wishlist.query.filter_by(child_id=child_id).all()
        return wishes, None

    def approve_wish(self, parent_id, wish_id, target_points):
        wish = (
            Wishlist.query
            .join(Child, Wishlist.child_id == Child.id)
            .filter(
                Wishlist.id == wish_id,
                Child.parent_id == parent_id
            )
            .first()
        )

        if not wish:
            return None, "wish_not_found"

        if target_points <= 0:
            return None, "invalid_target_points"

        if wish.status != "PENDING":
            return None, "wish_already_processed"

        wish.status = "APPROVED"
        wish.target_points = target_points
        wish.reviewed_by = parent_id

        db.session.commit()
        return wish, None

    def reject_wish(self, parent_id, wish_id):
       wish = (
        Wishlist.query
        .join(Child, Wishlist.child_id == Child.id)
        .filter(
            Wishlist.id == wish_id,
            Child.parent_id == parent_id
        )
        .first()
    )

         if not wish:
            return None, "wish_not_found"

        if wish.status != "PENDING":
            return None, "wish_already_processed"

        wish.status = "REJECTED"
        wish.reviewed_by = parent_id
        
        db.session.commit()
        return wish, None

    def get_wishlist_status(self, child_id):
        child_points = ChildPoints.query.filter_by(child_id=child_id).first()
        total_points = child_points.total_points if child_points else 0

        wishes = Wishlist.query.filter_by(child_id=child_id,status="APPROVED").all()
        
        result = []
        for wish in wishes:
            target = wish.target_points or 0
            current_points = min(total_points, target) if target > 0 else 0
            result.append({
                 "wish_id": wish.id,
                 "name": wish.name,
                 "target_points": target,
                 "current_points": current_points,
                 "remaining": max(target - current_points, 0),
                "is_completed": current_points >= target
            })

        return {"child_id": child_id,"wishes": result}, None