# Task Bank API

The Task Bank API provides predefined task categories and randomly generated task suggestions that parents can use when creating new tasks.

Parents can retrieve the available task categories and request task suggestions based on one or more selected children and a specific category.

## Base Path

```text
/api/task-bank
```

## Endpoints

| Method | Endpoint | Description | Authentication |
| ------ | -------- | ----------- | -------------- |
| `GET` | `/categories` | Retrieve all available task categories | Access token required |
| `POST` | `/suggestions` | Retrieve random task suggestions for the selected children and category | Access token required |

## Get Task Categories

Retrieves all available task bank categories that can be used when requesting task suggestions.

### Request

```http
GET /api/task-bank/categories
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
{
  "categories": [
    "FINANCIAL",
    "SOCIAL",
    "MORAL",
    "RELIGIOUS"
  ]
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

## Get Random Task Suggestions

Retrieves up to five random task suggestions from the task bank for one or more selected children.

The authenticated parent must be a guardian of every child included in the request.

The returned suggestions are filtered by category and by the selected children's ages. A task is included only when it is suitable for both the youngest and oldest selected child.

The response language can be Arabic or English.

### Request

```http
POST /api/task-bank/suggestions
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
| `child_ids` | Array of strings | Yes | Unique identifiers of the children for whom suggestions are requested. At least one child ID is required, and duplicate IDs are not allowed. |
| `category` | String | Yes | Task category. Accepted values are `RELIGIOUS`, `FINANCIAL`, `MORAL`, and `SOCIAL`. |
| `lang` | String | No | Language used for the suggestion title and description. Accepted values are `ar` and `en`. Defaults to `en`. |

Example:

```json
{
  "child_ids": [
    "953e2b6e-8b7e-484a-ad1e-7709e2cb0301",
    "5f52148c-bba2-4f40-92d8-427ecfa22088"
  ],
  "category": "FINANCIAL",
  "lang": "en"
}
```

### Success Response

**Status Code:** `200 OK`

```json
{
  "suggestions": [
    {
      "title": "Create a weekly savings plan",
      "description": "Decide how much money to save this week and record your progress.",
      "points": 15,
      "category": "FINANCIAL",
      "task_frequency": "WEEKLY",
      "recurrence_day": 0,
      "is_auto_verified": false
    },
    {
      "title": "Compare prices before buying",
      "description": "Compare the prices of two similar products and choose the better option.",
      "points": 10,
      "category": "FINANCIAL",
      "task_frequency": "ONCE",
      "recurrence_day": null,
      "is_auto_verified": false
    }
  ]
}
```

Each suggestion contains:

| Field | Type | Description |
| ----- | ---- | ----------- |
| `title` | String | Suggested task title in the requested language. |
| `description` | String | Suggested task description in the requested language. |
| `points` | Integer | Default number of points recommended for the task. |
| `category` | String | Category requested by the parent. |
| `task_frequency` | String | Suggested task frequency. |
| `recurrence_day` | Integer or null | Default recurrence day based on the suggested frequency. It is `null` when no recurrence day is required. |
| `is_auto_verified` | Boolean | Indicates whether the task should be approved automatically. Task bank suggestions always return `false`. |

The endpoint returns a maximum of five suggestions.

If fewer than five tasks match the selected category and age range, all available matching tasks are returned.

If no tasks match the selected children's age range, the endpoint returns:

```json
{
  "suggestions": []
}
```

### Error Responses

#### Invalid Request Data

Returned when the request body does not match the required structure or contains a value outside the allowed Swagger model values.

**Status Code:** `400 Bad Request`

The validation response is generated automatically by Flask-RESTX and may contain details about the invalid field.

#### Child IDs Required

Returned when `child_ids` is missing or contains an empty list.

**Status Code:** `400 Bad Request`

```json
{
  "error": "child_ids is required"
}
```

#### Duplicate Child IDs

Returned when the same child identifier appears more than once in `child_ids`.

**Status Code:** `400 Bad Request`

```json
{
  "error": "Duplicate child IDs are not allowed"
}
```

#### Invalid Category

Returned when the requested category does not exist in the task bank.

**Status Code:** `400 Bad Request`

```json
{
  "error": "Invalid category"
}
```

#### Invalid Language

Returned when `lang` is not `ar` or `en`.

**Status Code:** `400 Bad Request`

```json
{
  "error": "Invalid language"
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

Returned when at least one child does not exist or is not accessible to the authenticated parent.

**Status Code:** `404 Not Found`

```json
{
  "error": "Child not found"
}
```

#### Failed to Retrieve Task Suggestions

Returned when an unexpected service error prevents the suggestions from being retrieved.

**Status Code:** `500 Internal Server Error`

```json
{
  "error": "Failed to retrieve task suggestions"
}
```
