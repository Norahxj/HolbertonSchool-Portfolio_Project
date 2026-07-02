from app.schemas.auth_schema import RegisterSchema, LoginSchema, ChildLoginSchema
from app.schemas.user_schema import UserResponseSchema, UserUpdateSchema
from app.schemas.child_schema import ChildResponseSchema, ChildCreateSchema, ChildUpdateSchema, ChildWithAccessCodeSchema
from app.schemas.task_schema import TaskResponseSchema, TaskCreateSchema, TaskUpdateSchema
from app.schemas.task_assignment_schema import (ChildTaskAssignmentResponseSchema, ParentTaskAssignmentResponseSchema)