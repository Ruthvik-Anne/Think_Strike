"""
ThinkStrike - Automated Reporting System
Created: 2025-08-07 15:33:04
Author: Ruthvik-Anne
"""

from fastapi import APIRouter, Depends, HTTPException
from sqlmodel import Session
from typing import List
from database import get_session
from models import Report, User, Question
from datetime import datetime

router = APIRouter(prefix="/api/reports", tags=["reports"])

@router.post("/create")
async def create_report(
    student_id: int,
    question_id: int,
    report_type: str,
    db: Session = Depends(get_session)
):
    """Create an automated question report"""
    
    # Verify question exists
    question = db.query(Question).filter(Question.id == question_id).first()
    if not question:
        raise HTTPException(status_code=404, detail="Question not found")
    
    # Create report
    report = Report(
        student_id=student_id,
        question_id=question_id,
        type=report_type,
        status="pending",
        created_at=datetime.utcnow()
    )
    
    db.add(report)
    db.commit()
    db.refresh(report)
    
    return {
        "message": "Report submitted successfully",
        "report_id": report.id
    }

@router.get("/teacher/{teacher_id}")
async def get_teacher_reports(
    teacher_id: int,
    db: Session = Depends(get_session)
):
    """Get all reports for questions created by a teacher"""
    reports = db.query(Report)\
        .join(Question)\
        .filter(Question.creator_id == teacher_id)\
        .order_by(Report.created_at.desc())\
        .all()
    
    return reports

@router.put("/{report_id}/status")
async def update_report_status(
    report_id: int,
    status: str,
    db: Session = Depends(get_session)
):
    """Update report status"""
    report = db.query(Report).filter(Report.id == report_id).first()
    if not report:
        raise HTTPException(status_code=404, detail="Report not found")
    
    report.status = status
    db.commit()
    db.refresh(report)
    
    return report