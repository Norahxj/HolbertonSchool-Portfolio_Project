from app.models.reward_model import Reward
from app.repositories.reward_repository import RewardRepository
from app.repositories.child_repository import ChildRepository
from app.utils.datetime_utils import riyadh_weekday

class RewardService:
    def __init__(self):
        self.reward_repository = RewardRepository()
        self.child_repository = ChildRepository()

    def create_reward(self, parent_id, reward_data):
        child = self.child_repository.get_child_for_guardian(reward_data["child_id"], parent_id)
        if not child:
            return None, "child_not_found"
        unlock_day = reward_data.get("unlock_day", 3)
        today_weekday = riyadh_weekday()
        description = reward_data.get("description")
        if description is not None:
            description = description.strip()
        reward = Reward(
            child_id=child.id,
            reward_name=reward_data["reward_name"].strip(),
            description=description,
            status=(
                "UNLOCKED"
                if unlock_day == today_weekday
                else "LOCKED"
            ),
            unlock_day=unlock_day,
            assigned_by=parent_id
        )
        reward, error = self.reward_repository.create_reward(reward)
        if error:
            return None, "create_failed"
        return reward, None

    def get_rewards_for_child_as_parent(self, child_id, parent_id):
        child = self.child_repository.get_child_for_guardian(child_id, parent_id)
        if not child:
            return None, "child_not_found"
        return self.reward_repository.get_rewards_by_child_id(child_id), None

    def get_my_rewards(self, child_id):
        return self.reward_repository.get_rewards_by_child_id(child_id), None

    def update_reward(self, reward_id, parent_id, reward_data):
        reward = self.reward_repository.get_reward_for_parent(reward_id, parent_id)
        if not reward:
            return None, "reward_not_found"
        if "reward_name" in reward_data:
            reward.reward_name = reward_data["reward_name"].strip()
        if "description" in reward_data:
            description = reward_data["description"]
            if description is not None:
                description = description.strip()
            reward.description =  description
        if "unlock_day" in reward_data:
            reward.unlock_day = reward_data["unlock_day"]
            if reward.status != "CLAIMED":
                today_weekday =  riyadh_weekday()
                reward.status = (
                    "UNLOCKED"
                    if reward.unlock_day == today_weekday
                    else "LOCKED"
                )
        success, error = self.reward_repository.update_reward()
        if not success:
            return None, "update_failed"
        return reward, None

    def delete_reward(self, reward_id, parent_id):
        reward = self.reward_repository.get_reward_for_parent(reward_id, parent_id)
        if not reward:
            return False, "reward_not_found"
        if reward.status == "CLAIMED":
            return False, "claimed_reward_cannot_be_deleted"
        success, error = self.reward_repository.delete_reward(reward)
        if not success:
            return False, "delete_error"
        return True, None

    def unlock_today_rewards(self):
        today_weekday =  riyadh_weekday()
        rewards = (
            self.reward_repository.get_locked_rewards_by_unlock_day(today_weekday)
        )
        unlocked_count = 0
        for reward in rewards:
            reward.status = "UNLOCKED"
            unlocked_count += 1
        if unlocked_count == 0:
            return 0, None
        success, error = self.reward_repository.update_reward()
        if not success:
            return None, "update_failed"
        return unlocked_count, None

    def claim_reward(self, reward_id, child_id):
        reward = self.reward_repository.get_reward_by_id(reward_id)
        if not reward or reward.child_id != child_id:
            return None, "reward_not_found"
        if reward.status != "UNLOCKED":
            return None, "reward_not_unlocked"
        reward.status = "CLAIMED"
        success, error = self.reward_repository.update_reward()
        if not success:
            return None, "update_failed"
        return reward, None