from fastapi import APIRouter, Depends, HTTPException
from database import get_database
from models import QuizSubmissionRequest, QuizResult
from bson import ObjectId

router = APIRouter(tags=["student"])

@router.post("/quiz/submit/{quiz_id}")
async def submit_quiz(quiz_id: str, request: QuizSubmissionRequest, db=Depends(get_database)):
    # Get the quiz to calculate score
    quizzes_collection = db["quizzes"]
    quiz = await quizzes_collection.find_one({"quiz_id": quiz_id})
    if not quiz:
        raise HTTPException(status_code=404, detail="Quiz not found")
    # simple scoring: compare answers by question index/key
    questions = quiz.get("questions", [])
    correct_answers = {q.get("id", str(idx)): q.get("answer") for idx, q in enumerate(questions)}
    score = 0
    mistakes = []
    for qid, answer in request.answers.items():
        correct = correct_answers.get(qid)
        if correct is None:
            continue
        if answer == correct:
            score += 1
        else:
            mistakes.append({"question_id": qid, "expected": correct, "given": answer})
    result = {
        "quiz_id": quiz_id,
        "student_id": request.student_id,
        "score": score,
        "mistakes": mistakes
    }
    results_collection = db["results"]
    await results_collection.insert_one(result)
    return {"status": "submitted", "report": result}
