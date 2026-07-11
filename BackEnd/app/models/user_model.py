from app.extensions import db
from app.models.base_model import BaseModel


class User(BaseModel):
    __tablename__ = "users"
    
    first_name = db.Column(db.String(50), nullable=False)
    last_name = db.Column(db.String(50), nullable=False)
    phone = db.Column(db.String(10), unique=True, nullable=False)
    email = db.Column(db.String(120), unique=True, nullable=False)
    password_hash = db.Column(db.String(255), nullable=False)
    role = db.Column(db.String(20), default="parent", nullable=False)
    guardian_type = db.Column(db.String(10), nullable=False)
    tasks = db.relationship("Task", backref="creator", lazy=True, passive_deletes=True)
    daily_feedbacks = db.relationship("DailyFeedback", backref="creator", lazy=True, passive_deletes=True)
    family_id = db.Column(db.String(36), db.ForeignKey("families.id", ondelete="SET NULL"), nullable=True)
