from app.models.suggested_task_model import SuggestedTask


class TaskBankRepository:

    def get_all_tasks(self):
        return SuggestedTask.query.all()

    def get_tasks_by_category(self, category):
        return SuggestedTask.query.filter_by(category=category).all()

    def get_categories(self):
        rows = SuggestedTask.query.with_entities(SuggestedTask.category).distinct().all()
        return [row[0] for row in rows]