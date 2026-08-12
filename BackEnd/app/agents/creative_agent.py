import json
import os

from dotenv import load_dotenv
from langchain_openrouter import ChatOpenRouter

from app.agents.creative_task_schemas import (
    GeneratedTaskSelection,
)


load_dotenv()


class CreativeAgent:
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
                GeneratedTaskSelection,
                include_raw=True,
            )
        )

    def generate_tasks(
        self,
        child_context,
        performance_analysis,
        strategy,
        bank_selection,
        revision_feedback="",
    ):
        max_attempts = 3
        validation_errors = []

        for attempt in range(max_attempts):
            attempt_number = attempt + 1

            print(
                "[CREATIVE_AGENT] "
                f"Attempt {attempt_number} started",
                flush=True,
            )

            prompt = self._build_prompt(
                child_context,
                performance_analysis,
                strategy,
                bank_selection,
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
                error_message = (
                    "Structured output parsing "
                    "failed: "
                    f"{parsing_error}"
                )

                validation_errors = [
                    error_message
                ]

                print(
                    "[CREATIVE_AGENT] "
                    f"Attempt {attempt_number} "
                    f"parsing failed: "
                    f"{parsing_error}",
                    flush=True,
                )

                continue

            if result is None:
                error_message = (
                    "No valid structured generated "
                    "tasks were returned."
                )

                validation_errors = [
                    error_message
                ]

                print(
                    "[CREATIVE_AGENT] "
                    f"Attempt {attempt_number} "
                    "returned no parsed result",
                    flush=True,
                )

                continue

            try:
                self._validate_generated_tasks(
                    result,
                    strategy,
                    bank_selection,
                    performance_analysis,
                )

                print(
                    "[CREATIVE_AGENT] "
                    f"Attempt {attempt_number} "
                    "passed validation",
                    flush=True,
                )

                return result

            except ValueError as error:
                error_message = str(
                    error
                )

                validation_errors = [
                    error_message
                ]

                print(
                    "[CREATIVE_AGENT] "
                    f"Attempt {attempt_number} "
                    "failed validation: "
                    f"{error_message}",
                    flush=True,
                )

        final_error = (
            validation_errors[-1]
            if validation_errors
            else "Unknown validation error."
        )

        raise ValueError(
            "CreativeAgent failed to produce "
            "valid tasks after 3 attempts. "
            f"Last error: {final_error}"
        )

    def _build_prompt(
        self,
        child_context,
        performance_analysis,
        strategy,
        bank_selection,
        validation_errors=None,
        revision_feedback="",
    ):
        compact_context = (
            self._build_compact_child_context(
                child_context
            )
        )

        compact_bank = (
            self._build_compact_bank_selection(
                bank_selection
            )
        )

        context_json = json.dumps(
            compact_context,
            ensure_ascii=False,
            separators=(",", ":"),
            default=str,
        )

        performance_json = (
            performance_analysis
            .model_dump_json()
        )

        strategy_json = (
            strategy
            .model_dump_json()
        )

        bank_json = json.dumps(
            compact_bank,
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
PREVIOUS ATTEMPT WAS REJECTED.

VALIDATION ERRORS:
{errors_text}

Generate a new selection that corrects every error.
"""

        evaluator_feedback = ""

        if revision_feedback:
            evaluator_feedback = f"""
THE PREVIOUS COMPLETE WEEKLY PLAN WAS REJECTED
BY THE EVALUATOR.

EVALUATOR FEEDBACK:
{revision_feedback}

Correct only the problems relevant to the Creative Agent.

Do not repeat the same rejected task, unsupported
assumption, or problematic pattern.
"""

        return f"""
You are the Creative Task Generation Agent for Asalah.

Your responsibility is to create NEW personalized tasks
for the child.

You MUST NOT copy tasks from the selected bank tasks.

CHILD SUPPORTING CONTEXT:
{context_json}

PERFORMANCE ANALYSIS:
{performance_json}

WEEKLY STRATEGY:
{strategy_json}

SELECTED BANK TASKS:
{bank_json}

Generate exactly strategy.generated_tasks new tasks.

The generated tasks must complement the selected bank
tasks so the COMPLETE weekly plan follows the Strategy
Agent's category distribution.

RULES:

- Tasks must be appropriate for the child's age.

- Tasks must be safe, realistic, and clearly actionable.

- Use the Performance Analysis as the primary source for
  strengths, weaknesses, difficulty, workload, and point
  target.

- Use the Strategy as the primary source for category
  distribution, focus, and avoid patterns.

- Use CHILD SUPPORTING CONTEXT only for age, rejected
  patterns, and active goals.

- Do not assume siblings, pets, allowance, possessions,
  school circumstances, holidays, or specific resources
  unless explicitly present in the child data.

- Do not generate Ramadan or Eid tasks unless currently
  relevant in the child context.

- Do not simply rephrase a previously rejected task.

- Weak categories should be approached gradually with
  achievable tasks.

- Do not duplicate selected bank tasks.

- Do not generate two tasks that are essentially the same.

- DAILY tasks should normally be worth between
  2 and 5 points per completion.

- WEEKLY and ONCE tasks may have higher points according
  to effort.

- Consider the weekly points already contributed by
  selected bank tasks.

- Keep the complete weekly plan close to the Performance
  Agent's recommended weekly point target.

- Provide both Arabic and English titles and descriptions.

- Keep descriptions concise and actionable.

- Give a short practical reason for each generated task.

- Never assume the child owns toys, books, money,
  devices, pets, or other possessions unless explicitly
  established.

- Never assume the child has siblings.

- Do not require a specific friend, neighbor, or other
  person unless the context establishes availability.

{validation_feedback}

{evaluator_feedback}

Return only the required structured generated tasks.
"""

    def _build_compact_child_context(
        self,
        child_context,
    ):
        child = child_context.get(
            "child",
            {},
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
                "description": task.get(
                    "description",
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
                "progress_percentage": goal.get(
                    "progress_percentage",
                    0,
                ),
            })

        return {
            "age": child.get(
                "age"
            ),
            "rejected_task_patterns": (
                rejected_tasks
            ),
            "active_goals": (
                active_goals
            ),
        }

    def _build_compact_bank_selection(
        self,
        bank_selection,
    ):
        compact_tasks = []

        for task in bank_selection.tasks:
            compact_tasks.append({
                "bank_id": task.bank_id,
                "title_en": task.title_en,
                "title_ar": task.title_ar,
                "category": task.category,
                "points": task.points,
                "frequency": task.frequency,
            })

        return {
            "tasks": compact_tasks
        }

    def _validate_generated_tasks(
        self,
        selection,
        strategy,
        bank_selection,
        performance_analysis,
    ):
        if (
            len(selection.tasks)
            != strategy.generated_tasks
        ):
            raise ValueError(
                "CreativeAgent returned the wrong "
                "number of tasks."
            )

        forbidden_assumptions = [
            "sibling",
            "siblings",
            "brother",
            "sister",
            "toy",
            "toys",
            "allowance",
            "pet",
            "pets",
            "أخ",
            "أخت",
            "إخوة",
            "اخوة",
            "لعبة",
            "ألعاب",
            "مصروف",
            "حيوان أليف",
        ]

        bank_titles_en = {
            task.title_en.strip().lower()
            for task in bank_selection.tasks
        }

        bank_titles_ar = {
            task.title_ar.strip()
            for task in bank_selection.tasks
        }

        generated_titles_en = set()
        generated_titles_ar = set()

        for task in selection.tasks:
            title_en = (
                task.title_en
                .strip()
                .lower()
            )

            title_ar = (
                task.title_ar
                .strip()
            )

            if title_en in bank_titles_en:
                raise ValueError(
                    "Generated task duplicates "
                    "bank task: "
                    f'"{task.title_en}"'
                )

            if title_ar in bank_titles_ar:
                raise ValueError(
                    "Generated task duplicates "
                    "bank task: "
                    f'"{task.title_ar}"'
                )

            if (
                title_en
                in generated_titles_en
            ):
                raise ValueError(
                    "Duplicate generated task: "
                    f'"{task.title_en}"'
                )

            if (
                title_ar
                in generated_titles_ar
            ):
                raise ValueError(
                    "Duplicate generated task: "
                    f'"{task.title_ar}"'
                )

            generated_titles_en.add(
                title_en
            )

            generated_titles_ar.add(
                title_ar
            )

            if task.frequency == "DAILY":
                if task.points > 5:
                    raise ValueError(
                        f'DAILY generated task '
                        f'"{task.title_en}" '
                        "has more than 5 points."
                    )

            combined_text = (
                f"{task.title_en} "
                f"{task.title_ar} "
                f"{task.description_en} "
                f"{task.description_ar}"
            ).lower()

            for phrase in forbidden_assumptions:
                if (
                    phrase.lower()
                    in combined_text
                ):
                    raise ValueError(
                        f'Generated task '
                        f'"{task.title_en}" '
                        "may rely on an "
                        "unsupported assumption: "
                        f'"{phrase}".'
                    )

        total_weekly_points = 0

        for task in bank_selection.tasks:
            if task.frequency == "DAILY":
                total_weekly_points += (
                    task.points * 7
                )
            else:
                total_weekly_points += (
                    task.points
                )

        for task in selection.tasks:
            if task.frequency == "DAILY":
                total_weekly_points += (
                    task.points * 7
                )
            else:
                total_weekly_points += (
                    task.points
                )

        recommended_weekly_points = (
            performance_analysis
            .recommended_weekly_points
        )

        allowed_difference = 20

        if (
            total_weekly_points
            > recommended_weekly_points
            + allowed_difference
        ):
            raise ValueError(
                "Combined bank and generated tasks "
                "exceed the recommended weekly point "
                "target too much. "
                f"Current total: "
                f"{total_weekly_points}, "
                f"recommended: "
                f"{recommended_weekly_points}."
            )

        if (
            total_weekly_points
            < recommended_weekly_points
            - allowed_difference
        ):
            raise ValueError(
                "Combined bank and generated tasks "
                "are too far below the recommended "
                "weekly point target. "
                f"Current total: "
                f"{total_weekly_points}, "
                f"recommended: "
                f"{recommended_weekly_points}."
            )