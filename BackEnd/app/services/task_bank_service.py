import random
from datetime import date
from app.repositories.child_repository import ChildRepository
from app.seeders.financial_tasks import FINANCIAL_TASKS
from app.seeders.social_tasks import SOCIAL_TASKS
from app.seeders.moral_tasks import MORAL_TASKS
from app.seeders.religious_tasks import RELIGIOUS_TASKS


TASK_BANK = {
    "FINANCIAL": FINANCIAL_TASKS,
    "SOCIAL": SOCIAL_TASKS,
    "MORAL": MORAL_TASKS,
    "RELIGIOUS": RELIGIOUS_TASKS,
}


class TaskBankService:
    def __init__(self):
        self.child_repository = ChildRepository()

    def get_categories(self):
        return list(TASK_BANK.keys())

    def _default_recurrence_day(self, task_frequency):
        today = date.today()

        if task_frequency == "WEEKLY":
            return today.weekday()

        if task_frequency == "MONTHLY":
            return today.day

        return None

    def get_random_suggestions(self, parent_id, child_ids, category, lang="en", count=5):
        category = category.upper()

        if category not in TASK_BANK:
            return None, "invalid_category"

        children = [
            self.child_repository.get_child_for_guardian(child_id, parent_id)
            for child_id in child_ids
        ]

        if any(child is None for child in children):
            return None, "child_not_found"

        ages = [child.age for child in children]
        youngest_age = min(ages)
        oldest_age = max(ages)

        suitable_tasks = []

        for task in TASK_BANK[category]:
            if task["age_min"] <= youngest_age and task["age_max"] >= oldest_age:
                suitable_tasks.append(task)

        suggestions = random.sample(suitable_tasks, min(count, len(suitable_tasks)))
        result = []
        for task in suggestions:
            task_frequency = task.get("suggested_frequency", "ONCE")
            result.append({
                "title": task["title_ar"] if lang == "ar" else task["title_en"],
                "description": task["description_ar"] if lang == "ar" else task["description_en"],
                "points": task["default_points"],
                "category": category,
                "task_frequency": task_frequency,
                "recurrence_day": self._default_recurrence_day(task_frequency),
                "is_auto_verified": False
            })
        return result, None