// ThinkStrike Quiz Creator JavaScript

document.addEventListener('DOMContentLoaded', function() {
    // Initialize Quill editor
    const quill = new Quill('#editor', {
        theme: 'snow',
        modules: {
            toolbar: [
                [{ 'header': [1, 2, 3, false] }],
                ['bold', 'italic', 'underline'],
                [{ 'list': 'ordered'}, { 'list': 'bullet' }],
                ['clean']
            ]
        }
    });

    // Elements
    const generateBtn = document.getElementById('generateBtn');
    const saveQuizBtn = document.getElementById('saveQuizBtn');
    const questionsList = document.getElementById('questionsList');
    const difficultySelect = document.getElementById('difficultyLevel');
    const numQuestionsInput = document.getElementById('numQuestions');
    
    // Question type checkboxes
    const questionTypes = document.querySelectorAll('input[type="checkbox"]');

    // Event Listeners
    generateBtn.addEventListener('click', handleGeneration);
    saveQuizBtn.addEventListener('click', handleSave);

    async function handleGeneration() {
        // Show loading state
        generateBtn.disabled = true;
        generateBtn.innerHTML = '<span class="spinner-border spinner-border-sm"></span> Generating...';

        try {
            // Get selected question types
            const selectedTypes = Array.from(questionTypes)
                .filter(cb => cb.checked)
                .map(cb => cb.value);

            // Prepare request data
            const data = {
                text: quill.root.innerHTML,
                num_questions: parseInt(numQuestionsInput.value),
                difficulty: difficultySelect.value,
                question_types: selectedTypes
            };

            // Call AI API
            const response = await fetch('/api/ai/generate', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(data)
            });

            if (response.ok) {
                const questions = await response.json();
                renderQuestions(questions);
                showAlert('Questions generated successfully!', 'success');
            } else {
                throw new Error('Failed to generate questions');
            }
        } catch (error) {
            console.error('Error:', error);
            showAlert('Error generating questions', 'danger');
        } finally {
            // Reset button state
            generateBtn.disabled = false;
            generateBtn.innerHTML = '<i class="fas fa-magic"></i> Generate Questions';
        }
    }

    function renderQuestions(questions) {
        questionsList.innerHTML = questions.map((q, index) => `
            <div class="question-card" data-question-id="${index}">
                <div class="question-header">
                    <span class="difficulty-badge ${q.difficulty}">
                        ${q.difficulty.charAt(0).toUpperCase() + q.difficulty.slice(1)}
                    </span>
                    <div class="btn-group">
                        <button class="btn btn-sm btn-outline-primary edit-btn">
                            <i class="fas fa-edit"></i>
                        </button>
                        <button class="btn btn-sm btn-outline-danger delete-btn">
                            <i class="fas fa-trash"></i>
                        </button>
                    </div>
                </div>
                
                <div class="question-content">
                    <h6>Question ${index + 1}</h6>
                    <p>${q.question}</p>
                    
                    ${renderQuestionType(q)}
                    
                    <div class="explanation mt-2">
                        <small class="text-muted">
                            <i class="fas fa-info-circle"></i> ${q.explanation}
                        </small>
                    </div>
                </div>
            </div>
        `).join('');

        // Add event listeners to new elements
        addQuestionEventListeners();
    }

    function renderQuestionType(question) {
        switch (question.type) {
            case 'mcq':
                return `
                    <div class="choices">
                        ${question.choices.map((choice, i) => `
                            <div class="form-check">
                                <input class="form-check-input" type="radio" name="q${question.id}" 
                                    ${i === question.correct_index ? 'checked' : ''}>
                                <label class="form-check-label">${choice}</label>
                            </div>
                        `).join('')}
                    </div>
                `;
            
            case 'true_false':
                return `
                    <div class="btn-group" role="group">
                        <input type="radio" class="btn-check" name="q${question.id}" id="q${question.id}true" 
                            ${question.correct_answer ? 'checked' : ''}>
                        <label class="btn btn-outline-success" for="q${question.id}true">True</label>
                        
                        <input type="radio" class="btn-check" name="q${question.id}" id="q${question.id}false"
                            ${!question.correct_answer ? 'checked' : ''}>
                        <label class="btn btn-outline-danger" for="q${question.id}false">False</label>
                    </div>
                `;
            
            case 'short_answer':
                return `
                    <div class="short-answer">
                        <input type="text" class="form-control" placeholder="Type your answer here...">
                        <div class="mt-2">
                            <small class="text-muted">
                                <strong>Keywords:</strong> ${question.keywords.join(', ')}
                            </small>
                        </div>
                    </div>
                `;
        }
    }

    function addQuestionEventListeners() {
        // Edit buttons
        document.querySelectorAll('.edit-btn').forEach(btn => {
            btn.addEventListener('click', (e) => {
                const questionCard = e.target.closest('.question-card');
                editQuestion(questionCard.dataset.questionId);
            });
        });

        // Delete buttons
        document.querySelectorAll('.delete-btn').forEach(btn => {
            btn.addEventListener('click', (e) => {
                const questionCard = e.target.closest('.question-card');
                deleteQuestion(questionCard.dataset.questionId);
            });
        });
    }

    async function handleSave() {
        try {
            const questions = Array.from(document.querySelectorAll('.question-card'))
                .map(card => ({
                    id: card.dataset.questionId,
                    // Get other question data
                }));

            const response = await fetch('/api/teacher/quiz', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({
                    title: 'New Quiz',  // Add title input
                    questions: questions
                })
            });

            if (response.ok) {
                showAlert('Quiz saved successfully!', 'success');
            } else {
                throw new Error('Failed to save quiz');
            }
        } catch (error) {
            console.error('Error:', error);
            showAlert('Error saving quiz', 'danger');
        }
    }

    function editQuestion(questionId) {
        // Implement question editing
    }

    function deleteQuestion(questionId) {
        // Implement question deletion
    }

    function showAlert(message, type) {
        const alertDiv = document.createElement('div');
        alertDiv.className = `alert alert-${type} alert-dismissible fade show`;
        alertDiv.innerHTML = `
            ${message}
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        `;
        document.querySelector('.container').insertBefore(alertDiv, document.querySelector('.row'));
        setTimeout(() => alertDiv.remove(), 3000);
    }
});