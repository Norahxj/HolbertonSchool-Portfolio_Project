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
PREVIOUS EVALUATION ATTEMPT FAILED VALIDATION.

ERRORS:
{errors_text}

Correct every listed error.
"""

        return f"""
You are the Weekly Plan Evaluation Agent for Asalah.

Your responsibility is to evaluate the COMPLETE final
weekly plan before it is shown to the parent.

You do NOT create tasks.
You do NOT modify the plan.

The final plan already includes all selected bank and
AI-generated tasks.

Use each task's source field to identify whether the
task came from TASK_BANK or AI_GENERATED.

CHILD SUMMARY:
{context_json}

PERFORMANCE ANALYSIS:
{performance_json}

STRATEGY:
{strategy_json}

FINAL WEEKLY PLAN:
{plan_json}

Evaluate the plan carefully.

CHECK:

1. AGE APPROPRIATENESS
   Are all tasks suitable for the child's age?

2. SAFETY
   Are all tasks safe and appropriate for a family
   environment?

3. PERSONALIZATION
   Does the plan reasonably reflect the child's actual
   history, strengths, weak areas, and goals?

   Do not reward invented personalization.

4. UNSUPPORTED ASSUMPTIONS
   Does any task assume facts that are not established
   in the child summary?

   Examples include:
   siblings,
   pets,
   allowance,
   possessions,
   specific resources,
   school circumstances,
   friends,
   neighbors,
   holidays,
   or similar assumptions.

5. HISTORY
   Does the plan avoid blindly repeating unsuccessful
   task patterns?

   A rejected task does NOT mean the whole category
   should be avoided.

6. BALANCE
   Does the plan follow the intended category
   distribution and provide reasonable variety?

7. POINTS
   Are points proportional to difficulty?

   DAILY tasks may repeat up to 7 times.

   Compare the complete weekly point total with the
   Performance Agent's recommended_weekly_points.

8. DUPLICATION
   Are any tasks duplicates or essentially the same
   activity with slightly different wording?

9. ACTIONABILITY
   Is every task clear enough for the parent and child
   to understand what must be done?

10. TASK BANK INTEGRITY
    TASK_BANK tasks may have adjusted points.

    Changing points is allowed.

    However, report a BANK issue if a bank task appears
    inappropriate, unsuitable, or based on an unsupported
    assumption.

11. STRATEGY QUALITY
    Check whether the strategy reasonably follows the
    Performance Analysis.

12. PERFORMANCE ANALYSIS QUALITY
    Check whether the Performance Analysis contains
    unsupported claims or unreasonable recommendations
    based on the provided child summary.

13. PLANNER QUALITY
    Check whether summary_en and summary_ar accurately
    represent the actual plan.

    Arabic summary should not contain unnecessary
    English words.

    English summary should not contain unnecessary
    Arabic words.

ISSUE OWNERSHIP:

Use PERFORMANCE when the root problem comes from the
Performance Analysis.

Use STRATEGY when the Performance Analysis is reasonable
but the weekly strategy is poor.

Use BANK when the problem comes from a TASK_BANK task.

Use CREATIVE when the problem comes from an
AI_GENERATED task.

Use PLANNER when the final summary or representation
of the plan is the problem.

For multiple issues:

- Create one issue per meaningful problem.

- Assign each issue to the agent responsible for the
  root cause.

- Do not assign every issue to STRATEGY.

SEVERITY:

HIGH:
- safety problem
- serious age-inappropriateness
- major unsupported assumption

MEDIUM:
- meaningful quality problem that should be fixed
  before showing the plan

LOW:
- minor concern that does not prevent showing the plan

SCORING:

10 = excellent and ready to show

9 = very strong, only trivial concerns

8 = good and safe to show

7 = acceptable but meaningful improvement is possible

6 or below = should not be shown without revision

APPROVAL RULE:

approved is true only when:

- score >= 8
- and there are no HIGH severity issues

Be critical but reasonable.

Do not invent problems unsupported by the provided data.

If the plan is strong and safe, do not create issues
merely to force revision.

Keep feedback concise and useful.

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