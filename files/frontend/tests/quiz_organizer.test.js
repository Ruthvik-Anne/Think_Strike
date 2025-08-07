/**
 * ThinkStrike - Frontend Test Suite
 * Created: 2025-08-07 15:28:09
 * Author: Ruthvik-Anne
 */

import { QuizOrganizer } from '../static/js/quiz_organizer';
import { OfflineStorage } from '../static/js/offline_storage';
import '@testing-library/jest-dom';
import { fireEvent, render, screen } from '@testing-library/react';

describe('QuizOrganizer', () => {
    let organizer;
    let container;

    beforeEach(() => {
        container = document.createElement('div');
        container.id = 'quizContainer';
        document.body.appendChild(container);
        organizer = new QuizOrganizer('quizContainer');
    });

    afterEach(() => {
        document.body.removeChild(container);
        jest.clearAllMocks();
    });

    test('initializes correctly', () => {
        expect(organizer.container).toBeTruthy();
        expect(organizer.questions).toEqual([]);
    });

    test('handles question reordering', async () => {
        // Setup initial questions
        const questions = [
            { id: 1, text: 'Q1' },
            { id: 2, text: 'Q2' }
        ];
        await organizer.renderQuiz({ id: 1, questions });

        // Simulate drag and drop
        const dragEvent = {
            oldIndex: 0,
            newIndex: 1
        };
        await organizer.handleQuestionReorder(dragEvent);

        expect(organizer.questions[0].id).toBe(2);
        expect(organizer.questions[1].id).toBe(1);
    });

    test('saves to offline storage', async () => {
        const mockSave = jest.spyOn(organizer.offlineStorage, 'saveQuiz');
        await organizer.saveToOfflineStorage();
        expect(mockSave).toHaveBeenCalled();
    });

    test('handles network failures gracefully', async () => {
        // Mock failed fetch
        global.fetch = jest.fn(() => Promise.reject('Network error'));

        const questions = [{ id: 1, text: 'Q1' }];
        await organizer.renderQuiz({ id: 1, questions });

        // Try to save changes
        await organizer.saveChanges();

        // Should save to offline storage
        expect(organizer.offlineStorage.queueChange).toHaveBeenCalled();
    });
});

describe('OfflineStorage', () => {
    let storage;

    beforeEach(() => {
        storage = new OfflineStorage('test_store');
    });

    test('initializes IndexedDB', async () => {
        await storage.initializeDb();
        expect(storage.db).toBeTruthy();
    });

    test('saves and retrieves quiz', async () => {
        const quiz = { id: 1, title: 'Test Quiz' };
        await storage.saveQuiz(quiz);
        const retrieved = await storage.getQuiz(1);
        expect(retrieved).toEqual(quiz);
    });

    test('handles queued changes', async () => {
        const change = {
            type: 'update',
            quizId: 1,
            data: { title: 'Updated' }
        };
        await storage.queueChange(change);
        const changes = await storage.getQueuedChanges();
        expect(changes).toContainEqual(expect.objectContaining(change));
    });
});

describe('Performance Tests', () => {
    test('renders large quiz quickly', async () => {
        const organizer = new QuizOrganizer('quizContainer');
        const questions = Array(100).fill().map((_, i) => ({
            id: i,
            text: `Question ${i}`,
            type: 'mcq',
            choices: ['A', 'B', 'C', 'D']
        }));

        const startTime = performance.now();
        await organizer.renderQuiz({ id: 1, questions });
        const endTime = performance.now();

        expect(endTime - startTime).toBeLessThan(1000); // Should render in less than 1 second
    });
});

describe('Accessibility Tests', () => {
    test('supports keyboard navigation', () => {
        const { container } = render(<QuizOrganizer />);
        const firstQuestion = container.querySelector('.question-card');
        
        firstQuestion.focus();
        fireEvent.keyDown(firstQuestion, { key: 'Space' });
        
        expect(firstQuestion).toHaveClass('selected');
    });

    test('has proper ARIA labels', () => {
        const { container } = render(<QuizOrganizer />);
        const dragHandles = container.querySelectorAll('.drag-handle');
        
        dragHandles.forEach(handle => {
            expect(handle).toHaveAttribute('aria-label');
        });
    });
});