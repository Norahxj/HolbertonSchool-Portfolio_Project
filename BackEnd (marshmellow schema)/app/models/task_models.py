# Import necessary modules from SQLAlchemy and the base model
from sqlalchemy import Column, Integer, String, Boolean, ForeignKey, DateTime, Text
from sqlalchemy.orm import relationship
from datetime import datetime
from .base_model import BaseModel

# Define the TaskCategory model
class TaskCategory(BaseModel):
    __tablename__ = 'task_categories'  

    name_en = Column(String(100), unique=True, nullable=False)  # English name of the category.
    name_ar = Column(String(100), unique=True, nullable=False)  # Arabic name of the category.
    description_en = Column(Text, nullable=True)
    description_ar = Column(Text, nullable=True)

    # Define relationships
    suggested_tasks = relationship('SuggestedTask', back_populates='category', lazy=True)
    parent_custom_tasks = relationship('ParentCustomTask', back_populates='category', lazy=True)
    
    def __repr__(self):
        return f'<TaskCategory {self.name_en}>'

    # Convert the object to a dictionary for API responses
    def to_dict(self):
        return {
            'id': self.id,
            'name_en': self.name_en,
            'name_ar': self.name_ar,
            'description_en': self.description_en,
            'description_ar': self.description_ar,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None
        }

# Define the SuggestedTask model
class SuggestedTask(BaseModel):
    __tablename__ = 'suggested_tasks'  

    category_id = Column(Integer, ForeignKey('task_categories.id'), nullable=False)
    name_en = Column(String(255), nullable=False)
    name_ar = Column(String(255), nullable=False)
    description_en = Column(Text, nullable=True)
    description_ar = Column(Text, nullable=True)
    min_age = Column(Integer, default=6) 
    max_age = Column(Integer, default=16)
    default_points = Column(Integer, default=10)
    category = relationship('TaskCategory', back_populates='suggested_tasks') 

    # String representation 
    def __repr__(self):
        return f'<SuggestedTask {self.name_en}>'

    # Convert the object to a dictionary for API responses
    def to_dict(self):
        return {
            'id': self.id,
            'category_id': self.category_id,
            'name_en': self.name_en,
            'name_ar': self.name_ar,
            'description_en': self.description_en,
            'description_ar': self.description_ar,
            'min_age': self.min_age,
            'max_age': self.max_age,
            'default_points': self.default_points,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None
        }

# Define the ParentCustomTask model
class ParentCustomTask(BaseModel):
    __tablename__ = 'parent_custom_tasks' 

    parent_id = Column(String(60), ForeignKey('users.id'), nullable=False)
    category_id = Column(Integer, ForeignKey('task_categories.id'), nullable=False)
    name_en = Column(String(255), nullable=False)
    name_ar = Column(String(255), nullable=False)
    description_en = Column(Text, nullable=True)
    description_ar = Column(Text, nullable=True)
    points = Column(Integer, nullable=False)
    is_recurring = Column(Boolean, default=False)
    recurrence_type = Column(String(50), nullable=True)
    requires_verification = Column(Boolean, default=True)

   
    parent = relationship('User', back_populates='custom_tasks')  # Many-to-one relationship with User
    category = relationship('TaskCategory', back_populates='parent_custom_tasks')  # Many-to-one relationship with TaskCategory

    # String representation 
    def __repr__(self):
        return f'<ParentCustomTask {self.name_en}>'

    # Convert the object to a dictionary
    def to_dict(self):
        return {
            'id': self.id,
            'parent_id': self.parent_id,
            'category_id': self.category_id,
            'name_en': self.name_en,
            'name_ar': self.name_ar,
            'description_en': self.description_en,
            'description_ar': self.description_ar,
            'points': self.points,
            'is_recurring': self.is_recurring,
            'recurrence_type': self.recurrence_type,
            'requires_verification': self.requires_verification,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None
        }
