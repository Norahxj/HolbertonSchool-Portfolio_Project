from app.extensions import db
from app.models.base_model import BaseModel


class RevokedToken(BaseModel):
    __tablename__ = "revoked_tokens"

    jti = db.Column(db.String(255), unique=True, nullable=False)