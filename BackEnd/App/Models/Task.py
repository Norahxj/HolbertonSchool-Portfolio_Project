from enum import Enum
from uuid import UUID
from datetime import datetime
from typing import Optional

class TaskStatus(Enum):
	PENDING = "PENDING"
	APPROVED = "APPROVED"
	REJECTED = "REJECTED"

class Task:
	def __init__(self, id: UUID, child_id: UUID, title: str, description: str, points: int, status: TaskStatus, created_by: UUID, approved_at: Optional[datetime] = None):
		self.id = id
		self.child_id = child_id
		self.title = title
		self.description = description
		self.points = points
		self.status = status
		self.created_by = created_by
		self.approved_at = approved_at

	def approve(self):
		self.status = TaskStatus.APPROVED
		self.approved_at = datetime.now()

	def reject(self):
		self.status = TaskStatus.REJECTED
		self.approved_at = None
