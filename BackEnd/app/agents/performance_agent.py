import json
import os

from dotenv import load_dotenv
from langchain_openrouter import ChatOpenRouter

from app.agents.performance_schemas import (
    ChildPerformanceAnalysis,
)


load_dotenv()


class PerformanceAgent:
    def __init__(self):
        api_key = os.getenv(
            "OPENROUTER_API_KEY"
        )
        model_name = os.getenv(
            "OPENROUTER_MODEL"
        )

        if not api_key:
            raise ValueError(
                "OPENROUTER_API_KEY is missing"
            )

        if not model_name:
            raise ValueError(
                "OPENROUTER_MODEL is missing"
            )

        self.llm = ChatOpenRouter(
            model=model_name,
            api_key=api_key,
        )

        self.structured_llm = (
            self.llm.with_structured_output(
                ChildPerformanceAnalysis,
                include_raw=True,
            )
        )

    def analyze(
        self,
        child_context,
        revision_feedback="",
    ):
        max_attempts = 3
        validation_errors = []

        for _ in range(max_attempts):
            prompt = self._build_prompt(
                child_context,
                validation_errors,
                revision_feedback,
            )

            response = (
                self.structured_llm
                .invoke(prompt)
            )

            result = response.get(
                "parsed"
            )

            parsing_error = response.get(
                "parsing_error"
            )

            if parsing_error:
                validation_errors = [
                    (
                        "Structured output parsing "
                        "failed: "
                        f"{parsing_error}"
                    )
                ]
                continue

            if result is None:
                validation_errors = [
                    (
                        "No valid structured "
                        "performance analysis "
                        "was returned."
                    )
                ]
                continue

            try:
                result = (
                    self._normalize_analysis(
                        result,
                        child_context,
                    )
                )

                self._validate_analysis(
                    result,
                    child_context,
                )

                return result

            except ValueError as error:
                validation_errors = [
                    str(error)
                ]

        raise ValueError(
            "PerformanceAgent failed to produce "
            "a valid analysis after 3 attempts."
        )

    def _build_prompt(
        self,
        child_context,
        validation_errors=None,
        revision_feedback="",
    ):
        compact_context = (
            self._build_compact_context(
                child_context
            )
        )

        context_json = json.dumps(
            compact_context,
            ensure_ascii=False,
            separators=(",", ":"),
            default=str,
        )

        validation_feedback = ""

        if validation_errors:
            errors_text = "\n".join(
                f"- {error}"
                for error in validation_errors
            )

            validation_feedback = f"""
PREVIOUS PERFORMANCE ANALYSIS ATTEMPT WAS REJECTED.

ERRORS:
{errors_text}

Correct every listed error.
"""

        evaluator_feedback = ""

        if revision_feedback:
            evaluator_feedback = f"""
THE PREVIOUS COMPLETE WEEKLY PLAN WAS REJECTED.

EVALUATOR FEEDBACK:
{revision_feedback}

Reconsider only unsupported or unreasonable
Performance Analysis conclusions.

Do not invent new facts.
"""

        return f"""
You are the Performance Analysis Agent for Asalah.

Your only responsibility is to analyze the child's
historical performance and recommend a manageable
weekly workload.

You MUST NOT create or suggest tasks.

CHILD DATA:
{context_json}

Determine:

1. performance_level:
   LOW, MODERATE, or HIGH

2. recommended_task_count

3. recommended_weekly_points

4. difficulty_level:
   LOW, MEDIUM, or HIGH

5. strong_categories

6. weak_categories

7. a concise analysis

COLD START:

If history.has_enough_history is false:

- is_cold_start MUST be true
- strong_categories MUST be []
- weak_categories MUST be []
- do not spend effort inferring category strengths
  or weaknesses
- recommend a small and manageable starter workload

If history.has_enough_history is true:

- is_cold_start MUST be false
- strong and weak categories must be supported by
  category history

RULES:

- Low completion should generally lead to fewer
  and easier tasks.

- Consistently strong completion may support a
  slightly larger workload.

- Pending and pending-review tasks are not failures.

- A rejected task does not prove why it was rejected.

- A weak category should normally receive gradual
  improvement rather than automatic exclusion.

- Use history.completion_rate exactly as provided.

- Do not infer behavioral causes from statistics alone.

- Historical total_earned and total_spent are
  historical totals, not weekly values.

- Active goals may influence motivation but must not
  determine performance level by themselves.

- Do not overload the child to reach a goal faster.

- Keep analysis under 250 characters.

- Do not invent facts.

{validation_feedback}

{evaluator_feedback}

Return only the required structured analysis.
"""

    def _build_compact_context(
        self,
        child_context,
    ):
        child = child_context.get(
            "child",
            {},
        )

        history_summary = (
            child_context.get(
                "history_summary",
                {},
            )
        )

        points_summary = (
            child_context.get(
                "points_summary",
                {},
            )
        )

        wishlist_summary = (
            child_context.get(
                "wishlist_summary",
                {},
            )
        )

        task_history = (
            child_context.get(
                "task_history",
                [],
            )
        )

        rejected_tasks = []

        for task in task_history:
            if (
                task.get("status")
                != "REJECTED"
            ):
                continue

            rejected_tasks.append({
                "title": task.get(
                    "title",
                    "",
                ),
                "category": task.get(
                    "category",
                    "",
                ),
                "points": task.get(
                    "points",
                    0,
                ),
                "frequency": task.get(
                    "frequency",
                    "",
                ),
            })

        active_goals = []

        for goal in wishlist_summary.get(
            "active_goals",
            [],
        ):
            active_goals.append({
                "target_points": goal.get(
                    "target_points",
                    0,
                ),
                "remaining_points": goal.get(
                    "remaining_points",
                    0,
                ),
            })

        history = {
            "total_tasks": history_summary.get(
                "total_tasks",
                0,
            ),
            "approved_tasks": history_summary.get(
                "approved_tasks",
                0,
            ),
            "rejected_tasks": history_summary.get(
                "rejected_tasks",
                0,
            ),
            "pending_tasks": history_summary.get(
                "pending_tasks",
                0,
            ),
            "pending_review_tasks": (
                history_summary.get(
                    "pending_review_tasks",
                    0,
                )
            ),
            "completion_rate": history_summary.get(
                "completion_rate",
                0,
            ),
            "average_completed_task_points": (
                history_summary.get(
                    "average_completed_task_points",
                    0,
                )
            ),
            "has_enough_history": history_summary.get(
                "has_enough_history",
                False,
            ),
            "categories": history_summary.get(
                "categories",
                {},
            ),
        }

        points = {
            "current_points": points_summary.get(
                "current_points",
                child.get(
                    "current_points",
                    0,
                ),
            ),
            "total_earned": points_summary.get(
                "total_earned",
                0,
            ),
            "total_spent": points_summary.get(
                "total_spent",
                0,
            ),
        }

        return {
            "age": child.get(
                "age"
            ),
            "history": history,
            "points": points,
            "rejected_tasks": rejected_tasks,
            "active_goals": active_goals,
        }

    def _normalize_analysis(
        self,
        analysis,
        child_context,
    ):
        has_enough_history = (
            child_context
            .get(
                "history_summary",
                {},
            )
            .get(
                "has_enough_history",
                False,
            )
        )

        analysis.is_cold_start = (
            not has_enough_history
        )

        if analysis.is_cold_start:
            analysis.strong_categories = []
            analysis.weak_categories = []

        return analysis

    def _validate_analysis(
        self,
        analysis,
        child_context,
    ):
        history_summary = (
            child_context.get(
                "history_summary",
                {},
            )
        )

        has_enough_history = (
            history_summary.get(
                "has_enough_history",
                False,
            )
        )

        expected_cold_start = (
            not has_enough_history
        )

        if (
            analysis.is_cold_start
            != expected_cold_start
        ):
            raise ValueError(
                "PerformanceAgent returned "
                "an incorrect is_cold_start value."
            )

        if (
            analysis.recommended_task_count
            < 3
        ):
            raise ValueError(
                "Recommended task count "
                "cannot be below 3."
            )

        if (
            analysis.recommended_task_count
            > 7
        ):
            raise ValueError(
                "Recommended task count "
                "cannot exceed 7."
            )

        if (
            analysis.recommended_weekly_points
            < 40
        ):
            raise ValueError(
                "Recommended weekly points "
                "cannot be below 40."
            )

        if (
            analysis.recommended_weekly_points
            > 120
        ):
            raise ValueError(
                "Recommended weekly points "
                "cannot exceed 120."
            )

        valid_categories = {
            "RELIGIOUS",
            "FINANCIAL",
            "MORAL",
            "SOCIAL",
        }

        strong_categories = set(
            analysis.strong_categories
        )

        weak_categories = set(
            analysis.weak_categories
        )

        if not strong_categories.issubset(
            valid_categories
        ):
            raise ValueError(
                "PerformanceAgent returned "
                "an invalid strong category."
            )

        if not weak_categories.issubset(
            valid_categories
        ):
            raise ValueError(
                "PerformanceAgent returned "
                "an invalid weak category."
            )

        overlap = (
            strong_categories
            & weak_categories
        )

        if overlap:
            raise ValueError(
                "A category cannot be both "
                "strong and weak."
            )

        if expected_cold_start:
            if analysis.strong_categories:
                raise ValueError(
                    "Cold-start child must not "
                    "have strong categories."
                )

            if analysis.weak_categories:
                raise ValueError(
                    "Cold-start child must not "
                    "have weak categories."
                )