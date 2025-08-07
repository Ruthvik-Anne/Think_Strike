// ThinkStrike Teacher Dashboard JavaScript

document.addEventListener('DOMContentLoaded', function() {
    // Initialize variables
    const uploadMaterialBtn = document.getElementById('uploadMaterialBtn');
    const saveMaterialBtn = document.getElementById('saveMaterialBtn');
    const createQuizBtn = document.getElementById('createQuizBtn');
    const aiGeneratorForm = document.getElementById('aiGeneratorForm');
    const materialsList = document.querySelector('.materials-list');
    const quizzesList = document.getElementById('quizzesList');

    // Bootstrap modal instance
    const uploadMaterialModal = new bootstrap.Modal(document.getElementById('uploadMaterialModal'));

    // Load initial data
    loadMaterials();
    loadQuizzes();
    loadCategories();

    // Event Listeners
    uploadMaterialBtn.addEventListener('click', () => uploadMaterialModal.show());
    saveMaterialBtn.addEventListener('click', handleMaterialUpload);
    createQuizBtn.addEventListener('click', handleQuizCreate);
    aiGeneratorForm.addEventListener('submit', handleAIGeneration);

    // Functions
    async function loadMaterials() {
        try {
            const response = await fetch('/api/materials');
            const materials = await response.json();
            renderMaterials(materials);
        } catch (error) {
            console.error('Error loading materials:', error);
            showAlert('Error loading materials', 'danger');
        }
    }

    function renderMaterials(materials) {
        materialsList.innerHTML = materials.map(material => `
            <div class="material-card">
                <h5>${material.title}</h5>
                <p class="text-muted">${material.category}</p>
                <div class="d-flex justify-content-between align-items-center">
                    <a href="${material.fileUrl}" class="btn btn-sm btn-outline-success">Download</a>
                    <button class="btn btn-sm btn-danger" onclick="deleteMaterial(${material.id})">Delete</button>
                </div>
            </div>
        `).join('');
    }

    async function handleMaterialUpload(e) {
        e.preventDefault();
        
        const formData = new FormData();
        formData.append('title', document.getElementById('materialTitle').value);
        formData.append('category', document.getElementById('materialCategory').value);
        formData.append('file', document.getElementById('materialFile').files[0]);

        try {
            const response = await fetch('/api/materials', {
                method: 'POST',
                body: formData
            });

            if (response.ok) {
                uploadMaterialModal.hide();
                loadMaterials();
                showAlert('Material uploaded successfully', 'success');
            } else {
                throw new Error('Failed to upload material');
            }
        } catch (error) {
            console.error('Error uploading material:', error);
            showAlert('Error uploading material', 'danger');
        }
    }

    async function handleAIGeneration(e) {
        e.preventDefault();
        
        const data = {
            text: document.getElementById('sourceMaterial').value,
            numQuestions: parseInt(document.getElementById('numQuestions').value)
        };

        try {
            const response = await fetch('/api/ai/generate', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(data)
            });

            if (response.ok) {
                const questions = await response.json();
                renderGeneratedQuestions(questions);
                showAlert('Questions generated successfully', 'success');
            } else {
                throw new Error('Failed to generate questions');
            }
        } catch (error) {
            console.error('Error generating questions:', error);
            showAlert('Error generating questions', 'danger');
        }
    }

    function renderGeneratedQuestions(questions) {
        const container = document.getElementById('generatedQuestions');
        container.innerHTML = questions.map((q, index) => `
            <div class="question-item">
                <h6>Question ${index + 1}</h6>
                <p>${q.text}</p>
                <div class="choices">
                    ${JSON.parse(q.choices).map((choice, i) => `
                        <div class="form-check">
                            <input class="form-check-input" type="radio" name="q${index}" value="${i}" ${i === q.correct_index ? 'checked' : ''}>
                            <label class="form-check-label">${choice}</label>
                        </div>
                    `).join('')}
                </div>
            </div>
        `).join('');
    }

    // Utility functions
    function showAlert(message, type) {
        const alertDiv = document.createElement('div');
        alertDiv.className = `alert alert-${type} alert-dismissible fade show`;
        alertDiv.innerHTML = `
            ${message}
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        `;
        document.querySelector('.container-fluid').insertBefore(alertDiv, document.querySelector('.row'));
        setTimeout(() => alertDiv.remove(), 3000);
    }
});