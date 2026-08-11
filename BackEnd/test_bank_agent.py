from app.agents.performance_agent import PerformanceAgent
from app.agents.strategy_agent import StrategyAgent
from app.agents.bank_agent import BankAgent

from app.agents.performance_agent import PerformanceAgent

performance_agent = PerformanceAgent()
strategy_agent = StrategyAgent()


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
            }
        ],
    },

    "task_history": [
        {
            "title": "رتب غرفتك",
            "category": "MORAL",
            "points": 15,
            "frequency": "DAILY",
            "status": "APPROVED",
        },
        {
            "title": "وفر جزءًا من مصروفك",
            "category": "FINANCIAL",
            "points": 20,
            "frequency": "WEEKLY",
            "status": "REJECTED",
        },
    ],

    "points_history": [],

    "wishlist": [
        {
            "id": "wish-1",
            "name": "Bicycle",
            "target_points": 300,
            "status": "APPROVED",
        }
    ],
}


agent = PerformanceAgent()

analysis = agent.analyze(fake_child_context)


print("\n=== PERFORMANCE ANALYSIS ===\n")

print(
    analysis.model_dump_json(
        indent=2,
    )
)


performance = performance_agent.analyze(
    fake_child_context
)

print("\n=== PERFORMANCE ===\n")
print(
    performance.model_dump_json(
        indent=2,
    )
)


strategy = strategy_agent.create_strategy(
    fake_child_context,
    performance,
)

print("\n=== STRATEGY ===\n")
print(
    strategy.model_dump_json(
        indent=2,
    )
)


bank_agent = BankAgent()

bank_selection = bank_agent.select_tasks(
    fake_child_context,
    performance,
    strategy,
)

print("\n=== BANK TASK SELECTION ===\n")

print(
    bank_selection.model_dump_json(
        indent=2,
    )
)