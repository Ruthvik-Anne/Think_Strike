// ThinkStrike Admin Panel JavaScript

document.addEventListener('DOMContentLoaded', function() {
    // Initialize variables
    const addUserBtn = document.getElementById('addUserBtn');
    const saveUserBtn = document.getElementById('saveUserBtn');
    const usersList = document.getElementById('usersList');
    const roleAssignmentForm = document.getElementById('roleAssignmentForm');

    // Bootstrap modal instance
    const addUserModal = new bootstrap.Modal(document.getElementById('addUserModal'));

    // Load initial data
    loadUsers();
    loadUserSelect();

    // Event Listeners
    addUserBtn.addEventListener('click', () => addUserModal.show());
    saveUserBtn.addEventListener('click', handleAddUser);
    roleAssignmentForm.addEventListener('submit', handleRoleAssignment);

    // Functions
    async function loadUsers() {
        try {
            const response = await fetch('/api/users');
            const users = await response.json();
            renderUsers(users);
        } catch (error) {
            console.error('Error loading users:', error);
            showAlert('Error loading users', 'danger');
        }
    }

    function renderUsers(users) {
        usersList.innerHTML = users.map(user => `
            <tr>
                <td>${user.username}</td>
                <td><span class="badge bg-${getRoleBadgeColor(user.role)}">${user.role}</span></td>
                <td><span class="badge bg-${user.active ? 'success' : 'danger'}">${user.active ? 'Active' : 'Inactive'}</span></td>
                <td class="action-buttons">
                    <button class="btn btn-sm btn-primary" onclick="editUser(${user.id})">Edit</button>
                    <button class="btn btn-sm btn-danger" onclick="deleteUser(${user.id})">Delete</button>
                </td>
            </tr>
        `).join('');
    }

    async function handleAddUser(e) {
        e.preventDefault();
        
        const userData = {
            username: document.getElementById('newUsername').value,
            password: document.getElementById('newPassword').value,
            role: document.getElementById('newRole').value
        };

        try {
            const response = await fetch('/api/users', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(userData)
            });

            if (response.ok) {
                addUserModal.hide();
                loadUsers();
                showAlert('User added successfully', 'success');
            } else {
                throw new Error('Failed to add user');
            }
        } catch (error) {
            console.error('Error adding user:', error);
            showAlert('Error adding user', 'danger');
        }
    }

    async function handleRoleAssignment(e) {
        e.preventDefault();
        
        const data = {
            userId: document.getElementById('userSelect').value,
            role: document.getElementById('roleSelect').value
        };

        try {
            const response = await fetch('/api/users/role', {
                method: 'PUT',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(data)
            });

            if (response.ok) {
                loadUsers();
                showAlert('Role updated successfully', 'success');
            } else {
                throw new Error('Failed to update role');
            }
        } catch (error) {
            console.error('Error updating role:', error);
            showAlert('Error updating role', 'danger');
        }
    }

    // Utility functions
    function getRoleBadgeColor(role) {
        const colors = {
            'admin': 'primary',
            'teacher': 'success',
            'student': 'info'
        };
        return colors[role] || 'secondary';
    }

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