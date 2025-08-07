/**
 * ThinkStrike - Interactive Quiz Organizer
 * Created: 2025-08-07 15:26:08
 * Author: Ruthvik-Anne
 */

class QuizOrganizer {
    constructor(containerId) {
        this.container = document.getElementById(containerId);
        this.questions = [];
        this.currentQuiz = null;
        this.offlineStorage = new OfflineStorage('thinkstrike_quizzes');
        
        // Initialize Sortable.js
        this.initializeSortable();
        
        // Initialize offline capabilities
        this.initializeOfflineSupport();
    }

    initializeSortable() {
        new Sortable(this.container, {
            animation: 150,
            handle: '.drag-handle',
            ghostClass: 'question-ghost',
            chosenClass: 'question-chosen',
            dragClass: 'question-drag',
            onEnd: (evt) => this.handleQuestionReorder(evt),
            onSort: (evt) => this.saveToOfflineStorage()
        });
    }

    async initializeOfflineSupport() {
        // Register service worker
        if ('serviceWorker' in navigator) {
            try {
                await navigator.serviceWorker.register('/sw.js');
                console.log('Service Worker registered');
            } catch (error) {
                console.error('Service Worker registration failed:', error);
            }
        }

        // Load cached data
        await this.loadFromOfflineStorage();
    }

    async handleQuestionReorder(evt) {
        const newIndex = evt.newIndex;
        const oldIndex = evt.oldIndex;
        
        // Update local array
        const question = this.questions.splice(oldIndex, 1)[0];
        this.questions.splice(newIndex, 0, question);
        
        // Update numbers
        this.updateQuestionNumbers();
        
        // Save changes
        await this.saveChanges();
    }

    async saveChanges() {
        try {
            // Try online save first
            const response = await fetch('/api/teacher/quiz/reorder', {
                method: 'PUT',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    quiz_id: this.currentQuiz.id,
                    questions: this.questions
                })
            });

            if (!response.ok) throw new Error('Network response was not ok');

            // If successful, update offline storage
            await this.saveToOfflineStorage();
            
            this.showNotification('Changes saved successfully', 'success');
        } catch (error) {
            // If online save fails, store in offline queue
            await this.queueOfflineChange({
                type: 'reorder',
                quizId: this.currentQuiz.id,
                questions: this.questions,
                timestamp: new Date().toISOString()
            });
            
            this.showNotification('Changes saved offline', 'info');
        }
    }

    async loadQuiz(quizId) {
        try {
            // Try loading from network
            const response = await fetch(`/api/teacher/quiz/${quizId}`);
            if (!response.ok) throw new Error('Network response was not ok');
            
            const quiz = await response.json();
            await this.renderQuiz(quiz);
            
            // Update offline storage
            await this.saveToOfflineStorage();
        } catch (error) {
            // Load from offline storage if network fails
            const cachedQuiz = await this.offlineStorage.getQuiz(quizId);
            if (cachedQuiz) {
                await this.renderQuiz(cachedQuiz);
                this.showNotification('Loaded from offline storage', 'info');
            } else {
                this.showNotification('Failed to load quiz', 'error');
            }
        }
    }

    async renderQuiz(quiz) {
        this.currentQuiz = quiz;
        this.questions = quiz.questions;
        
        this.container.innerHTML = this.questions.map((question, index) => `
            <div class="question-card" data-id="${question.id}">
                <div class="card-header">
                    <div class="drag-handle">
                        <i class="fas fa-grip-vertical"></i>
                    </div>
                    <span class="question-number">#${index + 1}</span>
                    <div class="question-controls">
                        <button class="btn btn-sm btn-outline-primary edit-btn">
                            <i class="fas fa-edit"></i>
                        </button>
                        <button class="btn btn-sm btn-outline-info preview-btn">
                            <i class="fas fa-eye"></i>
                        </button>
                        <button class="btn btn-sm btn-outline-danger delete-btn">
                            <i class="fas fa-trash"></i>
                        </button>
                    </div>
                </div>
                <div class="card-body">
                    <div class="question-content">
                        <p class="question-text">${question.text}</p>
                        ${this.renderAnswers(question)}
                    </div>
                    <div class="question-footer">
                        <span class="badge bg-${this.getDifficultyColor(question.difficulty)}">
                            ${question.difficulty}
                        </span>
                        <span class="question-type">${question.type}</span>
                        <button class="btn btn-sm btn-link show-explanation" data-id="${question.id}">
                            Show Explanation
                        </button>
                    </div>
                </div>
            </div>
        `).join('');

        this.addEventListeners();
    }

    renderAnswers(question) {
        switch (question.type) {
            case 'mcq':
                return this.renderMCQAnswers(question);
            case 'true_false':
                return this.renderTrueFalseAnswers(question);
            case 'short_answer':
                return this.renderShortAnswerField(question);
            default:
                return '';
        }
    }

    async showExplanation(questionId) {
        try {
            const response = await fetch(`/api/quiz/explanation/${questionId}`);
            if (!response.ok) throw new Error('Failed to fetch explanation');
            
            const explanation = await response.json();
            
            // Show explanation in a modal
            const modal = new bootstrap.Modal(document.getElementById('explanationModal'));
            document.getElementById('explanationContent').innerHTML = `
                <h5>Explanation</h5>
                <p>${explanation.text}</p>
                <div class="concept-map">
                    ${this.renderConceptMap(explanation.concepts)}
                </div>
                <div class="related-topics">
                    <h6>Related Topics:</h6>
                    <ul>
                        ${explanation.relatedTopics.map(topic => 
                            `<li>${topic}</li>`
                        ).join('')}
                    </ul>
                </div>
            `;
            modal.show();
        } catch (error) {
            this.showNotification('Failed to load explanation', 'error');
        }
    }

    renderConceptMap(concepts) {
        // Implementation for concept map visualization
        // Using D3.js or similar library
    }

    addEventListeners() {
        // Edit buttons
        document.querySelectorAll('.edit-btn').forEach(btn => {
            btn.addEventListener('click', (e) => {
                const questionId = e.target.closest('.question-card').dataset.id;
                this.editQuestion(questionId);
            });
        });

        // Preview buttons
        document.querySelectorAll('.preview-btn').forEach(btn => {
            btn.addEventListener('click', (e) => {
                const questionId = e.target.closest('.question-card').dataset.id;
                this.previewQuestion(questionId);
            });
        });

        // Show explanation buttons
        document.querySelectorAll('.show-explanation').forEach(btn => {
            btn.addEventListener('click', (e) => {
                const questionId = e.target.dataset.id;
                this.showExplanation(questionId);
            });
        });
    }

    // Offline storage methods
    async saveToOfflineStorage() {
        if (this.currentQuiz) {
            await this.offlineStorage.saveQuiz(this.currentQuiz);
        }
    }

    async loadFromOfflineStorage() {
        const cachedQuizzes = await this.offlineStorage.getAllQuizzes();
        // Handle cached quizzes
    }

    async queueOfflineChange(change) {
        await this.offlineStorage.queueChange(change);
    }

    showNotification(message, type) {
        const alert = document.createElement('div');
        alert.className = `alert alert-${type} alert-dismissible fade show`;
        alert.innerHTML = `
            ${message}
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        `;
        document.querySelector('.notifications-container').appendChild(alert);
        setTimeout(() => alert.remove(), 3000);
    }
}

// Initialize the organizer
const quizOrganizer = new QuizOrganizer('quizContainer');