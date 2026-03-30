const { SeatAllocation, Student, Hall, ExamDay, Session, Subject, ExamDaySubject, Teacher, HallTeacher, DisabledBench, User, Department, Batch, sequelize } = require('../models');
const { Op } = require('sequelize');

const allocateSeats = async (req, res) => {
  const { dayId } = req.params;
  console.log(`Starting allocation for dayId: ${dayId}`);
  const t = await sequelize.transaction();

  try {
    // 1. Clear previous allocations
    await SeatAllocation.destroy({ where: { exam_day_id: dayId }, transaction: t });
    await HallTeacher.destroy({ where: { exam_day_id: dayId }, transaction: t });

    // 2. Get session and subjects
    const examDay = await ExamDay.findByPk(dayId, { include: [Session] });
    const examSubjects = await ExamDaySubject.findAll({ 
      where: { exam_day_id: dayId },
      include: [Subject]
    });
    
    if (!examSubjects.length) throw new Error('No subjects scheduled for this exam day.');

    // 3. Get all students
    const totalInDb = await Student.count();
    console.log(`ALLOCATION: Global total students in DB: ${totalInDb}`);

    const studentPromises = examSubjects.map(async (es) => {
      const students = await Student.findAll({
        where: {
          dept_id: es.Subject.dept_id,
          batch_id: es.Subject.batch_id,
        },
        include: [User]
      });
      return students.map(s => {
        const data = s.get({ plain: true });
        data.subject_id = es.subject_id;
        return data;
      });
    });
    
    const studentGroups = await Promise.all(studentPromises);
    let allStudentsRaw = [].concat(...studentGroups);
    const studentMap = new Map();
    allStudentsRaw.forEach(student => {
      if (!studentMap.has(student.id)) studentMap.set(student.id, student);
    });
    
    let allStudents = Array.from(studentMap.values()).sort((a, b) => {
      const valA = (examDay.Session.type === 'series' ? a.roll_no : a.reg_no) || '';
      const valB = (examDay.Session.type === 'series' ? b.roll_no : b.reg_no) || '';
      return valA.localeCompare(valB, undefined, { numeric: true });
    });

    const totalStudentCount = allStudents.length;
    console.log(`ALLOCATION: Targeted students for this exam: ${totalStudentCount}`);

    // 4. Halls and Disabled Benches
    const allHalls = await Hall.findAll({ order: [['name', 'ASC']] });
    const disabledBenches = await DisabledBench.findAll();
    const disabledSet = new Set(disabledBenches.map(b => `${b.hall_id}-${b.bench_row}-${b.bench_col}`));

    // Log capacity for debugging
    let totalUsableSeats = 0;
    allHalls.forEach(h => {
      let hallCap = 0;
      for (let r = 1; r <= h.rows; r++) {
        for (let c = 1; c <= h.cols; c++) {
          if (!disabledSet.has(`${h.id}-${r}-${c}`)) {
            hallCap += (examSubjects.length > 1) ? 3 : 2; // Rule: 2 for single, 3 for multi
          }
        }
      }
      console.log(`ALLOCATION: Hall ${h.name} has ${hallCap} usable seats.`);
      totalUsableSeats += hallCap;
    });
    console.log(`ALLOCATION: Total usable seats across all halls: ${totalUsableSeats}`);

    // Group students by subject
    const studentsBySubject = [];
    for (let i = 0; i < examSubjects.length; i++) {
      const subjectId = examSubjects[i].subject_id;
      const students = allStudents.filter(s => s.subject_id === subjectId);
      if (students.length > 0) studentsBySubject.push(students);
    }

    // 5. Allocation Logic
    const allocationsToCreate = [];
    const benchOccupants = {}; 
    const usedHallIds = new Set();

    for (const subjectPool of studentsBySubject) {
      for (const student of subjectPool) {
        let placed = false;

        // Try every single hall
        for (let hIdx = 0; hIdx < allHalls.length; hIdx++) {
          const hall = allHalls[hIdx];
          if (placed) break;

          // Fill Column-wise (Top-to-Bottom)
          for (let c = 1; c <= hall.cols; c++) {
            if (placed) break;
            for (let r = 1; r <= hall.rows; r++) {
              if (placed) break;

              const benchKey = `${hall.id}-${r}-${c}`;
              if (disabledSet.has(benchKey)) continue;

              benchOccupants[benchKey] = benchOccupants[benchKey] || [];

              // Try seat positions
              for (const seatPos of ['L', 'R', 'M']) {
                if (placed) break;
                if (benchOccupants[benchKey].some(occ => occ.seat_position === seatPos)) continue;

                let isConflict = false;
                if (seatPos === 'M') {
                  isConflict = benchOccupants[benchKey].some(occ => occ.subject_id === student.subject_id);
                }

                if (!isConflict) {
                  allocationsToCreate.push({
                    exam_day_id: dayId,
                    student_id: student.id,
                    hall_id: hall.id,
                    bench_row: r,
                    bench_col: c,
                    seat_position: seatPos,
                    created_at: new Date()
                  });

                  benchOccupants[benchKey].push({
                    seat_position: seatPos,
                    subject_id: student.subject_id
                  });

                  usedHallIds.add(hall.id);
                  placed = true;
                }
              }
            }
          }
        }

        if (!placed) {
          throw new Error(`Insufficient capacity! Could not seat student ${student.reg_no}.`);
        }
      }
    }

    console.log(`ALLOCATION SUCCESS: ${allocationsToCreate.length} students seated.`);

    // 6. Teacher Assignment (Only for halls actually used)
    const subjectIds = examSubjects.map(es => es.subject_id);
    const availableTeachers = await Teacher.findAll({
      where: { [Op.or]: [{ subject_id: { [Op.notIn]: subjectIds } }, { subject_id: null }] }
    });

    const teachersToCreate = [];
    let teacherPool = [...availableTeachers];
    for (const hallId of Array.from(usedHallIds)) {
      const hall = allHalls.find(h => h.id === hallId);
      const totalBenches = hall.rows * hall.cols;
      const teachersNeeded = totalBenches > 21 ? 2 : 1;

      for (let i = 0; i < teachersNeeded; i++) {
        if (teacherPool.length > 0) {
          const teacher = teacherPool.shift();
          teachersToCreate.push({
            exam_day_id: dayId,
            hall_id: hall.id,
            teacher_id: teacher.id,
            created_at: new Date()
          });
        }
      }
    }
    
    // Execute Bulk Creates
    if (allocationsToCreate.length) {
      await SeatAllocation.bulkCreate(allocationsToCreate, { transaction: t });
    }
    if (teachersToCreate.length) {
      await HallTeacher.bulkCreate(teachersToCreate, { transaction: t });
    }

    await t.commit();
    
    const finalAllocations = await SeatAllocation.findAll({
      where: { exam_day_id: dayId },
      include: [
        { model: Student, include: [User, Department, Batch] },
        { model: Hall }
      ],
      order: [['hall_id', 'ASC'], ['bench_row', 'ASC'], ['bench_col', 'ASC'], ['seat_position', 'ASC']]
    });

    res.json({ message: 'Allocation completed successfully.', allocations: finalAllocations });
  } catch (error) {
    if (t) await t.rollback();
    console.error('ALLOCATION ERROR:', error);
    res.status(500).json({ message: error.message });
  }
};

const getAllocations = async (req, res) => {
  try {
    const allocations = await SeatAllocation.findAll({
      where: { exam_day_id: req.params.dayId },
      include: [
        { model: Student, include: [User, Department, Batch] },
        { model: Hall }
      ],
      order: [['hall_id', 'ASC'], ['bench_row', 'ASC'], ['bench_col', 'ASC'], ['seat_position', 'ASC']]
    });

    const teachers = await HallTeacher.findAll({
      where: { exam_day_id: req.params.dayId },
      include: [
        { model: Teacher, include: [User] },
        { model: Hall }
      ]
    });

    res.json({ allocations, teachers });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const deleteAllocations = async (req, res) => {
  const { dayId } = req.params;
  const t = await sequelize.transaction();
  try {
    await SeatAllocation.destroy({ where: { exam_day_id: dayId }, transaction: t });
    await HallTeacher.destroy({ where: { exam_day_id: dayId }, transaction: t });
    await t.commit();
    res.json({ message: 'Allocations for the day have been cleared.' });
  } catch (error) {
    await t.rollback();
    res.status(500).json({ message: 'Failed to delete allocations.', error: error.message });
  }
};

const assignTeacherManually = async (req, res) => {
  const { dayId } = req.params;
  const { hallId, teacherId } = req.body;

  try {
    // If teacher is already assigned on this day, delete the old assignment (to "move" them)
    await HallTeacher.destroy({
      where: { exam_day_id: dayId, teacher_id: teacherId }
    });

    const assignment = await HallTeacher.create({
      exam_day_id: dayId,
      hall_id: hallId,
      teacher_id: teacherId,
      created_at: new Date()
    });

    const fullAssignment = await HallTeacher.findByPk(assignment.id, {
      include: [
        { model: Teacher, include: [User] },
        { model: Hall }
      ]
    });

    res.json({ message: 'Teacher assigned/moved successfully.', assignment: fullAssignment });
  } catch (error) {
    console.error('MANUAL TEACHER ASSIGN ERROR:', error);
    res.status(500).json({ message: error.message });
  }
};

const removeTeacherAssignment = async (req, res) => {
  const { dayId, teacherId } = req.params;

  try {
    await HallTeacher.destroy({
      where: { exam_day_id: dayId, teacher_id: teacherId }
    });
    res.json({ success: true, message: 'Teacher assignment removed.' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

module.exports = { allocateSeats, getAllocations, deleteAllocations, assignTeacherManually, removeTeacherAssignment };
