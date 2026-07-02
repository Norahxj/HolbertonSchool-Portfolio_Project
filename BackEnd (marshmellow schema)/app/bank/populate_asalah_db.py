import json
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from asalah_db_models import Base, TaskCategory, SuggestedTask, ParentCustomTask

# Database setup
engine = create_engine("sqlite:///asalah_tasks.db")
Base.metadata.create_all(engine) # Create tables if they don't exist
Session = sessionmaker(bind=engine)
session = Session()

def populate_database():
    # Add Task Categories
    categories_data = {
        "Culture & Tradition": {"name_en": "Culture & Tradition", "name_ar": "التراث والثقافة"},
        "Religion": {"name_en": "Religion", "name_ar": "الدين"},
        "Daily Chores": {"name_en": "Daily Chores", "name_ar": "الأعمال اليومية"},
        "Financial Values": {"name_en": "Financial Values", "name_ar": "القيم المالية"}
    }

    category_objects = {}
    for key, data in categories_data.items():
        category = session.query(TaskCategory).filter_by(name_en=data["name_en"]).first()
        if not category:
            category = TaskCategory(name_en=data["name_en"], name_ar=data["name_ar"])
            session.add(category)
            session.commit()
        category_objects[key] = category

    # Load extracted tasks from JSON
    with open("/home/ubuntu/extracted_tasks.json", "r", encoding="utf-8") as f:
        all_extracted_tasks = json.load(f)

    # Add Suggested Tasks
    for category_name, tasks_list in all_extracted_tasks.items():
        category = category_objects.get(category_name)
        if category:
            for task_data in tasks_list:
                # Check if task already exists to prevent duplicates on re-run
                existing_task = session.query(SuggestedTask).filter_by(
                    category_id=category.id,
                    task_en=task_data["english"],
                    task_ar=task_data["arabic"]
                ).first()
                if not existing_task:
                    suggested_task = SuggestedTask(
                        category_id=category.id,
                        task_en=task_data["english"],
                        task_ar=task_data["arabic"]
                    )
                    session.add(suggested_task)
    session.commit()
    session.close()

    print("Database populated successfully with categories and suggested tasks.")

if __name__ == "__main__":
    populate_database()
