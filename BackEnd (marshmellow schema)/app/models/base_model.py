# Import necessary modules from SQLAlchemy
from sqlalchemy import Column, String, DateTime
from sqlalchemy.ext.declarative import declarative_base
from datetime import datetime

# Create a declarative base for SQLAlchemy models
Base = declarative_base()

# Define the BaseModel class that all other models will inherit from
class BaseModel(Base):
    __abstract__ = True
# Unique identifier for each record
    id = Column(String(60), primary_key=True, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False)

    # Method to convert the model instance to a dictionary
    def to_dict(self):
        return {
            column.name: getattr(self, column.name).isoformat() if isinstance(getattr(self, column.name), datetime) else getattr(self, column.name)
            for column in self.__table__.columns
        }
