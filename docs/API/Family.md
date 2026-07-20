# Family API

The Family API allows parents to manage their family information and invite other registered parents to join their family.

Parents can update the family name, view invitations sent to them, and accept or reject pending family invitations.

## Base Path

```text
/api/family
```

## Endpoints

| Method | Endpoint | Description | Authentication |
| ------ | -------- | ----------- | -------------- |
| `POST` | `/invite` | Invite a registered parent to join the current family | Parent access token required |
| `PUT` | `/me` | Update the current family's name | Parent access token required |
| `GET` | `/invitations` | Retrieve invitations sent to the authenticated parent | Parent access token required |
| `PUT` | `/invitations/<invitation_id>/accept` | Accept a pending family invitation | Parent access token required |
| `PUT` | `/invitations/<invitation_id>/reject` | Reject a pending family invitation | Parent access token required |

## Invite Parent

Creates a pending invitation for an existing registered parent to join the authenticated parent's family.

The invited email address must belong to an existing user whose role is `parent`.

The invitation cannot be created when:

- The authenticated parent invites themselves.
- The invited user is not a parent.
- The invited user is already in the same family.
- The invited user's guardian type already exists in the family.
- A pending invitation already exists for the same email address in the family.

### Request

```http
POST /api/family/invite
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
| `email` | String | Yes | The registered email address of the parent to invite. It must be a valid email address, must not exceed 120 characters, and must satisfy the configured email-domain validation rules. |

Before processing, surrounding spaces are removed from the email address and the value is converted to lowercase.

Example:

```json
{
  "email": "parent@example.com"
}
```

### Success Response

**Status Code:** `201 Created`

```json
{
  "id": "7f99b02e-f745-49cc-bca9-16885fa5be75",
  "family_id": "fe021430-af74-46bc-a1e6-b4f85f532091",
  "invited_email": "parent@example.com",
  "invited_by": "7c92d33b-1d6c-4c7f-aeb6-f6c96bda5b39",
  "status": "PENDING",
  "created_at": "2026-07-20T16:40:00"
}
```

The invitation is created with the status `PENDING`.

### Error Responses

#### Invalid Input

Returned when the email field is missing, malformed, exceeds 120 characters, or fails the configured email-domain validation.

**Status Code:** `400 Bad Request`

When the email field is missing:

```json
{
  "errors": {
    "email": [
      "Missing data for required field."
    ]
  }
}
```

When the email format is invalid:

```json
{
  "errors": {
    "email": [
      "Not a valid email address."
    ]
  }
}
```

#### Current User Has No Family

Returned when the authenticated parent is not assigned to a family.

**Status Code:** `400 Bad Request`

```json
{
  "error": "Current user is not assigned to a family"
}
```

#### Cannot Invite Self

Returned when the invited email belongs to the authenticated parent.

**Status Code:** `400 Bad Request`

```json
{
  "error": "You cannot invite yourself"
}
```

#### Invited User Is Not a Parent

Returned when the invited email belongs to an existing account whose role is not `parent`.

**Status Code:** `400 Bad Request`

```json
{
  "error": "Invited user is not a parent"
}
```

#### User Already in the Same Family

Returned when the invited parent already belongs to the authenticated parent's family.

**Status Code:** `400 Bad Request`

```json
{
  "error": "User is already in your family"
}
```

#### Guardian Type Already Exists

Returned when the invited parent's guardian type already belongs to another parent in the authenticated parent's family.

**Status Code:** `400 Bad Request`

```json
{
  "error": "This family already has this guardian type"
}
```

#### Invitation Already Pending

Returned when a pending invitation already exists for the same email address in the authenticated parent's family.

**Status Code:** `400 Bad Request`

```json
{
  "error": "An invitation is already pending for this email"
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

#### Current User Not Found

Returned when the parent account associated with the access token no longer exists.

**Status Code:** `404 Not Found`

```json
{
  "error": "Current user not found"
}
```

#### Invited User Not Found

Returned when the invited email address does not belong to an existing user account.

**Status Code:** `404 Not Found`

```json
{
  "error": "Invited email does not belong to an existing user"
}
```

#### Failed to Create Invitation

Returned when the invitation cannot be created because of a database or unexpected server error.

**Status Code:** `500 Internal Server Error`

```json
{
  "error": "Failed to create invitation"
}
```

## Update Family Name

Updates the name of the family associated with the authenticated parent.

Only authenticated parent accounts can use this endpoint. The family is determined from the authenticated user's `family_id`; the client does not provide a family ID.

### Request

```http
PUT /api/family/me
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
| `name` | String | Yes | The new family name. After surrounding spaces are removed, the name must contain between 2 and 100 characters. |

The family name may contain letters, numbers, spaces, or symbols.

Surrounding spaces are removed before the name is saved.

Example:

```json
{
  "name": "Al-Zaid Family"
}
```

### Success Response

**Status Code:** `200 OK`

```json
{
  "id": "fe021430-af74-46bc-a1e6-b4f85f532091",
  "name": "Al-Zaid Family"
}
```

### Error Responses

#### Invalid Input

Returned when the request body is missing the `name` field or when the family name does not contain between 2 and 100 characters after surrounding spaces are removed.

**Status Code:** `400 Bad Request`

When the name field is missing:

```json
{
  "errors": {
    "name": [
      "Missing data for required field."
    ]
  }
}
```

When the family name is shorter than 2 characters:

```json
{
  "errors": {
    "name": [
      "Family name must be at least 2 characters long."
    ]
  }
}
```

When the family name exceeds 100 characters:

```json
{
  "errors": {
    "name": [
      "Family name must not exceed 100 characters."
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

#### User Not Found

Returned when the user account associated with the access token no longer exists.

**Status Code:** `404 Not Found`

```json
{
  "error": "User not found"
}
```

#### Family Not Found

Returned when the authenticated user is not associated with a family or when the associated family no longer exists.

**Status Code:** `404 Not Found`

```json
{
  "error": "Family not found"
}
```

#### Failed to Update Family

Returned when the family name cannot be updated because of a database or unexpected server error.

**Status Code:** `500 Internal Server Error`

```json
{
  "error": "Failed to update family"
}
```

## Get My Family Invitations

Retrieves all pending family invitations sent to the authenticated parent's registered email address.

Only invitations whose status is `PENDING` are returned. Accepted and rejected invitations are not included.

### Request

```http
GET /api/family/invitations
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
[
  {
    "id": "7f99b02e-f745-49cc-bca9-16885fa5be75",
    "family_id": "fe021430-af74-46bc-a1e6-b4f85f532091",
    "invited_email": "parent@example.com",
    "invited_by": "7c92d33b-1d6c-4c7f-aeb6-f6c96bda5b39",
    "status": "PENDING",
    "created_at": "2026-07-20T16:40:00"
  }
]
```

Each invitation contains:

| Field | Type | Description |
| ----- | ---- | ----------- |
| `id` | String | Unique identifier of the invitation. |
| `family_id` | String | Identifier of the family the parent is invited to join. |
| `invited_email` | String | Email address that received the invitation. |
| `invited_by` | String | Identifier of the parent who created the invitation. |
| `status` | String | Current invitation status. This endpoint only returns invitations with the value `PENDING`. |
| `created_at` | DateTime | Date and time when the invitation was created. |

When no pending invitations exist, the endpoint returns an empty array:

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

#### User Not Found

Returned when the user account associated with the access token no longer exists.

**Status Code:** `404 Not Found`

```json
{
  "error": "User not found"
}
```

#### Failed to Retrieve Invitations

Returned when the invitations cannot be retrieved because of an unexpected server error.

**Status Code:** `500 Internal Server Error`

```json
{
  "error": "Failed to retrieve invitations"
}
```
## Accept Family Invitation

Accepts a pending family invitation sent to the authenticated parent's registered email address.

When the invitation is accepted, the authenticated parent is moved to the invited family and added as a guardian for all children currently belonging to that family.

The parent's previous family is deleted automatically if it no longer contains any guardians or children after the parent leaves it.

The invitation cannot be accepted when:

- The invitation was not sent to the authenticated parent's email address.
- The invitation is no longer pending.
- The authenticated parent already belongs to the invited family.
- The authenticated parent's current family contains children.
- The invited family already contains a parent with the same guardian type.

### Request

```http
PUT /api/family/invitations/<invitation_id>/accept
```

### Authentication

A valid parent access token must be sent in the `Authorization` header.

Example:

```http
Authorization: <access-token>
```

### Path Parameters

| Parameter | Type | Required | Description |
| --------- | ---- | -------- | ----------- |
| `invitation_id` | String | Yes | Unique identifier of the family invitation to accept. |

### Success Response

**Status Code:** `200 OK`

```json
{
  "id": "7f99b02e-f745-49cc-bca9-16885fa5be75",
  "family_id": "fe021430-af74-46bc-a1e6-b4f85f532091",
  "invited_email": "parent@example.com",
  "invited_by": "7c92d33b-1d6c-4c7f-aeb6-f6c96bda5b39",
  "status": "ACCEPTED",
  "created_at": "2026-07-20T16:40:00"
}
```

After a successful response:

- The authenticated parent's `family_id` is changed to the invitation's `family_id`.
- The parent is added as a guardian for every child in the invited family.
- The invitation status is changed from `PENDING` to `ACCEPTED`.
- The previous family is deleted if it has no remaining guardians or children.

### Error Responses

#### Invitation Is Not Pending

Returned when the invitation has already been accepted, rejected, or otherwise no longer has the status `PENDING`.

**Status Code:** `400 Bad Request`

```json
{
  "error": "Invitation is not pending"
}
```

#### Guardian Type Already Exists

Returned when the invited family already contains a parent with the same guardian type as the authenticated parent.

**Status Code:** `400 Bad Request`

```json
{
  "error": "This family already has this guardian type"
}
```

#### Current Family Has Children

Returned when the authenticated parent's current family contains one or more children.

A parent cannot leave a family that contains children by accepting an invitation to another family.

**Status Code:** `400 Bad Request`

```json
{
  "error": "User cannot leave a family that has children"
}
```

#### Already in the Invited Family

Returned when the authenticated parent already belongs to the family associated with the invitation.

**Status Code:** `400 Bad Request`

```json
{
  "error": "User is already in this family"
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

#### User Not Found

Returned when the parent account associated with the access token no longer exists.

**Status Code:** `404 Not Found`

```json
{
  "error": "User not found"
}
```

#### Invitation Not Found

Returned when:

- The invitation does not exist.
- The invitation was not sent to the authenticated parent's registered email address.

**Status Code:** `404 Not Found`

```json
{
  "error": "Invitation not found"
}
```

#### Failed to Accept Invitation

Returned when the invitation cannot be accepted because of a database constraint or unexpected server error.

**Status Code:** `500 Internal Server Error`

```json
{
  "error": "Failed to accept invitation"
}
```


## Reject Family Invitation

Rejects a pending family invitation sent to the authenticated parent's registered email address.

Rejecting an invitation changes its status from `PENDING` to `REJECTED`. The authenticated parent remains in their current family, and no family membership or guardian relationships are changed.

### Request

```http
PUT /api/family/invitations/<invitation_id>/reject
```

### Authentication

A valid parent access token must be sent in the `Authorization` header.

Example:

```http
Authorization: <access-token>
```

### Path Parameters

| Parameter | Type | Required | Description |
| --------- | ---- | -------- | ----------- |
| `invitation_id` | String | Yes | Unique identifier of the family invitation to reject. |

### Success Response

**Status Code:** `200 OK`

```json
{
  "id": "7f99b02e-f745-49cc-bca9-16885fa5be75",
  "family_id": "fe021430-af74-46bc-a1e6-b4f85f532091",
  "invited_email": "parent@example.com",
  "invited_by": "7c92d33b-1d6c-4c7f-aeb6-f6c96bda5b39",
  "status": "REJECTED",
  "created_at": "2026-07-20T16:40:00"
}
```

After a successful response:

- The invitation status is changed from `PENDING` to `REJECTED`.
- The invitation remains stored in the database.
- The authenticated parent's family membership is not changed.
- No child guardian relationships are changed.

### Error Responses

#### Invitation Is Not Pending

Returned when the invitation has already been accepted, rejected, or otherwise no longer has the status `PENDING`.

**Status Code:** `400 Bad Request`

```json
{
  "error": "Invitation is not pending"
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

#### User Not Found

Returned when the parent account associated with the access token no longer exists.

**Status Code:** `404 Not Found`

```json
{
  "error": "User not found"
}
```

#### Invitation Not Found

Returned when:

- The invitation does not exist.
- The invitation was not sent to the authenticated parent's registered email address.

**Status Code:** `404 Not Found`

```json
{
  "error": "Invitation not found"
}
```

#### Failed to Reject Invitation

Returned when the invitation status cannot be saved because of a database or unexpected server error.

**Status Code:** `500 Internal Server Error`

```json
{
  "error": "Failed to reject invitation"
}
```