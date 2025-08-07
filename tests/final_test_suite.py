"""
ThinkStrike - Final Test Suite
Created: 2025-08-07 15:35:50
Author: Ruthvik-Anne
"""

import pytest
import json
from fastapi.testclient import TestClient
from sqlmodel import Session, SQLModel
from datetime import datetime
from main import app
from database import get_session

client = TestClient(app)

class TestRelease:
    def test_quiz_functionality(self):
        """Test core quiz features"""
        # Create quiz
        quiz_data = {
            "title": "Release Test Quiz",
            "questions": [
                {
                    "text": "Test question 1?",
                    "type": "mcq",
                    "choices": ["A", "B", "C", "D"],
                    "correct_index": 0
                }
            ]
        }
        response = client.post("/api/quizzes/create", json=quiz_data)
        assert response.status_code == 200
        quiz_id = response.json()["id"]

        # Take quiz
        answers = [{"question_id": 1, "answer": 0}]
        response = client.post(f"/api/quizzes/{quiz_id}/submit", json={"answers": answers})
        assert response.status_code == 200

    def test_offline_sync(self):
        """Test offline functionality"""
        offline_data = {
            "quizzes": [
                {
                    "id": 1,
                    "answers": [0, 1, 2],
                    "timestamp": "2025-08-07T15:35:50Z"
                }
            ]
        }
        response = client.post("/api/sync", json=offline_data)
        assert response.status_code == 200

    def test_reporting_system(self):
        """Test automated reporting"""
        report_data = {
            "question_id": 1,
            "report_type": "unclear",
            "student_id": 1
        }
        response = client.post("/api/reports/create", json=report_data)
        assert response.status_code == 200

    def test_performance(self):
        """Test system performance"""
        import time
        start_time = time.time()
        response = client.get("/api/quizzes")
        end_time = time.time()
        assert (end_time - start_time) < 1.0  # Response under 1 second

def run_release_tests():
    """Run all release tests and generate report"""
    test_suite = TestRelease()
    results = {
        "timestamp": "2025-08-07 15:35:50",
        "tests": []
    }

    tests = [
        test_suite.test_quiz_functionality,
        test_suite.test_offline_sync,
        test_suite.test_reporting_system,
        test_suite.test_performance
    ]

    for test in tests:
        try:
            test()
            results["tests"].append({
                "name": test.__name__,
                "status": "PASS",
                "timestamp": datetime.utcnow().isoformat()
            })
        except Exception as e:
            results["tests"].append({
                "name": test.__name__,
                "status": "FAIL",
                "error": str(e),
                "timestamp": datetime.utcnow().isoformat()
            })

    return results

if __name__ == "__main__":
    results = run_release_tests()
    print(json.dumps(results, indent=2))