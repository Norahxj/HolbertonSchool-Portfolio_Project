# Child API

The Child API provides operations for creating, retrieving, updating, and deleting children associated with the authenticated parent account.

## Base Path

```text
/api/children
```

## Endpoints

| Method   | Endpoint      | Description                                                    | Authentication        |
| -------- | ------------- | -------------------------------------------------------------- | --------------------- |
| `POST`   | `/`           | Create a new child                                             | Access token required |
| `GET`    | `/`           | Retrieve all children associated with the authenticated parent | Access token required |
| `GET`    | `/<child_id>` | Retrieve a specific child                                      | Access token required |
| `PUT`    | `/<child_id>` | Update a specific child                                        | Access token required |
| `DELETE` | `/<child_id>` | Delete a specific child and related data                       | Access token required |


## Create Child

Creates a new child account associated with the authenticated parent's family. A unique six-digit access code is automatically generated for the child and returned in the response.

### Request

```http
POST /api/children/
```

### Authentication

A valid parent access token must be sent in the `Authorization` header.

Example:

```http
Authorization: <access-token>
```

### Request Body

| Field        | Type   | Required | Description                                                                            |
| ------------ | ------ | -------- | -------------------------------------------------------------------------------------- |
| `name`       | String | Yes      | Child name (2–100 letters).                                                            |
| `birth_date` | Date   | Yes      | Child birth date in `YYYY-MM-DD` format. The child must be between 6 and 18 years old. |
| `phone`      | String | No       | Saudi phone number starting with `05` and consisting of 10 digits.                     |

Example:

```json
{
  "name": "Ahmed",
  "birth_date": "2015-05-10",
  "phone": "0512345678"
}
```

### Success Response

**Status Code:** `201 Created`

```json
{
  "id": "8d63d4ef-f5d7-48c5-8b65-0c08b0ef8b73",
  "name": "Ahmed",
  "birth_date": "2015-05-10",
  "phone": "0512345678",
  "age": 11,
  "access_code": "482731",
  "role": "child"
}
```

### Error Responses

#### Invalid Input

Returned when the request body fails validation or when the authenticated parent is not assigned to a family.

**Status Code:** `400 Bad Request`

Possible validation errors include:

* Child name is less than 2 or greater than 100 characters.
* Child name contains characters other than Arabic or English letters.
* Birth date is in the future.
* Child age is less than 6 or greater than 18 years.
* Invalid phone number format.
* Parent is not assigned to a family.

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

#### Parent Not Found

Returned when the authenticated parent account does not exist.

**Status Code:** `404 Not Found`

```json
{
  "error": "Parent not found"
}
```

#### Phone Number Already Used

Returned when the provided phone number is already associated with another child account.

**Status Code:** `409 Conflict`

```json
{
  "error": "Phone number already used"
}
```

#### Internal Server Error

Returned when an unexpected error occurs while creating the child account.

**Status Code:** `500 Internal Server Error`

Possible responses include:

```json
{
  "error": "Failed to generate child access code"
}
```

```json
{
  "error": "Could not create child due to invalid related data"
}
```

```json
{
  "error": "Could not create child"
}
```

## Get Children

Retrieves all children associated with the authenticated parent account.

### Request

```http id="9mrf5e"
GET /api/children/
```

### Authentication

A valid parent access token must be sent in the `Authorization` header.

Example:

```http id="lbnqz8"
Authorization: <access-token>
```

### Request Body

This endpoint does not require a request body.

### Success Response

**Status Code:** `200 OK`

```json id="4u8fkc"
[
  {
    "id": "8d63d4ef-f5d7-48c5-8b65-0c08b0ef8b73",
    "name": "Ahmed",
    "birth_date": "2015-05-10",
    "phone": "0512345678",
    "age": 11,
    "access_code": "482731",
    "role": "child"
  },
  {
    "id": "3b2a1dc4-9f62-4c69-b751-7e3f1e1d9a12",
    "name": "Sara",
    "birth_date": "2017-09-22",
    "phone": null,
    "age": 8,
    "access_code": "739214",
    "role": "child"
  }
]
```

If the authenticated parent has no associated children, an empty array is returned:

```json id="g2kh8s"
[]
```

### Error Responses

#### Invalid Access Token

Returned when the access token is missing, malformed, invalid, expired, or revoked.

**Status Code:** `401 Unauthorized`

Possible responses include:

```json id="u7hpcv"
{
  "error": "Authorization token is required"
}
```

```json id="s7k1oq"
{
  "error": "Invalid Authorization header"
}
```

```json id="w8yj9m"
{
  "error": "Invalid token"
}
```

```json id="2ihh4n"
{
  "error": "Token has expired"
}
```

```json id="3lqpxf"
{
  "error": "Token has been revoked"
}
```

#### Parent Access Required

Returned when the authenticated account is not a parent.

**Status Code:** `403 Forbidden`

```json id="4m2mcm"
{
  "error": "Parent access required"
}
```


## Get Child

Retrieves a specific child associated with the authenticated parent account.

### Request

```http id="r5y8pc"
GET /api/children/{child_id}
```

### Authentication

A valid parent access token must be sent in the `Authorization` header.

Example:

```http id="q9x6az"
Authorization: <access-token>
```

### Path Parameters

| Parameter  | Type          | Description                         |
| ---------- | ------------- | ----------------------------------- |
| `child_id` | String (UUID) | The unique identifier of the child. |

### Request Body

This endpoint does not require a request body.

### Success Response

**Status Code:** `200 OK`

```json id="k7u2mq"
{
  "id": "8d63d4ef-f5d7-48c5-8b65-0c08b0ef8b73",
  "name": "Ahmed",
  "birth_date": "2015-05-10",
  "phone": "0512345678",
  "age": 11,
  "access_code": "482731",
  "role": "child"
}
```

### Error Responses

#### Invalid Access Token

Returned when the access token is missing, malformed, invalid, expired, or revoked.

**Status Code:** `401 Unauthorized`

Possible responses include:

```json id="ef1kxu"
{
  "error": "Authorization token is required"
}
```

```json id="z1a8bg"
{
  "error": "Invalid Authorization header"
}
```

```json id="y4jh9d"
{
  "error": "Invalid token"
}
```

```json id="x0qk5r"
{
  "error": "Token has expired"
}
```

```json id="g3d7wc"
{
  "error": "Token has been revoked"
}
```

#### Parent Access Required

Returned when the authenticated account is not a parent.

**Status Code:** `403 Forbidden`

```json id="b4q6hp"
{
  "error": "Parent access required"
}
```

#### Child Not Found

Returned when the specified child does not exist or is not associated with the authenticated parent.

**Status Code:** `404 Not Found`

```json id="h8m2zw"
{
  "error": "Child not found"
}
```

## Update Child

Updates the information of a specific child associated with the authenticated parent account. At least one supported field must be provided.

### Request

```http
PUT /api/children/{child_id}
```

### Authentication

A valid parent access token must be sent in the `Authorization` header.

Example:

```http
Authorization: <access-token>
```

### Path Parameters

| Parameter  | Type          | Description                                   |
| ---------- | ------------- | --------------------------------------------- |
| `child_id` | String (UUID) | The unique identifier of the child to update. |

### Request Body

All fields are optional, but at least one field must be provided.

| Field        | Type             | Description                                                                                                       |
| ------------ | ---------------- | ----------------------------------------------------------------------------------------------------------------- |
| `name`       | String           | Child name (2–100 letters).                                                                                       |
| `birth_date` | Date             | Child birth date in `YYYY-MM-DD` format. The child must be between 6 and 18 years old.                            |
| `phone`      | String or `null` | Saudi phone number starting with `05` and consisting of 10 digits. Use `null` to remove the child's phone number. |

Example:

```json
{
  "name": "Ahmed Ali",
  "phone": "0598765432"
}
```

### Success Response

**Status Code:** `200 OK`

```json
{
  "id": "8d63d4ef-f5d7-48c5-8b65-0c08b0ef8b73",
  "name": "Ahmed Ali",
  "birth_date": "2015-05-10",
  "phone": "0598765432",
  "age": 11,
  "access_code": "482731",
  "role": "child"
}
```

### Error Responses

#### Invalid Input

Returned when the request body fails validation.

**Status Code:** `400 Bad Request`

Possible validation errors include:

* No fields were provided.
* Child name is less than 2 or greater than 100 characters.
* Child name contains characters other than Arabic or English letters.
* Birth date is in the future.
* Child age is less than 6 or greater than 18 years.
* Invalid phone number format.

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

Returned when the specified child does not exist or is not associated with the authenticated parent.

**Status Code:** `404 Not Found`

```json
{
  "error": "Child not found"
}
```

#### Phone Number Already Used

Returned when the provided phone number is already associated with another child account.

**Status Code:** `409 Conflict`

```json
{
  "error": "Phone number already used"
}
```

#### Internal Server Error

Returned when an unexpected error occurs while updating the child.

**Status Code:** `500 Internal Server Error`

```json
{
  "error": "Failed to update child"
}
```

## Delete Child

Deletes a specific child associated with the authenticated parent account, including the child's related data.

### Request

```http
DELETE /api/children/{child_id}
```

### Authentication

A valid parent access token must be sent in the `Authorization` header.

Example:

```http
Authorization: <access-token>
```

### Path Parameters

| Parameter  | Type          | Description                                   |
| ---------- | ------------- | --------------------------------------------- |
| `child_id` | String (UUID) | The unique identifier of the child to delete. |

### Request Body

This endpoint does not require a request body.

### Success Response

**Status Code:** `200 OK`

```json
{
  "message": "Child and related data deleted successfully"
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

#### Parent Not Found

Returned when the authenticated parent account no longer exists.

**Status Code:** `404 Not Found`

```json
{
  "error": "Parent not found"
}
```

#### Child Not Found

Returned when the specified child does not exist or is not associated with the authenticated parent.

**Status Code:** `404 Not Found`

```json
{
  "error": "Child not found"
}
```

#### Failed to Delete Child

Returned when an unexpected error occurs while deleting the child or the child's related data.

**Status Code:** `500 Internal Server Error`

```json
{
  "error": "Failed to delete child and related data"
}
```
