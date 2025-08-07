"""
ThinkStrike - Load Testing Suite
Created: 2025-08-07 15:28:09
Author: Ruthvik-Anne
"""

import locust
from locust import HttpUser, task, between
import random
import json

class QuizUser(HttpUser):
    wait_time = between(1, 3)
    
    def on_start(self):
        # Login
        response = self.client.post("/api/auth/login", json={
            "roll_number": "test_user",
            "password": "test_pass"
        })
        self.token = response.json()["access_token"]
        self.headers = {"Authorization": f"Bearer {self.token}"}

    @task(3)
    def view_quiz(self):
        quiz_id = random.randint(1, 10)
        self.client.get(f"/api/quiz/{quiz_id}", headers=self.headers)

    @task(2)
    def create_quiz(self):
        quiz_data = {
            "title": f"Test Quiz {random.randint(1, 1000)}",
            "questions": [
                {
                    "text": f"Question {i}?",
                    "type": "mcq",
                    "choices": ["A", "B", "C", "D"],
                    "correct_index": random.randint(0, 3)
                } for i in range(5)
            ]
        }
        self.client.post("/api/teacher/quiz", json=quiz_data, headers=self.headers)

    @task(1)
    def generate_questions(self):
        self.client.post(
            "/api/ai/generate",
            json={
                "text": "Sample text for question generation",
                "num_questions": 3,
                "difficulty": "medium"
            },
            headers=self.headers
        )

class AdminUser(HttpUser):
    wait_time = between(2, 5)

    def on_start(self):
        # Login as admin
        response = self.client.post("/api/auth/login", json={
            "roll_number": "admin",
            "password": "admin_pass"
        })
        self.token = response.json()["access_token"]
        self.headers = {"Authorization": f"Bearer {self.token}"}

    @task
    def manage_users(self):
        # Create user
        self.client.post(
            "/api/admin/users",
            json={
                "roll_number": f"user_{random.randint(1000, 9999)}",
                "name": "Test User",
                "role": "student"
            },
            headers=self.headers
        )

        # Get users list
        self.client.get("/api/admin/users", headers=self.headers)

if __name__ == "__main__":
    # Run with: locust -f load_test.py --host=http://localhost:8000
    pass