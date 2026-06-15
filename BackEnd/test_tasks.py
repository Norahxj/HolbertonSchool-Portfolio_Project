# Unit tests for task management system
# This file tests all task operations: create, get, approve, reject

import pytest
from uuid import uuid4
from datetime import datetime
from backEnd.app.api_models.task_api import TaskModel, TaskStatus
from app.services import task_service

# Fixture to create a sample task for testing
@pytest.fixture
def sample_task():
    """Create a sample task object for testing"""
    return TaskModel(
        id=uuid4(),
        child_id=uuid4(),
        title="Clean your room",
        description="Clean the bedroom and organize items",
        points=10,
        status=TaskStatus.PENDING,
        created_by=uuid4(),
        approved_at=None
    )

# Test 1: Create a task
def test_create_task(sample_task):
    """Test creating a new task"""
    # Before: database should be empty or have previous tasks
    initial_count = len(task_service.get_tasks())
    
    # Create the task
    created_task = task_service.create_task(sample_task)
    
    # After: task should be in database
    assert created_task is not None
    assert created_task.id == sample_task.id
    assert created_task.title == "Clean your room"
    assert created_task.status == TaskStatus.PENDING
    assert len(task_service.get_tasks()) == initial_count + 1
    print("✅ Test Create Task: PASSED")

# Test 2: Get all tasks
def test_get_all_tasks(sample_task):
    """Test retrieving all tasks"""
    # Create a task first
    task_service.create_task(sample_task)
    
    # Get all tasks
    all_tasks = task_service.get_tasks()
    
    # Verify tasks are returned
    assert isinstance(all_tasks, list)
    assert len(all_tasks) > 0
    assert any(task.id == sample_task.id for task in all_tasks)
    print("✅ Test Get All Tasks: PASSED")

# Test 3: Get a single task by ID
def test_get_task_by_id(sample_task):
    """Test retrieving a specific task by ID"""
    # Create a task first
    task_service.create_task(sample_task)
    
    # Get the task by ID
    retrieved_task = task_service.get_task(sample_task.id)
    
    # Verify the task is retrieved correctly
    assert retrieved_task is not None
    assert retrieved_task.id == sample_task.id
    assert retrieved_task.title == sample_task.title
    print("✅ Test Get Task by ID: PASSED")

# Test 4: Get non-existent task
def test_get_nonexistent_task():
    """Test retrieving a task that doesn't exist"""
    fake_id = uuid4()
    
    # Try to get a non-existent task
    result = task_service.get_task(fake_id)
    
    # Should return None
    assert result is None
    print("✅ Test Get Non-existent Task: PASSED")

# Test 5: Approve a task
def test_approve_task(sample_task):
    """Test approving a task"""
    # Create a task first
    task_service.create_task(sample_task)
    
    # Approve the task
    approved_task = task_service.approve_task(sample_task.id)
    
    # Verify the task is approved
    assert approved_task is not None
    assert approved_task.status == TaskStatus.APPROVED
    assert approved_task.id == sample_task.id
    print("✅ Test Approve Task: PASSED")

# Test 6: Reject a task
def test_reject_task(sample_task):
    """Test rejecting a task"""
    # Create a task first
    task_service.create_task(sample_task)
    
    # Reject the task
    rejected_task = task_service.reject_task(sample_task.id)
    
    # Verify the task is rejected
    assert rejected_task is not None
    assert rejected_task.status == TaskStatus.REJECTED
    assert rejected_task.id == sample_task.id
    print("✅ Test Reject Task: PASSED")

# Test 7: Approve non-existent task
def test_approve_nonexistent_task():
    """Test approving a task that doesn't exist"""
    fake_id = uuid4()
    
    # Try to approve a non-existent task
    result = task_service.approve_task(fake_id)
    
    # Should return None
    assert result is None
    print("✅ Test Approve Non-existent Task: PASSED")

# Test 8: Status changes
def test_status_transitions(sample_task):
    """Test changing task status from PENDING -> APPROVED -> REJECTED"""
    # Create a task
    task_service.create_task(sample_task)
    
    # Initial status should be PENDING
    task = task_service.get_task(sample_task.id)
    assert task.status == TaskStatus.PENDING
    
    # Change to APPROVED
    task = task_service.approve_task(sample_task.id)
    assert task.status == TaskStatus.APPROVED
    
    # Change to REJECTED
    task = task_service.reject_task(sample_task.id)
    assert task.status == TaskStatus.REJECTED
    
    print("✅ Test Status Transitions: PASSED")

# Run all tests if this file is executed directly
if __name__ == "__main__":
    print("=" * 60)
    print("Running Task Management Tests")
    print("=" * 60)
    
    # Clear the database before testing
    task_service.tasks_db.clear()
    
    # Create a sample task
    task = TaskModel(
        id=uuid4(),
        child_id=uuid4(),
        title="Test Task",
        description="This is a test task",
        points=5,
        status=TaskStatus.PENDING,
        created_by=uuid4(),
        approved_at=None
    )
    
    try:
        test_create_task(task)
        task_service.tasks_db.clear()
        
        test_get_all_tasks(TaskModel(id=uuid4(), child_id=uuid4(), title="Task 1", description="Desc", points=5, status=TaskStatus.PENDING, created_by=uuid4(), approved_at=None))
        task_service.tasks_db.clear()
        
        test_get_task_by_id(TaskModel(id=uuid4(), child_id=uuid4(), title="Task 2", description="Desc", points=5, status=TaskStatus.PENDING, created_by=uuid4(), approved_at=None))
        task_service.tasks_db.clear()
        
        test_get_nonexistent_task()
        task_service.tasks_db.clear()
        
        test_approve_task(TaskModel(id=uuid4(), child_id=uuid4(), title="Task 3", description="Desc", points=5, status=TaskStatus.PENDING, created_by=uuid4(), approved_at=None))
        task_service.tasks_db.clear()
        
        test_reject_task(TaskModel(id=uuid4(), child_id=uuid4(), title="Task 4", description="Desc", points=5, status=TaskStatus.PENDING, created_by=uuid4(), approved_at=None))
        task_service.tasks_db.clear()
        
        test_approve_nonexistent_task()
        task_service.tasks_db.clear()
        
        test_status_transitions(TaskModel(id=uuid4(), child_id=uuid4(), title="Task 5", description="Desc", points=5, status=TaskStatus.PENDING, created_by=uuid4(), approved_at=None))
        task_service.tasks_db.clear()
        
        print("=" * 60)
        print("✅ ALL TESTS PASSED SUCCESSFULLY!")
        print("=" * 60)
        
    except AssertionError as e:
        print(f"❌ TEST FAILED: {e}")
        print("=" * 60)
