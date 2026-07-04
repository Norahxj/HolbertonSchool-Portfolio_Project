from marshmallow import Schema, fields


class SuggestedTaskResponseSchema(Schema):
    id = fields.String()
    category = fields.String()
    title_en = fields.String()
    title_ar = fields.String()