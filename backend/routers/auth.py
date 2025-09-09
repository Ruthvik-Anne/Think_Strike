from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel, Field
from database import get_database
from auth_utils import hash_password, verify_password, create_access_token, decode_token, decode_token_allow_expired
from typing import Optional
from fastapi.security import OAuth2PasswordBearer
from bson import ObjectId

router = APIRouter(tags=["auth"])

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="auth/login")

class RegisterRequest(BaseModel):
    username: str
    password: str
    role: str = "student"  # student, teacher, admin

class LoginRequest(BaseModel):
    username: str
    password: str

async def get_current_user(token: str = Depends(oauth2_scheme), db=Depends(get_database)):
    payload = decode_token(token)
    if not payload:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid auth token")
    username = payload.get("sub")
    if not username:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid token payload")
    user = await db["users"].find_one({"username": username})
    if not user:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="User not found")
    user["_id"] = str(user["_id"])
    return user

def require_role(required: str):
    async def role_dep(user = Depends(get_current_user)):
        if user.get("role") != required and user.get("role") != "admin":
            raise HTTPException(status_code=403, detail="Insufficient role")
        return user
    return role_dep

@router.post("/auth/register", status_code=201)
async def register(req: RegisterRequest, current_user=Depends(require_role("admin")), db=Depends(get_database)):
    # Admin-only registration
    coll = db["users"]
    existing = await coll.find_one({"username": req.username})
    if existing:
        raise HTTPException(status_code=400, detail="Username already exists")
    hashed = hash_password(req.password)
    doc = {"username": req.username, "password_hash": hashed, "role": req.role}
    res = await coll.insert_one(doc)
    doc["_id"] = str(res.inserted_id)
    return {"username": req.username, "role": req.role, "_id": doc["_id"]}

@router.post("/auth/login")
async def login(req: LoginRequest, db=Depends(get_database)):
    coll = db["users"]
    user = await coll.find_one({"username": req.username})
    if not user:
        raise HTTPException(status_code=400, detail="Invalid credentials")
    if not verify_password(req.password, user.get("password_hash","")):
        raise HTTPException(status_code=400, detail="Invalid credentials")
    token = create_access_token({"sub": user["username"], "role": user.get("role", "student")})
    return {"access_token": token, "token_type": "bearer", "role": user.get("role","student"), "username": user["username"], "_id": str(user["_id"])}

class RefreshRequest(BaseModel):
    token: str

@router.post("/auth/refresh")
async def refresh(req: RefreshRequest):
    # Accept an expired token and issue a new access token (stateless refresh)
    payload = decode_token_allow_expired(req.token)
    if not payload or "sub" not in payload:
        raise HTTPException(status_code=401, detail="Invalid token")
    username = payload["sub"]
    role = payload.get("role", "student")
    new_token = create_access_token({"sub": username, "role": role})
    return {"access_token": new_token, "token_type": "bearer", "role": role, "username": username}
