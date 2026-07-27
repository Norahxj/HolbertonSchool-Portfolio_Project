# Testing Evidence and Results

## Purpose

Testing was performed throughout all four development sprints to verify that frontend and backend components worked correctly, met the documented requirements, and remained stable before merging new features.

---

# Testing Approach

The project used multiple testing methods during development:

- API testing using Swagger.
- Manual integration testing between Flutter and the backend using Dio requests.
- Flutter Widget Testing for UI components.
- End-to-end workflow testing after each completed feature.
- Validation testing based on backend documentation.
- Regression testing before every Pull Request merge.

---

# Testing Across Sprints

Testing activities were integrated into every sprint to ensure continuous quality assurance.

### Sprint 1

- Backend API testing.
- Authentication testing.
- Database validation.
- Initial API verification using Swagger.

### Sprint 2

- Frontend integration testing.
- Task management testing.
- Widget testing.
- API communication verification using Dio logs.

### Sprint 3

- Parent approval workflow testing.
- Noor Points calculation testing.
- Authentication token validation.
- Regression testing for completed features.

### Sprint 4

- Wishlist and Weekly Rewards testing.
- End-to-end workflow testing.
- Final integration testing.
- Performance verification and bug fixing.
---
# API Testing

All REST API endpoints were tested using Swagger before frontend integration.

The team verified:

- Authentication endpoints (Login, Register, Refresh Token)
- Child Management APIs
- Task Management APIs
- Task Assignment APIs
- Wishlist APIs
- Reward APIs
- Noor Points APIs

The following aspects were verified:

- Successful requests (200/201 responses)
- Validation errors (400 responses)
- Unauthorized access (401 responses)
- Correct request and response payloads
- Business rules defined in the backend documentation

---

# Validation Testing

Validation rules were tested according to the backend API documentation.

Examples include:

- Required fields cannot be empty.
- Invalid email and phone formats are rejected.
- Password validation rules.
- Children cannot create more than **5 wishlist items**.
- Required task information must be completed before submission.
- Parent approval flow follows the documented business rules.

Whenever backend validation rules existed, the same rules were reflected in the Flutter UI to provide immediate feedback to users.

---

# Flutter Widget Testing

Widget tests were created for frontend components to verify:

- Widget rendering.
- User interaction.
- Button actions.
- Form validation.
- Screen navigation.
- UI behavior after state changes.

---

# Integration Testing

Integration testing verified communication between the Flutter application and the backend APIs.

The following workflows were tested:

- Parent registration and login.
- Child login.
- Authentication token handling.
- Loading children.
- Creating tasks.
- Assigning tasks.
- Completing tasks.
- Parent approval and rejection.
- Wishlist management.
- Reward management.
- Noor Points updates.

HTTP requests were monitored using **Dio logs** to verify:

- Request URLs
- Request bodies
- Authentication headers
- HTTP status codes
- Response payloads
- Error responses

---

# Testing Evidence

The following integration tests were executed using the Flutter application connected to the deployed backend. All requests were verified using Dio logs to ensure correct communication between the frontend and backend.

## User Profile Retrieval

**Endpoint**

```text
GET /api/users/me
```

**Expected Result**

The authenticated parent's profile is returned successfully.

**Actual Result**

- HTTP Status: **200 OK**
- Parent profile retrieved successfully.

Verified information:

- First Name
- Last Name
- Email
- Phone Number
- Guardian Type
- User Role

**Status**

✅ Passed

---

## Retrieve Children

**Endpoint**

```text
GET /api/children/
```

**Expected Result**

The authenticated parent receives all registered children.

**Actual Result**

- HTTP Status: **200 OK**
- Existing children displayed successfully.
- Newly added children appeared immediately after creation.

Verified:

- Child ID
- Name
- Birth Date
- Age
- Access Code
- Role

**Status**

✅ Passed

---

## Add Child

**Endpoint**

```text
POST /api/children/
```

**Test Data**

```text
Name: نوره
Birth Date: 2011-07-09
```

**Expected Result**

A new child account is created and linked to the parent.

**Actual Result**

- HTTP Status: **201 Created**
- Child account created successfully.
- Access code generated automatically.
- Child immediately appeared in the children list.

**Status**

✅ Passed

---

## Generate Task Suggestions

**Endpoint**

```text
POST /api/task-bank/suggestions
```

**Expected Result**

The backend returns task suggestions based on the selected category.

**Actual Result**

- HTTP Status: **200 OK**
- Five task suggestions returned successfully.

Verified returned fields:

- Title
- Description
- Points
- Category
- Task Frequency
- Auto Verification

**Status**

✅ Passed

---

## Create Task

**Endpoint**

```text
POST /api/tasks/
```

**Expected Result**

A new task is created and assigned to the selected child.

**Actual Result**

- HTTP Status: **201 Created**
- Task created successfully.
- Task ID returned.
- Assignment generated automatically.

**Status**

✅ Passed

---

## Retrieve Child Tasks

**Endpoint**

```text
GET /api/tasks/child/{child_id}
```

**Expected Result**

The selected child's tasks are retrieved successfully.

**Actual Result**

- HTTP Status: **200 OK**
- Newly created task returned correctly.

Verified:

- Task Title
- Description
- Points
- Category
- Frequency
- Auto Verification

**Status**

✅ Passed

---

## Retrieve Child Task Assignments

**Endpoint**

```text
GET /api/task-assignments/child/{child_id}
```

**Expected Result**

Assignments belonging to the child are displayed correctly.

**Actual Result**

- HTTP Status: **200 OK**
- Assignment retrieved successfully.

Verified:

- Assignment Status
- Task Information
- Child Information
- Assigned Date

**Status**

✅ Passed

---

## Parent Review Workflow

The complete parent review workflow was verified using different assignment states.

Verified states:

- APPROVED
- REJECTED
- PENDING

Verified returned data:

- Assignment Status
- completed_at timestamp
- approved_at timestamp
- Task Information
- Child Information
- Assigned Date

This confirmed that task approval and rejection behaved correctly according to the backend business rules.

**Status**

✅ Passed

---

## Automatic UI Refresh

After successfully creating children and tasks, the application refreshed automatically and displayed updated information retrieved from the backend.

Verified updates:

- Newly created child appeared immediately.
- Newly created task appeared under the selected child.
- Task assignment became visible without inconsistencies.

**Status**

✅ Passed

---

# End-to-End Workflow Testing

Complete user workflows were tested after implementing each feature.

Example workflow:

1. Parent logs into the application.
2. Parent creates a task.
3. Task is assigned to a child.
4. Child logs in.
5. Child completes the task.
6. Parent reviews the completed task.
7. Parent approves or rejects the task.
8. Noor Points are updated correctly.
9. Application UI refreshes with updated data.

---

# Regression Testing

Before every Pull Request:

- The feature owner tested the complete feature.
- Team members reviewed the implementation.
- Existing functionality was re-tested to ensure no new issues were introduced.
- Pull Requests were merged only after successful verification.

---

# Example Test Evidence

## Successful API Request

```text
POST /api/tasks/

Status Code: 201 Created

Request:
- Title: اقرأ صفحة من القرآن
- Category: MORAL
- Points: 15
- Frequency: DAILY

Result:
Task created successfully and returned a valid task ID.
```

---

## Successful Task Completion

```text
PUT /api/task-assignments/{assignment_id}/complete

Status Code: 200 OK

Result:
- Assignment status updated to APPROVED
- completed_at timestamp returned
- approved_at timestamp returned
```

---

## API Response Verification

```text
GET /api/task-assignments/my

Status Code: 200 OK

Returned:

- Task information
- Assignment status
- Completion timestamps
- Approval timestamps
- Child information
- Assigned date
```

The frontend correctly parsed and displayed the returned data.

---

# Testing Results

| Test Type | Status |
|-----------|--------|
| API Testing | ✅ Passed |
| Authentication Testing | ✅ Passed |
| Validation Testing | ✅ Passed |
| Widget Testing | ✅ Passed |
| Integration Testing | ✅ Passed |
| End-to-End Workflow Testing | ✅ Passed |
| Regression Testing | ✅ Passed |

---

# Conclusion

Continuous testing was performed throughout development rather than only at the end of the project. API endpoints were validated using Swagger, frontend behavior was verified through Widget Tests and manual integration testing, and complete application workflows were executed after each implemented feature. Regression testing before every Pull Request ensured that newly implemented functionality did not negatively impact existing features, resulting in a stable, reliable, and fully functional application.