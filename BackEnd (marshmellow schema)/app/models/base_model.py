
from sqlalchemy import Column, String, DateTime
from sqlalchemy.ext.declarative import declarative_base
from datetime import datetime

# create a declarative base for SQLAlchemy models

# define the BaseModel class that all other models will inherit from. unique identifier for each record. method to convert the model instance to a dictionary
Base = declarative_base()


class BaseModel(Base):
    __abstract__ = True

    id = Column(String(60), primary_key=True, nullable=False) #uuid
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False)


    def to_dict(self):
        return {
            column.name: getattr(self, column.name).isoformat() if isinstance(getattr(self, column.name), datetime) else getattr(self, column.name)
            for column in self.__table__.columns
        }
