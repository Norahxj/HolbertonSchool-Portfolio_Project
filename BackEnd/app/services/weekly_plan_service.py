from app.agents.weekly_plan_workflow import WeeklyPlanWorkflow
from app.services.child_context_service import ChildContextService


class WeeklyPlanService:
    def __init__(self):
        self.child_context_service = ChildContextService()
        self.workflow = WeeklyPlanWorkflow()

    def generate_weekly_plan(
        self,
        child_id,
        max_revisions=3,
    ):
        child_context, error = (
            self.child_context_service
            .get_child_context(child_id)
        )

        if error:
            return None, error

        if not child_context:
            return None, "child_context_not_found"

        result = self.workflow.generate(
            child_context=child_context,
            max_revisions=max_revisions,
        )

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
            "strategy": result.get("strategy"),
            "revision_count": result.get(
                "revision_count",
                0,
            ),
        }, None