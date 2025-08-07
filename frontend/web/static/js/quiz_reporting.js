/**
 * ThinkStrike - Quiz Reporting System
 * Created: 2025-08-07 15:33:04
 * Author: Ruthvik-Anne
 */

class QuizReporting {
    constructor() {
        this.setupEventListeners();
    }

    setupEventListeners() {
        // Add report buttons to each question
        document.querySelectorAll('.question-card').forEach(card => {
            const reportBtn = document.createElement('button');
            reportBtn.className = 'btn btn-sm btn-outline-warning report-btn';
            reportBtn.innerHTML = '<i class="fas fa-flag"></i> Report';
            reportBtn.onclick = () => this.showReportDialog(card.dataset.questionId);
            
            card.querySelector('.question-footer').appendChild(reportBtn);
        });
    }

    async showReportDialog(questionId) {
        const result = await Swal.fire({
            title: 'Report Question',
            html: `
                <select id="reportType" class="form-select mb-3">
                    <option value="unclear">Question is unclear</option>
                    <option value="incorrect">Answer seems incorrect</option>
                    <option value="technical">Technical issue</option>
                    <option value="other">Other issue</option>
                </select>
            `,
            showCancelButton: true,
            confirmButtonText: 'Submit Report',
            cancelButtonText: 'Cancel',
            preConfirm: () => {
                return document.getElementById('reportType').value;
            }
        });

        if (result.isConfirmed) {
            await this.submitReport(questionId, result.value);
        }
    }

    async submitReport(questionId, reportType) {
        try {
            const response = await fetch('/api/reports/create', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({
                    question_id: questionId,
                    report_type: reportType,
                    student_id: currentUser.id  // Global user object
                })
            });

            if (!response.ok) throw new Error('Failed to submit report');

            Swal.fire(
                'Report Submitted',
                'Your teacher has been notified about this question.',
                'success'
            );
        } catch (error) {
            console.error('Error submitting report:', error);
            Swal.fire(
                'Error',
                'Failed to submit report. Please try again.',
                'error'
            );
        }
    }
}

// Initialize reporting system
const reporting = new QuizReporting();