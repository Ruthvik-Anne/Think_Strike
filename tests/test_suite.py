"""
ThinkStrike - Comprehensive Test Suite
Created: 2025-08-07 15:28:09
Author: Ruthvik-Anne
"""

import pytest
from fastapi.testclient import TestClient
from sqlmodel import Session, SQLModel, create_engine
from sqlalchemy.pool import StaticPool
import json
import os
from datetime import datetime

from main import app
from models import User, Quiz, Question, Attempt
from database import get_session

# Test database setup
SQLALCHEMY_DATABASE_URL = "sqlite://"

engine = create_engine(
    SQLALCHEMY_DATABASE_URL,
    connect_args={"check_same_thread": False},
    poolclass=StaticPool,
)

def override_get_session():
    session = Session(engine)
    try:
        yield session
    finally:
        session.close()

app.dependency_overrides[get_session] = override_get_session

# Create test client
client = TestClient(app)

@pytest.fixture(autouse=True)
def setup_database():
    SQLModel.metadata.create_all(engine)
    yield
    SQLModel.metadata.drop_all(engine)

class TestAuthentication:
    def test_user_login(self):
        # Create test user
        response = client.post(
            "/api/admin/users",
            json={
                "roll_number": "12345",
                "name": "Test User",
                "password": "testpass123",
                "role": "student"
            }
        )
        assert response.status_code == 200

        # Test login
        response = client.post(
            "/api/auth/login",
            json={
                "roll_number": "12345",
                "password": "testpass123"
            }
        )
        assert response.status_code == 200
        assert "access_token" in response.json()

    def test_invalid_login(self):
        response = client.post(
            "/api/auth/login",
            json={
                "roll_number": "99999",
                "password": "wrongpass"
            }
        )
        assert response.status_code == 401

class TestQuizManagement:
    @pytest.fixture
    def auth_headers(self):
        # Create and login as teacher
        client.post(
            "/api/admin/users",
            json={
                "roll_number": "teacher1",
                "name": "Test Teacher",
                "password": "teacherpass",
                "role": "teacher"
            }
        )
        response = client.post(
            "/api/auth/login",
            json={
                "roll_number": "teacher1",
                "password": "teacherpass"
            }
        )
        token = response.json()["access_token"]
        return {"Authorization": f"Bearer {token}"}

    def test_create_quiz(self, auth_headers):
        response = client.post(
            "/api/teacher/quiz",
            headers=auth_headers,
            json={
                "title": "Test Quiz",
                "questions": [
                    {
                        "text": "Test question?",
                        "type": "mcq",
                        "choices": ["A", "B", "C", "D"],
                        "correct_index": 0,
                        "difficulty": "medium"
                    }
                ]
            }
        )
        assert response.status_code == 200
        assert "id" in response.json()

    def test_quiz_reordering(self, auth_headers):
        # Create quiz first
        quiz_response = client.post(
            "/api/teacher/quiz",
            headers=auth_headers,
            json={
                "title": "Reorder Test",
                "questions": [
                    {"text": "Q1", "type": "mcq", "choices": ["A", "B"], "correct_index": 0},
                    {"text": "Q2", "type": "mcq", "choices": ["A", "B"], "correct_index": 1}
                ]
            }
        )
        quiz_id = quiz_response.json()["id"]

        # Test reordering
        response = client.put(
            f"/api/teacher/quiz/{quiz_id}/reorder",
            headers=auth_headers,
            json={
                "question_order": [2, 1]
            }
        )
        assert response.status_code == 200

class TestOfflineSync:
    def test_sync_mechanism(self, auth_headers):
        # Create offline changes
        changes = {
            "timestamp": "2025-08-07T15:28:09Z",
            "changes": [
                {
                    "type": "quiz_update",
                    "data": {
                        "quiz_id": 1,
                        "questions": [
                            {"text": "Updated Q1", "type": "mcq"}
                        ]
                    }
                }
            ]
        }

        response = client.post(
            "/api/sync",
            headers=auth_headers,
            json=changes
        )
        assert response.status_code == 200
        assert "synced" in response.json()

class TestAIFeatures:
    def test_question_generation(self, auth_headers):
        response = client.post(
            "/api/ai/generate",
            headers=auth_headers,
            json={
                "text": "The quick brown fox jumps over the lazy dog.",
                "num_questions": 2,
                "difficulty": "medium"
            }
        )
        assert response.status_code == 200
        questions = response.json()
        assert len(questions) == 2
        assert all("explanation" in q for q in questions)

    def test_answer_explanation(self, auth_headers):
        response = client.get(
            "/api/quiz/explanation/1",
            headers=auth_headers
        )
        assert response.status_code == 200
        assert "explanation" in response.json()
        assert "concepts" in response.json()

class TestPerformance:
    @pytest.mark.benchmark
    def test_quiz_load_performance(self, benchmark):
        def load_quiz():
            return client.get("/api/quiz/1")
        
        result = benchmark(load_quiz)
        assert result.status_code == 200
        assert result.elapsed.total_seconds() < 0.5

class TestSecurity:
    def test_sql_injection_prevention(self):
        response = client.post(
            "/api/auth/login",
            json={
                "roll_number": "' OR '1'='1",
                "password": "' OR '1'='1"
            }
        )
        assert response.status_code == 401

    def test_xss_prevention(self, auth_headers):
        response = client.post(
            "/api/teacher/quiz",
            headers=auth_headers,
            json={
                "title": "<script>alert('xss')</script>",
                "questions": []
            }
        )
        assert response.status_code == 200
        assert "<script>" not in response.json()["title"]
