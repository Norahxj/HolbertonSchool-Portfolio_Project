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

Correct only strategy-level problems.

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

Your ONLY responsibility is to decide how the weekly
plan should be composed.

You DO NOT choose actual tasks.

The Performance Agent has already determined:
- performance level
- workload
- weekly point target
- difficulty
- strong categories
- weak categories
- cold-start status

CHILD SUPPORTING CONTEXT:
{context_json}

PERFORMANCE ANALYSIS:
{analysis_json}

DECIDE:

1. bank_tasks

2. generated_tasks

3. category_distribution across:
   RELIGIOUS
   FINANCIAL
   MORAL
   SOCIAL

4. a short weekly focus

5. task patterns to avoid

RULES:

- total_tasks MUST equal
  performance_analysis.recommended_task_count.

- bank_tasks + generated_tasks MUST equal total_tasks.

- category_distribution values MUST sum to total_tasks.

- Do not create or suggest specific tasks.

- Use Performance Analysis as the primary source for
  workload, strengths, weaknesses, difficulty,
  cold-start status, and weekly points.

- Use child context only for age and rejected patterns.

- Weak categories may receive gradual attention.

- A weak category does not need to be excluded.

- Strong categories may still be represented.

- Cold-start plans should be reasonably balanced.

- Do not invent strengths or weaknesses for cold start.

- The bank provides stable existing tasks.

- Generated tasks provide personalization and variety.

- A rejected task does not mean the whole category
  should be avoided.

- Avoid unsuccessful task patterns when possible.

- Do not increase workload to reach goals faster.

- Keep focus under 150 characters.

- Keep strategy_reasoning under 250 characters.

- Keep avoid concise.

- Do not invent facts.

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

        task_history = (
            child_context.get(
                "task_history",
                [],
            )
        )

        wishlist_summary = (
            child_context.get(
                "wishlist_summary",
                {},
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

        return {
            "age": child.get(
                "age"
            ),
            "rejected_task_patterns": (
                rejected_tasks
            ),
            "active_goals_count": len(
                wishlist_summary.get(
                    "active_goals",
                    [],
                )
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
                "match PerformanceAgent recommendation."
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