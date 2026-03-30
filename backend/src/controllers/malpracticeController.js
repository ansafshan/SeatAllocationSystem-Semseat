const { MalpracticeLog, Student, Teacher, User, ExamDay, Session, Department, Batch } = require('../models');

const reportMalpractice = async (req, res) => {
  const { student_id, exam_day_id, reason } = req.body;
  try {
    const teacher = await Teacher.findOne({ where: { user_id: req.user.id } });
    const log = await MalpracticeLog.create({
      student_id,
      exam_day_id,
      reason,
      reported_by_teacher_id: teacher ? teacher.id : null
    });
    res.status(201).json(log);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

const getStudentMalpractice = async (req, res) => {
  try {
    const history = await MalpracticeLog.findAll({
      where: { student_id: req.params.studentId },
      include: [
        { model: ExamDay, include: [Session] },
        { model: Teacher, include: [{ model: User, attributes: ['name'] }] }
      ],
      order: [['created_at', 'DESC']],
    });
    res.json(history);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const getMyMalpractice = async (req, res) => {
  try {
    const student = await Student.findOne({ where: { user_id: req.user.id } });
    if (!student) return res.status(404).json({ message: 'Student profile not found' });

    const history = await MalpracticeLog.findAll({
      where: { student_id: student.id },
      include: [
        { model: ExamDay, include: [Session] },
        { model: Teacher, include: [{ model: User, attributes: ['name'] }] }
      ],
      order: [['created_at', 'DESC']],
    });
    res.json(history);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const getRecentReports = async (req, res) => {
  try {
    const teacher = await Teacher.findOne({ where: { user_id: req.user.id } });
    if (!teacher) return res.status(404).json({ message: 'Teacher profile not found' });

    const reports = await MalpracticeLog.findAll({
      where: { reported_by_teacher_id: teacher.id },
      include: [
        { model: Student, include: [User, Department, Batch] },
        { model: ExamDay, include: [Session] }
      ],
      order: [['created_at', 'DESC']],
      limit: 20
    });
    res.json(reports);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const deleteMalpractice = async (req, res) => {
  try {
    const log = await MalpracticeLog.findByPk(req.params.id);
    if (!log) return res.status(404).json({ message: 'Log not found' });

    // Admin can delete anything
    if (req.user.role === 'admin') {
      await log.destroy();
      return res.json({ message: 'Log deleted by admin' });
    }

    // Teacher can delete their own report within a time window (e.g., 30 mins) or just any of theirs
    if (req.user.role === 'teacher') {
      const teacher = await Teacher.findOne({ where: { user_id: req.user.id } });
      if (log.reported_by_teacher_id !== teacher.id) {
        return res.status(403).json({ message: 'Not authorized to delete this report' });
      }
      
      // Optional: Check time window
      const now = new Date();
      const reportedAt = new Date(log.created_at);
      const diffMins = (now - reportedAt) / (1000 * 60);
      
      if (diffMins > 60) {
        return res.status(400).json({ message: 'Cannot delete report after 1 hour. Contact Admin.' });
      }

      await log.destroy();
      return res.json({ message: 'Report deleted successfully' });
    }

    res.status(403).json({ message: 'Unauthorized' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

module.exports = { 
  reportMalpractice, 
  getStudentMalpractice, 
  getMyMalpractice, 
  getRecentReports, 
  deleteMalpractice 
};
