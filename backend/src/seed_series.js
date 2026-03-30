const { User, Department, Batch, Subject, Student, Teacher, Hall, Session, ExamDay, sequelize } = require('./models');

const seedSeriesData = async () => {
  try {
    console.log('Clearing database and seeding Series Exam data (Comprehensive)...');
    await sequelize.sync({ force: true });
    console.log('Tables cleared.');

    // 1. Departments
    const depts = {
      EC: await Department.create({ name: 'Electronics & Communication' }),
      CS: await Department.create({ name: 'Computer Science & Engineering' }),
      AD: await Department.create({ name: 'Artificial Intelligence & Data Science' }),
      EEE: await Department.create({ name: 'Electrical & Electronics Engineering' }),
    };
    console.log('Departments seeded.');

    // 2. Batches
    const batches = {
      S8EC: await Batch.create({ name: 'S8 EC', dept_id: depts.EC.id }),
      S6CS: await Batch.create({ name: 'S6 CS', dept_id: depts.CS.id }),
      S6AD: await Batch.create({ name: 'S6 AD', dept_id: depts.AD.id }),
      S6EC: await Batch.create({ name: 'S6 EC', dept_id: depts.EC.id }),
      S6EEE: await Batch.create({ name: 'S6 EEE', dept_id: depts.EEE.id }),
      S4CS: await Batch.create({ name: 'S4 CS', dept_id: depts.CS.id }),
      S4AD: await Batch.create({ name: 'S4 AD', dept_id: depts.AD.id }),
      S4EC: await Batch.create({ name: 'S4 EC', dept_id: depts.EC.id }),
      S4EEE: await Batch.create({ name: 'S4 EEE', dept_id: depts.EEE.id }),
    };
    console.log('Batches seeded.');

    // 3. Subjects (Ensuring EVERY batch has at least one subject)
    const subjectData = [
      { name: 'ECT402', code: 'ECT402', dept_id: depts.EC.id, batch_id: batches.S8EC.id },
      { name: 'CST306', code: 'CST306', dept_id: depts.CS.id, batch_id: batches.S6CS.id },
      { name: 'ADT302', code: 'ADT302', dept_id: depts.AD.id, batch_id: batches.S6AD.id }, 
      { name: 'ECT302', code: 'ECT302', dept_id: depts.EC.id, batch_id: batches.S6EC.id },
      { name: 'EEE302', code: 'EEE302', dept_id: depts.EEE.id, batch_id: batches.S6EEE.id },
      { name: 'GMAT401', code: 'GMAT401', dept_id: depts.CS.id, batch_id: batches.S4CS.id },
      { name: 'GBMAT401', code: 'GBMAT401', dept_id: depts.AD.id, batch_id: batches.S4AD.id },
      { name: 'ECT204', code: 'ECT204', dept_id: depts.EC.id, batch_id: batches.S4EC.id }, 
      { name: 'EET204', code: 'EET204', dept_id: depts.EEE.id, batch_id: batches.S4EEE.id }, 
    ];
    
    const createdSubjects = {};
    for (const sub of subjectData) {
      const s = await Subject.create(sub);
      createdSubjects[sub.code] = s;
    }
    console.log('Subjects seeded.');

    // 4. Admin & Teachers
    await User.create({ name: 'Admin', email: 'admin@semseat.com', password_hash: 'admin', role: 'admin' });
    
    for (const code in createdSubjects) {
      const sub = createdSubjects[code];
      const staffId = `STF${code}`;
      const teacherUser = await User.create({
        name: `Teacher ${code}`,
        email: `teacher_${code.toLowerCase()}@college.edu`,
        password_hash: `${staffId}@edu`.toLowerCase(),
        role: 'teacher'
      });
      await Teacher.create({ 
        user_id: teacherUser.id, 
        staff_id: staffId,
        dept_id: sub.dept_id, 
        subject_id: sub.id 
      });
    }
    console.log('Admin and Teachers seeded.');

    // 5. Students
    const studentRanges = [
      { batchKey: 'S8EC', prefix: 'S8EC', start: 1, end: 32, deptKey: 'EC' },
      { batchKey: 'S6CS', prefix: 'S6CSA', start: 1, end: 66, deptKey: 'CS' },
      { batchKey: 'S6CS', prefix: 'S6CSB', start: 1, end: 66, deptKey: 'CS' },
      { batchKey: 'S6AD', prefix: 'S6AD', start: 1, end: 59, deptKey: 'AD' },
      { batchKey: 'S6EC', prefix: 'S6EC', start: 1, end: 40, deptKey: 'EC' },
      { batchKey: 'S6EEE', prefix: 'S6EEE', start: 1, end: 19, deptKey: 'EEE' },
      { batchKey: 'S4CS', prefix: 'S4CSA', start: 1, end: 69, deptKey: 'CS' },
      { batchKey: 'S4CS', prefix: 'S4CSB', start: 1, end: 69, deptKey: 'CS' },
      { batchKey: 'S4AD', prefix: 'S4AD', start: 1, end: 61, deptKey: 'AD' },
      { batchKey: 'S4EC', prefix: 'S4EC', start: 1, end: 69, deptKey: 'EC' },
      { batchKey: 'S4EEE', prefix: 'S4EEE', start: 1, end: 28, deptKey: 'EEE' },
    ];

    const dummyDob = '2005-01-01';
    const birthYear = new Date(dummyDob).getFullYear();

    let totalStudents = 0;
    for (const range of studentRanges) {
      const batch = batches[range.batchKey];
      const dept = depts[range.deptKey];
      for (let i = range.start; i <= range.end; i++) {
        const num = i.toString().padStart(2, '0');
        const rollNo = `${range.prefix}${num}`;
        const regNo = `REG${range.prefix}${num}`;
        const name = `Student ${rollNo}`;
        const firstName = name.split(' ')[0];
        const password = `${firstName}@${birthYear}`.toLowerCase();

        const user = await User.create({
          name: name,
          email: `${rollNo.toLowerCase()}@college.edu`,
          password_hash: password,
          role: 'student'
        });

        await Student.create({
          user_id: user.id,
          reg_no: regNo,
          roll_no: rollNo,
          dob: dummyDob,
          dept_id: dept.id,
          batch_id: batch.id
        });
        totalStudents++;
      }
    }
    console.log(`Successfully seeded ${totalStudents} students.`);

    // 6. Halls
    const hallNames = ['601', '602', '603', '610', '616', '423', '412', '501', '503', '504', '413', '612'];
    for (const name of hallNames) {
      await Hall.create({ name: `Room ${name}`, rows: 6, cols: 3 });
    }
    console.log('12 rooms seeded (6x3).');

    // 7. Session & Initial Exam Day
    const session = await Session.create({ name: 'Series Exam March 2026', type: 'series' });
    await ExamDay.create({ session_id: session.id, date: '2026-03-30', slot: 'FN' });
    console.log('Session and initial Exam Day seeded.');

    console.log('All series seed data applied with full batch coverage!');
  } catch (error) {
    console.error('Seeding error:', error);
  } finally {
    await sequelize.close();
  }
};

seedSeriesData();
