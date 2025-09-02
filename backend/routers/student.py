from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from backend.database import get_db

router = APIRouter(prefix="/student", tags=["student"])

@router.post("/quiz/submit/{quiz_id}")
async def submit_quiz(quiz_id: int, answers: dict, db: Session = Depends(get_db)):
    score = sum(1 for ans in answers.values() if ans == "Option A")
    teacher_report = {
        "quiz_id": quiz_id,
        "student_id": answers.get("student_id"),
        "score": score,
    }
    return {"status": "submitted", "report": teacher_report}
