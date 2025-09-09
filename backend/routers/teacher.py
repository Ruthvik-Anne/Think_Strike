from fastapi import APIRouter, Depends, HTTPException
from database import get_database
from models import QuizGenerationRequest, Quiz
from ai.quiz_generator import generate_quiz
import uuid

router = APIRouter(tags=["teacher"])

@router.post("/quiz/generate", response_model=Quiz)
async def generate_quiz_endpoint(request: QuizGenerationRequest, db=Depends(get_database)):
    # Generate quiz using AI (synchronous helper)
    quiz_data = generate_quiz(request.topic, request.difficulty, request.num_questions, preview=False)
    
    # Create quiz document for MongoDB
    quiz_id = str(uuid.uuid4())
    quiz_doc = {
        "quiz_id": quiz_id,
        "topic": request.topic,
        "difficulty": request.difficulty,
        "questions": quiz_data.get("questions", [])
    }
    quizzes_collection = db["quizzes"]
    await quizzes_collection.insert_one(quiz_doc)
    # return the saved quiz (matching the Pydantic model)
    return Quiz(**quiz_doc)
