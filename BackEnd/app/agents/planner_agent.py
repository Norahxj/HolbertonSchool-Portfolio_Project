import json
import os

from dotenv import load_dotenv
from langchain_openrouter import ChatOpenRouter

from app.agents.planner_schemas import (
    PlannedTask,
    WeeklyPlanDraft,
    WeeklyPlanSummary,
)


load_dotenv()


class PlannerAgent:
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
                WeeklyPlanSummary,
                include_raw=True,
            )
        )

    def build_plan(
        self,
        child_context,
        performance_analysis,
        strategy,
        bank_selection,
        creative_selection,
        revision_feedback="",
    ):
        max_attempts = 3
        validation_errors = []

        for _ in range(max_attempts):
            prompt = self._build_prompt(
                child_context,
                performance_analysis,
                strategy,
                bank_selection,
                creative_selection,
                validation_errors,
                revision_feedback,
            )

            response = (
                self.structured_llm
                .invoke(prompt)
            )

            summary = response.get(
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

            if summary is None:
                validation_errors = [
                    (
                        "No valid structured "
                        "plan summary was returned."
                    )
                ]
                continue

            try:
                plan = self._assemble_plan(
                    summary,
                    child_context,
                    bank_selection,
                    creative_selection,
                )

                self._validate_plan(
                    plan,
                    performance_analysis,
                    strategy,
                )

                return plan

            except ValueError as error:
                validation_errors = [
                    str(error)
                ]

        raise ValueError(
            "PlannerAgent failed to produce "
            "a valid plan after 3 attempts."
        )

    def _build_prompt(
        self,
        child_context,
        performance_analysis,
        strategy,
        bank_selection,
        creative_selection,
        validation_errors=None,
        revision_feedback="",
    ):
        compact_context = (
            self._build_compact_context(
                child_context,
                performance_analysis,
            )
        )

        selected_tasks = (
            self._build_task_summary(
                bank_selection,
                creative_selection,
            )
        )

        context_json = json.dumps(
            compact_context,
            ensure_ascii=False,
            separators=(",", ":"),
            default=str,
        )

        strategy_json = (
            strategy.model_dump_json()
        )

        tasks_json = json.dumps(
            selected_tasks,
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
PREVIOUS PLANNER ATTEMPT FAILED VALIDATION.

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

Correct only planner-level summary issues.

You may revise:
- summary_en
- summary_ar

You MUST NOT invent tasks or change the selected
task composition.

Do not repeat the same rejected summary issue.
"""

        return f"""
You are the Weekly Plan Summary Agent for Asalah.

The weekly tasks have ALREADY been selected.

Your ONLY responsibility is to write a short,
parent-friendly summary of the final weekly plan
in English and Arabic.

CHILD SUMMARY:
{context_json}

WEEKLY STRATEGY:
{strategy_json}

SELECTED TASKS:
{tasks_json}

RULES:

- Write summary_en in natural English.

- Write summary_ar in natural Arabic.

- Each summary MUST be no more than 300 characters.

- Aim for 2 to 3 short sentences.

- Keep both summaries concise, natural, and clear.

- Describe the overall purpose and balance of
  the plan.

- Reflect the actual selected tasks and strategy.

- Do not create new tasks.

- Do not remove or modify tasks.

- Do not invent facts about the child.

- Do not mention unsupported possessions,
  family circumstances, school situations,
  pets, siblings, allowance, holidays, or
  other facts unless explicitly supported.

- Do not expose internal reasoning.

- Do not mention agents, prompts, models,
  validators, or implementation details.

- Avoid mixing English words into summary_ar.

- Avoid mixing Arabic words into summary_en.

{validation_feedback}

{evaluator_feedback}

Return only the required structured summaries.
"""

    def _build_compact_context(
        self,
        child_context,
        performance_analysis,
    ):
        child = child_context.get(
            "child",
            {},
        )

        return {
            "age": child.get(
                "age"
            ),
            "performance_level": (
                performance_analysis
                .performance_level
            ),
            "strong_categories": (
                performance_analysis
                .strong_categories
            ),
            "weak_categories": (
                performance_analysis
                .weak_categories
            ),
            "is_cold_start": (
                performance_analysis
                .is_cold_start
            ),
            "recommended_weekly_points": (
                performance_analysis
                .recommended_weekly_points
            ),
        }

    def _build_task_summary(
        self,
        bank_selection,
        creative_selection,
    ):
        tasks = []

        for task in bank_selection.tasks:
            tasks.append({
                "source": "TASK_BANK",
                "title_en": task.title_en,
                "title_ar": task.title_ar,
                "category": task.category,
                "points": task.points,
                "frequency": task.frequency,
            })

        for task in creative_selection.tasks:
            tasks.append({
                "source": "AI_GENERATED",
                "title_en": task.title_en,
                "title_ar": task.title_ar,
                "category": task.category,
                "points": task.points,
                "frequency": task.frequency,
            })

        return tasks

    def _assemble_plan(
        self,
        summary,
        child_context,
        bank_selection,
        creative_selection,
    ):
        tasks = []

        for task in bank_selection.tasks:
            tasks.append(
                PlannedTask(
                    source="TASK_BANK",
                    bank_id=task.bank_id,
                    title_en=task.title_en,
                    title_ar=task.title_ar,
                    description_en=(
                        task.description_en
                    ),
                    description_ar=(
                        task.description_ar
                    ),
                    category=task.category,
                    points=task.points,
                    frequency=task.frequency,
                    reason=task.reason,
                )
            )

        for task in creative_selection.tasks:
            tasks.append(
                PlannedTask(
                    source="AI_GENERATED",
                    bank_id=None,
                    title_en=task.title_en,
                    title_ar=task.title_ar,
                    description_en=(
                        task.description_en
                    ),
                    description_ar=(
                        task.description_ar
                    ),
                    category=task.category,
                    points=task.points,
                    frequency=task.frequency,
                    reason=task.reason,
                )
            )

        weekly_points = 0

        for task in tasks:
            if task.frequency == "DAILY":
                weekly_points += (
                    task.points * 7
                )
            else:
                weekly_points += task.points

        is_cold_start = not (
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

        return WeeklyPlanDraft(
            summary_en=summary.summary_en,
            summary_ar=summary.summary_ar,
            total_tasks=len(tasks),
            weekly_points=weekly_points,
            is_cold_start=is_cold_start,
            tasks=tasks,
        )

    def _validate_plan(
        self,
        plan,
        performance_analysis,
        strategy,
    ):
        if (
            plan.total_tasks
            != strategy.total_tasks
        ):
            raise ValueError(
                "PlannerAgent plan task count "
                "does not match the strategy."
            )

        if (
            len(plan.tasks)
            != strategy.total_tasks
        ):
            raise ValueError(
                "PlannerAgent tasks list does "
                "not match the strategy task count."
            )

        category_counts = {
            "RELIGIOUS": 0,
            "FINANCIAL": 0,
            "MORAL": 0,
            "SOCIAL": 0,
        }

        for task in plan.tasks:
            category_counts[
                task.category
            ] += 1

        expected = (
            strategy.category_distribution
        )

        expected_counts = {
            "RELIGIOUS": expected.RELIGIOUS,
            "FINANCIAL": expected.FINANCIAL,
            "MORAL": expected.MORAL,
            "SOCIAL": expected.SOCIAL,
        }

        if (
            category_counts
            != expected_counts
        ):
            raise ValueError(
                "Final plan category distribution "
                "does not match the strategy."
            )

        recommended_points = (
            performance_analysis
            .recommended_weekly_points
        )

        allowed_difference = 20

        if (
            plan.weekly_points
            > recommended_points
            + allowed_difference
        ):
            raise ValueError(
                "Final weekly plan exceeds the "
                "recommended point target too much."
            )

        if (
            plan.weekly_points
            < recommended_points
            - allowed_difference
        ):
            raise ValueError(
                "Final weekly plan is too far below "
                "the recommended point target."
            )