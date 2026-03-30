const express = require('express');
const router = express.Router();
const multer = require('multer');
const upload = multer({ dest: 'uploads/' });
const { getStudents, createStudent, bulkUploadStudents, updateStudent, deleteStudent, getStudentSeats } = require('../controllers/studentController');
const { getStudentMalpractice, getMyMalpractice, deleteMalpractice } = require('../controllers/malpracticeController');
const { protect, authorize } = require('../middleware/auth');

router.use(protect);

// Student-specific routes
router.get('/seats', authorize('student'), getStudentSeats);
router.get('/malpractice', authorize('student'), getMyMalpractice);

// Admin-only routes
router.get('/:studentId/malpractice', authorize('admin'), getStudentMalpractice);
router.delete('/malpractice/:id', authorize('admin'), deleteMalpractice);

router.route('/')
  .get(authorize('admin'), getStudents)
  .post(authorize('admin'), createStudent);
router.post('/bulk', authorize('admin'), upload.single('file'), bulkUploadStudents);
router.route('/:id')
  .put(authorize('admin'), updateStudent)
  .delete(authorize('admin'), deleteStudent);

module.exports = router;
