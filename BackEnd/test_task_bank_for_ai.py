from app.services.task_bank_service import TaskBankService


service = TaskBankService()

tasks = service.get_suitable_tasks_for_age(10)


print("\n=== SUITABLE TASKS FOR AGE 10 ===\n")

print(f"Total tasks: {len(tasks)}")

for task in tasks:
    print(
        f"[{task['category']}] "
        f"{task['title_en']} "
        f"- {task['default_points']} pts "
        f"- {task['suggested_frequency']}"
    )