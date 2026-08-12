import json
import os

from dotenv import load_dotenv
from langchain_openrouter import ChatOpenRouter

from app.agents.bank_task_schemas import (
    BankTaskSelection,
    BankTaskSelectionDecision,
    SelectedBankTask,
)
from app.services.task_bank_service import (
    TaskBankService,
)


load_dotenv()


class BankAgent:
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
                BankTaskSelectionDecision,
                include_raw=True,
            )
        )

        self.task_bank_service = (
            TaskBankService()
        )

    def select_tasks(
        self,
        child_context,
        performance_analysis,
        strategy,
        revision_feedback="",
    ):
        age = (
            child_context
            .get("child", {})
            .get("age")
        )

        if age is None:
            raise ValueError(
                "Child age is required "
                "for bank task selection."
            )

        category_counts = {
            "RELIGIOUS": (
                strategy
                .category_distribution
                .RELIGIOUS
            ),
            "FINANCIAL": (
                strategy
                .category_distribution
                .FINANCIAL
            ),
            "MORAL": (
                strategy
                .category_distribution
                .MORAL
            ),
            "SOCIAL": (
                strategy
                .category_distribution
                .SOCIAL
            ),
        }

        candidate_tasks = (
            self.task_bank_service
            .get_ai_candidates(
                age=age,
                child_context=child_context,
                category_counts=category_counts,
                limit=24,
            )
        )

        if (
            len(candidate_tasks)
            < strategy.bank_tasks
        ):
            raise ValueError(
                "Not enough suitable task-bank "
                "candidates for the weekly strategy."
            )

        max_attempts = 3
        validation_errors = []

        for _ in range(max_attempts):
            prompt = self._build_prompt(
                child_context,
                performance_analysis,
                strategy,
                candidate_tasks,
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
                        "selection was returned."
                    )
                ]

                continue

            try:
                self._validate_decision(
                    result,
                    candidate_tasks,
                    strategy,
                    performance_analysis,
                )

                return self._build_selection(
                    result,
                    candidate_tasks,
                )

            except ValueError as error:
                validation_errors = [
                    str(error)
                ]

        raise ValueError(
            "BankAgent failed to produce "
            "a valid selection after 3 attempts."
        )

    def _build_prompt(
        self,
        child_context,
        performance_analysis,
        strategy,
        candidate_tasks,
        validation_errors=None,
        revision_feedback="",
    ):
        compact_context = (
            self._build_compact_child_context(
                child_context
            )
        )

        compact_candidates = (
            self._build_compact_candidates(
                candidate_tasks
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
            strategy.model_dump_json()
        )

        bank_json = json.dumps(
            compact_candidates,
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
PREVIOUS ATTEMPT FAILED VALIDATION.

ERRORS:
{errors_text}

Correct every listed error.
"""

        evaluator_feedback = ""

        if revision_feedback:
            evaluator_feedback = f"""
THE PREVIOUS COMPLETE PLAN WAS REJECTED.

EVALUATOR FEEDBACK:
{revision_feedback}

Correct only the issues relevant to bank-task
selection.

Choose different bank tasks when needed and adjust
planned points when appropriate.

Do not repeat the same problematic selection.
"""

        return f"""
You are the Task Bank Selection Agent for Asalah.

Your ONLY responsibility is to choose existing tasks
from the provided task-bank candidates.

You MUST NOT create new tasks.

The backend has already:
- filtered tasks for the child's age
- filtered irrelevant categories
- removed obvious unsupported assumptions
- ranked suitable candidates

CHILD INFORMATION:
{context_json}

PERFORMANCE ANALYSIS:
{performance_json}

WEEKLY STRATEGY:
{strategy_json}

TASK BANK CANDIDATES:
{bank_json}

For every selected task, return ONLY:

- bank_id
- points
- reason

Do NOT return or rewrite:
- titles
- descriptions
- category
- frequency

The backend will restore those fields directly
from the task bank.

RULES:

- Select exactly strategy.bank_tasks tasks.

- Every bank_id MUST come from TASK BANK CANDIDATES.

- Do not select the same bank_id more than once.

- Points must remain proportional to task difficulty.

- DAILY tasks should normally be worth
  2 to 5 points per completion.

- DAILY tasks may repeat up to 7 times.

- Weekly point estimation:
  DAILY = points × 7
  other frequencies = points once.

- Respect the Performance Agent's
  recommended_weekly_points.

- Bank-selected tasks must leave room in the weekly
  points target for generated tasks.

- Match the Strategy Agent's category distribution
  as closely as possible.

- Use previous task information to avoid unnecessary
  repetition.

- Avoid previously rejected task patterns when
  a better candidate exists.

- A rejected task does NOT mean the whole category
  should be avoided.

- Weak categories should receive simpler or more
  suitable tasks.

- Do not introduce unsupported assumptions.

- Keep each reason short and practical.

{validation_feedback}

{evaluator_feedback}

Return only the required structured bank-task decision.
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

        task_history = (
            child_context.get(
                "task_history",
                [],
            )
        )

        compact_history = []

        for task in task_history:
            compact_history.append({
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
                "status": task.get(
                    "status",
                    "",
                ),
            })

        return {
            "age": child.get(
                "age"
            ),
            "completion_rate": (
                history_summary.get(
                    "completion_rate",
                    0,
                )
            ),
            "category_history": (
                history_summary.get(
                    "categories",
                    {},
                )
            ),
            "previous_tasks": (
                compact_history
            ),
        }

    def _build_compact_candidates(
        self,
        candidate_tasks,
    ):
        compact_candidates = []

        for task in candidate_tasks:
            compact_candidates.append({
                "bank_id": task[
                    "bank_id"
                ],
                "title_en": task[
                    "title_en"
                ],
                "title_ar": task[
                    "title_ar"
                ],
                "description_en": task[
                    "description_en"
                ],
                "description_ar": task[
                    "description_ar"
                ],
                "default_points": task[
                    "default_points"
                ],
                "suggested_frequency": task[
                    "suggested_frequency"
                ],
                "category": task[
                    "category"
                ],
            })

        return compact_candidates

    def _validate_decision(
        self,
        decision,
        candidate_tasks,
        strategy,
        performance_analysis,
    ):
        if (
            len(decision.tasks)
            != strategy.bank_tasks
        ):
            raise ValueError(
                "BankAgent returned the wrong "
                "number of tasks."
            )

        available_by_id = {
            task["bank_id"]: task
            for task in candidate_tasks
        }

        selected_ids = set()
        weekly_points = 0

        category_counts = {
            "RELIGIOUS": 0,
            "FINANCIAL": 0,
            "MORAL": 0,
            "SOCIAL": 0,
        }

        for selected_task in decision.tasks:
            if (
                selected_task.bank_id
                not in available_by_id
            ):
                raise ValueError(
                    "Unknown bank_id: "
                    f"{selected_task.bank_id}"
                )

            if (
                selected_task.bank_id
                in selected_ids
            ):
                raise ValueError(
                    "Duplicate bank task: "
                    f"{selected_task.bank_id}"
                )

            selected_ids.add(
                selected_task.bank_id
            )

            original = available_by_id[
                selected_task.bank_id
            ]

            frequency = original[
                "suggested_frequency"
            ]

            category = original[
                "category"
            ]

            category_counts[
                category
            ] += 1

            if (
                frequency == "DAILY"
                and selected_task.points > 5
            ):
                raise ValueError(
                    "DAILY bank task "
                    f'"{original["title_en"]}" '
                    "has more than 5 points."
                )

            if frequency == "DAILY":
                weekly_points += (
                    selected_task.points
                    * 7
                )
            else:
                weekly_points += (
                    selected_task.points
                )

        recommended_weekly_points = (
            performance_analysis
            .recommended_weekly_points
        )

        if (
            weekly_points
            > recommended_weekly_points
        ):
            raise ValueError(
                "Bank-selected tasks alone exceed "
                "the Performance Agent's "
                "recommended weekly point target. "
                f"Bank contribution: "
                f"{weekly_points}, target: "
                f"{recommended_weekly_points}."
            )

        expected_distribution = (
            strategy.category_distribution
        )

        expected_counts = {
            "RELIGIOUS": (
                expected_distribution.RELIGIOUS
            ),
            "FINANCIAL": (
                expected_distribution.FINANCIAL
            ),
            "MORAL": (
                expected_distribution.MORAL
            ),
            "SOCIAL": (
                expected_distribution.SOCIAL
            ),
        }

        for category, count in category_counts.items():
            if (
                count
                > expected_counts[category]
            ):
                raise ValueError(
                    "BankAgent selected too many "
                    f"{category} tasks for the "
                    "strategy distribution."
                )

    def _build_selection(
        self,
        decision,
        candidate_tasks,
    ):
        available_by_id = {
            task["bank_id"]: task
            for task in candidate_tasks
        }

        selected_tasks = []

        for selected in decision.tasks:
            original = available_by_id[
                selected.bank_id
            ]

            selected_tasks.append(
                SelectedBankTask(
                    bank_id=original[
                        "bank_id"
                    ],
                    title_en=original[
                        "title_en"
                    ],
                    title_ar=original[
                        "title_ar"
                    ],
                    description_en=original[
                        "description_en"
                    ],
                    description_ar=original[
                        "description_ar"
                    ],
                    category=original[
                        "category"
                    ],
                    points=selected.points,
                    frequency=original[
                        "suggested_frequency"
                    ],
                    reason=selected.reason,
                )
            )

        return BankTaskSelection(
            tasks=selected_tasks
        )