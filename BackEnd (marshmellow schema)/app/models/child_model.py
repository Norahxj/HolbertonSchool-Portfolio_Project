# Import necessary modules from SQLAlchemy and the base model
from sqlalchemy import Column, String, Integer, DateTime, Boolean, ForeignKey
from sqlalchemy.orm import relationship
from datetime import datetime
from .base_model import BaseModel

# Define the Child model
class Child(BaseModel):
    __tablename__ = 'children'
    parent_id = Column(String(60), ForeignKey('users.id'), nullable=False)  
    full_name = Column(String(120), nullable=False) 
    date_of_birth = Column(DateTime, nullable=False) 
    gender = Column(String(10), nullable=True)  
    avatar_url = Column(String(255), nullable=True)  
    current_noor_points = Column(Integer, default=0)  

    # Define relationships to other models
    parent = relationship('User', back_populates='children')  
    assigned_tasks = relationship('ChildTask', back_populates='child', lazy=True)  
    redeemed_rewards = relationship('ChildReward', back_populates='child', lazy=True)  
    wishes = relationship('Wish', back_populates='child', lazy=True) 
    received_feedback = relationship('DailyFeedback', back_populates='child', lazy=True) 

    # String representation of the Child object
    def __repr__(self):
        return f'<Child {self.full_name}>'
    
    def to_dict(self):
        return {
            'id': self.id,
            'parent_id': self.parent_id,
            'full_name': self.full_name,
            'date_of_birth': self.date_of_birth.isoformat() if self.date_of_birth else None,
            'gender': self.gender,
            'avatar_url': self.avatar_url,
            'current_noor_points': self.current_noor_points,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None
        }
