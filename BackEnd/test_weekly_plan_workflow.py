import json
import os
import sys

from dotenv import load_dotenv

from app.agents.weekly_plan_workflow import (
    WeeklyPlanWorkflow,
)


# ----------------------------------------------------------
# Windows terminal support for Arabic output
# ----------------------------------------------------------

if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(
        encoding="utf-8"
    )


# ----------------------------------------------------------
# Environment
# ----------------------------------------------------------

load_dotenv()


def print_section(
    title,
    data,
):
    print("\n")
    print("=" * 70)
    print(title)
    print("=" * 70)

    if data is None:
        print("None")
        return

    if hasattr(data, "model_dump"):
        data = data.model_dump(
            mode="json"
        )

    print(
        json.dumps(
            data,
            ensure_ascii=False,
            indent=2,
            default=str,
        )
    )


def validate_environment():
    required_variables = [
        "OPENROUTER_API_KEY",
        "OPENROUTER_MODEL",
    ]

    missing = [
        variable
        for variable in required_variables
        if not os.getenv(variable)
    ]

    if missing:
        raise RuntimeError(
            "Missing environment variables: "
            + ", ".join(missing)
        )

    print(
        "OpenRouter model:",
        os.getenv("OPENROUTER_MODEL"),
    )

    print(
        "LangSmith tracing:",
        os.getenv(
            "LANGSMITH_TRACING",
            "not configured",
        ),
    )

    print(
        "LangSmith project:",
        os.getenv(
            "LANGSMITH_PROJECT",
            "not configured",
        ),
    )

    print(
        "LangSmith API key:",
        (
            "configured"
            if os.getenv("LANGSMITH_API_KEY")
            else "not configured"
        ),
    )


# ----------------------------------------------------------
# Realistic test child context
#
# This follows the same structure produced by
# ChildContextService in the real backend.
# ----------------------------------------------------------

fake_child_context = {
    "child": {
        "id": "test-child-1",
        "name": "Ahmed",
        "age": 10,
        "current_points": 120,
    },

    "history_summary": {
        "total_tasks": 10,
        "approved_tasks": 6,
        "rejected_tasks": 2,
        "pending_tasks": 1,
        "pending_review_tasks": 1,
        "completion_rate": 0.75,
        "average_completed_task_points": 15,

        "categories": {
            "RELIGIOUS": {
                "total": 2,
                "approved": 2,
                "rejected": 0,
                "completion_rate": 1.0,
            },

            "FINANCIAL": {
                "total": 3,
                "approved": 1,
                "rejected": 2,
                "completion_rate": 0.33,
            },

            "MORAL": {
                "total": 3,
                "approved": 2,
                "rejected": 0,
                "completion_rate": 1.0,
            },

            "SOCIAL": {
                "total": 2,
                "approved": 1,
                "rejected": 0,
                "completion_rate": 1.0,
            },
        },

        "has_enough_history": True,
    },

    "points_summary": {
        "current_points": 120,
        "total_earned": 220,
        "total_spent": 100,
        "task_points_earned": 220,
        "wishes_achieved": 1,
    },

    "wishlist_summary": {
        "pending_wishes": 0,
        "approved_wishes": 1,
        "rejected_wishes": 0,
        "achieved_wishes": 1,

        "active_goals": [
            {
                "id": "wish-1",
                "name": "Bicycle",
                "target_points": 300,
                "current_points": 120,
                "remaining_points": 180,
                "progress_percentage": 0.4,
            },
        ],
    },

    "task_history": [
        {
            "assignment_id": "assignment-1",
            "task_id": "task-1",
            "title": "رتب غرفتك",
            "description": (
                "رتب غرفتك وأعد الأشياء "
                "إلى أماكنها."
            ),
            "category": "MORAL",
            "points": 15,
            "frequency": "DAILY",
            "status": "APPROVED",
            "assigned_date": "2026-08-01",
            "completed_at": "2026-08-01T15:00:00",
            "approved_at": "2026-08-01T16:00:00",
        },

        {
            "assignment_id": "assignment-2",
            "task_id": "task-2",
            "title": "المحافظة على الصلاة",
            "description": (
                "حافظ على أداء صلواتك "
                "في وقتها."
            ),
            "category": "RELIGIOUS",
            "points": 10,
            "frequency": "DAILY",
            "status": "APPROVED",
            "assigned_date": "2026-08-02",
            "completed_at": "2026-08-02T18:00:00",
            "approved_at": "2026-08-02T19:00:00",
        },

        {
            "assignment_id": "assignment-3",
            "task_id": "task-3",
            "title": "وفر جزءًا من مصروفك",
            "description": (
                "احتفظ بجزء من مصروفك "
                "بدل صرفه كاملًا."
            ),
            "category": "FINANCIAL",
            "points": 20,
            "frequency": "WEEKLY",
            "status": "REJECTED",
            "assigned_date": "2026-08-03",
            "completed_at": None,
            "approved_at": None,
        },

        {
            "assignment_id": "assignment-4",
            "task_id": "task-4",
            "title": "ادخر من مصروفك اليومي",
            "description": (
                "ضع جزءًا من مصروفك "
                "جانبًا للادخار."
            ),
            "category": "FINANCIAL",
            "points": 15,
            "frequency": "DAILY",
            "status": "REJECTED",
            "assigned_date": "2026-08-04",
            "completed_at": None,
            "approved_at": None,
        },

        {
            "assignment_id": "assignment-5",
            "task_id": "task-5",
            "title": "ساعد في ترتيب المنزل",
            "description": (
                "شارك في ترتيب مساحة "
                "مشتركة في المنزل."
            ),
            "category": "MORAL",
            "points": 10,
            "frequency": "WEEKLY",
            "status": "APPROVED",
            "assigned_date": "2026-08-05",
            "completed_at": "2026-08-05T14:00:00",
            "approved_at": "2026-08-05T15:00:00",
        },

        {
            "assignment_id": "assignment-6",
            "task_id": "task-6",
            "title": "استخدم كلمات لطيفة",
            "description": (
                "استخدم كلمات لطيفة "
                "ومهذبة أثناء حديثك."
            ),
            "category": "SOCIAL",
            "points": 8,
            "frequency": "DAILY",
            "status": "APPROVED",
            "assigned_date": "2026-08-06",
            "completed_at": "2026-08-06T14:00:00",
            "approved_at": "2026-08-06T15:00:00",
        },
    ],

    "points_history": [
        {
            "points": 15,
            "action": "TASK_COMPLETED",
            "created_at": "2026-08-01T16:00:00",
        },

        {
            "points": 10,
            "action": "TASK_COMPLETED",
            "created_at": "2026-08-02T19:00:00",
        },

        {
            "points": 10,
            "action": "TASK_COMPLETED",
            "created_at": "2026-08-05T15:00:00",
        },

        {
            "points": 8,
            "action": "TASK_COMPLETED",
            "created_at": "2026-08-06T15:00:00",
        },
    ],

    "wishlist": [
        {
            "id": "wish-1",
            "name": "Bicycle",
            "target_points": 300,
            "status": "APPROVED",
            "created_at": "2026-07-20T10:00:00",
        },
    ],
}


def main():
    print("\n")
    print("=" * 70)
    print("ASALAH WEEKLY PLAN WORKFLOW TEST")
    print("=" * 70)

    validate_environment()

    print_section(
        "INPUT CHILD CONTEXT",
        fake_child_context,
    )

    print(
        "\nCreating WeeklyPlanWorkflow..."
    )

    workflow = WeeklyPlanWorkflow()

    print(
        "Running complete multi-agent workflow..."
    )

    result = workflow.generate(
        child_context=fake_child_context,
        max_revisions=3,
    )

    # ------------------------------------------------------
    # Extract final workflow state
    # ------------------------------------------------------

    performance = result.get(
        "performance_analysis"
    )

    strategy = result.get(
        "strategy"
    )

    bank_selection = result.get(
        "bank_selection"
    )

    creative_selection = result.get(
        "creative_selection"
    )

    plan = result.get(
        "plan"
    )

    evaluation = result.get(
        "evaluation"
    )

    revision_count = result.get(
        "revision_count",
        0,
    )

    # ------------------------------------------------------
    # Print every final stage
    # ------------------------------------------------------

    print_section(
        "1. PERFORMANCE ANALYSIS",
        performance,
    )

    print_section(
        "2. WEEKLY STRATEGY",
        strategy,
    )

    print_section(
        "3. BANK TASK SELECTION",
        bank_selection,
    )

    print_section(
        "4. CREATIVE TASK SELECTION",
        creative_selection,
    )

    print_section(
        "5. FINAL WEEKLY PLAN",
        plan,
    )

    print_section(
        "6. FINAL EVALUATION",
        evaluation,
    )

    print("\n")
    print("=" * 70)
    print("WORKFLOW SUMMARY")
    print("=" * 70)

    print(
        "Revision count:",
        revision_count,
    )

    if evaluation is not None:
        print(
            "Evaluator score:",
            evaluation.score,
        )

        print(
            "Approved:",
            evaluation.approved,
        )

        print(
            "Issues:",
            len(evaluation.issues),
        )

    if plan is not None:
        print(
            "Total tasks:",
            plan.total_tasks,
        )

        print(
            "Weekly points:",
            plan.weekly_points,
        )

        print(
            "Cold start:",
            plan.is_cold_start,
        )

    # ------------------------------------------------------
    # Basic integrity checks
    # ------------------------------------------------------

    assert performance is not None, (
        "Performance Agent did not return a result."
    )

    assert strategy is not None, (
        "Strategy Agent did not return a result."
    )

    assert bank_selection is not None, (
        "Bank Agent did not return a result."
    )

    assert creative_selection is not None, (
        "Creative Agent did not return a result."
    )

    assert plan is not None, (
        "Planner Agent did not return a result."
    )

    assert evaluation is not None, (
        "Evaluator Agent did not return a result."
    )

    assert len(plan.tasks) == plan.total_tasks, (
        "Plan total_tasks does not match "
        "the actual tasks list."
    )

    assert (
        plan.total_tasks
        == strategy.total_tasks
    ), (
        "Final plan task count does not "
        "match the strategy."
    )

    assert (
        len(bank_selection.tasks)
        == strategy.bank_tasks
    ), (
        "Bank task count does not match "
        "the strategy."
    )

    assert (
        len(creative_selection.tasks)
        == strategy.generated_tasks
    ), (
        "Creative task count does not "
        "match the strategy."
    )

    expected_total = (
        len(bank_selection.tasks)
        + len(creative_selection.tasks)
    )

    assert len(plan.tasks) == expected_total, (
        "Final plan does not contain all "
        "selected tasks."
    )

    print("\n")
    print("=" * 70)

    if evaluation.approved:
        print(
            "SUCCESS: Final weekly plan was approved."
        )
    else:
        print(
            "WORKFLOW FINISHED, BUT THE FINAL PLAN "
            "WAS NOT APPROVED."
        )

        print(
            "This means the workflow reached the "
            "revision limit before approval."
        )

    print("=" * 70)

    print(
        "\nCheck LangSmith project "
        "'asalah-weekly-plan' for the full trace."
    )


if __name__ == "__main__":
    main()