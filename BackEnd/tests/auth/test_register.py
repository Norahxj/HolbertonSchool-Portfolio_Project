import pytest
REGISTER_URL = "/api/auth/register"


def valid_register_data():
    return {
        "first_name": "Manar",
        "last_name": "Zaid",
        "phone": "0551234567",
        "email": "manar.testing2026@gmail.com",
        "password": "Password123!",
        "guardian_type": "mother",
    }


def test_register_success(client):
    response = client.post(
        REGISTER_URL,
        json=valid_register_data(),
    )

    response_data = response.get_json()

    assert response.status_code == 201, response_data
    assert "access_token" in response_data
    assert "refresh_token" in response_data
    assert "user" in response_data

    assert response_data["user"]["first_name"] == "Manar"
    assert response_data["user"]["last_name"] == "Zaid"
    assert response_data["user"]["email"] == "manar.testing2026@gmail.com"
    assert response_data["user"]["phone"] == "0551234567"
    assert response_data["user"]["guardian_type"] == "mother"
    assert response_data["user"]["role"] == "parent"


def test_register_duplicate_email(client):
    first_user = valid_register_data()

    first_response = client.post(
        REGISTER_URL,
        json=first_user,
    )

    assert first_response.status_code == 201, first_response.get_json()

    second_user = valid_register_data()
    second_user["phone"] = "0559876543"

    response = client.post(
        REGISTER_URL,
        json=second_user,
    )

    assert response.status_code == 409, response.get_json()
    assert response.get_json()["error"] == "Email already registered"


def test_register_duplicate_phone(client):
    first_user = valid_register_data()

    first_response = client.post(
        REGISTER_URL,
        json=first_user,
    )

    assert first_response.status_code == 201, first_response.get_json()

    second_user = valid_register_data()
    second_user["email"] = "another.testing2026@gmail.com"

    response = client.post(
        REGISTER_URL,
        json=second_user,
    )

    assert response.status_code == 409, response.get_json()
    assert response.get_json()["error"] == "Phone number already used"


def test_register_missing_first_name(client):
    data = valid_register_data()
    data.pop("first_name")

    response = client.post(
        REGISTER_URL,
        json=data,
    )

    response_data = response.get_json()

    assert response.status_code == 400, response_data
    assert "errors" in response_data
    assert "first_name" in response_data["errors"]

def test_register_password_too_short(client):
    data = valid_register_data()
    data["password"] = "Pass1!"

    response = client.post(
        REGISTER_URL,
        json=data,
    )

    response_data = response.get_json()

    assert response.status_code == 400, response_data
    assert "errors" in response_data
    assert "password" in response_data["errors"]


def test_register_first_name_with_numbers(client):
    data = valid_register_data()
    data["first_name"] = "Manar123"

    response = client.post(
        REGISTER_URL,
        json=data,
    )

    response_data = response.get_json()

    assert response.status_code == 400, response_data
    assert "errors" in response_data
    assert "first_name" in response_data["errors"]

@pytest.mark.parametrize(
    "missing_field",
    [
        "last_name",
        "phone",
        "email",
        "password",
        "guardian_type",
    ],
)
def test_register_missing_required_field(client, missing_field):
    data = valid_register_data()
    data.pop(missing_field)

    response = client.post(
        REGISTER_URL,
        json=data,
    )

    response_data = response.get_json()

    assert response.status_code == 400, response_data
    assert "errors" in response_data
    assert missing_field in response_data["errors"]

def test_register_first_name_too_short(client):
    data = valid_register_data()
    data["first_name"] = "M"

    response = client.post(REGISTER_URL, json=data)
    response_data = response.get_json()

    assert response.status_code == 400, response_data
    assert "first_name" in response_data["errors"]


def test_register_first_name_too_long(client):
    data = valid_register_data()
    data["first_name"] = "M" * 51

    response = client.post(REGISTER_URL, json=data)
    response_data = response.get_json()

    assert response.status_code == 400, response_data
    assert "first_name" in response_data["errors"]


def test_register_first_name_with_symbols(client):
    data = valid_register_data()
    data["first_name"] = "Manar@"

    response = client.post(REGISTER_URL, json=data)
    response_data = response.get_json()

    assert response.status_code == 400, response_data
    assert "first_name" in response_data["errors"]


def test_register_empty_first_name(client):
    data = valid_register_data()
    data["first_name"] = ""

    response = client.post(REGISTER_URL, json=data)
    response_data = response.get_json()

    assert response.status_code == 400, response_data
    assert "first_name" in response_data["errors"]


def test_register_first_name_exactly_two_characters(client):
    data = valid_register_data()
    data["first_name"] = "Al"

    response = client.post(REGISTER_URL, json=data)
    response_data = response.get_json()

    assert response.status_code == 201, response_data
    assert response_data["user"]["first_name"] == "Al"


def test_register_first_name_exactly_fifty_characters(client):
    data = valid_register_data()
    data["first_name"] = "M" * 50

    response = client.post(REGISTER_URL, json=data)
    response_data = response.get_json()

    assert response.status_code == 201, response_data
    assert response_data["user"]["first_name"] == "M" * 50


def test_register_arabic_first_name(client):
    data = valid_register_data()
    data["first_name"] = "منار"

    response = client.post(REGISTER_URL, json=data)
    response_data = response.get_json()

    assert response.status_code == 201, response_data
    assert response_data["user"]["first_name"] == "منار"


def test_register_first_name_spaces_are_cleaned(client):
    data = valid_register_data()
    data["first_name"] = "   Manar    Ahmed   "

    response = client.post(REGISTER_URL, json=data)
    response_data = response.get_json()

    assert response.status_code == 201, response_data
    assert response_data["user"]["first_name"] == "Manar Ahmed"

def test_register_last_name_too_short(client):
    data = valid_register_data()
    data["last_name"] = "Z"

    response = client.post(REGISTER_URL, json=data)
    response_data = response.get_json()

    assert response.status_code == 400, response_data
    assert "last_name" in response_data["errors"]


def test_register_last_name_too_long(client):
    data = valid_register_data()
    data["last_name"] = "Z" * 51

    response = client.post(REGISTER_URL, json=data)
    response_data = response.get_json()

    assert response.status_code == 400, response_data
    assert "last_name" in response_data["errors"]


def test_register_last_name_with_numbers(client):
    data = valid_register_data()
    data["last_name"] = "Zaid123"

    response = client.post(REGISTER_URL, json=data)
    response_data = response.get_json()

    assert response.status_code == 400, response_data
    assert "last_name" in response_data["errors"]


def test_register_last_name_with_symbols(client):
    data = valid_register_data()
    data["last_name"] = "Zaid@"

    response = client.post(REGISTER_URL, json=data)
    response_data = response.get_json()

    assert response.status_code == 400, response_data
    assert "last_name" in response_data["errors"]


def test_register_empty_last_name(client):
    data = valid_register_data()
    data["last_name"] = ""

    response = client.post(REGISTER_URL, json=data)
    response_data = response.get_json()

    assert response.status_code == 400, response_data
    assert "last_name" in response_data["errors"]


def test_register_arabic_last_name(client):
    data = valid_register_data()
    data["last_name"] = "زيد"

    response = client.post(REGISTER_URL, json=data)
    response_data = response.get_json()

    assert response.status_code == 201, response_data
    assert response_data["user"]["last_name"] == "زيد"


def test_register_last_name_spaces_are_cleaned(client):
    data = valid_register_data()
    data["last_name"] = "   Al    Zaid   "

    response = client.post(REGISTER_URL, json=data)
    response_data = response.get_json()

    assert response.status_code == 201, response_data
    assert response_data["user"]["last_name"] == "Al Zaid"

@pytest.mark.parametrize(
    "invalid_phone",
    [
        "055123456",       # تسعة أرقام
        "05512345678",     # أحد عشر رقمًا
        "055123456A",      # يحتوي حرفًا
        "05512345@7",      # يحتوي رمزًا
        "0611234567",      # لا يبدأ بـ 05
        "0111234567",      # رقم ثابت
        "",                # فارغ
    ],
)
def test_register_invalid_phone(client, invalid_phone):
    data = valid_register_data()
    data["phone"] = invalid_phone

    response = client.post(REGISTER_URL, json=data)
    response_data = response.get_json()

    assert response.status_code == 400, response_data
    assert "phone" in response_data["errors"]


def test_register_phone_with_spaces_is_rejected(client):
    data = valid_register_data()
    data["phone"] = " 0551234567 "

    response = client.post(REGISTER_URL, json=data)
    response_data = response.get_json()

    assert response.status_code == 400, response_data
    assert "phone" in response_data["errors"]

@pytest.mark.parametrize(
    "invalid_email",
    [
        "manar",
        "manar@",
        "@gmail.com",
        "manar@gmail",
        "manar gmail@gmail.com",
        "",
    ],
)
def test_register_invalid_email(client, invalid_email):
    data = valid_register_data()
    data["email"] = invalid_email

    response = client.post(REGISTER_URL, json=data)
    response_data = response.get_json()

    assert response.status_code == 400, response_data
    assert "email" in response_data["errors"]


def test_register_email_longer_than_120_characters(client):
    data = valid_register_data()
    data["email"] = f"{'a' * 111}@gmail.com"

    assert len(data["email"]) > 120

    response = client.post(REGISTER_URL, json=data)
    response_data = response.get_json()

    assert response.status_code == 400, response_data
    assert "email" in response_data["errors"]


def test_register_email_is_saved_in_lowercase(client):
    data = valid_register_data()
    data["email"] = "MANAR.TESTING2026@GMAIL.COM"

    response = client.post(REGISTER_URL, json=data)
    response_data = response.get_json()

    assert response.status_code == 201, response_data
    assert response_data["user"]["email"] == "manar.testing2026@gmail.com"


def test_register_duplicate_email_is_case_insensitive(client):
    first_data = valid_register_data()
    first_data["email"] = "manar.testing2026@gmail.com"

    first_response = client.post(REGISTER_URL, json=first_data)

    assert first_response.status_code == 201, first_response.get_json()

    second_data = valid_register_data()
    second_data["email"] = "MANAR.TESTING2026@GMAIL.COM"
    second_data["phone"] = "0559876543"

    response = client.post(REGISTER_URL, json=second_data)
    response_data = response.get_json()

    assert response.status_code == 409, response_data
    assert response_data["error"] == "Email already registered"


def test_register_email_with_surrounding_spaces_is_rejected(client):
    data = valid_register_data()
    data["email"] = " manar.testing2026@gmail.com "

    response = client.post(REGISTER_URL, json=data)
    response_data = response.get_json()

    assert response.status_code == 400, response_data
    assert "email" in response_data["errors"]

@pytest.mark.parametrize(
    ("invalid_password", "case_description"),
    [
        ("password123!", "missing uppercase"),
        ("PASSWORD123!", "missing lowercase"),
        ("Password!!!", "missing number"),
        ("Password123", "missing special character"),
        ("", "empty password"),
    ],
)
def test_register_invalid_password(
    client,
    invalid_password,
    case_description,
):
    data = valid_register_data()
    data["password"] = invalid_password

    response = client.post(REGISTER_URL, json=data)
    response_data = response.get_json()

    assert response.status_code == 400, (
        case_description,
        response_data,
    )
    assert "password" in response_data["errors"]


@pytest.mark.parametrize(
    "special_character",
    [
        "!",
        "@",
        "#",
        "$",
        "%",
        "^",
        "&",
        "*",
        "_",
        "-",
        "+",
        "=",
        "/",
        "\\",
        "[",
        "]",
    ],
)
def test_register_accepts_supported_special_characters(
    client,
    special_character,
):
    data = valid_register_data()
    data["email"] = (
        f"manar.testing{ord(special_character)}@gmail.com"
    )
    data["password"] = f"Password1{special_character}"

    response = client.post(REGISTER_URL, json=data)
    response_data = response.get_json()

    assert response.status_code == 201, (
        special_character,
        response_data,
    )

@pytest.mark.parametrize(
    "guardian_type",
    [
        "father",
        "mother",
        "guardian",
    ],
)
def test_register_valid_guardian_types(client, guardian_type):
    data = valid_register_data()
    data["guardian_type"] = guardian_type

    response = client.post(REGISTER_URL, json=data)
    response_data = response.get_json()

    assert response.status_code == 201, response_data
    assert response_data["user"]["guardian_type"] == guardian_type


@pytest.mark.parametrize(
    "invalid_guardian_type",
    [
        "Father",
        "MOTHER",
        "parent",
        "brother",
        "",
    ],
)
def test_register_rejects_invalid_guardian_types(
    client,
    invalid_guardian_type,
):
    data = valid_register_data()
    data["guardian_type"] = invalid_guardian_type

    response = client.post(REGISTER_URL, json=data)
    response_data = response.get_json()

    assert response.status_code == 400, response_data
    assert "guardian_type" in response_data["errors"]

@pytest.mark.parametrize(
    ("field_name", "invalid_value"),
    [
        ("first_name", 123),
        ("last_name", 123),
        ("phone", 551234567),
        ("email", 123),
        ("password", 123),
        ("guardian_type", 123),
    ],
)
def test_register_rejects_invalid_field_types(
    client,
    field_name,
    invalid_value,
):
    data = valid_register_data()
    data[field_name] = invalid_value

    response = client.post(REGISTER_URL, json=data)
    response_data = response.get_json()

    assert response.status_code == 400, response_data
    assert "errors" in response_data
    assert field_name in response_data["errors"]


@pytest.mark.parametrize(
    "field_name",
    [
        "first_name",
        "last_name",
        "phone",
        "email",
        "password",
        "guardian_type",
    ],
)
def test_register_rejects_null_required_fields(client, field_name):
    data = valid_register_data()
    data[field_name] = None

    response = client.post(REGISTER_URL, json=data)
    response_data = response.get_json()

    assert response.status_code == 400, response_data
    assert "errors" in response_data
    assert field_name in response_data["errors"]

def test_register_response_does_not_expose_password(client):
    response = client.post(
        REGISTER_URL,
        json=valid_register_data(),
    )

    response_data = response.get_json()

    assert response.status_code == 201, response_data
    assert "password" not in response_data["user"]
    assert "password_hash" not in response_data["user"]


def test_register_returns_non_empty_tokens(client):
    response = client.post(
        REGISTER_URL,
        json=valid_register_data(),
    )

    response_data = response.get_json()

    assert response.status_code == 201, response_data
    assert isinstance(response_data["access_token"], str)
    assert isinstance(response_data["refresh_token"], str)
    assert response_data["access_token"]
    assert response_data["refresh_token"]


def test_register_creates_parent_role(client):
    response = client.post(
        REGISTER_URL,
        json=valid_register_data(),
    )

    response_data = response.get_json()

    assert response.status_code == 201, response_data
    assert response_data["user"]["role"] == "parent"