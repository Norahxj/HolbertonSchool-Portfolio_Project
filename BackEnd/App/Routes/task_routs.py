from fastapi import APIRouter, HTTPException
from uuid import UUID
from typing import List
from App.api_models.task_model import TaskModel, TaskStatus

router = APIRouter()

# بيانات مؤقتة للتجربة (بدل قاعدة البيانات)
tasks_db: List[TaskModel] = []

@router.post("/tasks", response_model=TaskModel)
def create_task(task: TaskModel):
	tasks_db.append(task)
	return task

@router.get("/tasks", response_model=List[TaskModel])
def get_tasks():
	return tasks_db

@router.get("/tasks/{task_id}", response_model=TaskModel)
def get_task(task_id: UUID):
	for task in tasks_db:
		if task.id == task_id:
			return task
	raise HTTPException(status_code=404, detail="Task not found")

@router.put("/tasks/{task_id}/approve", response_model=TaskModel)
def approve_task(task_id: UUID):
	for task in tasks_db:
		if task.id == task_id:
			task.status = TaskStatus.APPROVED
			return task
	raise HTTPException(status_code=404, detail="Task not found")

@router.put("/tasks/{task_id}/reject", response_model=TaskModel)
def reject_task(task_id: UUID):
	for task in tasks_db:
		if task.id == task_id:
			task.status = TaskStatus.REJECTED
			return task
	raise HTTPException(status_code=404, detail="Task not found")
