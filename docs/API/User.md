# User API

The User API provides operations for retrieving, updating, and deleting the authenticated parent account.

## Base Path

```text
/api/users
```

## Endpoints

| Method   | Endpoint | Description                                                | Authentication        |
| -------- | -------- | ---------------------------------------------------------- | --------------------- |
| `GET`    | `/me`    | Retrieve the authenticated parent's profile                | Access token required |
| `PUT`    | `/me`    | Update the authenticated parent's profile                  | Access token required |
| `DELETE` | `/me`    | Delete the authenticated parent's account and related data | Access token required |


## Get Current User

Retrieves the profile information of the authenticated parent account.

### Request

```http
GET /api/users/me
```

### Authentication

A valid parent access token must be sent in the `Authorization` header.

Example:

```http
Authorization: <access-token>
```

### Request Body

This endpoint does not require a request body.

### Success Response

**Status Code:** `200 OK`

```json
{
  "id": "4cf48758-8d59-43ec-b6f3-f6fb41550be6",
  "first_name": "سارة",
  "last_name": "أحمد",
  "phone": "0512345678",
  "email": "sara@gmail.com",
  "role": "parent",
  "guardian_type": "mother"
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

Returned when the authenticated account is a child rather than a parent.

**Status Code:** `403 Forbidden`

```json
{
  "error": "Parent access only"
}
```

#### User Not Found

Returned when the parent account associated with the access token no longer exists.

**Status Code:** `404 Not Found`

```json
{
  "error": "User not found"
}
```

## Update Current User

Updates the authenticated parent's profile information. Any combination of the supported fields can be provided. At least one field is required.

### Request

```http
PUT /api/users/me
```

### Authentication

A valid parent access token must be sent in the `Authorization` header.

Example:

```http
Authorization: <access-token>
```

### Request Body

All fields are optional, but at least one field must be provided.

| Field        | Type   | Description                                                                                                                                  |
| ------------ | ------ | -------------------------------------------------------------------------------------------------------------------------------------------- |
| `first_name` | String | First name (2–50 letters).                                                                                                                   |
| `last_name`  | String | Last name (2–50 letters).                                                                                                                    |
| `phone`      | String | Saudi phone number starting with `05` and consisting of 10 digits.                                                                           |
| `email`      | String | Valid email address (maximum 120 characters).                                                                                                |
| `password`   | String | New password. Must be at least 8 characters long and contain an uppercase letter, lowercase letter, number, and supported special character. |

Example:

```json
{
  "first_name": "Sara",
  "phone": "0512345678",
  "password": "NewPassword@123"
}
```

### Success Response

**Status Code:** `200 OK`

```json
{
  "id": "4cf48758-8d59-43ec-b6f3-f6fb41550be6",
  "first_name": "Sara",
  "last_name": "Ahmed",
  "phone": "0512345678",
  "email": "sara@gmail.com",
  "role": "parent",
  "guardian_type": "mother"
}
```

### Error Responses

#### Invalid Input

Returned when the request body fails validation.

**Status Code:** `400 Bad Request`

Possible validation errors include:

* No fields were provided.
* First or last name is too short or too long.
* First or last name contains non-letter characters.
* Invalid phone number format.
* Invalid email address or unsupported email domain.
* Password does not meet the required complexity.

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
  "error": "Parent access only"
}
```

#### User Not Found

Returned when the authenticated user no longer exists.

**Status Code:** `404 Not Found`

```json
{
  "error": "User not found"
}
```

#### Email or Phone Already Exists

Returned when the new email address or phone number is already used by another account.

**Status Code:** `409 Conflict`

Possible responses include:

```json
{
  "error": "Email already registered"
}
```

```json
{
  "error": "Phone number already used"
}
```

```json
{
  "error": "Email or phone already exists"
}
```

#### Internal Server Error

Returned when an unexpected error occurs while updating the account.

**Status Code:** `500 Internal Server Error`

```json
{
  "error": "Failed to update user"
}
```


## Delete Current User

Deletes the authenticated parent account and handles the related family data.

### Request

```http
DELETE /api/users/me
```

### Authentication

A valid parent access token must be sent in the `Authorization` header.

Example:

```http
Authorization: <access-token>
```

### Request Body

This endpoint does not require a request body.

### Deletion Behavior

When the account is deleted:

* The parent is removed from every associated child.
* Any child with no remaining guardians is deleted.
* The parent account is deleted.
* The family is deleted if no guardians remain in it.

### Success Response

**Status Code:** `200 OK`

```json
{
  "message": "User deleted successfully"
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
  "error": "Parent access only"
}
```

#### User Not Found

Returned when the parent account associated with the access token does not exist.

**Status Code:** `404 Not Found`

```json
{
  "error": "User not found"
}
```

#### Deletion Failed

Returned when an error occurs while deleting the user or related data.

**Status Code:** `500 Internal Server Error`

```json
{
  "error": "Failed to delete user and related data"
}
```
