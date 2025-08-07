/**
 * ThinkStrike - Messaging System
 * Created: 2025-08-07 15:30:28
 * Author: Ruthvik-Anne
 */

class MessagingSystem {
    constructor(userId) {
        this.userId = userId;
        this.ws = null;
        this.messageHandler = null;
        this.initializeWebSocket();
        this.setupEventListeners();
    }

    initializeWebSocket() {
        this.ws = new WebSocket(`ws://localhost:8000/api/communication/ws/${this.userId}`);
        
        this.ws.onopen = () => {
            console.log('WebSocket connection established');
            this.updateConnectionStatus('Connected');
        };

        this.ws.onmessage = (event) => {
            const message = JSON.parse(event.data);
            this.handleIncomingMessage(message);
        };

        this.ws.onclose = () => {
            console.log('WebSocket connection closed');
            this.updateConnectionStatus('Disconnected');
            // Attempt to reconnect after 5 seconds
            setTimeout(() => this.initializeWebSocket(), 5000);
        };
    }

    setupEventListeners() {
        const sendButton = document.getElementById('sendMessageBtn');
        const messageInput = document.getElementById('messageInput');

        sendButton.addEventListener('click', () => {
            const content = messageInput.value.trim();
            if (content) {
                this.sendMessage(content);
                messageInput.value = '';
            }
        });

        messageInput.addEventListener('keypress', (e) => {
            if (e.key === 'Enter' && !e.shiftKey) {
                e.preventDefault();
                sendButton.click();
            }
        });
    }

    async sendMessage(content) {
        try {
            const response = await fetch('/api/communication/messages', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({
                    sender_id: this.userId,
                    receiver_id: this.selectedTeacherId,
                    content: content
                })
            });

            if (!response.ok) throw new Error('Failed to send message');

            const message = await response.json();
            this.addMessageToChat(message, true);
        } catch (error) {
            console.error('Error sending message:', error);
            this.showNotification('Failed to send message', 'error');
        }
    }

    async loadTeachers() {
        try {
            const response = await fetch('/api/communication/teachers');
            const teachers = await response.json();
            this.renderTeacherList(teachers);
        } catch (error) {
            console.error('Error loading teachers:', error);
            this.showNotification('Failed to load teachers', 'error');
        }
    }

    renderTeacherList(teachers) {
        const container = document.getElementById('teacherList');
        container.innerHTML = teachers.map(teacher => `
            <div class="teacher-card" data-id="${teacher.id}">
                <div class="teacher-avatar">
                    <img src="${teacher.avatar_url || '/static/images/default-avatar.png'}" 
                         alt="${teacher.name}">
                    <span class="status-indicator ${teacher.online ? 'online' : 'offline'}"></span>
                </div>
                <div class="teacher-info">
                    <h5>${teacher.name}</h5>
                    <span class="badge bg-primary">${teacher.subject || 'General'}</span>
                    <small class="text-muted">
                        ${teacher.online ? 'Online' : 'Last seen: ' + this.formatLastSeen(teacher.last_seen)}
                    </small>
                </div>
                <button class="btn btn-primary btn-sm start-chat-btn">
                    <i class="fas fa-comment"></i> Chat
                </button>
            </div>
        `).join('');

        // Add click handlers
        container.querySelectorAll('.start-chat-btn').forEach(btn => {
            btn.addEventListener('click', (e) => {
                const teacherId = e.target.closest('.teacher-card').dataset.id;
                this.startChat(teacherId);
            });
        });
    }

    async startChat(teacherId) {
        this.selectedTeacherId = teacherId;
        try {
            const response = await fetch(`/api/communication/messages/${this.userId}`);
            const messages = await response.json();
            
            // Filter messages for selected teacher
            const chatMessages = messages.filter(m => 
                (m.sender_id === this.userId && m.receiver_id === teacherId) ||
                (m.sender_id === teacherId && m.receiver_id === this.userId)
            );

            this.renderChat(chatMessages);
        } catch (error) {
            console.error('Error loading chat:', error);
            this.showNotification('Failed to load chat history', 'error');
        }
    }

    renderChat(messages) {
        const container = document.getElementById('chatMessages');
        container.innerHTML = messages.map(message => `
            <div class="message ${message.sender_id === this.userId ? 'sent' : 'received'}">
                <div class="message-content">
                    <p>${message.content}</p>
                    <small class="message-time">
                        ${this.formatTimestamp(message.timestamp)}
                    </small>
                </div>
            </div>
        `).join('');

        // Scroll to bottom
        container.scrollTop = container.scrollHeight;
    }

    addMessageToChat(message, isOutgoing = false) {
        const container = document.getElementById('chatMessages');
        const messageElement = document.createElement('div');
        messageElement.className = `message ${isOutgoing ? 'sent' : 'received'}`;
        messageElement.innerHTML = `
            <div class="message-content">
                <p>${message.content}</p>
                <small class="message-time">
                    ${this.formatTimestamp(message.timestamp)}
                </small>
            </div>
        `;
        container.appendChild(messageElement);
        container.scrollTop = container.scrollHeight;
    }

    formatTimestamp(timestamp) {
        return new Date(timestamp).toLocaleTimeString();
    }

    formatLastSeen(timestamp) {
        const date = new Date(timestamp);
        const now = new Date();
        const diff = now - date;

        if (diff < 60000) return 'Just now';
        if (diff < 3600000) return `${Math.floor(diff / 60000)}m ago`;
        if (diff < 86400000) return `${Math.floor(diff / 3600000)}h ago`;
        return date.toLocaleDateString();
    }

    updateConnectionStatus(status) {
        const statusElement = document.getElementById('connectionStatus');
        if (statusElement) {
            statusElement.textContent = status;
            statusElement.className = `status-indicator ${status.toLowerCase()}`;
        }
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