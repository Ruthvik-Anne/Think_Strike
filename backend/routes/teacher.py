"""
ThinkStrike - Teacher Routes
Created: 2025-08-07
Author: Ruthvik-Anne
"""

from fastapi import APIRouter, Depends, HTTPException, UploadFile, File
from sqlmodel import Session
from typing import List
from database import get_session
from models import Material, Quiz
import crud

router = APIRouter(prefix="/api/teacher", tags=["teacher"])

@router.post("/materials")
async def upload_material(
    file: UploadFile = File(...),
    title: str = Form(...),
    category: str = Form(...),
    db: Session = Depends(get_session)
):
    """Upload learning material"""
    return await crud.save_material(file, title, category, db)

@router.get("/materials")
def get_materials(db: Session = Depends(get_session)):
    """Get all learning materials"""
    return crud.get_materials(db)

@router.post("/quizzes")
def create_quiz(quiz_data: Quiz, db: Session = Depends(get_session)):
    """Create a new quiz"""
    return crud.create_quiz(quiz_data, db)

@router.put("/quizzes/{quiz_id}")
def update_quiz(quiz_id: int, quiz_data: Quiz, db: Session = Depends(get_session)):
    """Update an existing quiz"""
    return crud.update_quiz(quiz_id, quiz_data, db)

@router.get("/analytics/student-progress")
def get_student_progress(db: Session = Depends(get_session)):
    """Get student progress analytics"""
    return crud.get_student_progress(db)