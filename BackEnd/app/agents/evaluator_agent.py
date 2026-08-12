import json
import os

from dotenv import load_dotenv
from langchain_openrouter import ChatOpenRouter

from app.agents.evaluator_schemas import (
    PlanEvaluation,
)


load_dotenv()


class EvaluatorAgent:
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
                PlanEvaluation,
                include_raw=True,
            )
        )

    def evaluate(
        self,
        child_context,
        performance_analysis,
        strategy,
        bank_selection,
        creative_selection,
        plan,
    ):
        max_attempts = 3
        validation_errors = []

        for _ in range(max_attempts):
            prompt = self._build_prompt(
                child_context,
                performance_analysis,
                strategy,
                plan,
                validation_errors,
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
                        "evaluation was returned."
                    )
                ]
                continue

            try:
                result = (
                    self._normalize_evaluation(
                        result
                    )
                )

                self._validate_evaluation(
                    result
                )

                return result

            except ValueError as error:
                validation_errors = [
                    str(error)
                ]

        raise ValueError(
            "EvaluatorAgent failed to produce "
            "a valid evaluation after 3 attempts."
        )

    def _build_prompt(
        self,
        child_context,
        performance_analysis,
        strategy,
        plan,
        validation_errors=None,
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

        performance_json = (
            performance_analysis
            .model_dump_json()
        )

        strategy_json = (
            strategy.model_dump_json()
        )

        plan_json = (
            plan.model_dump_json()
        )

        validation_feedback = ""

        if validation_errors:
            errors_text = "\n".join(
                f"- {error}"
                for error in validation_errors
            )

            validation_feedback = f"""
PREVIOUS EVALUATION FAILED VALIDATION.

ERRORS:
{errors_text}

Correct every listed error.
"""

        return f"""
You are the final Weekly Plan Evaluation Agent
for Asalah.

Evaluate whether the completed weekly plan is safe
and suitable to show to the parent.

You do NOT create tasks.
You do NOT modify tasks.
You do NOT search for minor criticisms.

CHILD SUMMARY:
{context_json}

PERFORMANCE ANALYSIS:
{performance_json}

STRATEGY:
{strategy_json}

FINAL WEEKLY PLAN:
{plan_json}

CHECK ONLY MEANINGFUL PROBLEMS:

1. AGE AND SAFETY

Tasks must be suitable for the child's age and safe
for a normal family environment.

2. UNSUPPORTED ASSUMPTIONS

Tasks must not require facts or resources that are not
reasonably supported.

Examples:
- siblings
- pets
- allowance
- specific possessions
- specific school circumstances
- holidays
- uncommon required resources

Normal everyday family or community interactions are
not automatically unsupported assumptions.

3. PERSONALIZATION AND HISTORY

The plan should reasonably use the child's actual
performance and history.

Do not invent reasons for past rejection.

Pending or pending-review tasks are not failures.

A rejected task does not mean its entire category
must be avoided.

4. CATEGORY BALANCE

The final task categories must follow the Strategy
Agent's category_distribution.

A weak category MAY be included intentionally for
gradual improvement.

Do NOT report an issue merely because a weak category
appears in the plan.

Not every category must appear every week.

Do NOT report an issue merely because one category
has zero tasks when the strategy itself assigns zero
tasks to that category.

5. POINTS

Points should be proportional to effort.

DAILY tasks may repeat up to 7 times.

The final weekly_points should remain reasonably close
to Performance recommended_weekly_points.

6. DUPLICATION AND ACTIONABILITY

Tasks should not be duplicates.

Each task should clearly explain what the child needs
to do.

7. BANK TASKS

TASK_BANK tasks may have adjusted points.

Do NOT second-guess the bank category simply because
you personally think another category could also fit.

Report a BANK issue only when the task itself is
clearly unsuitable, unsafe, contradictory, or based
on a meaningful unsupported assumption.

8. PERFORMANCE AND STRATEGY

Report a PERFORMANCE issue only when the Performance
Analysis makes a clearly unsupported or unreasonable
conclusion.

Report a STRATEGY issue only when the strategy clearly
conflicts with the Performance Analysis or violates
the intended workload.

9. PLANNER SUMMARY

summary_en and summary_ar must accurately represent
the actual tasks and strategy.

Minor wording preferences are not issues.

ISSUE OWNERSHIP:

PERFORMANCE:
The root problem is Performance Analysis.

STRATEGY:
The root problem is strategy composition.

BANK:
The root problem is a TASK_BANK selection.

CREATIVE:
The root problem is an AI_GENERATED task.

PLANNER:
The root problem is the final summary.

IMPORTANT ISSUE RULE:

Only create an issue when the problem should actually
be revised before showing the plan.

Do NOT create LOW issues.

Do NOT create observations, optional improvements,
or stylistic preferences as issues.

If the plan is good and safe to show:
- score must be 8, 9, or 10
- approved must be true
- issues MUST be empty

If the plan should be revised:
- approved must be false
- create only the meaningful MEDIUM or HIGH issues
  responsible for the revision

SEVERITY:

HIGH:
- safety problem
- serious age mismatch
- major unsupported assumption

MEDIUM:
- meaningful problem that should be corrected before
  showing the plan

SCORING:

10 = excellent
9 = very strong
8 = good and safe to show
7 = meaningful revision needed
6 or below = significant revision needed

APPROVAL:

approved = true only when:
- score >= 8
- there are no HIGH issues
- there is no meaningful issue requiring revision

Keep feedback very short.

For an approved plan, one concise sentence is enough.

Do not invent problems.

{validation_feedback}

Return only the required structured evaluation.
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
                "remaining_points": goal.get(
                    "remaining_points",
                    0,
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
            "rejected_task_patterns": (
                rejected_tasks
            ),
            "active_goals": (
                active_goals
            ),
        }

    def _normalize_evaluation(
        self,
        evaluation,
    ):
        has_high_issue = any(
            issue.severity == "HIGH"
            for issue in evaluation.issues
        )

        has_medium_issue = any(
            issue.severity == "MEDIUM"
            for issue in evaluation.issues
        )

        evaluation.approved = (
            evaluation.score >= 8
            and not has_high_issue
            and not has_medium_issue
        )

        if evaluation.approved:
            evaluation.issues = []

        return evaluation

    def _validate_evaluation(
        self,
        evaluation,
    ):
        valid_issue_types = {
            "PERFORMANCE",
            "STRATEGY",
            "BANK",
            "CREATIVE",
            "PLANNER",
        }

        valid_severities = {
            "MEDIUM",
            "HIGH",
        }

        for issue in evaluation.issues:
            if (
                issue.issue_type
                not in valid_issue_types
            ):
                raise ValueError(
                    "EvaluatorAgent returned an "
                    "invalid issue_type: "
                    f"{issue.issue_type}"
                )

            if (
                issue.severity
                not in valid_severities
            ):
                raise ValueError(
                    "EvaluatorAgent returned an "
                    "invalid severity: "
                    f"{issue.severity}"
                )

        has_high_issue = any(
            issue.severity == "HIGH"
            for issue in evaluation.issues
        )

        has_medium_issue = any(
            issue.severity == "MEDIUM"
            for issue in evaluation.issues
        )

        expected_approved = (
            evaluation.score >= 8
            and not has_high_issue
            and not has_medium_issue
        )

        if (
            evaluation.approved
            != expected_approved
        ):
            raise ValueError(
                "EvaluatorAgent approval state "
                "is inconsistent with score "
                "and meaningful issues."
            )

        if (
            evaluation.approved
            and evaluation.issues
        ):
            raise ValueError(
                "Approved evaluation must not "
                "contain revision issues."
            )