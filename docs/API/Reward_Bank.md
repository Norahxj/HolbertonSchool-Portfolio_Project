# Reward Bank API

The Reward Bank API provides predefined reward suggestions that parents can use when creating rewards for their children.

Parents can request randomly generated reward suggestions in either Arabic or English.

## Base Path

```text
/api/reward-bank
```

## Endpoints

| Method | Endpoint | Description | Authentication |
| ------ | -------- | ----------- | -------------- |
| `POST` | `/suggestions` | Retrieve random reward suggestions | Access token required |


## Get Random Reward Suggestions

Retrieves random reward suggestions from the reward bank.

The authenticated user must be a parent.

Reward names and descriptions are returned in the requested language. A maximum of five suggestions is returned by default.

### Request

```http
POST /api/reward-bank/suggestions
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
| `lang` | String | No | Language used for the reward name and description. Accepted values are `ar` and `en`. Defaults to `en`. |

Example:

```json
{
  "lang": "en"
}
```

### Success Response

**Status Code:** `200 OK`

```json
{
  "suggestions": [
    {
      "reward_name": "Go to the cinema",
      "description": "Enjoy a movie with your family.",
      "unlock_day": 4
    },
    {
      "reward_name": "Ice Cream",
      "description": "Choose your favorite ice cream flavor.",
      "unlock_day": 6
    }
  ]
}
```

Each suggestion contains:

| Field | Type | Description |
| ----- | ---- | ----------- |
| `reward_name` | String | Suggested reward name in the requested language. |
| `description` | String | Suggested reward description in the requested language. |
| `unlock_day` | Integer | Default unlock day for the reward. Values range from `0` (Monday) to `6` (Sunday). |

The endpoint returns up to five random reward suggestions.

If fewer than five reward suggestions are available, all available suggestions are returned.

### Error Responses

#### Invalid Request Data

Returned when the request body does not match the required structure or contains invalid values.

**Status Code:** `400 Bad Request`

The validation response is generated automatically by Flask-RESTX and may contain details about the invalid field.

#### Invalid Language

Returned when `lang` is not `ar` or `en`.

**Status Code:** `400 Bad Request`

```json
{
  "error": "Invalid language"
}
```

#### Count Must Be Greater Than Zero

Returned when the requested number of suggestions is less than or equal to zero.

**Status Code:** `400 Bad Request`

```json
{
  "error": "Count must be greater than zero"
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

#### Failed to Retrieve Reward Suggestions

Returned when an unexpected server error prevents the reward suggestions from being retrieved.

**Status Code:** `500 Internal Server Error`

```json
{
  "error": "Failed to retrieve reward suggestions"
}
```
