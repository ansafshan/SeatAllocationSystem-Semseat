const { Teacher, User, Department, Subject, HallTeacher, ExamDay, Session, Hall, SeatAllocation, Student, Batch, MalpracticeLog, sequelize } = require('../models');

const getTeachers = async (req, res) => {
  try {
    const teachers = await Teacher.findAll({
      include: [
        { model: User, attributes: ['name', 'email'] },
        { model: Department, attributes: ['name'] },
        { model: Subject, attributes: ['name', 'code'] }
      ],
      order: [['created_at', 'DESC']]
    });
    res.json(teachers);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const createTeacher = async (req, res) => {
  const { name, email, staff_id, dept_id, subject_id } = req.body;
  const t = await sequelize.transaction();
  try {
    const defaultPassword = `${staff_id}@edu`.toLowerCase();

    const user = await User.create({
      name, email, role: 'teacher', password_hash: defaultPassword
    }, { transaction: t });

    const teacher = await Teacher.create({
      user_id: user.id, staff_id, dept_id, subject_id
    }, { transaction: t });

    await t.commit();
    const fullTeacher = await Teacher.findByPk(teacher.id, {
      include: [
        { model: User, attributes: ['name', 'email'] },
        { model: Department, attributes: ['name'] },
        { model: Subject, attributes: ['name', 'code'] }
      ]
    });
    res.status(201).json(fullTeacher);
  } catch (error) {
    await t.rollback();
    res.status(400).json({ message: error.message });
  }
};

const updateTeacher = async (req, res) => {
  const { name, email, staff_id, dept_id, subject_id } = req.body;
  const t = await sequelize.transaction();
  try {
    const teacher = await Teacher.findByPk(req.params.id, { include: [User] });
    if (!teacher) return res.status(404).json({ message: 'Teacher not found' });

    teacher.staff_id = staff_id || teacher.staff_id;
    teacher.dept_id = dept_id || teacher.dept_id;
    teacher.subject_id = subject_id || teacher.subject_id;
    await teacher.save({ transaction: t });

    if (name || email) {
      teacher.User.name = name || teacher.User.name;
      teacher.User.email = email || teacher.User.email;
      await teacher.User.save({ transaction: t });
    }

    await t.commit();
    const updated = await Teacher.findByPk(teacher.id, {
      include: [User, Department, Subject]
    });
    res.json(updated);
  } catch (error) {
    await t.rollback();
    res.status(400).json({ message: error.message });
  }
};

const deleteTeacher = async (req, res) => {
  try {
    const teacher = await Teacher.findByPk(req.params.id, { include: [User] });
    if (teacher) {
      await teacher.User.destroy();
      res.json({ message: 'Teacher removed' });
    } else {
      res.status(404).json({ message: 'Teacher not found' });
    }
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const getTeacherDuties = async (req, res) => {
  try {
    const teacher = await Teacher.findOne({ where: { user_id: req.user.id } });
    if (!teacher) return res.status(404).json({ message: 'Teacher profile not found' });

    const duties = await HallTeacher.findAll({
      where: { teacher_id: teacher.id },
      include: [
        { model: Hall },
        { model: ExamDay, include: [Session] }
      ],
      order: [[ExamDay, 'date', 'ASC'], [ExamDay, 'slot', 'ASC']]
    });
    res.json(duties);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const getHallSeats = async (req, res) => {
  try {
    const allocations = await SeatAllocation.findAll({
      where: { exam_day_id: req.params.dayId, hall_id: req.params.hallId },
      include: [
        { model: Student, include: [User, Department, Batch] },
        { model: Hall }
      ],
      order: [['bench_row', 'ASC'], ['bench_col', 'ASC'], ['seat_position', 'ASC']]
    });
    res.json(allocations);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const reportMalpractice = async (req, res) => {
  const { student_id, exam_day_id, reason } = req.body;
  try {
    const log = await MalpracticeLog.create({
      student_id,
      exam_day_id,
      reason,
    });
    res.status(201).json(log);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

module.exports = { getTeachers, createTeacher, updateTeacher, deleteTeacher, getTeacherDuties, getHallSeats, reportMalpractice };
