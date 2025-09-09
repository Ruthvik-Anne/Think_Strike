from typing import List, Dict, Any
import random

def generate_quiz(topic: str, difficulty: str = "medium", num_questions: int = 5, preview: bool = False) -> Dict[str, Any]:
    topic_t = (topic or "General Knowledge").strip().title()
    n = max(1, min(int(num_questions or 5), 20))

    questions = []
    for i in range(n):
        opts = [f"{topic_t} Term A{i+1}", f"{topic_t} Term B{i+1}", f"{topic_t} Term C{i+1}", f"{topic_t} Term D{i+1}"]
        answer_index = i % 4
        questions.append({
            "question": f"{topic_t}: What is key concept #{i+1}?",
            "options": opts,
            "answer_index": answer_index,
            "explanation": f"In {topic_t}, concept #{i+1} relates to {difficulty} principles."
        })

    quiz = {
        "title": f"{topic_t} {difficulty.capitalize()} Quiz",
        "topic": topic_t,
        "difficulty": difficulty,
        "questions": questions
    }
    if preview:
        # reduce payload for preview
        quiz["questions"] = questions[: min(3, len(questions))]
    return quiz

def explain_answers(quiz: Dict[str, Any], answers: List[int]) -> Dict[str, Any]:
    correct = 0
    mistakes = []
    for idx, q in enumerate(quiz.get("questions", [])):
        expected = int(q.get("answer_index", 0))
        given = int(answers[idx]) if idx < len(answers) else -1
        if given == expected:
            correct += 1
        else:
            mistakes.append({
                "index": idx,
                "correct_index": expected,
                "given": given,
                "explanation": q.get("explanation") or "Review the concept and try again."
            })
    return {
        "score": correct,
        "total": len(quiz.get("questions", [])),
        "mistakes": mistakes,
        "summary": f"Scored {correct}/{len(quiz.get('questions', []))}"
    }
