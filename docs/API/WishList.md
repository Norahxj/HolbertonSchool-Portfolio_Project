# Wishlist API

The Wishlist API allows children to create and manage wishes and allows parents to review those wishes.

Children can create wishes, view their own wishlist, achieve approved wishes using their points, and delete pending or rejected wishes.

Parents can view a child's wishlist and approve or reject pending wishes.

## Base Path

```text
/api/wishlist
```

## Endpoints

| Method | Endpoint | Description | Authentication |
| ------- | -------- | ----------- | -------------- |
| `POST` | `/` | Create a new wish | Child access token required |
| `GET` | `/my` | Retrieve the authenticated child's wishes | Child access token required |
| `GET` | `/child/<child_id>` | Retrieve the wishes of a specific child | Parent access token required |
| `PUT` | `/<wish_id>/approve` | Approve a pending wish and assign target points | Parent access token required |
| `PUT` | `/<wish_id>/reject` | Reject a pending wish | Parent access token required |
| `PUT` | `/<wish_id>/achieve` | Achieve an approved wish using the child's points | Child access token required |
| `DELETE` | `/<wish_id>` | Delete a pending or rejected wish | Child access token required |

## Create Wish

Creates a new wish for the authenticated child.

A child can have a maximum of five wishes with the `PENDING` status at the same time.

The wish name is trimmed before it is stored. It must contain between 2 and 255 characters after removing leading and trailing spaces.

New wishes are created with:

- `status` set to `PENDING`.
- `target_points` set to `null`.
- `reviewed_by` set to `null`.
- `approved_at` set to `null`.

### Request

```http
POST /api/wishlist/
```

### Authentication

A valid child access token must be sent in the `Authorization` header.

Example:

```http
Authorization: <access-token>
```

### Request Body

| Field | Type | Required | Description |
| ----- | ---- | -------- | ----------- |
| `name` | String | Yes | The wish name. It must contain between 2 and 255 characters after removing leading and trailing spaces. |

Example:

```json
{
  "name": "New bicycle"
}
```

### Success Response

**Status Code:** `201 Created`

```json
{
  "id": "6f21c85e-cf6f-4d73-bf66-f9d1cdf3c733",
  "child_id": "953e2b6e-8b7e-484a-ad1e-7709e2cb0301",
  "name": "New bicycle",
  "target_points": null,
  "status": "PENDING",
  "reviewed_by": null,
  "approved_at": null,
  "created_at": "2026-07-20T14:30:00"
}
```

### Error Responses

#### Validation Error

Returned when the request body is missing, the `name` field is missing, or the wish name does not meet the validation rules.

**Status Code:** `400 Bad Request`

Missing name example:

```json
{
  "errors": {
    "name": [
      "Missing data for required field."
    ]
  }
}
```

Wish name shorter than two characters:

```json
{
  "errors": {
    "name": [
      "Wish name must be at least 2 characters long."
    ]
  }
}
```

Wish name longer than 255 characters:

```json
{
  "errors": {
    "name": [
      "Wish name must not exceed 255 characters."
    ]
  }
}
```

#### Wishlist Limit Reached

Returned when the child already has five wishes with the `PENDING` status.

**Status Code:** `400 Bad Request`

```json
{
  "error": "Wishlist limit reached. Maximum 5 pending wishes allowed."
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

#### Child Not Found

Returned when the child account identified by the access token no longer exists.

**Status Code:** `404 Not Found`

```json
{
  "error": "Child not found"
}
```

#### Failed to Create Wish

Returned when the wish cannot be saved because of a database or unexpected server error.

**Status Code:** `500 Internal Server Error`

```json
{
  "error": "Failed to create wish"
}
```

## Get My Wishlist

Retrieves all wishes belonging to the authenticated child.

The wishes are returned in descending order by creation date, with the newest wish appearing first.

All wishlist statuses may be included, such as:

- `PENDING`
- `APPROVED`
- `REJECTED`
- `ACHIEVED`

If the child does not have any wishes, the endpoint returns an empty list.

### Request

```http
GET /api/wishlist/my
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
    "id": "6f21c85e-cf6f-4d73-bf66-f9d1cdf3c733",
    "child_id": "953e2b6e-8b7e-484a-ad1e-7709e2cb0301",
    "name": "New bicycle",
    "target_points": 500,
    "status": "APPROVED",
    "reviewed_by": "a74eb32e-29ac-4f58-98cb-7783b63a4400",
    "approved_at": "2026-07-20T15:00:00",
    "created_at": "2026-07-20T14:30:00"
  },
  {
    "id": "e4d9c116-73f1-4023-a683-1a36cf2a3778",
    "child_id": "953e2b6e-8b7e-484a-ad1e-7709e2cb0301",
    "name": "Drawing set",
    "target_points": null,
    "status": "PENDING",
    "reviewed_by": null,
    "approved_at": null,
    "created_at": "2026-07-19T11:15:00"
  }
]
```

If the child has no wishes:

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

## Get Child Wishlist

Retrieves all wishes belonging to a specific child.

The authenticated parent must be registered as one of the child's guardians.

The wishes are returned in descending order by creation date, with the newest wish appearing first.

All wishlist statuses may be included, such as:

- `PENDING`
- `APPROVED`
- `REJECTED`
- `ACHIEVED`

If the child exists and has no wishes, the endpoint returns an empty list.

### Request

```http
GET /api/wishlist/child/{child_id}
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
| `child_id` | String (UUID) | The ID of the child whose wishlist will be retrieved. |

### Success Response

**Status Code:** `200 OK`

```json
[
  {
    "id": "6f21c85e-cf6f-4d73-bf66-f9d1cdf3c733",
    "child_id": "953e2b6e-8b7e-484a-ad1e-7709e2cb0301",
    "name": "New bicycle",
    "target_points": 500,
    "status": "APPROVED",
    "reviewed_by": "a74eb32e-29ac-4f58-98cb-7783b63a4400",
    "approved_at": "2026-07-20T15:00:00",
    "created_at": "2026-07-20T14:30:00"
  },
  {
    "id": "e4d9c116-73f1-4023-a683-1a36cf2a3778",
    "child_id": "953e2b6e-8b7e-484a-ad1e-7709e2cb0301",
    "name": "Drawing set",
    "target_points": null,
    "status": "PENDING",
    "reviewed_by": null,
    "approved_at": null,
    "created_at": "2026-07-19T11:15:00"
  }
]
```

If the child has no wishes:

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

## Approve Wish

Approves a pending wish and assigns the number of points required for the child to achieve it.

The authenticated parent must be registered as one of the child's guardians.

A child can have a maximum of three wishes with the `APPROVED` status at the same time.

When the wish is approved:

- Its status is changed from `PENDING` to `APPROVED`.
- The required target points are assigned.
- The authenticated parent's ID is stored in `reviewed_by`.
- The approval date and time are stored in `approved_at`.

Only wishes with the `PENDING` status can be approved.

### Request

```http
PUT /api/wishlist/{wish_id}/approve
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
| `wish_id` | String (UUID) | The ID of the pending wish to approve. |

### Request Body

| Field | Type | Required | Description |
| ----- | ---- | -------- | ----------- |
| `target_points` | Integer | Yes | The number of points the child must spend to achieve the wish. The value must be between `1` and `10000`. |

Example:

```json
{
  "target_points": 500
}
```

### Success Response

**Status Code:** `200 OK`

```json
{
  "id": "6f21c85e-cf6f-4d73-bf66-f9d1cdf3c733",
  "child_id": "953e2b6e-8b7e-484a-ad1e-7709e2cb0301",
  "name": "New bicycle",
  "target_points": 500,
  "status": "APPROVED",
  "reviewed_by": "a74eb32e-29ac-4f58-98cb-7783b63a4400",
  "approved_at": "2026-07-20T15:00:00",
  "created_at": "2026-07-20T14:30:00"
}
```

### Error Responses

#### Validation Error

Returned when the request body is missing, the `target_points` field is missing, the value is not an integer, or the value is outside the allowed range.

**Status Code:** `400 Bad Request`

Missing field example:

```json
{
  "errors": {
    "target_points": [
      "Missing data for required field."
    ]
  }
}
```

Invalid type example:

```json
{
  "errors": {
    "target_points": [
      "Not a valid integer."
    ]
  }
}
```

Value below the allowed minimum:

```json
{
  "errors": {
    "target_points": [
      "Must be greater than or equal to 1 and less than or equal to 10000."
    ]
  }
}
```

The exact Marshmallow range message may vary slightly depending on the installed Marshmallow version.

#### Wish Already Reviewed

Returned when the wish is not currently in the `PENDING` status.

This includes wishes that are already:

- `APPROVED`
- `REJECTED`
- `ACHIEVED`

**Status Code:** `400 Bad Request`

```json
{
  "error": "Wish has already been reviewed"
}
```

#### Approved Wishlist Limit Reached

Returned when the child already has three wishes with the `APPROVED` status.

**Status Code:** `400 Bad Request`

```json
{
  "error": "Approved wishlist limit reached. Maximum 3 approved wishes allowed."
}
```

#### Invalid Target Points

Returned when the target points are outside the allowed range, if this validation is reached through the service layer.

**Status Code:** `400 Bad Request`

```json
{
  "error": "Target points must be between 1 and 10000"
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

#### Wish Not Found

Returned when the wish does not exist.

**Status Code:** `404 Not Found`

```json
{
  "error": "Wish not found"
}
```

#### Child Not Found

Returned when the child associated with the wish does not exist or the authenticated parent is not registered as one of the child's guardians.

**Status Code:** `404 Not Found`

```json
{
  "error": "Child not found"
}
```

#### Failed to Approve Wish

Returned when the wish cannot be updated because of a database or unexpected server error.

**Status Code:** `500 Internal Server Error`

```json
{
  "error": "Failed to approve wish"
}
```

## Reject Wish

Rejects a pending wish.

The authenticated parent must be registered as one of the child's guardians.

When a wish is rejected:

- Its status is changed from `PENDING` to `REJECTED`.
- The authenticated parent's ID is stored in `reviewed_by`.
- `approved_at` is cleared (`null`).

Only wishes with the `PENDING` status can be rejected.

### Request

```http
PUT /api/wishlist/{wish_id}/reject
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
| `wish_id` | String (UUID) | The ID of the pending wish to reject. |

### Success Response

**Status Code:** `200 OK`

```json
{
  "id": "6f21c85e-cf6f-4d73-bf66-f9d1cdf3c733",
  "child_id": "953e2b6e-8b7e-484a-ad1e-7709e2cb0301",
  "name": "New bicycle",
  "target_points": null,
  "status": "REJECTED",
  "reviewed_by": "a74eb32e-29ac-4f58-98cb-7783b63a4400",
  "approved_at": null,
  "created_at": "2026-07-20T14:30:00"
}
```

### Error Responses

#### Wish Already Reviewed

Returned when the wish is not currently in the `PENDING` status.

This includes wishes that are already:

- `APPROVED`
- `REJECTED`
- `ACHIEVED`

**Status Code:** `400 Bad Request`

```json
{
  "error": "Wish has already been reviewed"
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

#### Wish Not Found

Returned when the specified wish does not exist.

**Status Code:** `404 Not Found`

```json
{
  "error": "Wish not found"
}
```

#### Child Not Found

Returned when the child associated with the wish does not exist or the authenticated parent is not registered as one of the child's guardians.

**Status Code:** `404 Not Found`

```json
{
  "error": "Child not found"
}
```

#### Failed to Reject Wish

Returned when the wish cannot be updated because of a database or unexpected server error.

**Status Code:** `500 Internal Server Error`

```json
{
  "error": "Failed to reject wish"
}
```



## Achieve Wish

Marks an approved wish as achieved by deducting its target points from the authenticated child's balance.

The wish must belong to the authenticated child and must currently have the `APPROVED` status.

When the wish is achieved:

- The wish's `target_points` value is deducted from the child's total points.
- The wish status is changed from `APPROVED` to `ACHIEVED`.
- A points history record is created with a negative points value.
- The history action is stored as `WISH_ACHIEVED`.
- The history record is linked to the achieved wish.

All changes are saved in one database transaction. If any part of the operation fails, all changes are rolled back.

### Request

```http
PUT /api/wishlist/{wish_id}/achieve
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
| `wish_id` | String (UUID) | The ID of the approved wish to achieve. |

### Success Response

**Status Code:** `200 OK`

```json
{
  "id": "6f21c85e-cf6f-4d73-bf66-f9d1cdf3c733",
  "child_id": "953e2b6e-8b7e-484a-ad1e-7709e2cb0301",
  "name": "New bicycle",
  "target_points": 500,
  "status": "ACHIEVED",
  "reviewed_by": "a74eb32e-29ac-4f58-98cb-7783b63a4400",
  "approved_at": "2026-07-20T15:00:00",
  "created_at": "2026-07-20T14:30:00"
}
```

The child's points balance is reduced by the value of `target_points`.

For example, if the child has `800` points and the wish requires `500` points, the remaining balance becomes `300`.

A corresponding points history record is also created internally:

```json
{
  "child_id": "953e2b6e-8b7e-484a-ad1e-7709e2cb0301",
  "points": -500,
  "action": "WISH_ACHIEVED",
  "wishlist_id": "6f21c85e-cf6f-4d73-bf66-f9d1cdf3c733"
}
```

This history object is not included in the endpoint response.

### Error Responses

#### Wish Already Achieved

Returned when the wish already has the `ACHIEVED` status.

**Status Code:** `400 Bad Request`

```json
{
  "error": "This wish has already been achieved"
}
```

#### Invalid Target Points

Returned when the wish does not have a valid positive `target_points` value.

This may happen if `target_points` is `null`, zero, or negative.

**Status Code:** `400 Bad Request`

```json
{
  "error": "Wish target points are invalid"
}
```

#### Wish Not Approved

Returned when the wish is not currently in the `APPROVED` status.

This includes wishes with statuses such as:

- `PENDING`
- `REJECTED`

**Status Code:** `400 Bad Request`

```json
{
  "error": "Wish is not approved"
}
```

#### Not Enough Points

Returned when the child does not have enough points to achieve the wish.

The same response is also returned when no points record exists for the child.

**Status Code:** `400 Bad Request`

```json
{
  "error": "Not enough points to achieve this wish"
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

#### Wish Not Found

Returned when the wish does not exist or does not belong to the authenticated child.

**Status Code:** `404 Not Found`

```json
{
  "error": "Wish not found"
}
```

#### Failed to Achieve Wish

Returned when the wish cannot be achieved because of a database or unexpected server error.

**Status Code:** `500 Internal Server Error`

```json
{
  "error": "Failed to achieve wish"
}
```

## Delete Wish

Deletes a wish belonging to the authenticated child.

Only wishes with one of the following statuses can be deleted:

- `PENDING`
- `REJECTED`

Wishes with the `APPROVED` or `ACHIEVED` status cannot be deleted.

The specified wish must belong to the authenticated child.

### Request

```http
DELETE /api/wishlist/{wish_id}
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
| `wish_id` | String (UUID) | The ID of the wish to delete. |

### Success Response

**Status Code:** `200 OK`

```json
{
  "message": "Wish deleted successfully"
}
```

### Error Responses

#### Wish Cannot Be Deleted

Returned when the wish is not in a deletable status.

Only wishes with the `PENDING` or `REJECTED` status can be deleted.

This error is returned for wishes with statuses such as:

- `APPROVED`
- `ACHIEVED`

**Status Code:** `400 Bad Request`

```json
{
  "error": "Only pending or rejected wishes can be deleted"
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

#### Wish Not Found

Returned when the wish does not exist or does not belong to the authenticated child.

**Status Code:** `404 Not Found`

```json
{
  "error": "Wish not found"
}
```

#### Failed to Delete Wish

Returned when the wish cannot be deleted because of a database or unexpected server error.

**Status Code:** `500 Internal Server Error`

```json
{
  "error": "Failed to delete wish"
}
```
