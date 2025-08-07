import express from 'express';
const router = express.Router();

// Get quizzes by subject with sorting
router.get('/quizzes', async (req, res) => {
  const { subject, sortBy = 'dueDate', order = 'asc' } = req.query;
  try {
    const quizzes = await Quiz.find({ 
      subject,
      status: 'PUBLISHED',
      dueDate: { $gt: new Date() }
    })
    .sort({ [sortBy]: order === 'asc' ? 1 : -1 });
    res.json(quizzes);
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch quizzes' });
  }
});

// Get curriculum by subject
router.get('/curriculum/:subject', async (req, res) => {
  try {
    const curriculum = await Curriculum.findOne({ 
      subject: req.params.subject,
      status: 'APPROVED'
    });
    res.json(curriculum);
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch curriculum' });
  }
});