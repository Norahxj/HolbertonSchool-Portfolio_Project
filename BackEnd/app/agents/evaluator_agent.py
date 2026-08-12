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
You are the Weekly Plan Evaluation Agent for Asalah.

Evaluate the COMPLETE final weekly plan before it is
shown to the parent.

You do NOT create or modify tasks.

CHILD SUMMARY:
{context_json}

PERFORMANCE ANALYSIS:
{performance_json}

STRATEGY:
{strategy_json}

FINAL WEEKLY PLAN:
{plan_json}

CHECK:

1. AGE
   Tasks must suit the child's age.

2. SAFETY
   Tasks must be safe and family-appropriate.

3. PERSONALIZATION
   The plan should reflect actual history, strengths,
   weak areas, and active goals.

4. UNSUPPORTED ASSUMPTIONS
   Reject tasks that assume unsupported siblings, pets,
   allowance, possessions, specific resources, school
   circumstances, friends, neighbors, or holidays.

5. HISTORY
   Avoid blindly repeating unsuccessful task patterns.
   A rejected task does not mean the whole category
   should be avoided.

6. BALANCE
   The category distribution and overall variety should
   follow the strategy.

7. POINTS
   Points must be proportional to difficulty.
   DAILY tasks may repeat up to 7 times.
   Compare weekly_points with the Performance Agent's
   recommended_weekly_points.

8. DUPLICATION
   Tasks should not duplicate the same activity.

9. ACTIONABILITY
   Each task must be clear and actionable.

10. BANK INTEGRITY
    TASK_BANK tasks may have adjusted points, but report
    BANK issues when a selected bank task is unsuitable
    or relies on an unsupported assumption.

11. STRATEGY QUALITY
    Strategy should reasonably follow Performance.

12. PERFORMANCE QUALITY
    Performance conclusions must be supported by the
    child summary.

13. PLANNER QUALITY
    summary_en and summary_ar must accurately represent
    the actual plan and should avoid unnecessary language
    mixing.

ISSUE OWNERSHIP:

- PERFORMANCE:
  root problem is Performance Analysis

- STRATEGY:
  root problem is strategy composition

- BANK:
  problem comes from a TASK_BANK task

- CREATIVE:
  problem comes from an AI_GENERATED task

- PLANNER:
  problem is in the final summary or representation

Use one issue per meaningful problem.

SEVERITY:

HIGH:
- safety
- serious age mismatch
- major unsupported assumption

MEDIUM:
- meaningful quality problem that should be fixed

LOW:
- minor concern that does not prevent showing the plan

SCORING:

10 = excellent
9 = very strong
8 = good and safe to show
7 = acceptable but needs meaningful improvement
6 or below = revise before showing

APPROVAL:

approved = true only when:
- score >= 8
- and there are no HIGH severity issues

Be critical but reasonable.

Do not invent unsupported problems.

Do not create issues only to force revision.

Keep issue descriptions and feedback concise.

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

        evaluation.approved = (
            evaluation.score >= 8
            and not has_high_issue
        )

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
            "LOW",
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

        expected_approved = (
            evaluation.score >= 8
            and not has_high_issue
        )

        if (
            evaluation.approved
            != expected_approved
        ):
            raise ValueError(
                "EvaluatorAgent approval state "
                "is inconsistent with the score "
                "and issue severity."
            )