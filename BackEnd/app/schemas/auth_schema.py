import re
from marshmallow import Schema, ValidationError, fields, validate, pre_load, validates
from email_validator import validate_email, EmailNotValidError

def validate_password(password):
    if len(password) < 8:
        raise ValidationError("Password must be at least 8 characters long.")
    if not re.search(r"[A-Z]", password):
        raise ValidationError("Password must contain at least one uppercase letter.")
    if not re.search(r"[a-z]", password):
        raise ValidationError("Password must contain at least one lowercase letter.")
    if not re.search(r"\d", password):
        raise ValidationError("Password must contain at least one number.")
    if not re.search(r"[!@#$%^&*(),.?\":{}|<>_\-+=/\\[\]]", password):
        raise ValidationError("Password must contain at least one special character.")
    
def validate_email_domain(email):
    try:
        validate_email(email,check_deliverability=True)
    except EmailNotValidError as error:
        raise ValidationError(str(error))
phone_validator = [
    validate.Length(equal=10,
        error="Phone number must be exactly 10 digits."
    ),
    validate.Regexp(r"^05\d{8}$",
        error="Phone number must start with 05 and contain only digits."
    )
]

class RegisterSchema(Schema):
    first_name = fields.String(required=True)
    last_name = fields.String(required=True)
    phone = fields.String(required=True, validate=phone_validator)
    email = fields.Email(required=True, validate=[validate.Length(max=120), validate_email_domain])
    password = fields.String(required=True, validate=validate_password)
    guardian_type = fields.String(required=True, validate=validate.OneOf(["father", "mother", "guardian"]))

    @pre_load
    def clean_names(self, data, **kwargs):
        if isinstance(data.get("first_name"), str):
            data["first_name"] = " ".join(data["first_name"].split())
        if isinstance(data.get("last_name"), str):data["last_name"] = " ".join(data["last_name"].split())
        return data
    
    @validates("first_name")
    def validate_first_name(self, value, **kwargs):
        if len(value) < 2:
            raise ValidationError("First name must be at least 2 characters long.")
        if len(value) > 50:
            raise ValidationError("First name must not exceed 50 characters.")
        if not re.fullmatch(r"[A-Za-z\u0600-\u06FF ]+", value):
            raise ValidationError("First name must contain letters only.")
        
    @validates("last_name")
    def validate_last_name(self, value, **kwargs):
        if len(value) < 2:
            raise ValidationError("Last name must be at least 2 characters long.")
        if len(value) > 50:
            raise ValidationError("Last name must not exceed 50 characters.")
        if not re.fullmatch(r"[A-Za-z\u0600-\u06FF ]+", value):
            raise ValidationError("Last name must contain letters only.")


class LoginSchema(Schema):
    email = fields.Email(required=True)
    password = fields.String(required=True)

class ChildLoginSchema(Schema):
    access_code = fields.String(required=True, validate=[
            validate.Length(equal=6),
            validate.Regexp(r"^[0-9]{6}$", error="Access code must be exactly 6 digits.")
        ])