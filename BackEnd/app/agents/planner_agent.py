import json
import os

from dotenv import load_dotenv
from langchain_openrouter import ChatOpenRouter

from app.agents.planner_schemas import (
    PlannedTask,
    WeeklyPlanDraft,
)


load_dotenv()


class PlannerAgent:
    def __init__(self):
        api_key = os.getenv("OPENROUTER_API_KEY")
        model_name = os.getenv("OPENROUTER_MODEL")

        if not api_key:
            raise ValueError("OPENROUTER_API_KEY is missing")

        if not model_name:
            raise ValueError("OPENROUTER_MODEL is missing")

        self.llm = ChatOpenRouter(
            model=model_name,
            api_key=api_key,
        )

        self.structured_llm = self.llm.with_structured_output(
            WeeklyPlanDraft,
            include_raw=True,
        )

    def build_plan(
        self,
        child_context,
        performance_analysis,
        strategy,
        bank_selection,
        creative_selection,
    ):
        prompt = self._build_prompt(
            child_context,
            performance_analysis,
            strategy,
            bank_selection,
            creative_selection,
        )

        response = self.structured_llm.invoke(prompt)

        result = response.get("parsed")
        parsing_error = response.get("parsing_error")

        if parsing_error:
            raise ValueError(
                f"PlannerAgent parsing failed: {parsing_error}"
            )

        if result is None:
            raise ValueError(
                "PlannerAgent failed to return structured output."
            )

        result = self._normalize_plan(
            result,
            child_context,
            bank_selection,
            creative_selection,
        )

        self._validate_plan(
            result,
            performance_analysis,
            strategy,
        )

        return result

    def _build_prompt(
        self,
        child_context,
        performance_analysis,
        strategy,
        bank_selection,
        creative_selection,
    ):
        context_json = json.dumps(
            child_context,
            ensure_ascii=False,
            indent=2,
            default=str,
        )

        performance_json = (
            performance_analysis.model_dump_json(
                indent=2,
            )
        )

        strategy_json = strategy.model_dump_json(
            indent=2,
        )

        bank_json = bank_selection.model_dump_json(
            indent=2,
        )

        creative_json = creative_selection.model_dump_json(
            indent=2,
        )

        return f"""
You are the Weekly Plan Assembly Agent for Asalah.

You do NOT create new tasks.

Your responsibility is to combine the already selected
bank tasks and AI-generated tasks into one coherent
weekly plan for the parent.

CHILD CONTEXT:
{context_json}

PERFORMANCE ANALYSIS:
{performance_json}

WEEKLY STRATEGY:
{strategy_json}

BANK TASKS:
{bank_json}

AI-GENERATED TASKS:
{creative_json}

Rules:

- Include every provided bank task.

- Include every provided AI-generated task.

- Do not remove tasks.

- Do not add tasks.

- Do not change task titles.

- Do not change descriptions.

- Do not change categories.

- Do not change frequencies.

- Do not change points.

- TASK BANK tasks must have source = TASK_BANK.

- AI-generated tasks must have source = AI_GENERATED.

- Bank tasks must preserve their bank_id.

- AI-generated tasks must have bank_id = null.

- Produce a short Arabic and English summary for the
  parent explaining the general purpose of the plan.

- Do not expose internal agent reasoning.

- Do not mention agents, prompts, models, validators,
  or technical implementation details.

Return only the required structured weekly plan.
"""

    def _normalize_plan(
        self,
        plan,
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
                    description_en=task.description_en,
                    description_ar=task.description_ar,
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
                    description_en=task.description_en,
                    description_ar=task.description_ar,
                    category=task.category,
                    points=task.points,
                    frequency=task.frequency,
                    reason=task.reason,
                )
            )

        plan.tasks = tasks
        plan.total_tasks = len(tasks)

        weekly_points = 0

        for task in tasks:
            if task.frequency == "DAILY":
                weekly_points += task.points * 7
            else:
                weekly_points += task.points

        plan.weekly_points = weekly_points

        plan.is_cold_start = not (
            child_context
            .get("history_summary", {})
            .get("has_enough_history", False)
        )

        return plan

    def _validate_plan(
        self,
        plan,
        performance_analysis,
        strategy,
    ):
        if plan.total_tasks != strategy.total_tasks:
            raise ValueError(
                "PlannerAgent plan task count does not match "
                "the strategy."
            )

        if len(plan.tasks) != strategy.total_tasks:
            raise ValueError(
                "PlannerAgent tasks list does not match "
                "the strategy task count."
            )

        category_counts = {
            "RELIGIOUS": 0,
            "FINANCIAL": 0,
            "MORAL": 0,
            "SOCIAL": 0,
        }

        for task in plan.tasks:
            category_counts[task.category] += 1

        expected = strategy.category_distribution

        expected_counts = {
            "RELIGIOUS": expected.RELIGIOUS,
            "FINANCIAL": expected.FINANCIAL,
            "MORAL": expected.MORAL,
            "SOCIAL": expected.SOCIAL,
        }

        if category_counts != expected_counts:
            raise ValueError(
                "Final plan category distribution does not "
                "match the strategy."
            )

        recommended_points = (
            performance_analysis.recommended_weekly_points
        )

        allowed_difference = 20

        if (
            plan.weekly_points
            > recommended_points + allowed_difference
        ):
            raise ValueError(
                "Final weekly plan exceeds the recommended "
                "point target too much."
            )

        if (
            plan.weekly_points
            < recommended_points - allowed_difference
        ):
            raise ValueError(
                "Final weekly plan is too far below the "
                "recommended point target."
            )