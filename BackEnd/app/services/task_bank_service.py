from app.repositories.task_bank_repository import TaskBankRepository


class TaskBankService:
    def __init__(self):
        self.task_bank_repository = TaskBankRepository()

    def get_categories(self):
        return self.task_bank_repository.get_categories()

    def get_tasks(self, category=None):
        if category:
            return self.task_bank_repository.get_tasks_by_category(category)

        return self.task_bank_repository.get_all_tasks()