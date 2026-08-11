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
            GeneratedTaskSelection,
            include_raw=True,
        )

    def generate_tasks(
        self,
        child_context,
        performance_analysis,
        strategy,
        bank_selection,
    ):
        max_attempts = 3
        validation_errors = []

        for attempt in range(max_attempts):
            prompt = self._build_prompt(
                child_context,
                performance_analysis,
                strategy,
                bank_selection,
                validation_errors,
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
                    (
                        "No valid structured generated "
                        "tasks were returned."
                    )
                ]
                continue

            try:
                self._validate_generated_tasks(
                    result,
                    strategy,
                    bank_selection,
                    performance_analysis,
                )

                return result

            except ValueError as error:
                validation_errors = [
                    str(error)
                ]

        raise ValueError(
            "CreativeAgent failed to produce valid tasks "
            "after 3 attempts."
        )

    def _build_prompt(
        self,
        child_context,
        performance_analysis,
        strategy,
        bank_selection,
        validation_errors=None,
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

        return f"""
You are the Creative Task Generation Agent for Asalah.

Your responsibility is to create NEW personalized tasks
for the child.

Do NOT copy tasks from the selected bank tasks.

CHILD CONTEXT:
{context_json}

PERFORMANCE ANALYSIS:
{performance_json}

WEEKLY STRATEGY:
{strategy_json}

TASKS ALREADY SELECTED FROM THE BANK:
{bank_json}

Generate exactly strategy.generated_tasks new tasks.

Your generated tasks should complement the bank tasks
so that the COMPLETE weekly plan follows the Strategy
Agent's category distribution as closely as possible.

Rules:

- Tasks must be appropriate for the child's age.

- Tasks must be safe, realistic, and clearly actionable.

- Do not assume siblings, pets, allowance, possessions,
  school circumstances, holidays, or access to specific
  resources unless present in the child data.

- Do not generate seasonal Ramadan or Eid tasks unless
  currently relevant according to the child context.

- Consider previous rejected tasks.

- Do not simply repeat a rejected task using different
  wording.

- Weak categories should be approached gradually with
  achievable tasks.

- Do not duplicate the bank-selected tasks.

- Do not generate two tasks that are essentially the same.

- DAILY tasks should have low points because they can
  repeat throughout the week.

- DAILY tasks should normally be worth between
  2 and 5 points per completion.

- WEEKLY and ONCE tasks may have higher points according
  to effort.

- Consider how many weekly points are already contributed
  by the selected bank tasks.

- Keep the Performance Agent's recommended weekly point
  target in mind.

- The combined points from bank tasks and generated tasks
  should remain close to the recommended weekly target.

- Provide both Arabic and English titles and descriptions.

- Explain why each generated task is appropriate for this
  specific plan.

- Never assume the child owns toys, books, money,
  devices, pets, or other possessions unless explicitly
  stated in the child context.

- Never assume the child has siblings.

- Do not require a specific friend, neighbor, or other
  person unless the child context establishes that such
  a person is available.

- Prefer tasks that the child can perform using only
  information and resources explicitly known from the
  child context.

{validation_feedback}

Return only the required structured generated tasks.
"""

    def _validate_generated_tasks(
        self,
        selection,
        strategy,
        bank_selection,
        performance_analysis,
    ):
        if len(selection.tasks) != strategy.generated_tasks:
            raise ValueError(
                "CreativeAgent returned the wrong number of tasks."
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
            title_en = task.title_en.strip().lower()
            title_ar = task.title_ar.strip()

            if title_en in bank_titles_en:
                raise ValueError(
                    "Generated task duplicates bank task: "
                    f'"{task.title_en}"'
                )

            if title_ar in bank_titles_ar:
                raise ValueError(
                    "Generated task duplicates bank task: "
                    f'"{task.title_ar}"'
                )

            if title_en in generated_titles_en:
                raise ValueError(
                    "Duplicate generated task: "
                    f'"{task.title_en}"'
                )

            if title_ar in generated_titles_ar:
                raise ValueError(
                    "Duplicate generated task: "
                    f'"{task.title_ar}"'
                )

            generated_titles_en.add(title_en)
            generated_titles_ar.add(title_ar)

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
                if phrase.lower() in combined_text:
                    raise ValueError(
                        f'Generated task "{task.title_en}" '
                        "may rely on an unsupported "
                        f'assumption: "{phrase}".'
                    )

        total_weekly_points = 0

        for task in bank_selection.tasks:
            if task.frequency == "DAILY":
                total_weekly_points += task.points * 7
            else:
                total_weekly_points += task.points

        for task in selection.tasks:
            if task.frequency == "DAILY":
                total_weekly_points += task.points * 7
            else:
                total_weekly_points += task.points

        recommended_weekly_points = (
            performance_analysis
            .recommended_weekly_points
        )

        allowed_difference = 20

        if (
            total_weekly_points
            > recommended_weekly_points + allowed_difference
        ):
            raise ValueError(
                "Combined bank and generated tasks exceed "
                "the recommended weekly point target too much. "
                f"Current total: {total_weekly_points}, "
                f"recommended: {recommended_weekly_points}."
            )

        if (
            total_weekly_points
            < recommended_weekly_points - allowed_difference
        ):
            raise ValueError(
                "Combined bank and generated tasks are too far "
                "below the recommended weekly point target. "
                f"Current total: {total_weekly_points}, "
                f"recommended: {recommended_weekly_points}."
            )