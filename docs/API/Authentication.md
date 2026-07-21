# Authentication API

The Authentication API handles parent registration, parent and child login, access token renewal, and logout operations.

## Base Path

```text
/api/auth
```

## Endpoints

| Method | Endpoint          | Description                                    | Authentication         |
| ------ | ----------------- | ---------------------------------------------- | ---------------------- |
| `POST` | `/register`       | Register a new parent account                  | Not required           |
| `POST` | `/login`          | Log in to a parent account                     | Not required           |
| `POST` | `/child-login`    | Log in to a child account using an access code | Not required           |
| `POST` | `/refresh`        | Generate a new access token                    | Refresh token required |
| `POST` | `/logout`         | Revoke the current access token                | Access token required  |
| `POST` | `/logout-refresh` | Revoke the current refresh token               | Refresh token required |

## Register Parent

Creates a new parent account and a new family associated with that account.

### Request

```http
POST /api/auth/register
```

### Authentication

Authentication is not required.

### Request Body

| Field           | Type   | Required | Validation                                                                                                                      |
| --------------- | ------ | -------: | ------------------------------------------------------------------------------------------------------------------------------- |
| `first_name`    | String |      Yes | Must contain between 2 and 50 characters. Only Arabic or English letters and spaces are allowed                                 |
| `last_name`     | String |      Yes | Must contain between 2 and 50 characters. Only Arabic or English letters and spaces are allowed                                 |
| `phone`         | String |      Yes | Must contain exactly 10 digits, start with `05`, and contain digits only                                                        |
| `email`         | String |      Yes | Must be a valid and deliverable email address with a maximum length of 120 characters                                           |
| `password`      | String |      Yes | Must contain at least 8 characters, including one uppercase letter, one lowercase letter, one number, and one supported special character |
| `guardian_type` | String |      Yes | Accepted values: `father`, `mother`, or `guardian`                                                                              |

### Example Request

```json
{
  "first_name": "سارة",
  "last_name": "أحمد",
  "phone": "0512345678",
  "email": "sara@gmail.com",
  "password": "Password123!",
  "guardian_type": "mother"
}
```

### Success Response

**Status Code:** `201 Created`

```json
{
  "access_token": "access-token",
  "refresh_token": "refresh-token",
  "user": {
    "id": "4cf48758-8d59-43ec-b6f3-f6fb41550be6",
    "first_name": "سارة",
    "last_name": "أحمد",
    "phone": "0512345678",
    "email": "sara@gmail.com",
    "role": "parent",
    "guardian_type": "mother"
  }
}
```

### Error Responses

#### Invalid Request Data

Returned when one or more request fields fail validation.

Examples include:

* A missing required field
* A first or last name shorter than 2 characters
* A first or last name containing numbers or special characters
* An invalid phone number
* An invalid or undeliverable email address
* A weak password
* An unsupported guardian type

**Status Code:** `400 Bad Request`

```json
{
  "errors": {
    "first_name": [
      "First name must contain letters only."
    ]
  }
}
```
Example:

```json
{
  "errors": {
    "email": [
      "Missing data for required field."
    ]
  }
}
```

#### Email Already Registered

Returned when the email address is already associated with an existing account.

**Status Code:** `409 Conflict`

```json
{
  "error": "Email already registered"
}
```

#### Phone Number Already Used

Returned when the phone number is already associated with an existing account.

**Status Code:** `409 Conflict`

```json
{
  "error": "Phone number already used"
}
```

#### Email or Phone Already Registered

Returned when a database conflict occurs while creating the account.

**Status Code:** `409 Conflict`

```json
{
  "error": "Email or Phone already registered"
}
```


## Login Parent

Authenticates a parent account using an email address and password.

### Request

```http
POST /api/auth/login
```

### Authentication

Authentication is not required.

### Request Body

| Field      | Type   | Required | Validation                    |
| ---------- | ------ | -------: | ----------------------------- |
| `email`    | String |      Yes | Must be a valid email address |
| `password` | String |      Yes | Required                      |

### Example Request

```json
{
  "email": "sara@gmail.com",
  "password": "Password123!"
}
```

### Success Response

**Status Code:** `200 OK`

```json
{
  "access_token": "access-token",
  "refresh_token": "refresh-token",
  "user": {
    "id": "4cf48758-8d59-43ec-b6f3-f6fb41550be6",
    "first_name": "سارة",
    "last_name": "أحمد",
    "phone": "0512345678",
    "email": "sara@gmail.com",
    "role": "parent",
    "guardian_type": "mother"
  }
}
```

### Error Responses

#### Invalid Request Data

Returned when the request body is missing a required field or the email format is invalid.

**Status Code:** `400 Bad Request`

```json
{
  "errors": {
    "email": [
      "Not a valid email address."
    ]
  }
}
```

#### Invalid Credentials

Returned when the email address does not exist or the password is incorrect.

**Status Code:** `401 Unauthorized`

```json
{
  "error": "Invalid email or password"
}
```

## Login Child

Authenticates a child account using a unique six-digit access code.

### Request

```http
POST /api/auth/child-login
```

### Authentication

Authentication is not required.

### Request Body

| Field         | Type   | Required | Validation                      |
| ------------- | ------ | -------: | ------------------------------- |
| `access_code` | String |      Yes | Must contain exactly six digits |

### Example Request

```json
{
  "access_code": "123456"
}
```

### Success Response

**Status Code:** `200 OK`

```json
{
  "access_token": "access-token",
  "refresh_token": "refresh-token",
  "child": {
    "id": "953e2b6e-8b7e-484a-ad1e-7709e2cb0301",
    "name": "أحمد",
    "birth_date": "2015-06-10",
    "phone": "0512345678"
  }
}
```

### Error Responses

#### Invalid Request Data

Returned when the access code is missing, does not contain exactly six characters, or contains non-numeric characters.

**Status Code:** `400 Bad Request`

```json
{
  "errors": {
    "access_code": [
      "Access code must be exactly 6 digits."
    ]
  }
}
```

Example of a missing access code:

```json
{
  "errors": {
    "access_code": [
      "Missing data for required field."
    ]
  }
}
```

#### Invalid Access Code

Returned when no child account is associated with the provided access code.

**Status Code:** `401 Unauthorized`

```json
{
  "error": "Invalid access code"
}
```

## Refresh Access Token

Generates a new access token using a valid refresh token.

### Request

```http
POST /api/auth/refresh
```

### Authentication

A valid refresh token must be sent in the `Authorization` header.

Example:

```http
Authorization: <refresh-token>
```


### Request Body

This endpoint does not require a request body.

### Success Response

**Status Code:** `200 OK`

```json
{
  "access_token": "new-access-token"
}
```

### Error Responses

#### Invalid Refresh Token

Returned when the refresh token is missing, malformed, invalid, expired, or revoked.

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


#### Invalid Role

Returned when the role stored in the refresh token is not recognized.

**Status Code:** `403 Forbidden`

```json
{
  "error": "Invalid role"
}
```

#### User or Child Not Found

Returned when the account associated with the refresh token no longer exists.

**Status Code:** `404 Not Found`

```json
{
  "error": "User not found"
}
```

or

```json
{
  "error": "Child not found"
}
```


## Logout

Revokes the current access token and logs the authenticated user or child out.

### Request

```http
POST /api/auth/logout
```

### Authentication

A valid access token must be sent in the `Authorization` header.

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
  "message": "Logged out successfully"
}
```

### Error Responses

#### Invalid Access Token

Returned when the access token is missing, malformed, invalid, expired, or already revoked.

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

#### Logout Failed

Returned when the access token could not be stored in the revoked-token list.

**Status Code:** `500 Internal Server Error`

```json
{
  "error": "Logout failed"
}
```

## Logout Refresh Token

Revokes the current refresh token and prevents it from being used to generate new access tokens.

### Request

```http
POST /api/auth/logout-refresh
```

### Authentication

A valid refresh token must be sent in the `Authorization` header.

Example:

```http
Authorization: <refresh-token>
```

### Request Body

This endpoint does not require a request body.

### Success Response

**Status Code:** `200 OK`

```json
{
  "message": "Refresh token logged out successfully"
}
```

### Error Responses

#### Invalid Refresh Token

Returned when the refresh token is missing, malformed, invalid, expired, or already revoked.

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

#### Refresh Token Logout Failed

Returned when the refresh token could not be stored in the revoked-token list.

**Status Code:** `500 Internal Server Error`

```json
{
  "error": "Logout failed"
}
```
