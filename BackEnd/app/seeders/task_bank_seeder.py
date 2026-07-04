import json
from app import create_app
from app.extensions import db
from app.models.suggested_task_model import SuggestedTask


def seed_task_bank():
    app = create_app()

    with app.app_context():
        with open("app/seeders/task_bank.json", "r", encoding="utf-8") as file:
            data = json.load(file)

        for category, tasks in data.items():
            for task in tasks:
                existing_task = SuggestedTask.query.filter_by(
                    category=category,
                    title_en=task["english"],
                    title_ar=task["arabic"]
                ).first()

                if existing_task:
                    continue

                suggested_task = SuggestedTask(
                    category=category,
                    title_en=task["english"],
                    title_ar=task["arabic"]
                )

                db.session.add(suggested_task)

        db.session.commit()

        print("Task bank seeded successfully.")


if __name__ == "__main__":
    seed_task_bank()