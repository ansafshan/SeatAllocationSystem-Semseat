const { Student, User, Department, Batch, SeatAllocation, ExamDay, Session, Hall, MalpracticeLog, sequelize } = require('../models');
const fs = require('fs');
const csv = require('csv-parser');

const getStudents = async (req, res) => {
  try {
    const students = await Student.findAll({
      include: [
        { model: User, attributes: ['name', 'email'] },
        { model: Department, attributes: ['name'] },
        { model: Batch, attributes: ['name'] }
      ],
      order: [['created_at', 'DESC']]
    });
    res.json(students);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const createStudent = async (req, res) => {
  const { name, email, reg_no, roll_no, dob, dept_id, batch_id } = req.body;
  const t = await sequelize.transaction();

  try {
    const birthYear = new Date(dob).getFullYear();
    const firstName = name.split(' ')[0];
    const defaultPassword = `${firstName}@${birthYear}`.toLowerCase();

    const user = await User.create({
      name, email, role: 'student', password_hash: defaultPassword
    }, { transaction: t });

    const student = await Student.create({
      user_id: user.id, reg_no, roll_no, dob, dept_id, batch_id
    }, { transaction: t });

    await t.commit();

    const fullStudent = await Student.findByPk(student.id, {
      include: [
        { model: User, attributes: ['name', 'email'] },
        { model: Department, attributes: ['name'] },
        { model: Batch, attributes: ['name'] }
      ]
    });
    res.status(201).json(fullStudent);
  } catch (error) {
    await t.rollback();
    res.status(400).json({ message: error.message });
  }
};

const bulkUploadStudents = async (req, res) => {
  if (!req.file) return res.status(400).json({ message: 'No file uploaded' });

  const results = [];
  fs.createReadStream(req.file.path)
    .pipe(csv())
    .on('data', (data) => results.push(data))
    .on('end', async () => {
      const t = await sequelize.transaction();
      try {
        for (const row of results) {
          const dob = row.dob; // Expecting YYYY-MM-DD
          const birthYear = new Date(dob).getFullYear();
          const firstName = row.name.split(' ')[0];
          const defaultPassword = `${firstName}@${birthYear}`.toLowerCase();

          const user = await User.create({
            name: row.name,
            email: row.email,
            role: 'student',
            password_hash: defaultPassword
          }, { transaction: t });

          await Student.create({
            user_id: user.id,
            reg_no: row.reg_no,
            roll_no: row.roll_no,
            dob: dob,
            dept_id: row.dept_id,
            batch_id: row.batch_id
          }, { transaction: t });
        }
        await t.commit();
        fs.unlinkSync(req.file.path);
        res.status(201).json({ message: `Successfully uploaded ${results.length} students` });
      } catch (error) {
        await t.rollback();
        fs.unlinkSync(req.file.path);
        res.status(400).json({ message: error.message });
      }
    });
};

const updateStudent = async (req, res) => {
  const { name, email, reg_no, roll_no, dept_id, batch_id } = req.body;
  const t = await sequelize.transaction();
  try {
    const student = await Student.findByPk(req.params.id, { include: [User] });
    if (!student) return res.status(404).json({ message: 'Student not found' });

    student.reg_no = reg_no || student.reg_no;
    student.roll_no = roll_no || student.roll_no;
    student.dept_id = dept_id || student.dept_id;
    student.batch_id = batch_id || student.batch_id;
    await student.save({ transaction: t });

    if (name || email) {
      student.User.name = name || student.User.name;
      student.User.email = email || student.User.email;
      await student.User.save({ transaction: t });
    }

    await t.commit();
    const updated = await Student.findByPk(student.id, {
      include: [User, Department, Batch]
    });
    res.json(updated);
  } catch (error) {
    await t.rollback();
    res.status(400).json({ message: error.message });
  }
};

const deleteStudent = async (req, res) => {
  const t = await sequelize.transaction();
  try {
    const student = await Student.findByPk(req.params.id);
    if (!student) {
      await t.rollback();
      return res.status(404).json({ message: 'Student not found' });
    }

    const userId = student.user_id;
    
    // Deleting the student record
    await student.destroy({ transaction: t });
    
    // Deleting the associated user record
    const user = await User.findByPk(userId);
    if (user) {
      await user.destroy({ transaction: t });
    }

    await t.commit();
    res.json({ message: 'Student and associated user removed' });
  } catch (error) {
    await t.rollback();
    res.status(500).json({ message: error.message });
  }
};

const getStudentSeats = async (req, res) => {
  try {
    const student = await Student.findOne({ where: { user_id: req.user.id } });
    if (!student) return res.status(404).json({ message: 'Student profile not found' });

    const seats = await SeatAllocation.findAll({
      where: { student_id: student.id },
      include: [
        { model: Hall },
        { model: ExamDay, include: [Session] }
      ],
      order: [[ExamDay, 'date', 'ASC'], [ExamDay, 'slot', 'ASC']]
    });
    res.json(seats);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const getMalpracticeHistory = async (req, res) => {
  try {
    const history = await MalpracticeLog.findAll({
      where: { student_id: req.params.id },
      include: [{ model: ExamDay, include: [Session] }],
      order: [['created_at', 'DESC']],
    });
    res.json(history);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

module.exports = { getStudents, createStudent, bulkUploadStudents, updateStudent, deleteStudent, getStudentSeats, getMalpracticeHistory };
