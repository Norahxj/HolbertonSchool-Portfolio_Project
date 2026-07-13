import random

from app.seeders.reward_suggestions import REWARD_SUGGESTIONS


class RewardBankService:

    def get_random_suggestions(
        self,
        lang="en",
        count=5
    ):
        lang = lang.lower()

        if lang not in ["ar", "en"]:
            return None, "invalid_language"

        suggestions = random.sample(
            REWARD_SUGGESTIONS,
            min(count, len(REWARD_SUGGESTIONS))
        )

        result = []

        for reward in suggestions:
            result.append({
                "reward_name": (
                    reward["reward_name_ar"]
                    if lang == "ar"
                    else reward["reward_name_en"]
                ),
                "description": (
                    reward["description_ar"]
                    if lang == "ar"
                    else reward["description_en"]
                ),
                "unlock_day": reward["default_unlock_day"]
            })

        return result, None