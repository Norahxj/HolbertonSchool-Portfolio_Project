import json
import os

from dotenv import load_dotenv
from langchain_openrouter import ChatOpenRouter

from app.agents.performance_schemas import (
    ChildPerformanceAnalysis,
)
from app.agents.strategy_schemas import (
    WeeklyPlanStrategy,
)


load_dotenv()


class StrategyAgent:
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
                WeeklyPlanStrategy,
                include_raw=True,
            )
        )

    def create_strategy(
        self,
        child_context,
        performance_analysis: ChildPerformanceAnalysis,
        revision_feedback="",
    ):
        max_attempts = 3
        validation_errors = []

        for _ in range(max_attempts):
            prompt = self._build_prompt(
                child_context,
                performance_analysis,
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
                        "strategy was returned."
                    )
                ]
                continue

            try:
                self._validate_strategy(
                    result,
                    performance_analysis,
                )

                return result

            except ValueError as error:
                validation_errors = [
                    str(error)
                ]

        raise ValueError(
            "StrategyAgent failed to produce "
            "a valid strategy after 3 attempts."
        )

    def _build_prompt(
        self,
        child_context,
        performance_analysis,
        validation_errors=None,
        revision_feedback="",
    ):
        compact_context = (
            self._build_compact_child_context(
                child_context
            )
        )

        context_json = json.dumps(
            compact_context,
            ensure_ascii=False,
            separators=(",", ":"),
            default=str,
        )

        analysis_json = (
            performance_analysis
            .model_dump_json()
        )

        validation_feedback = ""

        if validation_errors:
            errors_text = "\n".join(
                f"- {error}"
                for error in validation_errors
            )

            validation_feedback = f"""
PREVIOUS STRATEGY ATTEMPT FAILED VALIDATION.

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

Correct only the problems relevant to strategy.

You may revise:
- bank_tasks
- generated_tasks
- category_distribution
- focus
- avoid

You MUST still respect the Performance Agent's
recommended task count and workload.

Do not repeat the same rejected strategic pattern.
"""

        return f"""
You are the Weekly Planning Strategy Agent for Asalah.

You DO NOT choose actual tasks.

Your ONLY responsibility is to decide how the weekly
plan should be composed.

The Performance Agent has already analyzed the child's
raw history.

CHILD SUMMARY:
{context_json}

PERFORMANCE ANALYSIS:
{analysis_json}

DECIDE:

1. How many tasks come from the task bank.

2. How many tasks are newly generated.

3. How total tasks are distributed across:
   RELIGIOUS
   FINANCIAL
   MORAL
   SOCIAL

4. The main focus of this week's plan.

5. Patterns or task types that should be avoided.

RULES:

- total_tasks MUST equal
  performance_analysis.recommended_task_count.

- bank_tasks + generated_tasks MUST equal total_tasks.

- The sum of all category_distribution values
  MUST equal total_tasks.

- Do not create task titles.

- Do not create task descriptions.

- Do not recommend specific tasks.

- Use the Performance Analysis as the primary source
  for strengths, weaknesses, workload, and point target.

- Use the child summary only as supporting context.

- Weak categories may receive extra attention, but
  the plan must remain reasonably balanced.

- Strong categories may still be represented.

- For cold-start cases, prefer a balanced distribution
  and do not invent strengths or weaknesses.

- The task bank should provide stable proven tasks.

- Generated tasks should provide personalization
  and variety.

- Do not assume facts that are not present in the data.

- A rejected task does NOT mean the entire category
  should be avoided.

- Avoid unsuccessful task patterns, but the same
  category may be approached differently.

- Weak categories should normally receive gradual,
  easier attention rather than being removed.

- Do not invent historical time periods.

- Do not claim that the Performance Agent recommended
  something unless it appears in PERFORMANCE ANALYSIS.

- Respect the Performance Agent's recommended weekly
  point target.

- Do not increase workload simply to reach a wishlist
  goal faster.

{validation_feedback}

{evaluator_feedback}

Return only the required structured strategy.
"""

    def _build_compact_child_context(
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
                "name": goal.get(
                    "name",
                    "",
                ),
                "target_points": goal.get(
                    "target_points",
                    0,
                ),
                "remaining_points": goal.get(
                    "remaining_points",
                    0,
                ),
            })

        return {
            "age": child.get(
                "age"
            ),
            "current_points": child.get(
                "current_points",
                0,
            ),
            "completion_rate": (
                history_summary.get(
                    "completion_rate",
                    0,
                )
            ),
            "has_enough_history": (
                history_summary.get(
                    "has_enough_history",
                    False,
                )
            ),
            "category_history": (
                history_summary.get(
                    "categories",
                    {},
                )
            ),
            "rejected_task_patterns": (
                rejected_tasks
            ),
            "active_goals": (
                active_goals
            ),
        }

    def _validate_strategy(
        self,
        strategy,
        performance_analysis,
    ):
        expected_total = (
            performance_analysis
            .recommended_task_count
        )

        if strategy.total_tasks != expected_total:
            raise ValueError(
                "Strategy total_tasks does not "
                "match PerformanceAgent "
                "recommendation."
            )

        source_total = (
            strategy.bank_tasks
            + strategy.generated_tasks
        )

        if source_total != strategy.total_tasks:
            raise ValueError(
                "bank_tasks + generated_tasks "
                "must equal total_tasks."
            )

        category_total = (
            strategy
            .category_distribution
            .RELIGIOUS
            + strategy
            .category_distribution
            .FINANCIAL
            + strategy
            .category_distribution
            .MORAL
            + strategy
            .category_distribution
            .SOCIAL
        )

        if category_total != strategy.total_tasks:
            raise ValueError(
                "Category distribution must "
                "equal total_tasks."
            )