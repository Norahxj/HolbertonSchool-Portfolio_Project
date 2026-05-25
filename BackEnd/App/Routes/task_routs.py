# API Routes for task management
# This file handles HTTP endpoints and delegates business logic to the service layer
from fastapi import APIRouter, HTTPException
from uuid import UUID
from typing import List
from App.api_models.task_model import TaskModel, TaskStatus
from App.Services import task_service

router = APIRouter()

@router.post("/tasks", response_model=TaskModel)
def create_task(task: TaskModel):
    """
    Create a new task.
    Calls the service layer to add the task to the database.
    """
    return task_service.create_task(task)

@router.get("/tasks", response_model=List[TaskModel])
def get_tasks():
    """
    Retrieve all tasks.
    Calls the service layer to fetch all tasks from the database.
    """
    return task_service.get_tasks()

@router.get("/tasks/{task_id}", response_model=TaskModel)
def get_task(task_id: UUID):
    """
    Retrieve a single task by its ID.
    Calls the service layer and returns 404 if not found.
    """
    task = task_service.get_task(task_id)
    if task is None:
        raise HTTPException(status_code=404, detail="Task not found")
    return task

@router.put("/tasks/{task_id}/approve", response_model=TaskModel)
def approve_task(task_id: UUID):
    """
    Approve a task by changing its status to APPROVED.
    Calls the service layer and returns 404 if task not found.
    """
    task = task_service.approve_task(task_id)
    if task is None:
        raise HTTPException(status_code=404, detail="Task not found")
    return task

@router.put("/tasks/{task_id}/reject", response_model=TaskModel)
def reject_task(task_id: UUID):
    """
    Reject a task by changing its status to REJECTED.
    Calls the service layer and returns 404 if task not found.
    """
    task = task_service.reject_task(task_id)
    if task is None:
        raise HTTPException(status_code=404, detail="Task not found")
    return task
