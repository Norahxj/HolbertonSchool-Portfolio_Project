from app.extensions import db
from app.models.base_model import BaseModel


class SuggestedTask(BaseModel):
    __tablename__ = "suggested_tasks"

    category = db.Column(db.String(50), nullable=False)
    title_en = db.Column(db.String(255), nullable=False)
    title_ar = db.Column(db.String(255), nullable=False)