from marshmallow import Schema, fields, validate, validates, ValidationError


class WishlistResponseSchema(Schema):
    id = fields.String()
    child_id = fields.String()
    name = fields.String()
    target_points = fields.Integer(allow_none=True)
    status = fields.String()
    reviewed_by = fields.String(allow_none=True)
    approved_at = fields.DateTime(allow_none=True)
    created_at = fields.DateTime()


class WishlistCreateSchema(Schema):
    name = fields.String(
        required=True,
        validate=validate.Length(min=2, max=255)
    )

    @validates("name")
    def validate_name(self, value, **kwargs):
        if not value.strip():
            raise ValidationError("Wish name cannot be empty.")


class WishlistApproveSchema(Schema):
    target_points = fields.Integer(
        required=True,
        validate=validate.Range(min=1, max=10000)
    )