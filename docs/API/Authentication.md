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

| Field           | Type   | Required | Validation                                                                                                               |
| --------------- | ------ | -------: | ------------------------------------------------------------------------------------------------------------------------ |
| `first_name`    | String |      Yes | Must contain between 2 and 50 characters                                                                                 |
| `last_name`     | String |      Yes | Must contain between 2 and 50 characters                                                                                 |
| `phone`         | String |      Yes | Must contain exactly 10 digits and start with `05`                                                                       |
| `email`         | String |      Yes | Must be a valid and deliverable email address, with a maximum length of 120 characters                                   |
| `password`      | String |      Yes | Must contain at least 8 characters, including an uppercase letter, a lowercase letter, a number, and a special character |
| `guardian_type` | String |      Yes | Accepted values: `father`, `mother`, or `guardian`                                                                       |

### Example Request

```json
{
  "first_name": "Sara",
  "last_name": "Ahmed",
  "phone": "0512345678",
  "email": "sara@example.com",
  "password": "Password123!",
  "guardian_type": "mother"
}
```
