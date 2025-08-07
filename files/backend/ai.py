"""
Very small demo using TF-IDF to pick keywords and turn them into MCQs.
Replace with real NLP later.
"""
from sklearn.feature_extraction.text import TfidfVectorizer
import random, json

def generate_mcq(source_text: str, n: int = 3) -> list[dict]:
    vect = TfidfVectorizer(stop_words="english").fit([source_text])
    words = vect.get_feature_names_out()
    questions = []
    for _ in range(n):
        keyword = random.choice(words)
        q = {
            "text": f"What is related to '{keyword}'?",
            "choices": ["Option A", "Option B", keyword, "Option D"],
            "correct_index": 2
        }
        questions.append(q)
    return questions