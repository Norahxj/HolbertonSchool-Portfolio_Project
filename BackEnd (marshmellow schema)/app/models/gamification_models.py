from sqlalchemy import Column, Integer, String, Boolean, ForeignKey, DateTime, Text, Enum
from sqlalchemy.orm import relationship
from datetime import datetime
import enum
from .base_model import BaseModel

# Define an enumeration for Task Status. in short enum
class TaskStatus(enum.Enum):
    PENDING = "pending"
    COMPLETED = "completed"
    VERIFIED = "verified"
    REJECTED = "rejected"

# Define the ChildTask model
class ChildTask(BaseModel):
    __tablename__ = 'child_tasks'
#يعطي مفتاح لكل تاسك استخدمة forienkey
    child_id = Column(String(60), ForeignKey('children.id'), nullable=False)
    suggested_task_id = Column(Integer, ForeignKey('suggested_tasks.id'), nullable=True)
    parent_custom_task_id = Column(Integer, ForeignKey('parent_custom_tasks.id'), nullable=True)

    assigned_points = Column(Integer, nullable=False)
    status = Column(Enum(TaskStatus), default=TaskStatus.PENDING, nullable=False)
    due_date = Column(DateTime, nullable=True)
    completion_date = Column(DateTime, nullable=True)
    verification_date = Column(DateTime, nullable=True)
    parent_feedback_id = Column(String(60), ForeignKey('daily_feedback.id'), nullable=True)

    # Define relationships
    child = relationship('Child', back_populates='assigned_tasks')
    suggested_task = relationship('SuggestedTask')
    parent_custom_task = relationship('ParentCustomTask')
    parent_feedback = relationship('DailyFeedback', back_populates='child_tasks')
  
    # String representation
    def __repr__(self):
        return f'<ChildTask {self.id} - Child: {self.child_id} Status: {self.status.value}>'

    def to_dict(self):
        return {
            'id': self.id,
            'child_id': self.child_id,
            'suggested_task_id': self.suggested_task_id,
            'parent_custom_task_id': self.parent_custom_task_id,
            'assigned_points': self.assigned_points,
            'status': self.status.value,
            'due_date': self.due_date.isoformat() if self.due_date else None,
            'completion_date': self.completion_date.isoformat() if self.completion_date else None,
            'verification_date': self.verification_date.isoformat() if self.verification_date else None,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None
        }

# Define the Reward model
class Reward(BaseModel):
    __tablename__ = 'rewards'

    parent_id = Column(String(60), ForeignKey('users.id'), nullable=False)
    name_en = Column(String(255), nullable=False)
    name_ar = Column(String(255), nullable=False)
    description_en = Column(Text, nullable=True)
    description_ar = Column(Text, nullable=True)
    cost_points = Column(Integer, nullable=False)
    is_active = Column(Boolean, default=True)
    is_approved_by_parent = Column(Boolean, default=True)
    # Define relationship to User
    parent = relationship('User', back_populates='created_rewards')
    child_rewards = relationship('ChildReward', back_populates='reward', lazy=True)

    # String representation of the Reward object
    def __repr__(self):
        return f'<Reward {self.name_en} - Cost: {self.cost_points}>'

    # Convert the object to a dictionary
    def to_dict(self):
        return {
            'id': self.id,
            'parent_id': self.parent_id,
            'name_en': self.name_en,
            'name_ar': self.name_ar,
            'description_en': self.description_en,
            'description_ar': self.description_ar,
            'cost_points': self.cost_points,
            'is_active': self.is_active,
            'is_approved_by_parent': self.is_approved_by_parent,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None
        }

# Define the ChildReward model
class ChildReward(BaseModel):
    __tablename__ = 'child_rewards'

    child_id = Column(String(60), ForeignKey('children.id'), nullable=False)
    reward_id = Column(Integer, ForeignKey('rewards.id'), nullable=False)
    redemption_date = Column(DateTime, default=datetime.utcnow)
    is_fulfilled = Column(Boolean, default=False)
    fulfilled_date = Column(DateTime, nullable=True)
  
    # Define relationships
    child = relationship('Child', back_populates='redeemed_rewards')
    reward = relationship('Reward', back_populates='child_rewards')

   
    def __repr__(self):
        return f'<ChildReward {self.id} - Child: {self.child_id} Reward: {self.reward_id}>'

    
    def to_dict(self):
        return {
            'id': self.id,
            'child_id': self.child_id,
            'reward_id': self.reward_id,
            'redemption_date': self.redemption_date.isoformat() if self.redemption_date else None,
            'is_fulfilled': self.is_fulfilled,
            'fulfilled_date': self.fulfilled_date.isoformat() if self.fulfilled_date else None,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None
        }

# Define the Wish model
class Wish(BaseModel):
    __tablename__ = 'wishes'

    child_id = Column(String(60), ForeignKey('children.id'), nullable=False)
    name_en = Column(String(255), nullable=False)
    name_ar = Column(String(255), nullable=False)
    description_en = Column(Text, nullable=True)
    description_ar = Column(Text, nullable=True)
    target_points = Column(Integer, nullable=False)  # Points required to achieve the wish
    current_points = Column(Integer, default=0)  # Current points accumulated towards the wish
    is_achieved = Column(Boolean, default=False)
    achievement_date = Column(DateTime, nullable=True)  # Date when the wish was achieved
    is_approved_by_parent = Column(Boolean, default=False) # Whether the parent has approved this wish

    # Define relationship to Child
    child = relationship('Child', back_populates='wishes')
  
    def __repr__(self):
        return f'<Wish {self.name_en} - Child: {self.child_id} Target: {self.target_points}>'

    # Convert the object to a dictionary
    def to_dict(self):
        return {
            'id': self.id,
            'child_id': self.child_id,
            'name_en': self.name_en,
            'name_ar': self.name_ar,
            'description_en': self.description_en,
            'description_ar': self.description_ar,
            'target_points': self.target_points,
            'current_points': self.current_points,
            'is_achieved': self.is_achieved,
            'achievement_date': self.achievement_date.isoformat() if self.achievement_date else None,
            'is_approved_by_parent': self.is_approved_by_parent,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None
        }

# Define an Enum for Feedback Mood
class FeedbackMood(enum.Enum):
    HAPPY = "happy"
    SATISFIED = "satisfied"
    NOT_SATISFIED = "not_satisfied"

# Define the DailyFeedback model
class DailyFeedback(BaseModel):
    __tablename__ = 'daily_feedback'

    parent_id = Column(String(60), ForeignKey('users.id'), nullable=False)
    child_id = Column(String(60), ForeignKey('children.id'), nullable=False)
    feedback_date = Column(DateTime, default=datetime.utcnow, nullable=False)
    mood = Column(Enum(FeedbackMood), nullable=False)
    notes = Column(Text, nullable=True)

    # Define relationships
    parent = relationship('User', back_populates='given_feedback')
    child = relationship('Child', back_populates='received_feedback')
    child_tasks = relationship('ChildTask', back_populates='parent_feedback', lazy=True)

    def __repr__(self):
        return f'<DailyFeedback {self.id} - Child: {self.child_id} Mood: {self.mood.value}>'

    # Convert the object to a dictionary
    def to_dict(self):
        return {
            'id': self.id,
            'parent_id': self.parent_id,
            'child_id': self.child_id,
            'feedback_date': self.feedback_date.isoformat() if self.feedback_date else None,
            'mood': self.mood.value,
            'notes': self.notes,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None
        }
