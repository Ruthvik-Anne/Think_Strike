"""
ThinkStrike - CRUD Operations
Created: 2025-08-07
Author: Ruthvik-Anne

This module provides database CRUD (Create, Read, Update, Delete) operations
for the application's models. It serves as a data access layer between the
API endpoints and the database.
"""

from typing import List, Optional
from sqlmodel import select
from models import User, Quiz, Question, Attempt
from database import get_session

def create_user(username: str, password: str, role: str = "student") -> User:
    """
    Create a new user in the database.
    
    Args:
        username (str): Unique username
        password (str): User's password (should be hashed)
        role (str): User role (default: "student")
        
    Returns:
        User: Created user object
    """
    with get_session() as s:
        user = User(username=username, password=password, role=role)
        s.add(user)
        s.commit()
        s.refresh(user)
        return user

def get_user_by_name(username: str) -> Optional[User]:
    """
    Retrieve a user by their username.
    
    Args:
        username (str): Username to search for
        
    Returns:
        Optional[User]: User object if found, None otherwise
    """
    with get_session() as s:
        return s.exec(select(User).where(User.username == username)).first()

def create_quiz(title: str, questions: List[Question], creator_id: int) -> Quiz:
    """
    Create a new quiz with questions.
    
    Args:
        title (str): Quiz title
        questions (List[Question]): List of questions
        creator_id (int): User ID of quiz creator
        
    Returns:
        Quiz: Created quiz object
    """
    with get_session() as s:
        quiz = Quiz(title=title, created_by=creator_id, questions=questions)
        s.add(quiz)
        s.commit()
        s.refresh(quiz)
        return quiz