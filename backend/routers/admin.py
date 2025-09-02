from fastapi import APIRouter

router = APIRouter()

users_db = [
    {"id": "t1", "role": "teacher"},
    {"id": "s1", "role": "student"},
    {"id": "a1", "role": "admin"}
]

@router.get("/users")
def list_users():
    return users_db