"""
ThinkStrike - Advanced AI Question Generator
Created: 2025-08-07
Author: Ruthvik-Anne
"""

from transformers import pipeline
from sklearn.feature_extraction.text import TfidfVectorizer
from typing import List, Dict
import spacy
import numpy as np

class QuestionGenerator:
    def __init__(self):
        self.nlp = spacy.load("en_core_web_sm")
        self.question_generator = pipeline("text2text-generation", model="t5-base")
        self.tfidf = TfidfVectorizer(stop_words="english")
        
    def generate_questions(
        self,
        text: str,
        num_questions: int = 5,
        difficulty: str = "medium",
        question_types: List[str] = ["mcq", "true_false", "short_answer"]
    ) -> List[Dict]:
        """
        Generate questions from text with specified difficulty and types.
        
        Args:
            text (str): Source text
            num_questions (int): Number of questions to generate
            difficulty (str): easy/medium/hard
            question_types (List[str]): Types of questions to generate
            
        Returns:
            List[Dict]: Generated questions with metadata
        """
        # Process text
        doc = self.nlp(text)
        
        # Extract key concepts based on difficulty
        concepts = self._extract_concepts(doc, difficulty)
        
        # Generate questions
        questions = []
        for concept in concepts[:num_questions]:
            # Choose question type
            q_type = np.random.choice(question_types)
            
            if q_type == "mcq":
                question = self._generate_mcq(concept, difficulty)
            elif q_type == "true_false":
                question = self._generate_true_false(concept)
            else:
                question = self._generate_short_answer(concept, difficulty)
                
            questions.append(question)
            
        return questions
    
    def _extract_concepts(self, doc, difficulty):
        """Extract key concepts based on difficulty level"""
        concepts = []
        
        if difficulty == "easy":
            # Focus on main subjects and basic facts
            concepts = [sent for sent in doc.sents if len(sent.text.split()) < 15]
        elif difficulty == "medium":
            # Include relationships and definitions
            concepts = [ent.sent for ent in doc.ents if ent.label_ in ["CONCEPT", "TERM"]]
        else:  # hard
            # Complex relationships and advanced concepts
            concepts = [sent for sent in doc.sents if len(sent.text.split()) > 20]
            
        return concepts
    
    def _generate_mcq(self, concept, difficulty):
        """Generate MCQ with distractors"""
        # Generate question
        question = self.question_generator(concept.text)[0]["generated_text"]
        
        # Generate correct answer
        correct_answer = self._generate_answer(concept)
        
        # Generate distractors based on difficulty
        distractors = self._generate_distractors(correct_answer, difficulty)
        
        return {
            "type": "mcq",
            "question": question,
            "choices": [correct_answer] + distractors,
            "correct_index": 0,
            "difficulty": difficulty,
            "explanation": self._generate_explanation(concept, correct_answer)
        }
    
    def _generate_true_false(self, concept):
        """Generate true/false question"""
        is_true = np.random.choice([True, False])
        if is_true:
            question = concept.text
        else:
            # Modify the concept to make it false
            question = self._modify_statement(concept.text)
            
        return {
            "type": "true_false",
            "question": question,
            "correct_answer": is_true,
            "explanation": self._generate_explanation(concept, str(is_true))
        }
    
    def _generate_short_answer(self, concept, difficulty):
        """Generate short answer question"""
        question = self.question_generator(concept.text)[0]["generated_text"]
        
        return {
            "type": "short_answer",
            "question": question,
            "sample_answer": self._generate_answer(concept),
            "keywords": self._extract_keywords(concept, difficulty),
            "explanation": self._generate_explanation(concept, "")
        }
    
    def _generate_distractors(self, correct_answer, difficulty):
        """Generate misleading but plausible wrong answers"""
        # Implementation based on difficulty level
        pass
    
    def _generate_explanation(self, concept, answer):
        """Generate detailed explanation for the answer"""
        # Implementation for answer explanation
        pass
    
    def _modify_statement(self, text):
        """Modify a true statement to make it false"""
        # Implementation for statement modification
        pass
    
    def _extract_keywords(self, concept, difficulty):
        """Extract relevant keywords based on difficulty"""
        # Implementation for keyword extraction
        pass