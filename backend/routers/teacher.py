from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from backend.ai.quiz_generator import generate_quiz
from backend.database import get_db

router = APIRouter(prefix="/teacher", tags=["teacher"])

@router.post("/quiz/generate")
async def generate_quiz_endpoint(request: dict, db: Session = Depends(get_db)):
    topic = request.get("topic")
    difficulty = request.get("difficulty", "medium")
    num_questions = request.get("num_questions", 5)
    quiz = generate_quiz(topic, difficulty, num_questions, preview=False)
    return {"status": "saved", "quiz": quiz}

@router.post("/quiz/preview")
async def preview_quiz_endpoint(request: dict):
    topic = request.get("topic")
    difficulty = request.get("difficulty", "medium")
    num_questions = request.get("num_questions", 5)
    quiz = generate_quiz(topic, difficulty, num_questions, preview=True)
    return quiz
