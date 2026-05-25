from pydantic import BaseModel
from uuid import UUID
from datetime import datetime
from typing import Optional
from enum import Enum

class TaskStatus(str, Enum):
	PENDING = "PENDING"
	APPROVED = "APPROVED"
	REJECTED = "REJECTED"

class TaskModel(BaseModel):
	id: UUID
	child_id: UUID
	title: str
	description: str
	points: int
	status: TaskStatus
	created_by: UUID
	approved_at: Optional[datetime] = None
