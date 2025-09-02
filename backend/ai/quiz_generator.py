def generate_quiz(topic: str, difficulty: str = "medium", num_questions: int = 5, preview: bool = False):
    """
    Generate quiz questions based on topic and difficulty.
    - preview=True → return quiz but do not save to DB.
    """
    questions = []
    for i in range(num_questions):
        questions.append({
            "question": f"Sample {difficulty} question {i+1} on {topic}",
            "options": ["Option A", "Option B", "Option C", "Option D"],
            "answer": "Option A",
        })

    if preview:
        return {"preview": True, "topic": topic, "difficulty": difficulty, "questions": questions}
    return {"preview": False, "topic": topic, "difficulty": difficulty, "questions": questions}
