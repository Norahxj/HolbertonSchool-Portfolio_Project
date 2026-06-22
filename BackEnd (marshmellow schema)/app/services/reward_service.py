from app.extensions import db
from app.models.gamification_models import Reward, ChildReward, Wish
from app.models.user_model import User
from app.models.child_model import Child
from app.exceptions.api_exceptions import NotFoundError, ValidationError, ConflictError, ForbiddenError
from app.schemas.gamification_schemas import RewardSchema, ChildRewardSchema, WishSchema
from uuid import uuid4
from datetime import datetime

# Initialize Marshmallow schemas
reward_schema = RewardSchema()
rewards_schema = RewardSchema(many=True)
child_reward_schema = ChildRewardSchema()
child_rewards_schema = ChildRewardSchema(many=True)
wish_schema = WishSchema()
wishes_schema = WishSchema(many=True)

class RewardService:
    # Reward Management - Parent-defined rewards

    @staticmethod
    def create_reward(parent_id, data):
        # Validate input using Marshmallow schema
        errors = reward_schema.validate(data)
        if errors:
            raise ValidationError("Validation failed for reward creation", errors)

        # Ensure the parent_id in data matches the authenticated parent_id
        if data["parent_id"] != parent_id:
            raise ForbiddenError("Cannot create reward for another parent.")

        # Create a new Reward instance
        reward = Reward(id=str(uuid4()), **data)
        db.session.add(reward)
        db.session.commit()
        return reward_schema.dump(reward)

    @staticmethod
    def get_parent_rewards(parent_id, is_active=None):
        # Retrieve all rewards created by a specific parent
        query = Reward.query.filter_by(parent_id=parent_id)
        if is_active is not None:
            query = query.filter_by(is_active=is_active)
        rewards = query.all()
        return rewards_schema.dump(rewards)

    @staticmethod
    def get_reward_by_id(parent_id, reward_id):
        # Retrieve a specific reward by ID for a given parent
        reward = Reward.query.filter_by(id=reward_id, parent_id=parent_id).first()
        if not reward:
            raise NotFoundError(f"Reward with ID {reward_id} not found or does not belong to parent.")
        return reward_schema.dump(reward)

    @staticmethod
    def update_reward(parent_id, reward_id, data):
        # Retrieve the reward
        reward = Reward.query.filter_by(id=reward_id, parent_id=parent_id).first()
        if not reward:
            raise NotFoundError(f"Reward with ID {reward_id} not found or does not belong to parent.")

        # Validate input for update (partial update allowed)
        errors = reward_schema.validate(data, partial=True)
        if errors:
            raise ValidationError("Validation failed for reward update", errors)

        # Update reward attributes
        for key, value in data.items():
            setattr(reward, key, value)
        db.session.commit()
        return reward_schema.dump(reward)

    @staticmethod
    def delete_reward(parent_id, reward_id):
        reward = Reward.query.filter_by(id=reward_id, parent_id=parent_id).first()
        if not reward:
            raise NotFoundError(f"Reward with ID {reward_id} not found or does not belong to parent.")

        db.session.delete(reward) # Delete the reward from the database session
        db.session.commit()
        return {"message": "Reward deleted successfully"}

    # Child Reward Redemption

    @staticmethod
    def redeem_reward(child_id, reward_id):
        child = Child.query.get(child_id)
        if not child:
            raise NotFoundError(f"Child with ID {child_id} not found.")

        # Ensure reward exists and active
        reward = Reward.query.get(reward_id)
        if not reward or not reward.is_active:
            raise NotFoundError(f"Reward with ID {reward_id} not found or is not active.")

        # Check if child has enough points
        if child.current_noor_points < reward.cost_points:
            raise ConflictError("Child does not have enough points to redeem this reward.")

        # Deduct points
        child.current_noor_points -= reward.cost_points

        # Create a new ChildReward instance
        child_reward = ChildReward(id=str(uuid4()), child_id=child_id, reward_id=reward_id)
        db.session.add(child_reward)
        db.session.commit()
        return child_reward_schema.dump(child_reward)

    @staticmethod
    def get_child_redeemed_rewards(child_id, is_fulfilled=None):
        # Retrieve all rewards redeemed by a specific child give fulfillment status
        query = ChildReward.query.filter_by(child_id=child_id)
        if is_fulfilled is not None:
            query = query.filter_by(is_fulfilled=is_fulfilled)
        rewards = query.all()
        return child_rewards_schema.dump(rewards)

    @staticmethod
    def fulfill_child_reward(parent_id, child_reward_id):
        child_reward = ChildReward.query.get(child_reward_id)
        if not child_reward:
            raise NotFoundError(f"Child reward with ID {child_reward_id} not found.")

        child = Child.query.filter_by(id=child_reward.child_id, parent_id=parent_id).first()
        if not child:
            raise ForbiddenError("Cannot fulfill reward for a child not belonging to this parent.")

        if child_reward.is_fulfilled:
            raise ConflictError("Reward already fulfilled.")

        child_reward.is_fulfilled = True # Mark the reward as fulfilled
        child_reward.fulfilled_date = datetime.utcnow()
        db.session.commit() # Commit the transaction
        return child_reward_schema.dump(child_reward)

    # Wish Management

    @staticmethod
    def create_wish(child_id, data):
        # Validate input using Marshmallow schema
        errors = wish_schema.validate(data)
        if errors:
            raise ValidationError("Validation failed for wish creation", errors)

        # Ensure child exists
        child = Child.query.get(child_id)
        if not child:
            raise NotFoundError(f"Child with ID {child_id} not found.")

        # Ensure the child_id in data matches the authenticated child_id
        if data["child_id"] != child_id:
            raise ForbiddenError("Cannot create wish for another child.")

        # Create a new Wish instance
        wish = Wish(id=str(uuid4()), **data)
        db.session.add(wish)
        db.session.commit()
        return wish_schema.dump(wish)
      
    @staticmethod
    def get_child_wishes(child_id, is_achieved=None):
        query = Wish.query.filter_by(child_id=child_id)
        if is_achieved is not None:
            query = query.filter_by(is_achieved=is_achieved)
        wishes = query.all()
        return wishes_schema.dump(wishes)

    @staticmethod
    def get_wish_by_id(child_id, wish_id):
        wish = Wish.query.filter_by(id=wish_id, child_id=child_id).first()
        if not wish:
            raise NotFoundError(f"Wish with ID {wish_id} not found or does not belong to child.")
        return wish_schema.dump(wish)
      
    @staticmethod
    def update_wish(child_id, wish_id, data):
        wish = Wish.query.filter_by(id=wish_id, child_id=child_id).first()
        if not wish:
            raise NotFoundError(f"Wish with ID {wish_id} not found or does not belong to child.")
          
        errors = wish_schema.validate(data, partial=True)
        if errors:
            raise ValidationError("Validation failed for wish update", errors)

        # Update wish attributes
        for key, value in data.items():
            setattr(wish, key, value)

        # If target_points reached, mark as achieved
        if wish.current_points >= wish.target_points and not wish.is_achieved:
            wish.is_achieved = True
            wish.achievement_date = datetime.utcnow()

        db.session.commit()
        return wish_schema.dump(wish)

    @staticmethod
    def delete_wish(child_id, wish_id):
        # Retrieve the wish
        wish = Wish.query.filter_by(id=wish_id, child_id=child_id).first()
        if not wish:
            raise NotFoundError(f"Wish with ID {wish_id} not found or does not belong to child.")

        db.session.delete(wish)
        db.session.commit()
        return {"message": "Wish deleted successfully"}

    @staticmethod
    def approve_wish(parent_id, wish_id):
      
        wish = Wish.query.get(wish_id)
        if not wish:
            raise NotFoundError(f"Wish with ID {wish_id} not found.")
          
        child = Child.query.filter_by(id=wish.child_id, parent_id=parent_id).first()
        if not child:
            raise ForbiddenError("Cannot approve wish for a child not belonging to this parent.")

        if wish.is_approved_by_parent:
            raise ConflictError("Wish already approved by parent.")

        wish.is_approved_by_parent = True
        db.session.commit()
        return wish_schema.dump(wish)
