// ThinkStrike - Admin User Management
// Last Updated: 2025-08-07 15:21:17
// Author: Ruthvik-Anne

class UserManager {
    constructor() {
        this.table = null;
        this.initializeDataTable();
        this.setupEventListeners();
    }

    initializeDataTable() {
        this.table = $('#usersTable').DataTable({
            ajax: {
                url: '/api/admin/users',
                dataSrc: ''
            },
            columns: [
                { data: 'roll_number' },
                { data: 'name' },
                { 
                    data: 'role',
                    render: (data) => `<span class="badge bg-${this.getRoleBadgeColor(data)}">${data}</span>`
                },
                {
                    data: 'status',
                    render: (data) => `<span class="badge bg-${data ? 'success' : 'danger'}">${data ? 'Active' : 'Inactive'}</span>`
                },
                { 
                    data: 'last_login',
                    render: (data) => data ? new Date(data).toLocaleString() : 'Never'
                },
                {
                    data: null,
                    render: (data) => this.getActionButtons(data)
                }
            ],
            order: [[0, 'asc']],
            pageLength: 10,
            responsive: true
        });
    }

    setupEventListeners() {
        // Add User
        document.getElementById('saveUserBtn').addEventListener('click', () => this.handleAddUser());
        
        // Generate Password
        document.getElementById('generatePasswordBtn').addEventListener('click', () => this.generatePassword());
        
        // CSV Upload
        document.getElementById('uploadCsvBtn').addEventListener('click', () => this.handleCsvUpload());
        
        // Export Users
        document.getElementById('exportUsersBtn').addEventListener('click', () => this.exportUsers());
    }

    async handleAddUser() {
        try {
            const userData = {
                roll_number: document.getElementById('rollNumber').value,
                name: document.getElementById('userName').value,
                role: document.getElementById('userRole').value,
                password: document.getElementById('userPassword').value
            };

            const response = await fetch('/api/admin/users', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(userData)
            });

            if (response.ok) {
                this.showAlert('User added successfully!', 'success');
                this.table.ajax.reload();
                $('#addUserModal').modal('hide');
            } else {
                throw new Error('Failed to add user');
            }
        } catch (error) {
            this.showAlert('Error adding user: ' + error.message, 'danger');
        }
    }

    async handleCsvUpload() {
        try {
            const fileInput = document.getElementById('csvFile');
            const generatePasswords = document.getElementById('generatePasswords').checked;
            
            if (!fileInput.files[0]) {
                throw new Error('Please select a CSV file');
            }

            const formData = new FormData();
            formData.append('file', fileInput.files[0]);
            formData.append('generate_passwords', generatePasswords);

            const response = await fetch('/api/admin/users/csv', {
                method: 'POST',
                body: formData
            });

            if (response.ok) {
                const result = await response.json();
                this.showUploadResults(result);
                this.table.ajax.reload();
                $('#csvUploadModal').modal('hide');
            } else {
                throw new Error('Failed to upload CSV');
            }
        } catch (error) {
            this.showAlert('Error uploading CSV: ' + error.message, 'danger');
        }
    }

    showUploadResults(result) {
        const message = `
            Successfully imported ${result.success} users<br>
            Failed: ${result.failed}<br>
            ${result.generated_passwords ? 'Passwords have been generated' : ''}
        `;
        this.showAlert(message, 'success', 5000);
    }

    async exportUsers() {
        try {
            const response = await fetch('/api/admin/users/export');
            const blob = await response.blob();
            const url = window.URL.createObjectURL(blob);
            const a = document.createElement('a');
            a.href = url;
            a.download = `users_export_${new Date().toISOString().split('T')[0]}.csv`;
            document.body.appendChild(a);
            a.click();
            a.remove();
        } catch (error) {
            this.showAlert('Error exporting users: ' + error.message, 'danger');
        }
    }

    generatePassword() {
        const length = 12;
        const charset = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*';
        let password = '';
        for (let i = 0; i < length; i++) {
            password += charset.charAt(Math.floor(Math.random() * charset.length));
        }
        document.getElementById('userPassword').value = password;
    }

    getRoleBadgeColor(role) {
        const colors = {
            'admin': 'primary',
            'teacher': 'success',
            'student': 'info'
        };
        return colors[role] || 'secondary';
    }

    getActionButtons(data) {
        return `
            <div class="btn-group btn-group-sm">
                <button class="btn btn-primary" onclick="userManager.editUser(${data.id})">
                    <i class="fas fa-edit"></i>
                </button>
                <button class="btn btn-warning" onclick="userManager.resetPassword(${data.id})">
                    <i class="fas fa-key"></i>
                </button>
                <button class="btn btn-danger" onclick="userManager.deleteUser(${data.id})">
                    <i class="fas fa-trash"></i>
                </button>
            </div>
        `;
    }

    showAlert(message, type, duration = 3000) {
        const alertDiv = document.createElement('div');
        alertDiv.className = `alert alert-${type} alert-dismissible fade show`;
        alertDiv.innerHTML = `
            ${message}
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        `;
        document.querySelector('.container').insertBefore(alertDiv, document.querySelector('.card'));
        setTimeout(() => alertDiv.remove(), duration);
    }
}

// Initialize user manager
const userManager = new UserManager();