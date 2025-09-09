from fastapi import APIRouter, Depends
from database import get_database
from models import User
from typing import List

router = APIRouter()

@router.get("/users", response_model=List[User])
async def list_users(db=Depends(get_database)):
    users_collection = db["users"]
    users = await users_collection.find({}).to_list(length=100)
    return [User(**user) for user in users]