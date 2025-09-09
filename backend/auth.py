from fastapi import APIRouter, HTTPException, Depends, status
from db import users_col
from security import verify_password, hash_password, create_access_token
from models import LoginReq, TokenOut, UserCreate, UserOut
from bson import ObjectId
from deps import get_current_user, require_admin

router = APIRouter(prefix="/auth", tags=["auth"])

@router.post("/login", response_model=TokenOut)
async def login(req: LoginReq):
    user = await users_col.find_one({"email": req.email})
    if not user or not verify_password(req.password, user["password"]):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid credentials")
    uid = str(user["_id"])
    token = create_access_token(uid)
    return {"access_token": token, "role": user.get("role","student"), "id": uid, "token_type":"bearer"}

@router.get("/me")
async def me(user=Depends(get_current_user)):
    return {"id": str(user["_id"]), "email": user["email"], "role": user.get("role","student")}

@router.post("/register", response_model=UserOut, dependencies=[Depends(require_admin)])
async def register(req: UserCreate):
    existing = await users_col.find_one({"email": req.email})
    if existing:
        raise HTTPException(409, "Email already exists")
    doc = {"email": req.email, "password": hash_password(req.password), "role": req.role}
    res = await users_col.insert_one(doc)
    return {"id": str(res.inserted_id), "email": req.email, "role": req.role}
