const express = require('express');
const router = express.Router();
const { getTeachers, createTeacher, updateTeacher, deleteTeacher, getTeacherDuties, getHallSeats } = require('../controllers/teacherController');
const { reportMalpractice, getRecentReports, deleteMalpractice } = require('../controllers/malpracticeController');
const { protect, authorize } = require('../middleware/auth');

router.use(protect);

// Teacher-specific routes
router.get('/duties', authorize('teacher'), getTeacherDuties);
router.get('/halls/:dayId/:hallId/seats', authorize('teacher', 'admin'), getHallSeats);
router.post('/report-malpractice', authorize('teacher'), reportMalpractice);
router.get('/malpractice/recent', authorize('teacher'), getRecentReports);
router.delete('/malpractice/:id', authorize('teacher'), deleteMalpractice);

// Admin-only routes for managing teachers
router.route('/')
  .get(authorize('admin'), getTeachers)
  .post(authorize('admin'), createTeacher);

router.route('/:id')
  .put(authorize('admin'), updateTeacher)
  .delete(authorize('admin'), deleteTeacher);

module.exports = router;
