"""
SQLite database helper (SQLModel on top of SQLAlchemy).
"""
from sqlmodel import SQLModel, create_engine, Session

engine = create_engine("sqlite:///thinkstrike.db", echo=False)

def init_db() -> None:
    from models import User, Quiz, Question, Attempt  # ensure tables are imported
    SQLModel.metadata.create_all(engine)

def get_session() -> Session:
    return Session(engine)