// ThinkStrike - Question Organizer
// Last Updated: 2025-08-07 15:21:17
// Author: Ruthvik-Anne

class QuestionOrganizer {
    constructor(containerId) {
        this.container = document.getElementById(containerId);
        this.questions = [];
        this.draggedItem = null;
        this.initializeSortable();
    }

    initializeSortable() {
        new Sortable(this.container, {
            animation: 150,
            ghostClass: 'question-ghost',
            chosenClass: 'question-chosen',
            dragClass: 'question-drag',
            onEnd: (evt) => this.handleDragEnd(evt)
        });
    }

    handleDragEnd(evt) {
        const newIndex = evt.newIndex;
        const oldIndex = evt.oldIndex;
        
        // Update question order
        const question = this.questions.splice(oldIndex, 1)[0];
        this.questions.splice(newIndex, 0, question);
        
        // Save new order
        this.saveQuestionOrder();
    }

    async saveQuestionOrder() {
        try {
            const response = await fetch('/api/teacher/quiz/reorder', {
                method: 'PUT',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    quiz_id: this.quizId,
                    question_order: this.questions.map(q => q.id)
                })
            });

            if (!response.ok) throw new Error('Failed to save question order');
            
            showAlert('Question order updated successfully', 'success');
        } catch (error) {
            showAlert('Error saving question order: ' + error.message, 'danger');
        }
    }

    renderQuestions() {
        this.container.innerHTML = this.questions.map((question, index) => `
            <div class="question-card" data-id="${question.id}">
                <div class="question-header">
                    <span class="question-number">#${index + 1}</span>
                    <div class="question-controls">
                        <button class="btn btn-sm btn-outline-primary edit-btn">
                            <i class="fas fa-edit"></i>
                        </button>
                        <button class="btn btn-sm btn-outline-danger delete-btn">
                            <i class="fas fa-trash"></i>
                        </button>
                    </div>
                </div>
                <div class="question-content">
                    <div class="question-text">${question.text}</div>
                    ${this.renderAnswers(question)}
                </div>
                <div class="question-footer">
                    <span class="badge bg-${this.getDifficultyColor(question.difficulty)}">
                        ${question.difficulty}
                    </span>
                    <span class="question-type">${question.type}</span>
                </div>
            </div>
        `).join('');

        this.addQuestionEventListeners();
    }

    renderAnswers(question) {
        switch (question.type) {
            case 'mcq':
                return this.renderMCQAnswers(question);
            case 'true_false':
                return this.renderTrueFalseAnswers(question);
            case 'short_answer':
                return this.renderShortAnswerSample(question);
            default:
                return '';
        }
    }

    // ... Additional methods for rendering different question types ...
}

// Initialize question organizer
const organizer = new QuestionOrganizer('questionContainer');