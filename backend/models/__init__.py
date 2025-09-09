from . import quiz
from pydantic import BaseModel, Field, EmailStr
from typing import List, Optional

class TokenOut(BaseModel):
    access_token: str
    token_type: str = "bearer"
    role: str
    id: str

class LoginReq(BaseModel):
    email: EmailStr
    password: str

class UserCreate(BaseModel):
    email: EmailStr
    password: str
    role: str

class UserOut(BaseModel):
    id: str
    email: EmailStr
    role: str

class UserUpdate(BaseModel):
    email: Optional[EmailStr] = None
    password: Optional[str] = None
    role: Optional[str] = None

class Question(BaseModel):
    question: str
    options: List[str]
    answer_index: int
    explanation: str = ""

class QuizGenerateReq(BaseModel):
    topic: str
    difficulty: str = "medium"
    num_questions: int = 5

class QuizOut(BaseModel):
    id: str
    title: str
    topic: str
    difficulty: str
    questions: List[Question]
