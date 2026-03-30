const { Student, Teacher, ExamDay, Hall, MalpracticeLog, User, Session, sequelize } = require('../models');
const { Op } = require('sequelize');

const getDashboardStats = async (req, res) => {
  try {
    const studentCount = await Student.count();
    const teacherCount = await Teacher.count();
    const hallCount = await Hall.count();
    
    // Upcoming exams (today onwards)
    const today = new Date().toISOString().split('T')[0];
    const upcomingExamsCount = await ExamDay.count({
      where: {
        date: { [Op.gte]: today }
      }
    });

    res.json({
      students: studentCount,
      teachers: teacherCount,
      halls: hallCount,
      upcomingExams: upcomingExamsCount
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const getRecentMalpractices = async (req, res) => {
  try {
    const logs = await MalpracticeLog.findAll({
      limit: 10,
      order: [['created_at', 'DESC']],
      include: [
        { 
          model: Student, 
          include: [{ model: User, attributes: ['name'] }] 
        },
        { 
          model: ExamDay, 
          include: [{ model: Session, attributes: ['name'] }] 
        }
      ]
    });
    res.json(logs);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

module.exports = { getDashboardStats, getRecentMalpractices };
