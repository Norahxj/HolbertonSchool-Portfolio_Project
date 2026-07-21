# Dashboard API

The Dashboard API provides weekly progress statistics for children associated with the authenticated user.

Parents can retrieve dashboard information for all of their children, including task completion progress, task status counts, and the current week's date range.

## Base Path

```text
/api/dashboard
```

## Endpoints

| Method | Endpoint | Description | Authentication |
| ------ | -------- | ----------- | -------------- |
| `GET` | `/` | Retrieve the weekly dashboard for all children associated with the authenticated parent | Access token required |

## Get Parent Dashboard

Retrieves the current weekly dashboard statistics for every child associated with the authenticated parent.

The current week starts on Friday and ends on Thursday, based on the Riyadh date.

Task progress is calculated using approved tasks only. Tasks that are pending, waiting for review, or rejected are not counted as completed.

### Request

```http
GET /api/dashboard/
```

### Authentication

A valid parent access token must be sent in the `Authorization` header.

Example:

```http
Authorization: <access-token>
```

### Success Response

**Status Code:** `200 OK`

```json
[
  {
    "child_id": "953e2b6e-8b7e-484a-ad1e-7709e2cb0301",
    "child_name": "Ahmed",
    "child_age": 12,
    "week_start": "2026-07-17",
    "week_end": "2026-07-23",
    "progress_percentage": 50.0,
    "completed_tasks": 2,
    "approved_tasks": 2,
    "pending_review_tasks": 1,
    "pending_tasks": 1,
    "rejected_tasks": 0,
    "remaining_tasks": 2,
    "total_tasks": 4
  }
]
```

Each child dashboard contains:

| Field | Type | Description |
| ----- | ---- | ----------- |
| `child_id` | String | Unique identifier of the child. |
| `child_name` | String | Child's name. |
| `child_age` | Integer | Child's current age. |
| `week_start` | Date | Start date of the current dashboard week. The week starts on Friday. |
| `week_end` | Date | End date of the current dashboard week. The week ends on Thursday. |
| `progress_percentage` | Float | Percentage of assigned tasks that have the status `APPROVED`, rounded to one decimal place. |
| `completed_tasks` | Integer | Number of approved tasks. This value is equal to `approved_tasks`. |
| `approved_tasks` | Integer | Number of assignments with the status `APPROVED`. |
| `pending_review_tasks` | Integer | Number of assignments with the status `PENDING_REVIEW`. |
| `pending_tasks` | Integer | Number of assignments with the status `PENDING`. |
| `rejected_tasks` | Integer | Number of assignments with the status `REJECTED`. |
| `remaining_tasks` | Integer | Number of tasks that are not approved. Calculated as `total_tasks - approved_tasks`. |
| `total_tasks` | Integer | Total number of task assignments assigned to the child during the current week. |

The progress percentage is calculated as:

```text
(approved_tasks / total_tasks) × 100
```

When the child has no task assignments during the current week, `progress_percentage` is `0`.

When the authenticated parent has no associated children, the endpoint returns an empty array:

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

#### Parent Not Found

Returned when the parent account associated with the access token no longer exists.

**Status Code:** `404 Not Found`

```json
{
  "error": "Parent not found"
}
```

#### Failed to Retrieve Dashboard

Returned when an unexpected service or database error prevents the dashboard from being retrieved.

**Status Code:** `500 Internal Server Error`

```json
{
  "error": "Failed to retrieve dashboard"
}
```
:::