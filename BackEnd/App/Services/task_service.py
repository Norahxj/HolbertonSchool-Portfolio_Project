# Task service layer - handles all business logic for task management
# This is the single source of truth for task data (tasks_db)
# All routes and operations go through this service

from uuid import UUID
from typing import List, Optional
from App.api_models.task_model import TaskModel, TaskStatus

# Temporary in-memory database for tasks (single source of truth)
# In production, this would be replaced with a real database
tasks_db: List[TaskModel] = []

def create_task(task: TaskModel) -> TaskModel:
    """
    Add a new task to the database.
    Takes a TaskModel object and stores it in memory.
    Returns the created task.
    """
    tasks_db.append(task)
    return task

def get_tasks() -> List[TaskModel]:
    """
    Retrieve all tasks from the database.
    Returns a list of all TaskModel objects.
    """
    return tasks_db

def get_task(task_id: UUID) -> Optional[TaskModel]:
    """
    Retrieve a single task by its ID.
    Searches through tasks_db for a matching ID.
    Returns the task if found, None if not found.
    """
    for task in tasks_db:
        if task.id == task_id:
            return task
    return None

def approve_task(task_id: UUID) -> Optional[TaskModel]:
    """
    Approve a task by setting its status to APPROVED.
    Finds the task by ID and updates its status.
    Returns the updated task if found, None if not found.
    """
    for task in tasks_db:
        if task.id == task_id:
            task.status = TaskStatus.APPROVED
            return task
    return None

def reject_task(task_id: UUID) -> Optional[TaskModel]:
    """
    Reject a task by setting its status to REJECTED.
    Finds the task by ID and updates its status.
    Returns the updated task if found, None if not found.
    """
    for task in tasks_db:
        if task.id == task_id:
            task.status = TaskStatus.REJECTED
            return task
    return None
