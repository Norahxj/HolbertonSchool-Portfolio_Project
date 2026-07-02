from marshmallow import Schema, fields, validate, validates, ValidationError


class UserResponseSchema(Schema):
    id = fields.String()
    full_name = fields.String()
    email = fields.Email()
    role = fields.String()
    guardian_type = fields.String()


class UserUpdateSchema(Schema):
    full_name = fields.String(
        required=False,
        validate=validate.Length(min=2, max=100)
    )

    email = fields.Email(required=False)

    @validates("full_name")
    def validate_full_name(self, value, **kwargs):
        if not value.strip():
            raise ValidationError("Full name cannot be empty.")