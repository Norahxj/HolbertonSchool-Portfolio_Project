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
## Get Child Rewards

Retrieves all rewards assigned to a specific child.

The authenticated parent must be registered as one of the child's guardians.

If the child has no rewards, the endpoint returns an empty list.

### Request

```http
GET /api/rewards/child/{child_id}
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
| `child_id` | String (UUID) | The ID of the child whose rewards will be retrieved. |

### Success Response

**Status Code:** `200 OK`

```json
[
  {
    "id": "fd44b6c0-78b3-456d-9c41-7d2a4d92d4b1",
    "child_id": "953e2b6e-8b7e-484a-ad1e-7709e2cb0301",
    "reward_name": "New Football",
    "description": "You earned a new football for completing your weekly tasks.",
    "status": "LOCKED",
    "unlock_day": 4,
    "assigned_by": "7c92d33b-1d6c-4c7f-aeb6-f6c96bda5b39",
    "created_at": "2026-07-20T15:20:00"
  },
  {
    "id": "3ab81862-15fd-49e0-a4a9-cf99b2af8d1f",
    "child_id": "953e2b6e-8b7e-484a-ad1e-7709e2cb0301",
    "reward_name": "Ice Cream",
    "description": null,
    "status": "UNLOCKED",
    "unlock_day": 0,
    "assigned_by": "7c92d33b-1d6c-4c7f-aeb6-f6c96bda5b39",
    "created_at": "2026-07-21T18:10:00"
  }
]
```

If the child has no rewards:

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

Returned when the specified child does not exist or the authenticated parent is not registered as one of the child's guardians.

**Status Code:** `404 Not Found`

```json
{
  "error": "Child not found"
}
```

#### Failed to Retrieve Rewards

Returned when the rewards cannot be retrieved because of a database or unexpected server error.

**Status Code:** `500 Internal Server Error`

```json
{
  "error": "Failed to retrieve rewards"
}
```

## Get My Rewards

Retrieves all rewards assigned to the authenticated child.

The child ID is obtained from the authenticated access token. Before retrieving the rewards, the system verifies that the child account still exists.

If the child has no assigned rewards, the endpoint returns an empty list.

### Request

```http
GET /api/rewards/my
```

### Authentication

A valid child access token must be sent in the `Authorization` header.

Example:

```http
Authorization: <access-token>
```

### Success Response

**Status Code:** `200 OK`

```json
[
  {
    "id": "fd44b6c0-78b3-456d-9c41-7d2a4d92d4b1",
    "child_id": "953e2b6e-8b7e-484a-ad1e-7709e2cb0301",
    "reward_name": "New Football",
    "description": "You earned a new football for completing your weekly tasks.",
    "status": "LOCKED",
    "unlock_day": 4,
    "assigned_by": "7c92d33b-1d6c-4c7f-aeb6-f6c96bda5b39",
    "created_at": "2026-07-20T15:20:00"
  },
  {
    "id": "3ab81862-15fd-49e0-a4a9-cf99b2af8d1f",
    "child_id": "953e2b6e-8b7e-484a-ad1e-7709e2cb0301",
    "reward_name": "Ice Cream",
    "description": null,
    "status": "UNLOCKED",
    "unlock_day": 0,
    "assigned_by": "7c92d33b-1d6c-4c7f-aeb6-f6c96bda5b39",
    "created_at": "2026-07-21T18:10:00"
  }
]
```

If the child has no assigned rewards:

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

#### Child Not Found

Returned when the child account associated with the access token no longer exists.

**Status Code:** `404 Not Found`

```json
{
  "error": "Child not found"
}
```

#### Failed to Retrieve Rewards

Returned when the rewards cannot be retrieved because of a database or unexpected server error.

**Status Code:** `500 Internal Server Error`

```json
{
  "error": "Failed to retrieve rewards"
}
```

## Update Reward

Updates an existing reward created by the authenticated parent.

The parent can update the reward name, description, unlock day, or any combination of these fields.

At least one field must be included in the request body.

If `unlock_day` is updated, the reward status is recalculated using the current weekday in Riyadh:

- The status becomes `UNLOCKED` when `unlock_day` matches the current weekday.
- The status becomes `LOCKED` when `unlock_day` does not match the current weekday.
- If the reward has already been claimed, its status remains `CLAIMED`.

### Request

```http
PUT /api/rewards/{reward_id}
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
| `reward_id` | String (UUID) | The ID of the reward to update. |

### Request Body

| Field | Type | Required | Description |
| ----- | ---- | -------- | ----------- |
| `reward_name` | String | No | Updated reward name. After removing surrounding spaces, it must contain between 2 and 100 characters. |
| `description` | String or `null` | No | Updated reward description. Maximum 500 characters. Send `null` to remove the current description. |
| `unlock_day` | Integer | No | Updated unlock weekday. Valid values are `0` (Monday) through `6` (Sunday). |

At least one field must be provided.

Example:

```json
{
  "reward_name": "Family Picnic",
  "description": "A weekend picnic with the family.",
  "unlock_day": 5
}
```

The request may also update a single field:

```json
{
  "unlock_day": 4
}
```

### Success Response

**Status Code:** `200 OK`

```json
{
  "id": "fd44b6c0-78b3-456d-9c41-7d2a4d92d4b1",
  "child_id": "953e2b6e-8b7e-484a-ad1e-7709e2cb0301",
  "reward_name": "Family Picnic",
  "description": "A weekend picnic with the family.",
  "status": "LOCKED",
  "unlock_day": 5,
  "assigned_by": "7c92d33b-1d6c-4c7f-aeb6-f6c96bda5b39",
  "created_at": "2026-07-20T15:20:00"
}
```

The returned status may be `LOCKED`, `UNLOCKED`, or `CLAIMED`, depending on the reward's current state and the updated unlock day.

### Error Responses

#### Invalid Input

Returned when the request body is empty or one or more fields fail validation.

**Status Code:** `400 Bad Request`

When no fields are provided:

```json
{
  "error": "At least one field must be provided"
}
```

When the reward name is too short:

```json
{
  "errors": {
    "reward_name": [
      "Reward name must be at least 2 characters long."
    ]
  }
}
```

When the reward name is too long:

```json
{
  "errors": {
    "reward_name": [
      "Reward name must not exceed 100 characters."
    ]
  }
}
```

When the description exceeds 500 characters:

```json
{
  "errors": {
    "description": [
      "Longer than maximum length 500."
    ]
  }
}
```

When `unlock_day` is outside the allowed range:

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

#### Reward Not Found

Returned when the reward does not exist or was not created by the authenticated parent.

**Status Code:** `404 Not Found`

```json
{
  "error": "Reward not found"
}
```

#### Failed to Update Reward

Returned when the reward cannot be updated because of a database or unexpected server error.

**Status Code:** `500 Internal Server Error`

```json
{
  "error": "Failed to update reward"
}
```

## Delete Reward

Deletes an existing reward created by the authenticated parent.

Only rewards with the status `LOCKED` or `UNLOCKED` can be deleted. A reward that has already been claimed cannot be deleted.

### Request

```http
DELETE /api/rewards/{reward_id}
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
| `reward_id` | String (UUID) | The ID of the reward to delete. |

### Success Response

**Status Code:** `200 OK`

```json
{
  "message": "Reward deleted successfully"
}
```

### Error Responses

#### Claimed Reward Cannot Be Deleted

Returned when the reward has already been claimed by the child.

**Status Code:** `400 Bad Request`

```json
{
  "error": "Claimed rewards cannot be deleted"
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

#### Reward Not Found

Returned when the reward does not exist or was not created by the authenticated parent.

**Status Code:** `404 Not Found`

```json
{
  "error": "Reward not found"
}
```

#### Failed to Delete Reward

Returned when the reward cannot be deleted because of a database or unexpected server error.

**Status Code:** `500 Internal Server Error`

```json
{
  "error": "Failed to delete reward"
}
```
## Claim Reward

Claims an unlocked reward assigned to the authenticated child.

The reward must belong to the authenticated child and must currently have the status `UNLOCKED`.

After a successful claim, the reward status is changed to `CLAIMED`.

### Request

```http
PUT /api/rewards/{reward_id}/claim
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
| `reward_id` | String (UUID) | The ID of the reward to claim. |

### Success Response

**Status Code:** `200 OK`

```json
{
  "id": "fd44b6c0-78b3-456d-9c41-7d2a4d92d4b1",
  "child_id": "953e2b6e-8b7e-484a-ad1e-7709e2cb0301",
  "reward_name": "New Football",
  "description": "You earned a new football for completing your weekly tasks.",
  "status": "CLAIMED",
  "unlock_day": 4,
  "assigned_by": "7c92d33b-1d6c-4c7f-aeb6-f6c96bda5b39",
  "created_at": "2026-07-20T15:20:00"
}
```

### Error Responses

#### Reward Is Not Unlocked Yet

Returned when the reward exists and belongs to the authenticated child, but its current status is not `UNLOCKED`.

This includes rewards with the status `LOCKED` or `CLAIMED`.

**Status Code:** `400 Bad Request`

```json
{
  "error": "Reward is not unlocked yet"
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

#### Reward Not Found

Returned when the reward does not exist or is not assigned to the authenticated child.

**Status Code:** `404 Not Found`

```json
{
  "error": "Reward not found"
}
```

#### Failed to Claim Reward

Returned when the reward status cannot be updated because of a database or unexpected server error.

**Status Code:** `500 Internal Server Error`

```json
{
  "error": "Failed to claim reward"
}
```
