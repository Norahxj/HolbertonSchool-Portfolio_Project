from app.extensions import db
import uuid
from app.utils.datetime_utils import utc_now


class BaseModel(db.Model):
	__abstract__ = True  

	id = db.Column(db.String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
	created_at = db.Column(db.DateTime(timezone=True), default=utc_now, nullable=False)
	updated_at = db.Column(db.DateTime(timezone=True), default=utc_now, onupdate=utc_now, nullable=False)