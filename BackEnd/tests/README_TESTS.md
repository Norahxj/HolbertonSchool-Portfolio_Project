# Asalah Backend Tests

This test suite validates the following backend modules:

* Authentication
* User
* Child
* Task

The tests cover normal scenarios, edge cases, validation rules, authorization, authentication, invalid inputs, and error handling.

---

## Requirements

Activate the virtual environment:

### Windows

```bash
.venv\Scripts\activate
```

Install pytest if it is not already installed:

```bash
pip install pytest
```

---

## Run All Tests

Execute all tests:

```bash
python -m pytest -q
```

Example output:

```text
298 passed in 2m 14s
```

---

## Run Tests with Detailed Output

To display every test case and its result:

```bash
python -m pytest -v
```

Example output:

```text
tests/test_auth.py::TestAuthRegister::test_register_success PASSED
tests/test_auth.py::TestAuthRegister::test_duplicate_email PASSED
tests/test_user.py::TestUserLayer::test_get_current_user PASSED
tests/test_child.py::TestChildLayer::test_create_child PASSED
tests/test_task.py::TestTaskCreate::test_create_task_once_success PASSED
...
```

This mode is useful during demonstrations because it shows every executed test and whether it passed or failed.

---

## Test Coverage

The test suite includes:

* Successful requests
* Invalid input validation
* Missing required fields
* Invalid data types
* Authorization and authentication
* Duplicate resources
* Boundary value testing
* Empty values
* Invalid UUIDs
* Unauthorized access
* Error handling
* CRUD operations
* Task recurrence validation
* Parent and Child permission checks

---

## Expected Result

If all tests pass, pytest will display a summary similar to:

```text
========================
298 passed
========================
```

If a test fails, pytest will display:

* The name of the failed test
* The expected result
* The actual result
* The exact line where the failure occurred
* A traceback to help identify the issue
