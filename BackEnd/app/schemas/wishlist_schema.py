from marshmallow import Schema, fields, validate, ValidationError, validates


class WishlistResponseSchema(Schema):
    id = fields.String()
    child_id = fields.String()
    name = fields.String()
    target_points = fields.Integer()
    status = fields.String()
    created_at = fields.DateTime()
    updated_at = fields.DateTime()

class WishlistCreateSchema(Schema):
    child_id = fields.String(required=True)
    name = fields.String(required=True, validate=validate.Length(min=2, max=100))

    @validates("name")
    def validate_name(self, value, **kwargs):
        if not value.strip():
            raise ValidationError("Name cannot be empty.")


class WishlistUpdateSchema(Schema):
    name = fields.String(required=False, validate=validate.Length(min=2, max=100))
    target_points = fields.Integer(required=False, validate=validate.Range(min=0))

    @validates("name")
    def validate_name(self, value, **kwargs):
        if not value.strip():
            raise ValidationError("Name cannot be empty.")


class WishlistApproveSchema(Schema):
    wish_id = fields.String(required=True)


class WishlistRejectSchema(Schema):
    wish_id = fields.String(required=True)


class WishlistProgressSchema(Schema):
    current_points = fields.Integer(required=True, validate=validate.Range(min=0))
