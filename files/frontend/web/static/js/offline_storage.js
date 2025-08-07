/**
 * ThinkStrike - Offline Storage Manager
 * Created: 2025-08-07 15:26:08
 * Author: Ruthvik-Anne
 */

class OfflineStorage {
    constructor(storeName) {
        this.storeName = storeName;
        this.db = null;
        this.initializeDb();
    }

    async initializeDb() {
        try {
            this.db = await new Promise((resolve, reject) => {
                const request = indexedDB.open(this.storeName, 1);
                
                request.onerror = () => reject(request.error);
                request.onsuccess = () => resolve(request.result);
                
                request.onupgradeneeded = (event) => {
                    const db = event.target.result;
                    
                    // Create stores
                    if (!db.objectStoreNames.contains('quizzes')) {
                        db.createObjectStore('quizzes', { keyPath: 'id' });
                    }
                    
                    if (!db.objectStoreNames.contains('changes')) {
                        db.createObjectStore('changes', { 
                            keyPath: 'id',
                            autoIncrement: true 
                        });
                    }
                };
            });
        } catch (error) {
            console.error('Failed to initialize IndexedDB:', error);
        }
    }

    async saveQuiz(quiz) {
        await this.ensureDb();
        
        return new Promise((resolve, reject) => {
            const transaction = this.db.transaction(['quizzes'], 'readwrite');
            const store = transaction.objectStore('quizzes');
            
            const request = store.put(quiz);
            
            request.onsuccess = () => resolve();
            request.onerror = () => reject(request.error);
        });
    }

    async getQuiz(quizId) {
        await this.ensureDb();
        
        return new Promise((resolve, reject) => {
            const transaction = this.db.transaction(['quizzes'], 'readonly');
            const store = transaction.objectStore('quizzes');
            
            const request = store.get(quizId);
            
            request.onsuccess = () => resolve(request.result);
            request.onerror = () => reject(request.error);
        });
    }

    async getAllQuizzes() {
        await this.ensureDb();
        
        return new Promise((resolve, reject) => {
            const transaction = this.db.transaction(['quizzes'], 'readonly');
            const store = transaction.objectStore('quizzes');
            
            const request = store.getAll();
            
            request.onsuccess = () => resolve(request.result);
            request.onerror = () => reject(request.error);
        });
    }

    async queueChange(change) {
        await this.ensureDb();
        
        return new Promise((resolve, reject) => {
            const transaction = this.db.transaction(['changes'], 'readwrite');
            const store = transaction.objectStore('changes');
            
            const request = store.add(change);
            
            request.onsuccess = () => resolve();
            request.onerror = () => reject(request.error);
        });
    }

    async getQueuedChanges() {
        await this.ensureDb();
        
        return new Promise((resolve, reject) => {
            const transaction = this.db.transaction(['changes'], 'readonly');
            const store = transaction.objectStore('changes');
            
            const request = store.getAll();
            
            request.onsuccess = () => resolve(request.result);
            request.onerror = () => reject(request.error);
        });
    }

    async clearChange(changeId) {
        await this.ensureDb();
        
        return new Promise((resolve, reject) => {
            const transaction = this.db.transaction(['changes'], 'readwrite');
            const store = transaction.objectStore('changes');
            
            const request = store.delete(changeId);
            
            request.onsuccess = () => resolve();
            request.onerror = () => reject(request.error);
        });
    }

    async ensureDb() {
        if (!this.db) {
            await this.initializeDb();
        }
    }
}