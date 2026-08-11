import json
import os

from dotenv import load_dotenv
from langchain_openrouter import ChatOpenRouter

from app.agents.bank_task_schemas import (
    BankTaskSelection,
)
from app.services.task_bank_service import (
    TaskBankService,
)


load_dotenv()


class BankAgent:
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
            BankTaskSelection,
            include_raw=True,
        )

        self.task_bank_service = TaskBankService()

    def select_tasks(
        self,
        child_context,
        performance_analysis,
        strategy,
        revision_feedback="",
    ):
        age = child_context["child"]["age"]

        suitable_tasks = (
            self.task_bank_service
            .get_suitable_tasks_for_age(age)
        )

        max_attempts = 3
        validation_errors = []

        for attempt in range(max_attempts):
            prompt = self._build_prompt(
                child_context,
                performance_analysis,
                strategy,
                suitable_tasks,
                validation_errors,
                revision_feedback,
            )

            response = self.structured_llm.invoke(prompt)

            result = response.get("parsed")
            parsing_error = response.get("parsing_error")

            if parsing_error:
                validation_errors = [
                    (
                        "Structured output parsing failed: "
                        f"{parsing_error}"
                    )
                ]
                continue

            if result is None:
                validation_errors = [
                    "No valid structured selection was returned."
                ]
                continue

            try:
                self._validate_selection(
                    result,
                    suitable_tasks,
                    strategy,
                    performance_analysis,
                )

                return result

            except ValueError as error:
                validation_errors = [
                    str(error)
                ]

        raise ValueError(
            "BankAgent failed to produce a valid selection "
            "after 3 attempts."
        )

    def _build_prompt(
        self,
        child_context,
        performance_analysis,
        strategy,
        suitable_tasks,
        validation_errors=None,
        revision_feedback="",
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

        bank_json = json.dumps(
            suitable_tasks,
            ensure_ascii=False,
            indent=2,
            default=str,
        )

        validation_feedback = ""

        if validation_errors:
            errors_text = "\n".join(
                f"- {error}"
                for error in validation_errors
            )

            validation_feedback = f"""
PREVIOUS ATTEMPT WAS REJECTED BY THE
BANK AGENT VALIDATOR.

VALIDATION ERRORS:
{errors_text}

Correct every validation error in the new selection.
"""

        evaluator_feedback = ""

        if revision_feedback:
            evaluator_feedback = f"""
THE PREVIOUS COMPLETE WEEKLY PLAN WAS REJECTED
BY THE EVALUATOR.

EVALUATOR FEEDBACK:
{revision_feedback}

Correct the problems relevant to the Bank Agent.

Select different bank tasks when necessary.

You may also adjust the planned points when appropriate.

Do not repeat the same rejected selection or problematic
pattern.

Remember that changing planned points does NOT modify
the original task bank.

You must still preserve the original bank task identity,
titles, descriptions, category, and frequency.
"""

        return f"""
You are the Task Bank Selection Agent for Asalah.

Your responsibility is ONLY to choose tasks from
the provided Asalah task bank.

You MUST NOT create new tasks.

CHILD CONTEXT:
{context_json}

PERFORMANCE ANALYSIS:
{performance_json}

WEEKLY STRATEGY:
{strategy_json}

AVAILABLE TASK BANK:
{bank_json}

Your job:

- Select exactly strategy.bank_tasks tasks.

- Every selected task MUST exist in AVAILABLE TASK BANK.

- Copy the exact bank_id from the task bank.

- Preserve the original task titles.

- Preserve the original task descriptions.

- Preserve the original category.

- Preserve the original suggested frequency.

- You MAY adjust the task points for this weekly plan.

- Changing points does NOT modify the original task bank.

- default_points from the task bank is only a reference
  value, not a required value for this weekly plan.

- Adjust points when necessary so the task fits the
  child's workload, difficulty level, and recommended
  weekly point target.

- Points must remain proportional to task difficulty.

- DAILY tasks may repeat up to 7 times during the week.

- DAILY tasks should normally be worth between
  2 and 5 points per completion.

- For weekly point estimation:
  DAILY = points × 7
  all other frequencies = points once.

- Consider the Performance Agent's
  recommended_weekly_points.

- Do not choose bank tasks whose combined weekly point
  contribution would make it impossible to build a
  reasonable complete weekly plan.

- Choose tasks that match the Strategy Agent's
  category distribution as closely as possible.

- Consider the child's previous task history.

- Avoid repeating previously rejected task patterns
  when a more suitable bank task exists.

- A rejected task does not mean the entire category
  should be avoided.

- Weak categories should normally receive a simpler
  or more suitable task.

- Do not assume siblings, pets, allowance, school
  circumstances, holidays, possessions, or other
  personal details that are not present in the
  child context.

- Do not select seasonal tasks such as Ramadan or Eid
  unless the child context explicitly indicates that
  they are currently relevant.

- Explain briefly why each task was selected.

{validation_feedback}

{evaluator_feedback}

Return only the required structured bank task selection.
"""

    def _validate_selection(
        self,
        selection,
        suitable_tasks,
        strategy,
        performance_analysis,
    ):
        if len(selection.tasks) != strategy.bank_tasks:
            raise ValueError(
                "BankAgent returned the wrong number of tasks."
            )

        available_by_id = {
            task["bank_id"]: task
            for task in suitable_tasks
        }

        selected_ids = set()

        weekly_points = 0

        for selected_task in selection.tasks:
            if selected_task.bank_id not in available_by_id:
                raise ValueError(
                    f"Unknown bank_id: {selected_task.bank_id}"
                )

            if selected_task.bank_id in selected_ids:
                raise ValueError(
                    f"Duplicate bank task: "
                    f"{selected_task.bank_id}"
                )

            selected_ids.add(
                selected_task.bank_id
            )

            original = available_by_id[
                selected_task.bank_id
            ]

            if selected_task.title_en != original["title_en"]:
                raise ValueError(
                    "BankAgent changed title_en for "
                    f"{selected_task.bank_id}"
                )

            if selected_task.title_ar != original["title_ar"]:
                raise ValueError(
                    "BankAgent changed title_ar for "
                    f"{selected_task.bank_id}"
                )

            if (
                selected_task.description_en
                != original["description_en"]
            ):
                raise ValueError(
                    "BankAgent changed description_en for "
                    f"{selected_task.bank_id}"
                )

            if (
                selected_task.description_ar
                != original["description_ar"]
            ):
                raise ValueError(
                    "BankAgent changed description_ar for "
                    f"{selected_task.bank_id}"
                )

            if selected_task.category != original["category"]:
                raise ValueError(
                    "BankAgent changed category for "
                    f"{selected_task.bank_id}"
                )

            if (
                selected_task.frequency
                != original["suggested_frequency"]
            ):
                raise ValueError(
                    "BankAgent changed frequency for "
                    f"{selected_task.bank_id}"
                )

            if selected_task.points < 1:
                raise ValueError(
                    f'Bank task "{selected_task.title_en}" '
                    "must have at least 1 point."
                )

            if selected_task.points > 50:
                raise ValueError(
                    f'Bank task "{selected_task.title_en}" '
                    "cannot exceed 50 points."
                )

            if selected_task.frequency == "DAILY":
                if selected_task.points > 5:
                    raise ValueError(
                        f'DAILY bank task '
                        f'"{selected_task.title_en}" '
                        f"has {selected_task.points} points. "
                        "DAILY tasks must have no more than "
                        "5 points per completion."
                    )

                weekly_points += (
                    selected_task.points * 7
                )

            else:
                weekly_points += selected_task.points

        recommended_weekly_points = (
            performance_analysis
            .recommended_weekly_points
        )

        if weekly_points > recommended_weekly_points:
            raise ValueError(
                "Bank-selected tasks alone exceed the "
                "Performance Agent's recommended weekly "
                f"point target. Bank contribution: "
                f"{weekly_points}, target: "
                f"{recommended_weekly_points}."
            )