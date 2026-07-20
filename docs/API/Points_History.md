# Points History API

The Points History API allows children to view their own points transaction history and allows parents to view the points history of children under their guardianship.

Points history records may include points earned from approved task assignments and points deducted when approved wishlist items are achieved.

## Base Path

```text
/api/points-history
```

## Endpoints

| Method | Endpoint | Description | Authentication |
| ------ | -------- | ----------- | -------------- |
| `GET` | `/my` | Retrieve the authenticated child's points history | Child access token required |
| `GET` | `/child/<child_id>` | Retrieve the points history of a specific child | Parent access token required |


## Get My Points History

Retrieves the complete points transaction history of the authenticated child.

The history is returned in descending order by creation date, with the newest transaction appearing first.

Each history record may represent:

- Points earned from an approved task assignment.
- Points deducted after achieving an approved wishlist item.

Depending on the transaction type, either `task_assignment` or `wishlist` will contain additional details, while the other field will be `null`.

If the child has no points history, the endpoint returns an empty list.

### Request

```http
GET /api/points-history/my
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
    "id": "7c0e80af-43a8-4d0d-a778-3d31e1dc23d7",
    "child_id": "953e2b6e-8b7e-484a-ad1e-7709e2cb0301",
    "points": 20,
    "action": "TASK_APPROVED",
    "task_assignment_id": "a9dfe0b5-c0d5-41f5-a6f2-fc635d92a0b4",
    "wishlist_id": null,
    "task_assignment": {
      "id": "a9dfe0b5-c0d5-41f5-a6f2-fc635d92a0b4",
      "status": "APPROVED",
      "assigned_date": "2026-07-20",
      "completed_at": "2026-07-20T15:00:00",
      "approved_at": "2026-07-20T15:10:00",
      "task": {
        "id": "7dbd3a2e-3b85-4d4d-83c3-4c6d4fd2b84",
        "title": "Clean your room",
        "description": "Organize and clean your room.",
        "points": 20,
        "category": "DAILY"
      }
    },
    "wishlist": null,
    "created_at": "2026-07-20T15:10:00"
  },
  {
    "id": "cb97d66c-f537-47e4-a70f-f0e4bb5d30d5",
    "child_id": "953e2b6e-8b7e-484a-ad1e-7709e2cb0301",
    "points": -500,
    "action": "WISH_ACHIEVED",
    "task_assignment_id": null,
    "wishlist_id": "6f21c85e-cf6f-4d73-bf66-f9d1cdf3c733",
    "task_assignment": null,
    "wishlist": {
      "id": "6f21c85e-cf6f-4d73-bf66-f9d1cdf3c733",
      "name": "New bicycle",
      "target_points": 500,
      "status": "ACHIEVED",
      "approved_at": "2026-07-20T15:00:00"
    },
    "created_at": "2026-07-21T09:30:00"
  }
]
```

If the child has no points history:

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

Returned when the child account associated with the access token does not exist.

**Status Code:** `404 Not Found`

```json
{
  "error": "Child not found"
}
```

#### Failed to Retrieve Points History

Returned when the points history cannot be retrieved because of a database or unexpected server error.

**Status Code:** `500 Internal Server Error`

```json
{
  "error": "Failed to retrieve points history"
}
```

## Get Child Points History

Retrieves the complete points transaction history of a specific child.

The authenticated parent must be registered as one of the child's guardians.

The history is returned in descending order by creation date, with the newest transaction appearing first.

Each history record may represent:

- Points earned from an approved task assignment.
- Points deducted after achieving an approved wishlist item.

Depending on the transaction type, either `task_assignment` or `wishlist` will contain additional details, while the other field will be `null`.

If the child has no points history, the endpoint returns an empty list.

### Request

```http
GET /api/points-history/child/{child_id}
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
| `child_id` | String (UUID) | The ID of the child whose points history will be retrieved. |

### Success Response

**Status Code:** `200 OK`

```json
[
  {
    "id": "7c0e80af-43a8-4d0d-a778-3d31e1dc23d7",
    "child_id": "953e2b6e-8b7e-484a-ad1e-7709e2cb0301",
    "points": 20,
    "action": "TASK_APPROVED",
    "task_assignment_id": "a9dfe0b5-c0d5-41f5-a6f2-fc635d92a0b4",
    "wishlist_id": null,
    "task_assignment": {
      "id": "a9dfe0b5-c0d5-41f5-a6f2-fc635d92a0b4",
      "status": "APPROVED",
      "assigned_date": "2026-07-20",
      "completed_at": "2026-07-20T15:00:00",
      "approved_at": "2026-07-20T15:10:00",
      "task": {
        "id": "7dbd3a2e-3b85-4d4d-83c3-4c6d4fd2b84",
        "title": "Clean your room",
        "description": "Organize and clean your room.",
        "points": 20,
        "category": "DAILY"
      }
    },
    "wishlist": null,
    "created_at": "2026-07-20T15:10:00"
  },
  {
    "id": "cb97d66c-f537-47e4-a70f-f0e4bb5d30d5",
    "child_id": "953e2b6e-8b7e-484a-ad1e-7709e2cb0301",
    "points": -500,
    "action": "WISH_ACHIEVED",
    "task_assignment_id": null,
    "wishlist_id": "6f21c85e-cf6f-4d73-bf66-f9d1cdf3c733",
    "task_assignment": null,
    "wishlist": {
      "id": "6f21c85e-cf6f-4d73-bf66-f9d1cdf3c733",
      "name": "New bicycle",
      "target_points": 500,
      "status": "ACHIEVED",
      "approved_at": "2026-07-20T15:00:00"
    },
    "created_at": "2026-07-21T09:30:00"
  }
]
```

If the child has no points history:

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

Returned when the child does not exist or the authenticated parent is not registered as one of the child's guardians.

**Status Code:** `404 Not Found`

```json
{
  "error": "Child not found"
}
```

#### Failed to Retrieve Points History

Returned when the points history cannot be retrieved because of a database or unexpected server error.

**Status Code:** `500 Internal Server Error`

```json
{
  "error": "Failed to retrieve points history"
}
```
