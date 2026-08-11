from app.agents.weekly_plan_workflow import WeeklyPlanWorkflow
from app.services.child_context_service import ChildContextService


class WeeklyPlanService:
    def __init__(self):
        self.child_context_service = ChildContextService()
        self.workflow = WeeklyPlanWorkflow()

    def generate_weekly_plan(
        self,
        child_id,
        guardian_id,
        max_revisions=3,
    ):
        child_context, error = (
            self.child_context_service
            .get_child_context(
                child_id,
                guardian_id,
            )
        )

        if error:
            return None, error

        if not child_context:
            return None, "child_context_not_found"

        try:
            result = self.workflow.generate(
                child_context=child_context,
                max_revisions=max_revisions,
            )

        except Exception as error:
            error_name = (
                error.__class__.__name__
            )

            error_text = str(error).lower()

            if (
                error_name
                == "TooManyRequestsResponseError"
                or "rate limit" in error_text
                or "too many requests" in error_text
            ):
                return None, "ai_rate_limit"

            if (
                "service unavailable" in error_text
                or "no available providers" in error_text
                or "provider unavailable" in error_text
                or "bad gateway" in error_text
            ):
                return None, "ai_service_unavailable"

            raise

        evaluation = result.get("evaluation")
        plan = result.get("plan")

        if evaluation is None:
            return None, "evaluation_missing"

        if plan is None:
            return None, "plan_missing"

        if not evaluation.approved:
            return {
                "approved": False,
                "plan": plan,
                "evaluation": evaluation,
                "revision_count": result.get(
                    "revision_count",
                    0,
                ),
            }, None

        return {
            "approved": True,
            "plan": plan,
            "evaluation": evaluation,
            "performance_analysis": result.get(
                "performance_analysis"
            ),
            "strategy": result.get(
                "strategy"
            ),
            "revision_count": result.get(
                "revision_count",
                0,
            ),
        }, None