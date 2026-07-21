# Daily Feedback API

The Daily Feedback API allows parents to create and update daily feedback for children under their guardianship.

Parents can view feedback created for their children, while authenticated children can view feedback associated with their own accounts.

## Base Path

```text
/api/daily-feedback
```

## Endpoints

| Method | Endpoint | Description | Authentication |
| ------ | -------- | ----------- | -------------- |
| `POST` | `/` | Create daily feedback for a child | Parent access token required |
| `GET` | `/child/<child_id>` | Retrieve feedback for a specific child | Parent access token required |
| `GET` | `/my` | Retrieve feedback for the authenticated child | Child access token required |
| `PUT` | `/<feedback_id>` | Update an existing feedback record | Parent access token required |


## Create Daily Feedback

Creates daily feedback for a child under the authenticated parent's guardianship.

Each parent can create only one feedback record per child per day.

The feedback date is assigned automatically using the current date in Riyadh and cannot be provided in the request body.

### Request

```http
POST /api/daily-feedback
```

### Authentication

A valid parent access token must be sent in the `Authorization` header.

Example:

```http
Authorization: <access-token>
```

### Request Body

| Field | Type | Required | Description |
| ----- | ---- | -------- | ----------- |
| `child_id` | String (UUID) | Yes | The ID of the child receiving the feedback. The authenticated parent must be one of the child's guardians. |
| `mood` | String | Yes | The feedback mood. Allowed values are `HAPPY`, `PROUD`, `GREAT`, `LOVE`, `STRONG`, and `STAR`. |

Example:

```json
{
  "child_id": "953e2b6e-8b7e-484a-ad1e-7709e2cb0301",
  "mood": "PROUD"
}
```

### Success Response

**Status Code:** `201 Created`

```json
{
  "id": "9e1b77a8-1d1c-4852-a82b-8e3671d5b9cb",
  "child_id": "953e2b6e-8b7e-484a-ad1e-7709e2cb0301",
  "created_by": "7c92d33b-1d6c-4c7f-aeb6-f6c96bda5b39",
  "mood": "PROUD",
  "feedback_date": "2026-07-20",
  "created_at": "2026-07-20T16:15:00"
}
```

### Error Responses

#### Invalid Input

Returned when one or more required fields are missing or contain invalid values.

**Status Code:** `400 Bad Request`

When `child_id` is missing:

```json
{
  "errors": {
    "child_id": [
      "Missing data for required field."
    ]
  }
}
```

When `mood` is missing:

```json
{
  "errors": {
    "mood": [
      "Missing data for required field."
    ]
  }
}
```

When `mood` is not one of the supported values:

```json
{
  "errors": {
    "mood": [
      "Must be one of: HAPPY, PROUD, GREAT, LOVE, STRONG, STAR."
    ]
  }
}
```

#### Feedback Already Exists Today

Returned when the authenticated parent has already created feedback for the same child on the current Riyadh date.

**Status Code:** `400 Bad Request`

```json
{
  "error": "You already created feedback for this child today"
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

#### Failed to Create Feedback

Returned when the feedback cannot be created because of a database or unexpected server error.

**Status Code:** `500 Internal Server Error`

```json
{
  "error": "Failed to create feedback"
}
```



## Get Child Daily Feedback

Retrieves all daily feedback records for a specific child under the authenticated parent's guardianship.

The response includes feedback created by all guardians for the child, not only feedback created by the authenticated parent.

Feedback records are returned from newest to oldest based on their creation time.

### Request

```http
GET /api/daily-feedback/child/{child_id}
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
| `child_id` | String (UUID) | The ID of the child whose feedback records will be retrieved. |

### Success Response

**Status Code:** `200 OK`

```json
[
  {
    "id": "9e1b77a8-1d1c-4852-a82b-8e3671d5b9cb",
    "child_id": "953e2b6e-8b7e-484a-ad1e-7709e2cb0301",
    "created_by": "7c92d33b-1d6c-4c7f-aeb6-f6c96bda5b39",
    "mood": "PROUD",
    "feedback_date": "2026-07-20",
    "created_at": "2026-07-20T16:15:00"
  },
  {
    "id": "2a52cc1f-e946-4ce0-b237-88ef7ebed67f",
    "child_id": "953e2b6e-8b7e-484a-ad1e-7709e2cb0301",
    "created_by": "6581f2d4-2693-4db8-95d9-85395df5ca97",
    "mood": "HAPPY",
    "feedback_date": "2026-07-19",
    "created_at": "2026-07-19T18:10:00"
  }
]
```

If the child has no feedback records, an empty array is returned:

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

#### Failed to Retrieve Feedback

Returned when feedback records cannot be retrieved because of an unexpected server or database error.

**Status Code:** `500 Internal Server Error`

```json
{
  "error": "Failed to retrieve feedback"
}
```

## Get My Daily Feedback

Retrieves all daily feedback records for the authenticated child.

Feedback records are returned from newest to oldest based on their creation time.

### Request

```http
GET /api/daily-feedback/my
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
    "id": "9e1b77a8-1d1c-4852-a82b-8e3671d5b9cb",
    "child_id": "953e2b6e-8b7e-484a-ad1e-7709e2cb0301",
    "created_by": "7c92d33b-1d6c-4c7f-aeb6-f6c96bda5b39",
    "mood": "PROUD",
    "feedback_date": "2026-07-20",
    "created_at": "2026-07-20T16:15:00"
  },
  {
    "id": "2a52cc1f-e946-4ce0-b237-88ef7ebed67f",
    "child_id": "953e2b6e-8b7e-484a-ad1e-7709e2cb0301",
    "created_by": "6581f2d4-2693-4db8-95d9-85395df5ca97",
    "mood": "HAPPY",
    "feedback_date": "2026-07-19",
    "created_at": "2026-07-19T18:10:00"
  }
]
```

If the authenticated child has no feedback records, an empty array is returned:

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

#### Failed to Retrieve Feedback

Returned when the feedback records cannot be retrieved because of a database or unexpected server error.

**Status Code:** `500 Internal Server Error`

```json
{
  "error": "Failed to retrieve feedback"
}
```


## Update Daily Feedback

Updates the mood value of an existing daily feedback record created by the authenticated parent.

A parent can update only feedback records they created. The child, feedback date, and creator cannot be changed through this endpoint.

### Request

```http
PUT /api/daily-feedback/{feedback_id}
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
| `feedback_id` | String (UUID) | The ID of the daily feedback record to update. |

### Request Body

| Field | Type | Required | Description |
| ----- | ---- | -------- | ----------- |
| `mood` | String | Yes | The updated feedback mood. Allowed values are `HAPPY`, `PROUD`, `GREAT`, `LOVE`, `STRONG`, and `STAR`. |

Example:

```json
{
  "mood": "GREAT"
}
```

### Success Response

**Status Code:** `200 OK`

```json
{
  "id": "9e1b77a8-1d1c-4852-a82b-8e3671d5b9cb",
  "child_id": "953e2b6e-8b7e-484a-ad1e-7709e2cb0301",
  "created_by": "7c92d33b-1d6c-4c7f-aeb6-f6c96bda5b39",
  "mood": "GREAT",
  "feedback_date": "2026-07-20",
  "created_at": "2026-07-20T16:15:00"
}
```

### Error Responses

#### Invalid Input

Returned when the required `mood` field is missing or contains an unsupported value.

**Status Code:** `400 Bad Request`

When `mood` is missing:

```json
{
  "errors": {
    "mood": [
      "Missing data for required field."
    ]
  }
}
```

When `mood` contains an unsupported value:

```json
{
  "errors": {
    "mood": [
      "Must be one of: HAPPY, PROUD, GREAT, LOVE, STRONG, STAR."
    ]
  }
}
```

A request containing no update fields may also return:

```json
{
  "error": "No fields provided for update"
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

#### Feedback Not Found

Returned when the feedback record does not exist or was not created by the authenticated parent.

**Status Code:** `404 Not Found`

```json
{
  "error": "Feedback not found"
}
```

#### Failed to Update Feedback

Returned when the feedback cannot be updated because of a database or unexpected server error.

**Status Code:** `500 Internal Server Error`

```json
{
  "error": "Failed to update feedback"
}
```