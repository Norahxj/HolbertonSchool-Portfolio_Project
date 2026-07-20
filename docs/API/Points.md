# Points API

The Points API allows parents to view the current points balance of their children and allows authenticated children to view their own points balance.

Points are earned when task assignments are approved and may be deducted when a child achieves an approved wishlist item.

## Base Path

```text
/api/points
```

## Endpoints

| Method | Endpoint | Description | Authentication |
| ------ | -------- | ----------- | -------------- |
| `GET` | `/child/<child_id>` | Retrieve the current points balance of a specific child | Parent access token required |
| `GET` | `/my` | Retrieve the authenticated child's current points balance | Child access token required |


## Get Child Points

Retrieves the current points balance of a specific child.

The authenticated parent must be registered as one of the child's guardians.

If the child exists but does not yet have a points record, a new points record is automatically created with a balance of `0`.

### Request

```http
GET /api/points/child/{child_id}
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
| `child_id` | String (UUID) | The ID of the child whose points balance will be retrieved. |

### Success Response

**Status Code:** `200 OK`

```json
{
  "child_id": "953e2b6e-8b7e-484a-ad1e-7709e2cb0301",
  "total_points": 250
}
```

If the child does not yet have a points record, the endpoint creates one automatically and returns:

```json
{
  "child_id": "953e2b6e-8b7e-484a-ad1e-7709e2cb0301",
  "total_points": 0
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

#### Child Not Found

Returned when the child does not exist or the authenticated parent is not registered as one of the child's guardians.

**Status Code:** `404 Not Found`

```json
{
  "error": "Child not found"
}
```

#### Failed to Retrieve Child Points

Returned when the points record cannot be retrieved or created because of a database or unexpected server error.

**Status Code:** `500 Internal Server Error`

```json
{
  "error": "Failed to retrieve child points"
}
```

## Get My Points

Retrieves the current points balance of the authenticated child.

If the child exists but does not yet have a points record, a new points record is automatically created with a balance of `0`.

### Request

```http
GET /api/points/my
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
{
  "child_id": "953e2b6e-8b7e-484a-ad1e-7709e2cb0301",
  "total_points": 250
}
```

If the child does not yet have a points record, the endpoint creates one automatically and returns:

```json
{
  "child_id": "953e2b6e-8b7e-484a-ad1e-7709e2cb0301",
  "total_points": 0
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

#### Failed to Retrieve Points

Returned when the points record cannot be retrieved or created because of a database or unexpected server error.

**Status Code:** `500 Internal Server Error`

```json
{
  "error": "Failed to retrieve points"
}
```
