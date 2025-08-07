"""
ThinkStrike - Database Models
Created: 2025-08-07
Author: Ruthvik-Anne

This module defines the SQLModel models for the application's database schema.
These models represent the core entities: Users, Quizzes, Questions, and Attempts.
"""

from typing import List, Optional
from datetime import datetime
from sqlmodel import SQLModel, Field, Relationship

class User(SQLModel, table=True):
    """
    User model representing application users with role-based access.
    
    Attributes:
        id (int): Primary key
        username (str): Unique username
        password (str): Hashed password (TODO: implement proper hashing)
        role (str): User role (admin/teacher/student)
        attempts (List[Attempt]): User's quiz attempts
    """
    id: Optional[int] = Field(default=None, primary_key=True)
    username: str = Field(index=True, unique=True)
    password: str
    role: str = Field(default="student")
    attempts: List["Attempt"] = Relationship(back_populates="user")

class Quiz(SQLModel, table=True):
    """
    Quiz model representing a collection of questions.
    
    Attributes:
        id (int): Primary key
        title (str): Quiz title
        created_by (int): User ID of quiz creator
        questions (List[Question]): Questions in this quiz
    """
    id: Optional[int] = Field(default=None, primary_key=True)
    title: str
    created_by: int = Field(foreign_key="user.id")
    questions: List["Question"] = Relationship(back_populates="quiz")

class Question(SQLModel, table=True):
    """
    Question model representing a multiple-choice question.
    
    Attributes:
        id (int): Primary key
        quiz_id (int): Foreign key to parent quiz
        text (str): Question text
        choices (str): JSON string of answer choices
        correct_index (int): Index of correct answer in choices
    """
    id: Optional[int] = Field(default=None, primary_key=True)
    quiz_id: int = Field(foreign_key="quiz.id")
    text: str
    choices: str
    correct_index: int
    quiz: Quiz = Relationship(back_populates="questions")

class Attempt(SQLModel, table=True):
    """
    Attempt model representing a user's quiz attempt.
    
    Attributes:
        id (int): Primary key
        user_id (int): Foreign key to user
        quiz_id (int): Foreign key to quiz
        score (float): Quiz score
        taken_at (datetime): Timestamp of attempt
    """
    id: Optional[int] = Field(default=None, primary_key=True)
    user_id: int = Field(foreign_key="user.id")
    quiz_id: int = Field(foreign_key="quiz.id")
    score: float
    taken_at: datetime = Field(default_factory=datetime.utcnow)
    user: User = Relationship(back_populates="attempts")