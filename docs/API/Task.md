# Task API

The Task API provides operations for creating, retrieving, updating, and deleting tasks, as well as retrieving tasks assigned to a specific child.

## Base Path

```text
/api/tasks
```

## Endpoints

| Method | Endpoint | Description | Authentication |
| ------- | -------- | ----------- | -------------- |
| `POST` | `/` | Create a new task | Parent access token required |
| `GET` | `/` | Retrieve all tasks created by the authenticated parent | Parent access token required |
| `GET` | `/<task_id>` | Retrieve a specific task | Parent access token required |
| `PUT` | `/<task_id>` | Update a specific task | Parent access token required |
| `DELETE` | `/<task_id>` | Delete a specific task | Parent access token required |
| `GET` | `/child/<child_id>` | Retrieve all tasks assigned to a specific child | Parent access token required |


## Create Task

Creates a new task and assigns it to one or more children associated with the authenticated parent account.

If the task is due on the creation date, a pending task assignment is also created for each selected child.

### Request

```http
POST /api/tasks/
```

### Authentication

A valid parent access token must be sent in the `Authorization` header.

Example:

```http
Authorization: <access-token>
```

### Request Body

| Field              | Type              | Required    | Description                                                                                                                                             |
| ------------------ | ----------------- | ----------- | ------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `child_ids`        | Array of strings  | Yes         | List of child IDs to assign the task to. At least one child ID must be provided, and duplicate IDs are not allowed.                                     |
| `title`            | String            | Yes         | Task title. Must contain between 2 and 100 characters after trimming spaces.                                                                            |
| `description`      | String            | Yes         | Task description. Must contain between 2 and 500 characters after trimming spaces.                                                                      |
| `points`           | Integer           | Yes         | Points awarded for completing the task. Must be between 1 and 100.                                                                                      |
| `task_frequency`   | String            | No          | Task frequency. Allowed values: `ONCE`, `DAILY`, `WEEKLY`, or `MONTHLY`. Defaults to `ONCE`.                                                            |
| `recurrence_day`   | Integer or `null` | Conditional | Required for weekly and monthly tasks. Must be `0` to `6` for `WEEKLY`, or `1` to `31` for `MONTHLY`. Must be omitted or `null` for `ONCE` and `DAILY`. |
| `category`         | String            | Yes         | Task category. Allowed values: `RELIGIOUS`, `FINANCIAL`, `MORAL`, or `SOCIAL`.                                                                          |
| `is_auto_verified` | Boolean           | No          | Determines whether completing the task is automatically approved. Defaults to `false`.                                                                  |

Example for a weekly task:

```json
{
  "child_ids": [
    "c061c0d0-d3d2-42fa-a108-621c9e537acc"
  ],
  "title": "Clean your room",
  "description": "Organize the room and put everything back in its place.",
  "points": 10,
  "task_frequency": "WEEKLY",
  "recurrence_day": 5,
  "category": "MORAL",
  "is_auto_verified": false
}
```

Example for a one-time task:

```json
{
  "child_ids": [
    "c061c0d0-d3d2-42fa-a108-621c9e537acc",
    "7ac16ea4-6dbe-47ae-91bb-f77c1cb868d6"
  ],
  "title": "Help prepare dinner",
  "description": "Help the family prepare dinner today.",
  "points": 15,
  "task_frequency": "ONCE",
  "category": "SOCIAL",
  "is_auto_verified": true
}
```

### Success Response

**Status Code:** `201 Created`

```json
{
  "id": "39b96ab1-c720-49df-a479-fab78fcf1965",
  "title": "Clean your room",
  "description": "Organize the room and put everything back in its place.",
  "points": 10,
  "task_frequency": "WEEKLY",
  "recurrence_day": 5,
  "category": "MORAL",
  "is_auto_verified": false,
  "created_by": "4379bf17-4666-4213-b229-cbc40a776d31",
  "created_at": "2026-07-20T00:30:00"
}
```

### Error Responses

#### Invalid Input

Returned when the request body fails validation.

**Status Code:** `400 Bad Request`

Possible validation errors include:

* A required field is missing.
* `child_ids` is empty.
* Duplicate child IDs were provided.
* The title is shorter than 2 characters or longer than 100 characters.
* The description is shorter than 2 characters or longer than 500 characters.
* Points are less than 1 or greater than 100.
* The task frequency is invalid.
* The category is invalid.
* `recurrence_day` was provided for an `ONCE` or `DAILY` task.
* `recurrence_day` is missing for a `WEEKLY` or `MONTHLY` task.
* A weekly recurrence day is outside the range `0` to `6`.
* A monthly recurrence day is outside the range `1` to `31`.

Possible custom responses include:

```json
{
  "error": "Duplicate child IDs are not allowed"
}
```

```json
{
  "error": "At least one child ID is required"
}
```

Marshmallow validation errors are returned in this format:

```json
{
  "errors": {
    "points": [
      "Must be greater than or equal to 1 and less than or equal to 100."
    ]
  }
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

#### Child Not Found

Returned when at least one provided child ID does not exist or is not associated with the authenticated parent.

**Status Code:** `404 Not Found`

```json
{
  "error": "Child not found"
}
```

#### Failed to Create Task

Returned when an unexpected error occurs while creating the task, linking it to the selected children, or creating task assignments.

**Status Code:** `500 Internal Server Error`

```json
{
  "error": "Failed to create task"
}
```

## Get Parent Tasks

Retrieves all tasks created by the authenticated parent.

The response may contain an empty list if the parent has not created any tasks.

### Request

```http
GET /api/tasks/
```

### Authentication

A valid parent access token must be sent in the `Authorization` header.

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
    "id": "39b96ab1-c720-49df-a479-fab78fcf1965",
    "title": "Clean your room",
    "description": "Organize the room and put everything back in its place.",
    "points": 10,
    "task_frequency": "WEEKLY",
    "recurrence_day": 5,
    "category": "MORAL",
    "is_auto_verified": false,
    "created_by": "4379bf17-4666-4213-b229-cbc40a776d31",
    "created_at": "2026-07-20T00:30:00"
  },
  {
    "id": "5ac18f69-cb85-4f02-a99b-a03145369f8c",
    "title": "Help prepare dinner",
    "description": "Help the family prepare dinner today.",
    "points": 15,
    "task_frequency": "ONCE",
    "recurrence_day": null,
    "category": "SOCIAL",
    "is_auto_verified": true,
    "created_by": "4379bf17-4666-4213-b229-cbc40a776d31",
    "created_at": "2026-07-20T01:00:00"
  }
]
```

If the authenticated parent has not created any tasks, an empty list is returned:

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

## Get Task

Retrieves a specific task created by the authenticated parent.

### Request

```http id="2r4a8n"
GET /api/tasks/{task_id}
```

### Authentication

A valid parent access token must be sent in the `Authorization` header.

Example:

```http id="v6s2fh"
Authorization: <access-token>
```

### Path Parameters

| Parameter | Type          | Description                     |
| --------- | ------------- | ------------------------------- |
| `task_id` | String (UUID) | The ID of the task to retrieve. |

### Request Body

No request body is required.

### Success Response

**Status Code:** `200 OK`

```json id="4m0dxr"
{
  "id": "39b96ab1-c720-49df-a479-fab78fcf1965",
  "title": "Clean your room",
  "description": "Organize the room and put everything back in its place.",
  "points": 10,
  "task_frequency": "WEEKLY",
  "recurrence_day": 5,
  "category": "MORAL",
  "is_auto_verified": false,
  "created_by": "4379bf17-4666-4213-b229-cbc40a776d31",
  "created_at": "2026-07-20T00:30:00"
}
```

### Error Responses

#### Invalid Access Token

Returned when the access token is missing, malformed, invalid, expired, or revoked.

**Status Code:** `401 Unauthorized`

Possible responses include:

```json id="a5f9ke"
{
  "error": "Authorization token is required"
}
```

```json id="7n0uv1"
{
  "error": "Invalid Authorization header"
}
```

```json id="u6y4qm"
{
  "error": "Invalid token"
}
```

```json id="r3q8lt"
{
  "error": "Token has expired"
}
```

```json id="g8m1wp"
{
  "error": "Token has been revoked"
}
```

#### Parent Access Required

Returned when the authenticated account is not a parent.

**Status Code:** `403 Forbidden`

```json id="f0w7an"
{
  "error": "Parent access required"
}
```

#### Task Not Found

Returned when the task does not exist or is not associated with the authenticated parent.

**Status Code:** `404 Not Found`

```json id="m4v2pc"
{
  "error": "Task not found"
}
```

## Update Task

Updates one or more fields of a specific task created by the authenticated parent.

Only the fields included in the request body are updated. At least one field must be provided.

If the updated task becomes due on the current date, a pending task assignment is created for each assigned child unless an assignment already exists for that child and date.

### Request

```http
PUT /api/tasks/{task_id}
```

### Authentication

A valid parent access token must be sent in the `Authorization` header.

Example:

```http
Authorization: <access-token>
```

### Path Parameters

| Parameter | Type          | Description                   |
| --------- | ------------- | ----------------------------- |
| `task_id` | String (UUID) | The ID of the task to update. |

### Request Body

At least one of the following fields must be provided.

| Field              | Type              | Required    | Description                                                                                             |
| ------------------ | ----------------- | ----------- | ------------------------------------------------------------------------------------------------------- |
| `title`            | String            | No          | New task title. Must contain between 2 and 100 characters after trimming spaces.                        |
| `description`      | String            | No          | New task description. Must contain between 2 and 500 characters after trimming spaces.                  |
| `points`           | Integer           | No          | New number of points. Must be between 1 and 100.                                                        |
| `task_frequency`   | String            | No          | New task frequency. Allowed values: `ONCE`, `DAILY`, `WEEKLY`, or `MONTHLY`.                            |
| `recurrence_day`   | Integer or `null` | Conditional | Must be `0` to `6` for `WEEKLY`, or `1` to `31` for `MONTHLY`. It is not allowed for `ONCE` or `DAILY`. |
| `category`         | String            | No          | New task category. Allowed values: `RELIGIOUS`, `FINANCIAL`, `MORAL`, or `SOCIAL`.                      |
| `is_auto_verified` | Boolean           | No          | Determines whether completing the task is automatically approved.                                       |

Example updating the title and points:

```json
{
  "title": "Clean and organize your room",
  "points": 20
}
```

Example changing the task to a weekly task:

```json
{
  "task_frequency": "WEEKLY",
  "recurrence_day": 5
}
```

Example changing the task to a one-time task:

```json
{
  "task_frequency": "ONCE"
}
```

When changing a task to `ONCE` or `DAILY`, the stored `recurrence_day` is automatically set to `null`.

### Success Response

**Status Code:** `200 OK`

```json
{
  "id": "39b96ab1-c720-49df-a479-fab78fcf1965",
  "title": "Clean and organize your room",
  "description": "Organize the room and put everything back in its place.",
  "points": 20,
  "task_frequency": "WEEKLY",
  "recurrence_day": 5,
  "category": "MORAL",
  "is_auto_verified": false,
  "created_by": "4379bf17-4666-4213-b229-cbc40a776d31",
  "created_at": "2026-07-20T00:30:00"
}
```

### Error Responses

#### Invalid Input

Returned when the request body fails validation.

**Status Code:** `400 Bad Request`

Possible validation errors include:

* The request body contains no fields.
* The title is shorter than 2 characters or longer than 100 characters.
* The description is shorter than 2 characters or longer than 500 characters.
* Points are less than 1 or greater than 100.
* The task frequency is invalid.
* The category is invalid.
* `recurrence_day` is provided for an `ONCE` or `DAILY` task.
* `recurrence_day` is missing or invalid for a `WEEKLY` task.
* `recurrence_day` is missing or invalid for a `MONTHLY` task.

Example for an empty request body:

```json
{
  "errors": {
    "_schema": [
      "At least one field must be provided."
    ]
  }
}
```

Example for an invalid recurrence day:

```json
{
  "error": "Invalid recurrence_day for selected task_frequency"
}
```

Example for an invalid task frequency:

```json
{
  "error": "Invalid task frequency"
}
```

Other Marshmallow validation errors are returned in this format:

```json
{
  "errors": {
    "points": [
      "Must be greater than or equal to 1 and less than or equal to 100."
    ]
  }
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

#### Task Not Found

Returned when the task does not exist or was not created by the authenticated parent.

**Status Code:** `404 Not Found`

```json
{
  "error": "Task not found"
}
```

#### Failed to Update Task

Returned when an unexpected error occurs while updating the task or creating a task assignment.

**Status Code:** `500 Internal Server Error`

```json
{
  "error": "Failed to update task"
}
```


## Delete Task

Deletes a specific task created by the authenticated parent.

Deleting the task also removes related records according to the configured database relationships and cascade rules.

### Request

```http
DELETE /api/tasks/{task_id}
```

### Authentication

A valid parent access token must be sent in the `Authorization` header.

Example:

```http
Authorization: <access-token>
```

### Path Parameters

| Parameter | Type          | Description                   |
| --------- | ------------- | ----------------------------- |
| `task_id` | String (UUID) | The ID of the task to delete. |

### Request Body

No request body is required.

### Success Response

**Status Code:** `200 OK`

```json
{
  "message": "Task deleted successfully"
}
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

Returned when the task does not exist or was not created by the authenticated parent.

**Status Code:** `404 Not Found`

```json
{
  "error": "Task not found"
}
```

#### Failed to Delete Task

Returned when an unexpected error occurs while deleting the task.

**Status Code:** `500 Internal Server Error`

```json
{
  "error": "Failed to delete task"
}
```

## Get Tasks by Child

Retrieves all tasks assigned to a specific child associated with the authenticated parent.

The response may contain an empty list if the child exists but has no assigned tasks.

### Request

```http
GET /api/tasks/child/{child_id}
```

### Authentication

A valid parent access token must be sent in the `Authorization` header.

Example:

```http
Authorization: <access-token>
```

### Path Parameters

| Parameter  | Type          | Description                                        |
| ---------- | ------------- | -------------------------------------------------- |
| `child_id` | String (UUID) | The ID of the child whose tasks will be retrieved. |

### Request Body

No request body is required.

### Success Response

**Status Code:** `200 OK`

```json
[
  {
    "id": "39b96ab1-c720-49df-a479-fab78fcf1965",
    "title": "Clean your room",
    "description": "Organize the room and put everything back in its place.",
    "points": 10,
    "task_frequency": "WEEKLY",
    "recurrence_day": 5,
    "category": "MORAL",
    "is_auto_verified": false,
    "created_by": "4379bf17-4666-4213-b229-cbc40a776d31",
    "created_at": "2026-07-20T00:30:00"
  },
  {
    "id": "5ac18f69-cb85-4f02-a99b-a03145369f8c",
    "title": "Help prepare dinner",
    "description": "Help the family prepare dinner today.",
    "points": 15,
    "task_frequency": "ONCE",
    "recurrence_day": null,
    "category": "SOCIAL",
    "is_auto_verified": true,
    "created_by": "4379bf17-4666-4213-b229-cbc40a776d31",
    "created_at": "2026-07-20T01:00:00"
  }
]
```

If the child exists but has no assigned tasks, an empty list is returned:

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

#### Child Not Found

Returned when the child does not exist or is not associated with the authenticated parent.

**Status Code:** `404 Not Found`

```json
{
  "error": "Child not found"
}
```
