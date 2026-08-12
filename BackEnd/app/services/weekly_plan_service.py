import time

from datetime import datetime

from app.agents.weekly_plan_workflow import (
    WeeklyPlanWorkflow,
)
from app.extensions import db
from app.models.weekly_plan_proposal_model import (
    WeeklyPlanProposal,
)
from app.repositories.weekly_plan_proposal_repository import (
    WeeklyPlanProposalRepository,
)
from app.services.child_context_service import (
    ChildContextService,
)
from app.services.task_service import TaskService


class WeeklyPlanService:
    def __init__(self):
        self.child_context_service = (
            ChildContextService()
        )
        self.workflow = WeeklyPlanWorkflow()
        self.proposal_repository = (
            WeeklyPlanProposalRepository()
        )
        self.task_service = TaskService()

    def generate_weekly_plan(
        self,
        child_id,
        guardian_id,
        max_revisions=3,
    ):
        request_start = time.perf_counter()

        print(
            "[WEEKLY_PLAN] Request started",
            flush=True,
        )

        print(
            "[WEEKLY_PLAN] Starting child context",
            flush=True,
        )

        context_start = time.perf_counter()

        child_context, error = (
            self.child_context_service
            .get_child_context(
                child_id,
                guardian_id,
            )
        )

        context_duration = (
            time.perf_counter()
            - context_start
        )

        print(
            "[WEEKLY_PLAN] Child context finished in "
            f"{context_duration:.2f}s",
            flush=True,
        )

        if error:
            print(
                "[WEEKLY_PLAN] Child context error: "
                f"{error}",
                flush=True,
            )

            return None, error

        if not child_context:
            print(
                "[WEEKLY_PLAN] Child context missing",
                flush=True,
            )

            return None, "child_context_not_found"

        print(
            "[WEEKLY_PLAN] Starting AI workflow",
            flush=True,
        )

        workflow_start = time.perf_counter()

        try:
            result = self.workflow.generate(
                child_context=child_context,
                max_revisions=max_revisions,
            )

        except Exception as error:
            workflow_duration = (
                time.perf_counter()
                - workflow_start
            )

            print(
                "[WEEKLY_PLAN] AI workflow failed after "
                f"{workflow_duration:.2f}s",
                flush=True,
            )

            print(
                "[WEEKLY_PLAN] AI error: "
                f"{error.__class__.__name__}: {error}",
                flush=True,
            )

            error_name = (
                error.__class__.__name__
            )

            error_text = str(
                error
            ).lower()

            if (
                error_name
                == "TooManyRequestsResponseError"
                or "rate limit" in error_text
                or "too many requests" in error_text
            ):
                return None, "ai_rate_limit"

            if (
                "service unavailable" in error_text
                or "no available providers"
                in error_text
                or "provider unavailable"
                in error_text
                or "bad gateway" in error_text
            ):
                return (
                    None,
                    "ai_service_unavailable",
                )

            raise

        workflow_duration = (
            time.perf_counter()
            - workflow_start
        )

        print(
            "[WEEKLY_PLAN] AI workflow finished in "
            f"{workflow_duration:.2f}s",
            flush=True,
        )

        evaluation = result.get(
            "evaluation"
        )

        plan = result.get(
            "plan"
        )

        if evaluation is None:
            print(
                "[WEEKLY_PLAN] Evaluation missing",
                flush=True,
            )

            return None, "evaluation_missing"

        if plan is None:
            print(
                "[WEEKLY_PLAN] Plan missing",
                flush=True,
            )

            return None, "plan_missing"

        if not evaluation.approved:
            total_duration = (
                time.perf_counter()
                - request_start
            )

            print(
                "[WEEKLY_PLAN] Plan not approved. "
                "Total request time: "
                f"{total_duration:.2f}s",
                flush=True,
            )

            return {
                "approved": False,
                "plan": plan,
                "evaluation": evaluation,
                "revision_count": result.get(
                    "revision_count",
                    0,
                ),
            }, None

        print(
            "[WEEKLY_PLAN] Creating proposal",
            flush=True,
        )

        proposal_start = time.perf_counter()

        proposal = WeeklyPlanProposal(
            child_id=child_id,
            created_by=guardian_id,
            status="PENDING",
            plan_json=plan.model_dump(
                mode="json"
            ),
        )

        proposal, proposal_error = (
            self.proposal_repository
            .create_proposal(
                proposal
            )
        )

        proposal_duration = (
            time.perf_counter()
            - proposal_start
        )

        print(
            "[WEEKLY_PLAN] Proposal creation "
            f"finished in {proposal_duration:.2f}s",
            flush=True,
        )

        if proposal_error:
            print(
                "[WEEKLY_PLAN] Proposal creation "
                f"failed: {proposal_error}",
                flush=True,
            )

            return (
                None,
                "proposal_create_failed",
            )

        total_duration = (
            time.perf_counter()
            - request_start
        )

        print(
            "[WEEKLY_PLAN] Request completed in "
            f"{total_duration:.2f}s",
            flush=True,
        )

        return {
            "approved": True,
            "proposal_id": proposal.id,
            "proposal_status": proposal.status,
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

    def approve_weekly_plan(
        self,
        proposal_id,
        guardian_id,
        language="ar",
    ):
        proposal = (
            self.proposal_repository
            .get_for_creator(
                proposal_id,
                guardian_id,
            )
        )

        if not proposal:
            return None, "proposal_not_found"

        if proposal.status == "APPROVED":
            return (
                None,
                "proposal_already_approved",
            )

        if proposal.status != "PENDING":
            return None, "proposal_not_pending"

        plan_json = proposal.plan_json

        if not isinstance(
            plan_json,
            dict,
        ):
            return None, "invalid_plan_data"

        planned_tasks = plan_json.get(
            "tasks"
        )

        if not planned_tasks:
            return None, "tasks_required"

        try:
            created_tasks, task_error = (
                self.task_service
                .create_tasks_from_weekly_plan(
                    parent_id=guardian_id,
                    child_id=proposal.child_id,
                    planned_tasks=planned_tasks,
                    language=language,
                    commit=False,
                )
            )

            if task_error:
                db.session.rollback()
                return None, task_error

            proposal.status = "APPROVED"
            proposal.approved_at = (
                datetime.utcnow()
            )

            success, proposal_error = (
                self.proposal_repository
                .update_proposal(
                    commit=False,
                )
            )

            if (
                not success
                or proposal_error
            ):
                db.session.rollback()

                return (
                    None,
                    "proposal_update_failed",
                )

            db.session.commit()

            return {
                "proposal_id": proposal.id,
                "proposal_status": (
                    proposal.status
                ),
                "child_id": proposal.child_id,
                "created_task_ids": [
                    task.id
                    for task in created_tasks
                ],
                "created_tasks_count": len(
                    created_tasks
                ),
            }, None

        except Exception:
            db.session.rollback()
            return None, "approval_failed"