from sqlalchemy.exc import IntegrityError
from app.extensions import db
from app.models.reward_model import Reward


class RewardRepository:

    def create_reward(self, reward):
        try:
            db.session.add(reward)
            db.session.commit()
            return reward, None
        except IntegrityError:
            db.session.rollback()
            return None, "integrity_error"

    def get_reward_by_id(self, reward_id):
        return db.session.get(Reward, reward_id)

    def get_rewards_by_child_id(self, child_id):
        return Reward.query.filter_by(child_id=child_id).all()

    def get_reward_for_parent(self, reward_id, parent_id):
        return Reward.query.filter_by(
            id=reward_id,
            assigned_by=parent_id
        ).first()

    def update_reward(self):
        try:
            db.session.commit()
            return True, None
        except IntegrityError:
            db.session.rollback()
            return False, "integrity_error"

    def delete_reward(self, reward):
        try:
            db.session.delete(reward)
            db.session.commit()
            return True, None
        except IntegrityError:
            db.session.rollback()
            return False, "integrity_error"
        

    def get_locked_rewards_by_unlock_day(self, unlock_day):
        return Reward.query.filter_by(
            status="LOCKED",
            unlock_day=unlock_day
        ).all()