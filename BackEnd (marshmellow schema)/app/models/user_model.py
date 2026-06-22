from sqlalchemy import Column, String, DateTime, Boolean
from sqlalchemy.orm import relationship
from datetime import datetime
from .base_model import BaseModel

# Define the User model
class User(BaseModel):
    __tablename__ = 'users'  

    full_name = Column(String(120), nullable=False) #first and last name is better
    email = Column(String(120), unique=True, nullable=False)
    password_hash = Column(String(128), nullable=False)
    is_parent = Column(Boolean, default=True)  # الخيار يعطي الاهل صالحيه انه ممكن يصير ادمن 
    
    # Define relationships to other models
    children = relationship('Child', back_populates='parent', lazy=True)
    custom_tasks = relationship('ParentCustomTask', back_populates='parent', lazy=True)
    created_rewards = relationship('Reward', back_populates='parent', lazy=True)
    given_feedback = relationship('DailyFeedback', back_populates='parent', lazy=True)

    # String representation
    def __repr__(self):
        return f'<User {self.email}>'

    # Convert the object to a dictionary
    def to_dict(self): # الافضل يكون بسيرفر
        return {
            'id': self.id,
            'full_name': self.full_name,
            'email': self.email,
            'is_parent': self.is_parent,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None
        }
