from fastapi import APIRouter, Depends, HTTPException
from typing import Any, Dict, List
from bson import ObjectId
from db import results_col, quizzes_col
from deps import get_current_user

router = APIRouter(prefix="/analytics", tags=["analytics"])

@router.get("/teacher/{teacher_id}")
async def teacher_analytics(teacher_id: str, user=Depends(get_current_user)):
    # aggregate results by quiz for this teacher
    pipe = [
        {"$match": {"teacher_id": teacher_id}},
        {"$group": {"_id": "$quiz_id", "attempts": {"$sum": 1}, "avgScore": {"$avg": "$score"}, "total": {"$avg": "$total"}}},
        {"$limit": 100}
    ]
    agg = results_col.aggregate(pipe)
    items = []
    async for doc in agg:
        items.append({
            "quiz_id": doc["_id"],
            "attempts": int(doc.get("attempts",0)),
            "avg_score": float(doc.get("avgScore",0.0)),
            "avg_total": float(doc.get("total",0.0))
        })
    return {"teacher_id": teacher_id, "quizzes": items}

@router.get("/student/{student_id}")
async def student_analytics(student_id: str, user=Depends(get_current_user)):
    # last 50 attempts chronology
    cur = results_col.find({"student_id": student_id}).sort("created_at", 1).limit(50)
    series = []
    async for r in cur:
        series.append({
            "ts": r.get("created_at"),
            "score": r.get("score", 0),
            "total": r.get("total", 0),
            "topic": r.get("topic", "General")
        })
    return {"student_id": student_id, "history": series}
