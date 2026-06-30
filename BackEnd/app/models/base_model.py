from app.extensions import db
import uuid
from datetime import datetime


class BaseModel(db.Model):
	__abstract__ = True  

	id = db.Column(db.String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
	created_at = db.Column(db.DateTime, default=datetime.now, nullable=False)
	updated_at = db.Column(db.DateTime, default=datetime.now, onupdate=datetime.now, nullable=False)