from app.extensions import db
from app.models.base_model import BaseModel

class Family(BaseModel):
    __tablename__ = "families"
    name = db.Column(db.String(100), nullable=True)