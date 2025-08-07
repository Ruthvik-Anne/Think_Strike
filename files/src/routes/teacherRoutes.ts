/**
 * Teacher Routes
 * Handles all teacher-specific operations including curriculum management
 * Last Updated: 2025-08-07 21:22:27 IST
 * Author: Ruthvik-Anne
 */

import express from 'express';
import { TeacherController } from '../controllers/TeacherController';
import { authMiddleware, subjectAccessMiddleware } from '../middleware/auth';

const router = express.Router();
const controller = new TeacherController();

// Middleware to check teacher's subject access
router.use(authMiddleware, subjectAccessMiddleware);

/**
 * Upload curriculum and textbook
 * POST /api/teacher/curriculum
 * @body {Curriculum} curriculum - Curriculum data
 * @body {TextbookData} textbook - Textbook content and metadata
 */
router.post('/curriculum', async (req, res) => {
  try {
    const result = await controller.uploadCurriculum(req.body);
    res.json(result);
  } catch (error) {
    res.status(500).json({ error: 'Failed to upload curriculum' });
  }
});

/**
 * Get subject-specific performance metrics
 * GET /api/teacher/performance/:subject
 * @param {string} subject - Subject code
 */
router.get('/performance/:subject', async (req, res) => {
  try {
    const metrics = await controller.getPerformanceMetrics(req.params.subject);
    res.json(metrics);
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch performance metrics' });
  }
});

// Export router
export default router;