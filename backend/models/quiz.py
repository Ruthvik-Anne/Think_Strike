from pydantic import BaseModel, Field
from typing import Optional
from bson import ObjectId

class PyObjectId(str):
    @classmethod
    def __get_validators__(cls):
        yield cls.validate

    @classmethod
    def validate(cls, v):
        if isinstance(v, ObjectId):
            return str(v)
        if isinstance(v, str):
            return v
        raise TypeError('ObjectId required')

class QuizModel(BaseModel):
    id: Optional[PyObjectId] = Field(default=None, alias="_id")
    title: str
    description: str
    difficulty: str  # Easy/Medium/Hard
    time: int        # minutes
    questions: int

    class Config:
        allow_population_by_field_name = True
        json_encoders = {ObjectId: str}
