# Rewards API

The Rewards API allows parents to create, view, update, and delete rewards assigned to their children.

Children can view rewards assigned to them and claim rewards that have been unlocked.

## Base Path

```text
/api/rewards
```

## Endpoints

| Method | Endpoint | Description | Authentication |
| ------ | -------- | ----------- | -------------- |
| `POST` | `/` | Create a new reward for a child | Parent access token required |
| `GET` | `/child/<child_id>` | Retrieve the rewards assigned to a specific child | Parent access token required |
| `GET` | `/my` | Retrieve the authenticated child's rewards | Child access token required |
| `PUT` | `/<reward_id>` | Update an existing reward | Parent access token required |
| `DELETE` | `/<reward_id>` | Delete an existing reward | Parent access token required |
| `PUT` | `/<reward_id>/claim` | Claim an unlocked reward | Child access token required |

## Create Reward

Creates a new reward for one of the authenticated parent's children.

The authenticated parent must be registered as one of the child's guardians.

If `unlock_day` matches the current weekday (Riyadh time), the reward is created with the status `UNLOCKED`. Otherwise, it is created with the status `LOCKED`.

If `unlock_day` is not provided, it defaults to `3` (Thursday).

### Request

```http
POST /api/rewards
```

### Authentication

A valid parent access token must be sent in the `Authorization` header.

Example:

```http
Authorization: <access-token>
```

### Request Body

| Field | Type | Required | Description |
|------|------|----------|-------------|
| `child_id` | String (UUID) | Yes | ID of the child who will receive the reward. |
| `reward_name` | String | Yes | Reward name. Must contain between 2 and 100 non-whitespace characters. |
| `description` | String | No | Reward description. Maximum 500 characters. May be `null`. |
| `unlock_day` | Integer | No | Weekday on which the reward becomes available. Valid values are `0` (Monday) through `6` (Sunday). Defaults to `3` (Thursday). |

Example:

```json
{
  "child_id": "953e2b6e-8b7e-484a-ad1e-7709e2cb0301",
  "reward_name": "New Football",
  "description": "You earned a new football for completing your weekly tasks.",
  "unlock_day": 4
}
```

### Success Response

**Status Code:** `201 Created`

```json
{
  "id": "fd44b6c0-78b3-456d-9c41-7d2a4d92d4b1",
  "child_id": "953e2b6e-8b7e-484a-ad1e-7709e2cb0301",
  "reward_name": "New Football",
  "description": "You earned a new football for completing your weekly tasks.",
  "status": "LOCKED",
  "unlock_day": 4,
  "assigned_by": "7c92d33b-1d6c-4c7f-aeb6-f6c96bda5b39",
  "created_at": "2026-07-20T15:20:00"
}
```

### Error Responses

#### Invalid Input

Returned when one or more request fields fail validation.

**Status Code:** `400 Bad Request`

Example responses:

```json
{
  "errors": {
    "reward_name": [
      "Reward name must be at least 2 characters long."
    ]
  }
}
```

```json
{
  "errors": {
    "reward_name": [
      "Reward name must not exceed 100 characters."
    ]
  }
}
```

```json
{
  "errors": {
    "description": [
      "Longer than maximum length 500."
    ]
  }
}
```

```json
{
  "errors": {
    "unlock_day": [
      "Must be greater than or equal to 0 and less than or equal to 6."
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

Returned when the specified child does not exist or the authenticated parent is not registered as one of the child's guardians.

**Status Code:** `404 Not Found`

```json
{
  "error": "Child not found"
}
```

#### Failed to Create Reward

Returned when the reward cannot be created because of a database or unexpected server error.

**Status Code:** `500 Internal Server Error`

```json
{
  "error": "Failed to create reward"
}
```
