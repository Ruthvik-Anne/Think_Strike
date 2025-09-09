from fastapi import APIRouter, Depends, HTTPException
from database import get_database
from typing import List
from bson import ObjectId
from auth import require_role, get_current_user

router = APIRouter(tags=["users"])

@router.get("/users", response_model=List[dict])
async def list_users(db=Depends(get_database), current_user=Depends(require_role("admin"))):
    coll = db["users"]
    docs = await coll.find().to_list(200)
    out = []
    for d in docs:
        out.append({"_id": str(d["_id"]), "username": d.get("username"), "role": d.get("role")})
    return out

@router.delete("/users/{user_id}")
async def delete_user(user_id: str, db=Depends(get_database), current_user=Depends(require_role("admin"))):
    coll = db["users"]
    res = await coll.delete_one({"_id": ObjectId(user_id)})
    if res.deleted_count == 0:
        raise HTTPException(status_code=404, detail="User not found")
    return {"status": "deleted"}
