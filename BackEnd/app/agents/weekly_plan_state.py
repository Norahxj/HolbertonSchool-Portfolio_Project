from typing import TypedDict

from app.agents.performance_schemas import (
    ChildPerformanceAnalysis,
)
from app.agents.strategy_schemas import (
    WeeklyPlanStrategy,
)
from app.agents.bank_task_schemas import (
    BankTaskSelection,
)
from app.agents.creative_task_schemas import (
    GeneratedTaskSelection,
)
from app.agents.planner_schemas import (
    WeeklyPlanDraft,
)
from app.agents.evaluator_schemas import (
    PlanEvaluation,
)


class WeeklyPlanState(TypedDict, total=False):
    child_context: dict

    performance_analysis: ChildPerformanceAnalysis

    strategy: WeeklyPlanStrategy

    bank_selection: BankTaskSelection

    creative_selection: GeneratedTaskSelection

    plan: WeeklyPlanDraft

    evaluation: PlanEvaluation

    revision_count: int

    max_revisions: int

    revision_feedback: str