const express = require('express');
const router = express.Router();
const { getSession, getSessions, createSession, deleteSession, getExamDay, getExamDays, createExamDay, deleteExamDay, getExamDaySubjects, addExamDaySubject, removeExamDaySubject } = require('../controllers/examController');
const { allocateSeats, getAllocations, deleteAllocations, assignTeacherManually, removeTeacherAssignment } = require('../controllers/allocationController');
const { protect, authorize } = require('../middleware/auth');

router.use(protect);
router.use(authorize('admin'));

// SESSIONS
router.route('/sessions').get(getSessions).post(createSession);
router.route('/sessions/:sessionId').get(getSession).delete(deleteSession);

// EXAM DAYS
router.route('/sessions/:sessionId/days').get(getExamDays).post(createExamDay);
router.route('/exam-days/:dayId').get(getExamDay).delete(deleteExamDay);

// EXAM DAY SUBJECTS
router.route('/exam-days/:dayId/subjects').get(getExamDaySubjects).post(addExamDaySubject);
router.delete('/exam-days/:dayId/subjects/:subjectId', removeExamDaySubject);

// ALLOCATION
router.post('/exam-days/:dayId/allocate', allocateSeats);
router.route('/exam-days/:dayId/allocations').get(getAllocations).delete(deleteAllocations);
router.post('/exam-days/:dayId/assign-teacher', assignTeacherManually);
router.delete('/exam-days/:dayId/teachers/:teacherId', removeTeacherAssignment);

module.exports = router;
