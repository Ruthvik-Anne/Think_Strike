from auth import require_role, get_current_user
from fastapi import APIRouter, Depends, HTTPException
from typing import List, Dict, Any
from database import get_database
from bson import ObjectId
from pydantic import BaseModel, Field
import logging
from ai.tf_model import generate_quiz, explain_answers

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/quizzes", tags=["quizzes"])

# Pydantic models for request/response
class QuizCreate(BaseModel):
    title: str
    description: str
    difficulty: str = "Easy"
    time: int = 10
    questions: int = 5

class QuizOut(BaseModel):
    id: str = Field(alias="_id")
    title: str
    description: str
    difficulty: str
    time: int
    questions: int

@router.get("/", response_model=List[QuizOut])
async def list_quizzes(db=Depends(get_database)):
    coll = db["quizzes"]
    docs = await coll.find().to_list(200)
    # Normalize docs to match QuizOut (questions stored as list length)
    out = []
    for d in docs:
        out.append({
            "_id": str(d.get("_id")),
            "title": d.get("title"),
            "description": d.get("description"),
            "difficulty": d.get("difficulty"),
            "time": d.get("time"),
            "questions": len(d.get("questions", [])) if isinstance(d.get("questions", []), list) else d.get("questions", 0)
        })
    return out

@router.get("/{quiz_id}", response_model=Dict[str, Any])
async def get_quiz(quiz_id: str, db=Depends(get_database)):
    coll = db["quizzes"]
    doc = await coll.find_one({"_id": ObjectId(quiz_id)})
    if not doc:
        raise HTTPException(status_code=404, detail="Quiz not found")
    # Ensure questions have id fields
    for idx, q in enumerate(doc.get("questions", [])):
        if "id" not in q:
            q["id"] = f"q{idx+1}"
    doc["_id"] = str(doc["_id"])
    return doc

@router.post("/", response_model=Dict[str, Any])
async def create_quiz(payload: QuizCreate, db=Depends(get_database), current_user=Depends(require_role('teacher'))):
    coll = db["quizzes"]
    # Create simple questions array placeholder
    qlist = []
    for i in range(payload.questions):
        qlist.append({
            "id": f"q{i+1}",
            "question": f"Question {i+1} for {payload.title}",
            "options": ["A","B","C","D"],
            "answer": "A"
        })
    doc = {
        "title": payload.title,
        "description": payload.description,
        "difficulty": payload.difficulty,
        "time": payload.time,
        "questions": qlist
    }
    res = await coll.insert_one(doc)
    doc["_id"] = str(res.inserted_id)
    return doc

@router.post("/{quiz_id}/submit")
async def submit_quiz(quiz_id: str, answers: Dict[str, str], db=Depends(get_database), current_user=Depends(get_current_user)):
    coll = db["quizzes"]
    doc = await coll.find_one({"_id": ObjectId(quiz_id)})
    if not doc:
        raise HTTPException(status_code=404, detail="Quiz not found")
    feedback = explain_answers(doc, answers)
    # Save results
    results_coll = db["results"]
    result_doc = {
        "quiz_id": quiz_id,
        "answers": answers,
        "score": feedback["score"],
        "total": feedback["total"],
    }
    await results_coll.insert_one(result_doc)
    return feedback

# AI generation endpoint — uses tf_model.generate_quiz
class GenerateRequest(BaseModel):
    topic: str
    difficulty: str = "medium"
    num_questions: int = 5

@router.post("/generate", response_model=Dict[str, Any])
async def generate_endpoint(req: GenerateRequest, current_user=Depends(require_role('teacher'))):
    quiz = generate_quiz(req.topic, req.difficulty, req.num_questions, preview=False)
    return quiz
