import json
import random

from app.utils.datetime_utils import riyadh_today
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

    def get_suitable_tasks_for_age(self, age):
        suitable_tasks = []

        for category, tasks in TASK_BANK.items():
            for index, task in enumerate(tasks):
                if task["age_min"] <= age <= task["age_max"]:
                    suitable_tasks.append({
                        "bank_id": f"{category}_{index}",
                        "title_en": task["title_en"],
                        "title_ar": task["title_ar"],
                        "description_en": task["description_en"],
                        "description_ar": task["description_ar"],
                        "default_points": task["default_points"],
                        "age_min": task["age_min"],
                        "age_max": task["age_max"],
                        "suggested_frequency": task.get(
                            "suggested_frequency",
                            "ONCE",
                        ),
                        "category": category,
                    })

        return suitable_tasks

    def get_ai_candidates(
        self,
        age,
        child_context,
        category_counts,
        limit=24,
    ):
        suitable_tasks = self.get_suitable_tasks_for_age(
            age
        )

        needed_categories = {
            category
            for category, count in category_counts.items()
            if count > 0
        }

        if needed_categories:
            suitable_tasks = [
                task
                for task in suitable_tasks
                if task["category"] in needed_categories
            ]

        context_text = json.dumps(
            child_context,
            ensure_ascii=False,
            default=str,
        ).lower()

        filtered_tasks = []

        for task in suitable_tasks:
            if self._has_unsupported_assumption(
                task,
                context_text,
            ):
                continue

            filtered_tasks.append(task)

        previous_titles = self._get_previous_titles(
            child_context
        )

        ranked_tasks = sorted(
            filtered_tasks,
            key=lambda task: self._candidate_score(
                task,
                previous_titles,
            ),
            reverse=True,
        )

        if not needed_categories:
            return ranked_tasks[:limit]

        grouped = {
            category: []
            for category in needed_categories
        }

        for task in ranked_tasks:
            category = task["category"]

            if category in grouped:
                grouped[category].append(task)

        candidates = []
        selected_ids = set()

        category_order = sorted(
            needed_categories,
            key=lambda category: (
                -category_counts.get(category, 0),
                category,
            ),
        )

        per_category_limit = max(
            3,
            limit // max(
                len(category_order),
                1,
            ),
        )

        for category in category_order:
            category_tasks = grouped.get(
                category,
                [],
            )

            for task in category_tasks[
                :per_category_limit
            ]:
                if task["bank_id"] in selected_ids:
                    continue

                candidates.append(task)
                selected_ids.add(
                    task["bank_id"]
                )

                if len(candidates) >= limit:
                    return candidates

        if len(candidates) < limit:
            for task in ranked_tasks:
                if task["bank_id"] in selected_ids:
                    continue

                candidates.append(task)
                selected_ids.add(
                    task["bank_id"]
                )

                if len(candidates) >= limit:
                    break

        return candidates

    def _get_previous_titles(
        self,
        child_context,
    ):
        titles = set()

        for task in child_context.get(
            "task_history",
            [],
        ):
            title = (
                task.get("title")
                or ""
            ).strip().lower()

            if title:
                titles.add(title)

        return titles

    def _candidate_score(
        self,
        task,
        previous_titles,
    ):
        score = 100

        title_en = (
            task["title_en"]
            .strip()
            .lower()
        )

        title_ar = (
            task["title_ar"]
            .strip()
            .lower()
        )

        if (
            title_en in previous_titles
            or title_ar in previous_titles
        ):
            score -= 30

        frequency = task[
            "suggested_frequency"
        ]

        if frequency == "WEEKLY":
            score += 10

        elif frequency == "ONCE":
            score += 8

        elif frequency == "MONTHLY":
            score += 5

        elif frequency == "DAILY":
            score += 2

        default_points = task[
            "default_points"
        ]

        if default_points <= 20:
            score += 5

        elif default_points >= 30:
            score -= 3

        return score

    def _has_unsupported_assumption(
        self,
        task,
        context_text,
    ):
        task_text = (
            f"{task['title_en']} "
            f"{task['title_ar']} "
            f"{task['description_en']} "
            f"{task['description_ar']}"
        ).lower()

        assumption_groups = [
            {
                "task_terms": [
                    "sibling",
                    "siblings",
                    "brother",
                    "sister",
                    "أخ",
                    "أخت",
                    "إخوة",
                    "اخوة",
                ],
                "context_terms": [
                    "sibling",
                    "siblings",
                    "brother",
                    "sister",
                    "أخ",
                    "أخت",
                    "إخوة",
                    "اخوة",
                ],
            },
            {
                "task_terms": [
                    "allowance",
                    "مصروف",
                ],
                "context_terms": [
                    "allowance",
                    "مصروف",
                ],
            },
            {
                "task_terms": [
                    "pet",
                    "pets",
                    "حيوان أليف",
                ],
                "context_terms": [
                    "pet",
                    "pets",
                    "حيوان أليف",
                ],
            },
            {
                "task_terms": [
                    "ramadan",
                    "رمضان",
                ],
                "context_terms": [
                    "ramadan",
                    "رمضان",
                ],
            },
            {
                "task_terms": [
                    "eid",
                    "العيد",
                    "عيد",
                ],
                "context_terms": [
                    "eid",
                    "العيد",
                    "عيد",
                ],
            },
        ]

        for group in assumption_groups:
            task_requires_fact = any(
                term in task_text
                for term in group["task_terms"]
            )

            if not task_requires_fact:
                continue

            context_supports_fact = any(
                term in context_text
                for term in group["context_terms"]
            )

            if not context_supports_fact:
                return True

        return False

    def _default_recurrence_day(
        self,
        task_frequency,
    ):
        today = riyadh_today()

        if task_frequency == "WEEKLY":
            return today.weekday()

        if task_frequency == "MONTHLY":
            return today.day

        return None

    def get_random_suggestions(
        self,
        parent_id,
        child_ids,
        category,
        lang="en",
        count=5,
    ):
        category = category.upper()

        if category not in TASK_BANK:
            return None, "invalid_category"

        if not child_ids:
            return None, "child_ids_required"

        if len(child_ids) != len(set(child_ids)):
            return None, "duplicate_child_ids"

        if count <= 0:
            return None, "invalid_count"

        lang = lang.lower()

        if lang not in {"ar", "en"}:
            return None, "invalid_language"

        children = (
            self.child_repository
            .get_children_for_guardian(
                child_ids,
                parent_id,
            )
        )

        if len(children) != len(child_ids):
            return None, "child_not_found"

        ages = [
            child.age
            for child in children
        ]

        youngest_age = min(ages)
        oldest_age = max(ages)

        suitable_tasks = []

        for task in TASK_BANK[category]:
            if (
                task["age_min"] <= youngest_age
                and task["age_max"] >= oldest_age
            ):
                suitable_tasks.append(task)

        suggestions = random.sample(
            suitable_tasks,
            min(
                count,
                len(suitable_tasks),
            ),
        )

        result = []

        for task in suggestions:
            task_frequency = task.get(
                "suggested_frequency",
                "ONCE",
            )

            result.append({
                "title": (
                    task["title_ar"]
                    if lang == "ar"
                    else task["title_en"]
                ),
                "description": (
                    task["description_ar"]
                    if lang == "ar"
                    else task["description_en"]
                ),
                "points": task[
                    "default_points"
                ],
                "category": category,
                "task_frequency": (
                    task_frequency
                ),
                "recurrence_day": (
                    self._default_recurrence_day(
                        task_frequency
                    )
                ),
                "is_auto_verified": False,
            })

        return result, None