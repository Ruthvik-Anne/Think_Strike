from fastapi import APIRouter, Depends, HTTPException
from typing import List
from models import QuizGenerateReq, QuizOut, Question
from deps import get_current_user
from bson import ObjectId
import json, os

router = APIRouter(prefix="/quizzes", tags=["quizzes"])

# Optional TensorFlow import
_tf = None
_model = None

def _try_load_tf():
    global _tf
    if _tf is not None:
        return _tf
    try:
        import tensorflow as tf  # type: ignore
        _tf = tf
    except Exception:
        _tf = None
    return _tf

def _try_load_model():
    global _model
    if _model is not None:
        return _model
    tf = _try_load_tf()
    if tf is None:
        return None
    model_path = os.path.join(os.path.dirname(__file__), "tf_model")
    if os.path.isdir(model_path) and os.path.exists(os.path.join(model_path, "saved_model.pb")):
        try:
            _model = tf.saved_model.load(model_path)
        except Exception:
            _model = None
    return _model

def _fallback_generate(topic: str, difficulty: str, num: int):
    topic_t = topic.strip().title() or "General Knowledge"
    n = max(1, min(num or 10, 20))
    qs = []
    for i in range(n):
        qs.append({
            "question": f"{topic_t}: What is key concept #{i+1}?",
            "options": [f"{topic_t} term A{i+1}", f"{topic_t} term B{i+1}", f"{topic_t} term C{i+1}", f"{topic_t} term D{i+1}"],
            "answer_index": i % 4,
            "explanation": f"In {topic_t}, concept #{i+1} relates to {difficulty} principles."
        })
    return {
        "title": f"{topic_t} {difficulty.capitalize()} Quiz",
        "topic": topic,
        "difficulty": difficulty,
        "questions": qs
    }

@router.post("/generate", response_model=QuizOut)
async def generate_quiz(req: QuizGenerateReq, user=Depends(get_current_user)):
    topic = req.topic or "General Knowledge"
    difficulty = (req.difficulty or "medium").lower()
    num = int(req.num_questions or 10)

    model = _try_load_model()
    if model is not None:
        try:
            out_json = model.generate(topic, difficulty, num).numpy().decode("utf-8")  # type: ignore[attr-defined]
            data = json.loads(out_json)
        except Exception as e:
            # fall back on any TF runtime error
            data = _fallback_generate(topic, difficulty, num)
    else:
        data = _fallback_generate(topic, difficulty, num)

    qs: List[Question] = []
    for q in data.get("questions", []):
        qs.append(Question(
            question=q.get("question", ""),
            options=(q.get("options") or ["A","B","C","D"])[:4],
            answer_index=int(q.get("answer_index", 0)),
            explanation=q.get("explanation", "")
        ))
    return QuizOut(
        id=str(ObjectId()),
        title=data.get("title", f"{topic} Quiz"),
        topic=data.get("topic", topic),
        difficulty=data.get("difficulty", difficulty),
        questions=qs
    )
