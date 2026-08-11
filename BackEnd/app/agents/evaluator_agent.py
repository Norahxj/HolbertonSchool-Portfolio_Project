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
            PlanEvaluation,
            include_raw=True,
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
        prompt = self._build_prompt(
            child_context,
            performance_analysis,
            strategy,
            bank_selection,
            creative_selection,
            plan,
        )

        response = self.structured_llm.invoke(prompt)

        result = response.get("parsed")
        parsing_error = response.get("parsing_error")

        if parsing_error:
            raise ValueError(
                f"EvaluatorAgent parsing failed: {parsing_error}"
            )

        if result is None:
            raise ValueError(
                "EvaluatorAgent failed to return "
                "structured output."
            )

        return self._normalize_evaluation(result)

    def _build_prompt(
        self,
        child_context,
        performance_analysis,
        strategy,
        bank_selection,
        creative_selection,
        plan,
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

        plan_json = plan.model_dump_json(
            indent=2,
        )

        return f"""
You are the Weekly Plan Evaluation Agent for Asalah.

Your responsibility is to evaluate the COMPLETE weekly
plan before it is shown to the parent.

You do NOT create tasks.
You do NOT modify the plan.

CHILD CONTEXT:
{context_json}

PERFORMANCE ANALYSIS:
{performance_json}

STRATEGY:
{strategy_json}

BANK TASK SELECTION:
{bank_json}

AI-GENERATED TASK SELECTION:
{creative_json}

FINAL WEEKLY PLAN:
{plan_json}

Evaluate the plan carefully.

Check:

1. AGE APPROPRIATENESS
Are all tasks suitable for the child's age?

2. SAFETY
Are all tasks safe and appropriate for a family
environment?

3. PERSONALIZATION
Does the plan reasonably reflect the child's actual
history, strengths, weak areas, points history, and
wishlist information?

Do not reward invented personalization.

4. UNSUPPORTED ASSUMPTIONS
Does any task assume siblings, pets, allowance,
possessions, specific resources, school circumstances,
friends, neighbors, holidays, or other facts that are
not established in the child context?

5. HISTORY
Does the plan avoid blindly repeating unsuccessful
task patterns?

A rejected task does not automatically mean the
entire category should be avoided.

6. BALANCE
Does the plan follow the intended category
distribution and provide reasonable variety?

7. POINTS
Are points proportional to task difficulty?

Remember:
DAILY tasks may repeat up to 7 times.

Check whether the complete weekly point total is
reasonable relative to the Performance Agent's
recommended_weekly_points.

8. DUPLICATION
Are any tasks duplicates or essentially the same
activity with slightly different wording?

9. ACTIONABILITY
Can the parent and child clearly understand what
must be done?

10. TASK BANK INTEGRITY
Bank tasks may have adjusted points for this weekly
plan.

Changing points is allowed.

However, a bank task should not have its identity,
title, description, category, or frequency changed.

11. STRATEGY QUALITY
Check whether the Strategy Agent made a reasonable
decision based on the Performance Analysis.

12. PERFORMANCE ANALYSIS QUALITY
Check whether the Performance Agent made unsupported
claims or unreasonable recommendations based on the
child data.

ISSUE OWNERSHIP:

Use PERFORMANCE when the root problem comes from the
Performance Analysis.

Use STRATEGY when the Performance Analysis is reasonable
but the weekly strategy itself is poor.

Use BANK when the problem comes from a selected bank
task.

Use CREATIVE when the problem comes from an AI-generated
task.

Use PLANNER only when the final assembly, summaries,
or representation of the plan is the problem.

SCORING:

10 = excellent and ready to show
9 = very strong, only trivial concerns
8 = good and safe to show
7 = acceptable but meaningful improvement is possible
6 or below = should not be shown without revision

APPROVAL RULE:

- approved should be true only when score >= 8
  AND there are no HIGH severity issues.

- Be critical but reasonable.

- Do not invent problems unsupported by the provided
  information.

- Feedback should clearly explain the overall evaluation.

Return only the required structured evaluation.
"""

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