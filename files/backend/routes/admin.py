"""
ThinkStrike - Admin Routes
Created: 2025-08-07
Author: Ruthvik-Anne
"""

from fastapi import APIRouter, Depends, HTTPException
from sqlmodel import Session
from typing import List
from database import get_session
from models import User, Role
import crud

router = APIRouter(prefix="/api/admin", tags=["admin"])

@router.get("/users", response_model=List[User])
def get_users(db: Session = Depends(get_session)):
    """Get all users"""
    return crud.get_all_users(db)

@router.post("/users")
def create_user(username: str, password: str, role: str, db: Session = Depends(get_session)):
    """Create a new user"""
    return crud.create_user(username, password, role, db)

@router.put("/users/{user_id}/role")
def update_user_role(user_id: int, role: str, db: Session = Depends(get_session)):
    """Update user role"""
    return crud.update_user_role(user_id, role, db)

@router.delete("/users/{user_id}")
def delete_user(user_id: int, db: Session = Depends(get_session)):
    """Delete a user"""
    return crud.delete_user(user_id, db)