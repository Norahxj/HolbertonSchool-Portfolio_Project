from marshmallow import Schema, fields, validate, ValidationError

def validate_wish_name(value):
    cleaned_value = value.strip()
    if len(cleaned_value) < 2:
        raise ValidationError("Wish name must be at least 2 characters long.")
    if len(cleaned_value) > 255:
        raise ValidationError("Wish name must not exceed 255 characters.")

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
    name = fields.String(required=True, validate=validate_wish_name)

class WishlistApproveSchema(Schema):
    target_points = fields.Integer(required=True, validate=validate.Range(min=1, max=10000))