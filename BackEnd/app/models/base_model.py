from App.Extensions import db
import uuid
from datetime import datetime


class BaseModel(db.Model):
	"""
	Base model class - provides common fields and methods for all models.
	All models should inherit from this class.
	
	Common fields:
	- id: Unique identifier (UUID)
	- created_at: Timestamp when the record was created
	- updated_at: Timestamp when the record was last updated
	"""
	__abstract__ = True  # This prevents creating a table for BaseModel itself

	id = db.Column(db.String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
	created_at = db.Column(db.DateTime, default=datetime.now, nullable=False)
	updated_at = db.Column(db.DateTime, default=datetime.now, onupdate=datetime.now, nullable=False)

	def to_dict(self):
		"""
		Convert model instance to dictionary.
		Can be overridden in child models for custom serialization.
		"""
		return {
			"id": self.id,
			"created_at": self.created_at,
			"updated_at": self.updated_at
		}
