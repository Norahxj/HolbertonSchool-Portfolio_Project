# Testing Evidence and Results

## Purpose

Testing was performed throughout the development process to verify that frontend and backend components worked correctly, met the documented requirements, and remained stable before merging new features.

---

# Testing Approach

Multiple testing techniques were used throughout the four development sprints to ensure the quality and stability of the MVP.

The project included:

- API testing using Swagger.
- Manual integration testing between the Flutter application and the deployed backend.
- Flutter Widget Testing.
- Validation testing based on backend business rules.
- End-to-end workflow testing.
- Regression testing after implementing new features.

---

# API Testing

All REST API endpoints were tested before and after frontend integration.

The following APIs were verified:

- Authentication APIs
- Child Management APIs
- Task APIs
- Task Assignment APIs
- Parent Review APIs
- Wishlist APIs
- Weekly Rewards APIs
- Noor Points APIs

The following aspects were validated during testing:

- Successful responses (200 / 201)
- Validation errors (400)
- Unauthorized requests (401)
- Request payloads
- Response payloads
- Backend business rules

---

# Validation Testing

Validation rules implemented in the backend were also applied in the Flutter application.

Examples included:

- Required fields cannot be empty.
- Invalid email format is rejected.
- Invalid phone numbers are rejected.
- Password validation.
- Child creation validation.
- Task creation validation.
- Wishlist limitations.
- Parent approval workflow.

Providing the same validation rules in both frontend and backend ensured consistent user feedback.

---
# Frontend Testing

In addition to automated widget testing, the Flutter application was manually tested throughout the development process to verify that all user interface components functioned correctly after integration with the backend APIs.

The following frontend features were verified:

- Parent Login screen.
- Parent Registration screen.
- Child Login screen.
- Parent Dashboard.
- Add Child screen.
- Add Task screen.
- Parent Review screen.
- Completed Tasks screen.
- Wishlist screen.
- Weekly Rewards screen.

The following aspects were tested:

- Form validation.
- Navigation between screens.
- API integration.
- State updates.
- Automatic UI refresh after API operations.
- Error message display.
- Responsive layouts and UI consistency.

Frontend testing was performed after implementing each feature and again during integration testing to ensure that the user interface behaved correctly and provided a consistent user experience across the complete MVP.


---
# Flutter Widget Testing

Widget tests were executed using Flutter's testing framework to verify frontend components.

The following areas were tested:

- Widget rendering.
- User interaction.
- Button functionality.
- Form validation.
- Navigation.
- State updates.

Example test execution:

```text
flutter test

00:02 +3: All tests passed!
```

The widget tests verified that the application's core UI components rendered correctly and behaved as expected after implementation.

---

# Integration Testing

Integration testing verified communication between the Flutter application and the deployed backend.

The following workflows were tested:

- Parent registration.
- Parent login.
- Child login.
- Retrieve parent profile.
- Load children.
- Add child.
- Generate task suggestions.
- Create tasks.
- Retrieve child tasks.
- Retrieve task assignments.
- Parent review workflow.
- Automatic UI refresh after API updates.

During testing, Dio request and response logs were used to verify:

- Request URLs.
- Request bodies.
- Authentication headers.
- HTTP status codes.
- Response payloads.
- Error responses.

This confirmed that frontend and backend communicated correctly.

---

# Testing Evidence

The following tests were executed against the deployed backend.

## User Profile Retrieval

**Endpoint**

```text
GET /api/users/me
```

**Expected Result**

The authenticated parent's profile is returned.

**Actual Result**

- HTTP Status: **200 OK**
- Parent profile successfully retrieved.

Verified:

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

Return all children associated with the authenticated parent.

**Actual Result**

- HTTP Status: **200 OK**
- Children retrieved successfully.
- Newly created children appeared immediately after creation.

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

**Expected Result**

Create a new child account linked to the authenticated parent.

**Actual Result**

- HTTP Status: **201 Created**
- Child account created successfully.
- Access code generated automatically.
- Child appeared immediately in the children list.

**Status**

✅ Passed

---

## Generate Task Suggestions

**Endpoint**

```text
POST /api/task-bank/suggestions
```

**Expected Result**

Return task suggestions for the selected category.

**Actual Result**

- HTTP Status: **200 OK**
- Five task suggestions returned successfully.

Verified:

- Title
- Description
- Points
- Category
- Frequency
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

Create a new task successfully.

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

Return all tasks assigned to the selected child.

**Actual Result**

- HTTP Status: **200 OK**
- Tasks retrieved successfully.

Verified:

- Title
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

Return all task assignments for the selected child.

**Actual Result**

- HTTP Status: **200 OK**
- Assignments retrieved successfully.

Verified:

- Assignment Status
- Task Information
- Child Information
- Assigned Date

**Status**

✅ Passed

---

## Parent Review Workflow

The complete parent review workflow was tested.

Verified assignment states:

- PENDING
- APPROVED
- REJECTED

Verified returned data:

- Assignment Status
- Task Information
- Child Information
- Assigned Date
- completed_at
- approved_at

The workflow behaved according to the backend business rules.

**Status**

✅ Passed

---

## Automatic UI Refresh

After creating children and tasks, the application refreshed automatically.

Verified:

- Newly created children appeared immediately.
- Newly created tasks were displayed correctly.
- Updated assignment data was reflected without inconsistencies.

**Status**

✅ Passed

---

# End-to-End Workflow Testing

Complete application workflows were tested after implementing each feature.

Example workflow:

1. Parent logs in.
2. Parent adds a child.
3. Parent creates a task.
4. Parent assigns the task.
5. Child logs in.
6. Child completes the task.
7. Parent reviews the completed task.
8. Parent approves or rejects the task.
9. Noor Points are updated correctly.
10. The interface refreshes automatically.

All workflow steps completed successfully.

---

# Regression Testing

Regression testing was performed throughout development.

Before every Pull Request:

- The feature owner tested the implemented functionality.
- Team members reviewed the code.
- Existing functionality was re-tested.
- Pull Requests were merged only after successful verification.

---

# Example Test Evidence

## Example 1 – Child Creation

```text
POST /api/children/

Status Code: 201 Created

Result:
- Child account created successfully.
- Access code generated automatically.
- Child immediately appeared in the children list.
```

---

## Example 2 – Task Suggestions

```text
POST /api/task-bank/suggestions

Status Code: 200 OK

Result:
- Five task suggestions returned successfully.

Verified:
- Title
- Description
- Points
- Category
- Frequency
```

---

# Testing Results

| Test Type | Status |
| ---------- | ------ |
| API Testing | ✅ Passed |
| Authentication Testing | ✅ Passed |
| Validation Testing | ✅ Passed |
| Flutter Widget Testing | ✅ Passed |
| Integration Testing | ✅ Passed |
| End-to-End Workflow Testing | ✅ Passed |
| Regression Testing | ✅ Passed |

---

# Conclusion

Testing was performed continuously throughout the four development sprints rather than only at the end of the project. Backend APIs were validated using Swagger, frontend functionality was verified through Flutter Widget Tests and manual integration testing, and complete user workflows were executed against the deployed backend. Continuous regression testing, API verification, and end-to-end validation ensured that the MVP remained stable, fully integrated, and ready for deployment.