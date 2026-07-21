# Cron API

The Cron API runs the application's scheduled daily background jobs.

It generates task assignments for recurring tasks that are due on the current Riyadh date and unlocks rewards whose configured unlock day matches the current Riyadh weekday.

This endpoint is intended for an external cron service and does not use JWT authentication. Access is protected using a secret value sent in the `X-Cron-Secret` request header.

## Base Path

```text
/api/cron
```

## Endpoints

| Method | Endpoint | Description | Authentication |
| ------ | -------- | ----------- | -------------- |
| `POST` | `/run-daily-jobs` | Run recurring task assignment generation and reward unlocking jobs | Cron secret required |

## Run Daily Jobs

Runs the application's scheduled daily jobs.

The endpoint performs two operations:

1. Generates task assignments for recurring tasks that are due on the current Riyadh date.
2. Unlocks locked rewards whose `unlock_day` matches the current Riyadh weekday.

The two jobs are executed independently. If one or both jobs report an error, the endpoint returns a partial failure response.

### Request

```http
POST /api/cron/run-daily-jobs
```

### Authentication

JWT authentication is not used.

A valid cron secret must be sent in the `X-Cron-Secret` request header.

Example:

```http
X-Cron-Secret: <cron-secret>
```

The provided value must exactly match the server's configured `CRON_SECRET` environment variable.

### Request Body

This endpoint does not require a request body.

### Daily Job Behavior

#### Recurring Task Assignments

The task assignment job retrieves recurring tasks and checks whether each task is due on the current Riyadh date.

For each due task and assigned child:

- An assignment is not created if an assignment already exists for the same task, child, and date.
- A new assignment is created with the status `PENDING`.
- Successfully created assignments increase the `created` count.
- Assignment creation failures increase the `failed` count.
- If at least one assignment fails, the task assignment job reports `partial_failure`.

#### Reward Unlocking

The reward job retrieves locked rewards whose `unlock_day` matches the current Riyadh weekday.

For each matching reward:

- The reward status is changed from `LOCKED` to `UNLOCKED`.
- The `unlocked` count is increased.

If no rewards are due, the job succeeds and returns an unlocked count of `0`.

### Success Response

Returned when both daily jobs complete without reporting an error.

**Status Code:** `200 OK`

```json
{
  "status": "success",
  "jobs": {
    "task_assignments": {
      "success": true,
      "created": 8,
      "failed": 0,
      "error": null
    },
    "rewards": {
      "success": true,
      "unlocked": 3,
      "error": null
    }
  },
  "message": "Daily jobs completed successfully"
}
```

### Response Fields

| Field | Type | Description |
| ----- | ---- | ----------- |
| `status` | String | Overall result. It is `success` when both jobs succeed and `partial_failure` when one or both jobs report an error. |
| `jobs` | Object | Results of the individual daily jobs. |
| `jobs.task_assignments.success` | Boolean | Indicates whether task assignment generation completed without reported failures. |
| `jobs.task_assignments.created` | Integer | Number of new task assignments created. |
| `jobs.task_assignments.failed` | Integer | Number of task assignments that could not be created. |
| `jobs.task_assignments.error` | String or null | Service error returned by the assignment job. It is `null` when the job succeeds. |
| `jobs.rewards.success` | Boolean | Indicates whether the reward unlocking job completed successfully. |
| `jobs.rewards.unlocked` | Integer | Number of rewards changed from `LOCKED` to `UNLOCKED`. It is `0` when no rewards are due or when the reward job fails. |
| `jobs.rewards.error` | String or null | Service error returned by the reward job. It is `null` when the job succeeds. |
| `message` | String | Human-readable summary of the overall result. |

### Error Responses

#### Unauthorized Cron Request

Returned when the `X-Cron-Secret` header is missing or does not match the configured server secret.

**Status Code:** `401 Unauthorized`

```json
{
  "error": "Unauthorized"
}
```

#### Daily Jobs Completed with Errors

Returned when one or both daily jobs report an error.

**Status Code:** `500 Internal Server Error`

Example where some task assignments fail while rewards are unlocked successfully:

```json
{
  "status": "partial_failure",
  "jobs": {
    "task_assignments": {
      "success": false,
      "created": 6,
      "failed": 2,
      "error": "partial_failure"
    },
    "rewards": {
      "success": true,
      "unlocked": 3,
      "error": null
    }
  },
  "message": "Daily jobs completed with one or more errors"
}
```

Example where reward updates fail while task assignments succeed:

```json
{
  "status": "partial_failure",
  "jobs": {
    "task_assignments": {
      "success": true,
      "created": 8,
      "failed": 0,
      "error": null
    },
    "rewards": {
      "success": false,
      "unlocked": 0,
      "error": "update_failed"
    }
  },
  "message": "Daily jobs completed with one or more errors"
}
```
