from fastapi import APIRouter, Depends, HTTPException
from typing import List, Optional
from bson import ObjectId
from db import users_col
from deps import require_admin
from models import UserCreate, UserOut, UserUpdate

router = APIRouter(prefix="/admin", tags=["admin"], dependencies=[Depends(require_admin)])

@router.get("/users", response_model=List[UserOut])
async def list_users(role: Optional[str] = None, q: Optional[str] = None, skip: int = 0, limit: int = 100):
    filt = {}
    if role: filt["role"] = role
    if q: filt["email"] = {"$regex": q, "$options": "i"}
    cursor = users_col.find(filt).skip(skip).limit(min(limit, 200))
    out = []
    async for u in cursor:
        out.append({"id": str(u["_id"]), "email": u["email"], "role": u.get("role","student")})
    return out

@router.post("/users", response_model=UserOut)
async def create_user(req: UserCreate):
    exists = await users_col.find_one({"email": req.email})
    if exists: raise HTTPException(409, "Email already exists")
    from security import hash_password
    res = await users_col.insert_one({"email": req.email, "password": hash_password(req.password), "role": req.role})
    return {"id": str(res.inserted_id), "email": req.email, "role": req.role}

@router.put("/users/{user_id}", response_model=UserOut)
async def update_user(user_id: str, req: UserUpdate):
    update = {}
    if req.email is not None: update["email"] = req.email
    if req.role is not None: update["role"] = req.role
    if req.password: 
        from security import hash_password
        update["password"] = hash_password(req.password)
    if not update: raise HTTPException(400, "No fields to update")
    res = await users_col.update_one({"_id": ObjectId(user_id)}, {"$set": update})
    if res.matched_count == 0: raise HTTPException(404, "User not found")
    u = await users_col.find_one({"_id": ObjectId(user_id)})
    return {"id": str(u["_id"]), "email": u["email"], "role": u.get("role","student")}

@router.delete("/users/{user_id}")
async def delete_user(user_id: str):
    res = await users_col.delete_one({"_id": ObjectId(user_id)})
    if res.deleted_count == 0: raise HTTPException(404, "User not found")
    return {"status": "deleted"}
