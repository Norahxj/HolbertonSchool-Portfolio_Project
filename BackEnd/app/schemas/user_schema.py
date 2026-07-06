from marshmallow import Schema, fields, validate, validates, ValidationError


class UserResponseSchema(Schema):
    id = fields.String()
    first_name = fields.String()
    last_name = fields.String()
    phone = fields.Integer()
    email = fields.Email()
    role = fields.String()
    guardian_type = fields.String()


class UserUpdateSchema(Schema):
    first_name = fields.String(required=False, validate=validate.Length(min=2, max=50))
    last_name = fields.String(required=False, validate=validate.Length(min=2, max=50))
    phone = fields.String(required=False, validate=[validate.Length(equal=10), validate.Regexp(r"^05\d{8}$")])
    email = fields.Email(required=False)

    @validates("first_name")
    def validate_first_name(self, value, **kwargs):
        if not value.strip():
            raise ValidationError("First name cannot be empty.")
        
    @validates("last_name")
    def validate_last_name(self, value, **kwargs):
        if not value.strip():
            raise ValidationError("Last name cannot be empty.")