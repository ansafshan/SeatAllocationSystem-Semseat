const { Session, ExamDay, ExamDaySubject, Subject, Department, Batch, Student, Hall, SeatAllocation, Teacher, HallTeacher, sequelize } = require('../models');

// SESSIONS
const getSession = async (req, res) => {
  try {
    const session = await Session.findByPk(req.params.sessionId);
    if (!session) return res.status(404).json({ message: 'Session not found' });
    res.json(session);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const getSessions = async (req, res) => {
  try {
    const sessions = await Session.findAll({ order: [['created_at', 'DESC']] });
    res.json(sessions);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const createSession = async (req, res) => {
  try {
    const session = await Session.create(req.body);
    res.status(201).json(session);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

const deleteSession = async (req, res) => {
  try {
    const { sessionId } = req.params;
    const session = await Session.findByPk(sessionId);
    if (!session) {
      return res.status(404).json({ message: 'Session not found' });
    }
    await session.destroy(); // Assuming cascade delete is set up in the model
    res.json({ message: 'Session deleted successfully' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// EXAM DAYS
const getExamDay = async (req, res) => {
  try {
    const day = await ExamDay.findByPk(req.params.dayId, {
      include: [Session]
    });
    if (!day) return res.status(404).json({ message: 'Exam day not found' });
    res.json(day);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const getExamDays = async (req, res) => {
  try {
    const days = await ExamDay.findAll({
      where: { session_id: req.params.sessionId },
      include: [Session],
      order: [['date', 'ASC'], ['slot', 'ASC']]
    });
    res.json(days);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const createExamDay = async (req, res) => {
  try {
    const day = await ExamDay.create({ ...req.body, session_id: req.params.sessionId });
    res.status(201).json(day);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

const deleteExamDay = async (req, res) => {
  try {
    const { dayId } = req.params;
    const day = await ExamDay.findByPk(dayId);
    if (!day) {
      return res.status(404).json({ message: 'Exam day not found' });
    }
    await day.destroy();
    res.json({ message: 'Exam day deleted successfully' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// EXAM DAY SUBJECTS
const getExamDaySubjects = async (req, res) => {
  try {
    const subjects = await ExamDaySubject.findAll({
      where: { exam_day_id: req.params.dayId },
      include: [{ model: Subject, include: [Department, Batch] }]
    });
    res.json(subjects);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const addExamDaySubject = async (req, res) => {
  try {
    const entry = await ExamDaySubject.create({
      exam_day_id: req.params.dayId,
      subject_id: req.body.subject_id
    });
    const fullEntry = await ExamDaySubject.findByPk(entry.id, {
      include: [{ model: Subject, include: [Department, Batch] }]
    });
    res.status(201).json(fullEntry);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

const removeExamDaySubject = async (req, res) => {
  try {
    await ExamDaySubject.destroy({
      where: { exam_day_id: req.params.dayId, subject_id: req.params.subjectId }
    });
    res.json({ message: 'Subject removed from exam day' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

module.exports = {
  getSession, getSessions, createSession, deleteSession,
  getExamDay, getExamDays, createExamDay, deleteExamDay,
  getExamDaySubjects, addExamDaySubject, removeExamDaySubject
};
