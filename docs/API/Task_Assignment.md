# Task Assignment API

The Task Assignment API provides operations for retrieving task assignments, completing assigned tasks, and allowing parents to approve or reject completed assignments.

## Base Path

```text
/api/task-assignments
```

## Endpoints

| Method | Endpoint | Description | Authentication |
| ------- | -------- | ----------- | -------------- |
| `GET` | `/task/<task_id>` | Retrieve all assignments for a specific task | Parent access token required |
| `GET` | `/my` | Retrieve all assignments for the authenticated child | Child access token required |
| `GET` | `/child/<child_id>` | Retrieve all assignments for a specific child | Parent access token required |
| `PUT` | `/<assignment_id>/complete` | Mark an assigned task as completed | Child access token required |
| `PUT` | `/<assignment_id>/approve` | Approve a completed task assignment | Parent access token required |
| `PUT` | `/<assignment_id>/reject` | Reject a completed task assignment | Parent access token required |


## Get Assignments by Task

Retrieves all assignments generated for a specific task accessible to the authenticated parent.

Each returned assignment contains its current status, assignment date, completion and approval timestamps, task information, and child information.

Assignments are ordered from the most recent assignment date to the oldest.

If the task exists but has no generated assignments, an empty list is returned.

### Request

```http
GET /api/task-assignments/task/{task_id}
```

### Authentication

A valid parent access token must be sent in the `Authorization` header.

Example:

```http
Authorization: <access-token>
```

### Path Parameters

| Parameter | Type | Description |
| --------- | ---- | ----------- |
| `task_id` | String (UUID) | The ID of the task whose assignments will be retrieved. |

### Request Body

No request body is required.

### Success Response

**Status Code:** `200 OK`

```json
[
  {
    "id": "bc82384d-f2f9-4e2b-88a5-f2f1abca77a2",
    "status": "PENDING_REVIEW",
    "completed_at": "2026-07-20T17:30:00",
    "approved_at": null,
    "task": {
      "id": "39b96ab1-c720-49df-a479-fab78fcf1965",
      "title": "Clean your room",
      "description": "Organize the room and put everything back in its place.",
      "points": 10,
      "task_frequency": "WEEKLY",
      "recurrence_day": 5,
      "category": "MORAL",
      "is_auto_verified": false
    },
    "child": {
      "id": "953e2b6e-8b7e-484a-ad1e-7709e2cb0301",
      "name": "Ahmed",
      "age": 10
    },
    "assigned_date": "2026-07-20"
  }
]
```

If the task exists but has no generated assignments, an empty list is returned:

```json
[]
```

### Error Responses

#### Invalid Access Token

Returned when the access token is missing, malformed, invalid, expired, or revoked.

**Status Code:** `401 Unauthorized`

Possible responses include:

```json
{
  "error": "Authorization token is required"
}
```

```json
{
  "error": "Invalid Authorization header"
}
```

```json
{
  "error": "Invalid token"
}
```

```json
{
  "error": "Token has expired"
}
```

```json
{
  "error": "Token has been revoked"
}
```

#### Parent Access Required

Returned when the authenticated account is not a parent.

**Status Code:** `403 Forbidden`

```json
{
  "error": "Parent access required"
}
```

#### Task Not Found

Returned when the task does not exist or is not accessible to the authenticated parent.

**Status Code:** `404 Not Found`

```json
{
  "error": "Task not found"
}
```


## Get My Assignments

Retrieves all task assignments belonging to the authenticated child.

Assignments are ordered from the most recent assignment date to the oldest.

If the child has no task assignments, an empty list is returned.

### Request

```http
GET /api/task-assignments/my
```

### Authentication

A valid child access token must be sent in the `Authorization` header.

Example:

```http
Authorization: <access-token>
```

### Request Body

No request body is required.

### Success Response

**Status Code:** `200 OK`

```json
[
  {
    "id": "bc82384d-f2f9-4e2b-88a5-f2f1abca77a2",
    "status": "PENDING_REVIEW",
    "completed_at": "2026-07-20T17:30:00",
    "approved_at": null,
    "task": {
      "id": "39b96ab1-c720-49df-a479-fab78fcf1965",
      "title": "Clean your room",
      "description": "Organize the room and put everything back in its place.",
      "points": 10,
      "task_frequency": "WEEKLY",
      "recurrence_day": 5,
      "category": "MORAL",
      "is_auto_verified": false
    },
    "assigned_date": "2026-07-20"
  }
]
```

If the authenticated child has no task assignments, an empty list is returned:

```json
[]
```

### Error Responses

#### Invalid Access Token

Returned when the access token is missing, malformed, invalid, expired, or revoked.

**Status Code:** `401 Unauthorized`

Possible responses include:

```json
{
  "error": "Authorization token is required"
}
```

```json
{
  "error": "Invalid Authorization header"
}
```

```json
{
  "error": "Invalid token"
}
```

```json
{
  "error": "Token has expired"
}
```

```json
{
  "error": "Token has been revoked"
}
```

#### Child Access Required

Returned when the authenticated account is not a child.

**Status Code:** `403 Forbidden`

```json
{
  "error": "Child access required"
}
```

## Get Assignments by Child

Retrieves all task assignments for a specific child associated with the authenticated parent.

Assignments are ordered from the most recent assignment date to the oldest.

If the child exists but has no task assignments, an empty list is returned.

### Request

```http
GET /api/task-assignments/child/{child_id}
```

### Authentication

A valid parent access token must be sent in the `Authorization` header.

Example:

```http
Authorization: <access-token>
```

### Path Parameters

| Parameter | Type | Description |
| --------- | ---- | ----------- |
| `child_id` | String (UUID) | The ID of the child whose task assignments will be retrieved. |

### Request Body

No request body is required.

### Success Response

**Status Code:** `200 OK`

```json
[
  {
    "id": "bc82384d-f2f9-4e2b-88a5-f2f1abca77a2",
    "status": "PENDING_REVIEW",
    "completed_at": "2026-07-20T17:30:00",
    "approved_at": null,
    "task": {
      "id": "39b96ab1-c720-49df-a479-fab78fcf1965",
      "title": "Clean your room",
      "description": "Organize the room and put everything back in its place.",
      "points": 10,
      "task_frequency": "WEEKLY",
      "recurrence_day": 5,
      "category": "MORAL",
      "is_auto_verified": false
    },
    "child": {
      "id": "953e2b6e-8b7e-484a-ad1e-7709e2cb0301",
      "name": "Ahmed",
      "age": 10
    },
    "assigned_date": "2026-07-20"
  }
]
```

If the child exists but has no task assignments, an empty list is returned:

```json
[]
```

### Error Responses

#### Invalid Access Token

Returned when the access token is missing, malformed, invalid, expired, or revoked.

**Status Code:** `401 Unauthorized`

Possible responses include:

```json
{
  "error": "Authorization token is required"
}
```

```json
{
  "error": "Invalid Authorization header"
}
```

```json
{
  "error": "Invalid token"
}
```

```json
{
  "error": "Token has expired"
}
```

```json
{
  "error": "Token has been revoked"
}
```

#### Parent Access Required

Returned when the authenticated account is not a parent.

**Status Code:** `403 Forbidden`

```json
{
  "error": "Parent access required"
}
```

#### Child Not Found or Access Denied

Returned when the child does not exist or is not associated with the authenticated parent.

**Status Code:** `404 Not Found`

```json
{
  "error": "Child not found or access denied"
}
```

## Complete Assignment

Marks a task assignment as completed by the authenticated child.

The resulting assignment status depends on whether the task is configured for automatic verification:

- If `is_auto_verified` is `true`, the assignment is immediately approved, and the task points are added to the child's total points.
- If `is_auto_verified` is `false`, the assignment is moved to `PENDING_REVIEW` until a parent approves or rejects it.

A rejected assignment can be completed again by the child.

### Request

```http
PUT /api/task-assignments/{assignment_id}/complete
```

### Authentication

A valid child access token must be sent in the `Authorization` header.

Example:

```http
Authorization: <access-token>
```

### Path Parameters

| Parameter | Type | Description |
| --------- | ---- | ----------- |
| `assignment_id` | String (UUID) | The ID of the task assignment to complete. |

### Request Body

No request body is required.

### Success Response

**Status Code:** `200 OK`

#### Automatically Verified Assignment

If the task has automatic verification enabled, the assignment is immediately approved:

```json
{
  "id": "bc82384d-f2f9-4e2b-88a5-f2f1abca77a2",
  "status": "APPROVED",
  "completed_at": "2026-07-20T17:30:00",
  "approved_at": "2026-07-20T17:30:00",
  "task": {
    "id": "39b96ab1-c720-49df-a479-fab78fcf1965",
    "title": "Clean your room",
    "description": "Organize the room and put everything back in its place.",
    "points": 10,
    "task_frequency": "WEEKLY",
    "recurrence_day": 5,
    "category": "MORAL",
    "is_auto_verified": true
  },
  "assigned_date": "2026-07-20"
}
```

The task points are also added to the child's total points, and a points history record is created with the action `TASK_APPROVED`.

#### Assignment Requiring Parent Review

If automatic verification is disabled, the assignment is sent for parent review:

```json
{
  "id": "bc82384d-f2f9-4e2b-88a5-f2f1abca77a2",
  "status": "PENDING_REVIEW",
  "completed_at": "2026-07-20T17:30:00",
  "approved_at": null,
  "task": {
    "id": "39b96ab1-c720-49df-a479-fab78fcf1965",
    "title": "Clean your room",
    "description": "Organize the room and put everything back in its place.",
    "points": 10,
    "task_frequency": "WEEKLY",
    "recurrence_day": 5,
    "category": "MORAL",
    "is_auto_verified": false
  },
  "assigned_date": "2026-07-20"
}
```

### Error Responses

#### Assignment Already Completed or Waiting for Review

Returned when the assignment status is already `APPROVED` or `PENDING_REVIEW`.

**Status Code:** `400 Bad Request`

```json
{
  "error": "Assignment already completed or waiting for review"
}
```

#### Invalid Access Token

Returned when the access token is missing, malformed, invalid, expired, or revoked.

**Status Code:** `401 Unauthorized`

Possible responses include:

```json
{
  "error": "Authorization token is required"
}
```

```json
{
  "error": "Invalid Authorization header"
}
```

```json
{
  "error": "Invalid token"
}
```

```json
{
  "error": "Token has expired"
}
```

```json
{
  "error": "Token has been revoked"
}
```

#### Child Access Required

Returned when the authenticated account is not a child.

**Status Code:** `403 Forbidden`

```json
{
  "error": "Child access required"
}
```

#### Assignment Not Found

Returned when the assignment does not exist or does not belong to the authenticated child.

**Status Code:** `404 Not Found`

```json
{
  "error": "Assignment not found"
}
```

#### Failed to Complete Assignment

Returned when the assignment cannot be updated, points cannot be added, the points history cannot be created, or another unexpected database error occurs.

**Status Code:** `500 Internal Server Error`

```json
{
  "error": "Failed to complete assignment"
}
```

## Approve Assignment

Approves a task assignment that is currently waiting for parent review.

Only the parent who created the original task can approve the assignment.

When the assignment is approved:

- Its status is changed to `APPROVED`.
- The approval timestamp is recorded.
- The task points are added to the child's total points.
- A points history record is created for the approved task.

### Request

```http
PUT /api/task-assignments/{assignment_id}/approve
```

### Authentication

A valid parent access token must be sent in the `Authorization` header.

Example:

```http
Authorization: <access-token>
```

### Path Parameters

| Parameter | Type | Description |
| --------- | ---- | ----------- |
| `assignment_id` | String (UUID) | The ID of the task assignment to approve. |

### Request Body

No request body is required.

### Success Response

**Status Code:** `200 OK`

```json
{
  "id": "bc82384d-f2f9-4e2b-88a5-f2f1abca77a2",
  "status": "APPROVED",
  "completed_at": "2026-07-20T17:30:00",
  "approved_at": "2026-07-20T18:00:00",
  "task": {
    "id": "39b96ab1-c720-49df-a479-fab78fcf1965",
    "title": "Clean your room",
    "description": "Organize the room and put everything back in its place.",
    "points": 10,
    "task_frequency": "WEEKLY",
    "recurrence_day": 5,
    "category": "MORAL",
    "is_auto_verified": false
  },
  "child": {
    "id": "953e2b6e-8b7e-484a-ad1e-7709e2cb0301",
    "name": "Ahmed",
    "age": 10
  },
  "assigned_date": "2026-07-20"
}
```

### Error Responses

#### Assignment Is Not Waiting for Review

Returned when the assignment status is not `PENDING_REVIEW`.

This includes assignments that are still pending, already approved, or rejected.

**Status Code:** `400 Bad Request`

```json
{
  "error": "Assignment is not waiting for review"
}
```

#### Invalid Access Token

Returned when the access token is missing, malformed, invalid, expired, or revoked.

**Status Code:** `401 Unauthorized`

Possible responses include:

```json
{
  "error": "Authorization token is required"
}
```

```json
{
  "error": "Invalid Authorization header"
}
```

```json
{
  "error": "Invalid token"
}
```

```json
{
  "error": "Token has expired"
}
```

```json
{
  "error": "Token has been revoked"
}
```

#### Parent Access Required

Returned when the authenticated account is not a parent.

**Status Code:** `403 Forbidden`

```json
{
  "error": "Parent access required"
}
```

#### Assignment Not Found

Returned when the assignment does not exist or the authenticated parent did not create the original task.

**Status Code:** `404 Not Found`

```json
{
  "error": "Assignment not found"
}
```

#### Failed to Approve Assignment

Returned when the assignment cannot be updated, the task points cannot be added, the points history cannot be created, or another unexpected database error occurs.

**Status Code:** `500 Internal Server Error`

```json
{
  "error": "Failed to approve assignment"
}
```

## Reject Assignment

Rejects a task assignment that is currently waiting for parent review.

Only the parent who created the original task can reject the assignment.

When an assignment is rejected:

- Its status is changed to `REJECTED`.
- The approval timestamp is cleared.
- No points are awarded to the child.
- No points history record is created.

A rejected assignment can be completed again by the child.

### Request

```http
PUT /api/task-assignments/{assignment_id}/reject
```

### Authentication

A valid parent access token must be sent in the `Authorization` header.

Example:

```http
Authorization: <access-token>
```

### Path Parameters

| Parameter | Type | Description |
| --------- | ---- | ----------- |
| `assignment_id` | String (UUID) | The ID of the task assignment to reject. |

### Request Body

No request body is required.

### Success Response

**Status Code:** `200 OK`

```json
{
  "id": "bc82384d-f2f9-4e2b-88a5-f2f1abca77a2",
  "status": "REJECTED",
  "completed_at": "2026-07-20T17:30:00",
  "approved_at": null,
  "task": {
    "id": "39b96ab1-c720-49df-a479-fab78fcf1965",
    "title": "Clean your room",
    "description": "Organize the room and put everything back in its place.",
    "points": 10,
    "task_frequency": "WEEKLY",
    "recurrence_day": 5,
    "category": "MORAL",
    "is_auto_verified": false
  },
  "child": {
    "id": "953e2b6e-8b7e-484a-ad1e-7709e2cb0301",
    "name": "Ahmed",
    "age": 10
  },
  "assigned_date": "2026-07-20"
}
```

### Error Responses

#### Assignment Is Not Waiting for Review

Returned when the assignment status is not `PENDING_REVIEW`.

This includes assignments that are still pending, already approved, or already rejected.

**Status Code:** `400 Bad Request`

```json
{
  "error": "Assignment is not waiting for review"
}
```

#### Invalid Access Token

Returned when the access token is missing, malformed, invalid, expired, or revoked.

**Status Code:** `401 Unauthorized`

Possible responses include:

```json
{
  "error": "Authorization token is required"
}
```

```json
{
  "error": "Invalid Authorization header"
}
```

```json
{
  "error": "Invalid token"
}
```

```json
{
  "error": "Token has expired"
}
```

```json
{
  "error": "Token has been revoked"
}
```

#### Parent Access Required

Returned when the authenticated account is not a parent.

**Status Code:** `403 Forbidden`

```json
{
  "error": "Parent access required"
}
```

#### Assignment Not Found

Returned when the assignment does not exist or the authenticated parent did not create the original task.

**Status Code:** `404 Not Found`

```json
{
  "error": "Assignment not found"
}
```

#### Failed to Reject Assignment

Returned when an unexpected database error occurs while updating the assignment.

**Status Code:** `500 Internal Server Error`

```json
{
  "error": "Failed to reject assignment"
}
```