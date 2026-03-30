const { User, Department, Batch, Subject, Student, Teacher, Hall, sequelize } = require('./models');

const seedStressTest = async () => {
  try {
    console.log('--- STARTING BULK STRESS TEST SEEDING ---');
    await sequelize.sync({ force: true });
    console.log('Database cleared.');

    // 1. Departments
    const depts = [
      { name: 'Computer Science', code: 'CS' },
      { name: 'Electronics', code: 'EC' },
      { name: 'Mechanical', code: 'ME' },
      { name: 'Civil Engineering', code: 'CE' }
    ];
    const createdDepts = [];
    for (const d of depts) {
      createdDepts.push(await Department.create({ name: d.name }));
    }

    // 2. Batch
    const batch = await Batch.create({ name: '2022-26', dept_id: createdDepts[0].id });

    // 3. Subjects (4 subjects, 1 per dept)
    const subjects = [
      { name: 'Compiler Design', code: 'CST302', dept_id: createdDepts[0].id },
      { name: 'Computer Networks', code: 'ECT304', dept_id: createdDepts[1].id },
      { name: 'Thermal Engineering', code: 'MET306', dept_id: createdDepts[2].id },
      { name: 'Structural Analysis', code: 'CET308', dept_id: createdDepts[3].id }
    ];
    const createdSubs = [];
    for (const s of subjects) {
      createdSubs.push(await Subject.create({ ...s, batch_id: batch.id }));
    }

    // 4. Admin & Teachers
    await User.create({ name: 'Admin', email: 'admin@edu.ktu', password_hash: 'admin', role: 'admin' });

    for (const sub of createdSubs) {
      const staffId = `TCH${sub.code}`;
      const user = await User.create({
        name: `Prof. ${sub.code}`,
        email: `teacher_${sub.code.toLowerCase()}@edu.ktu`,
        password_hash: `${staffId}@edu`.toLowerCase(),
        role: 'teacher'
      });
      await Teacher.create({
        user_id: user.id,
        staff_id: staffId,
        dept_id: sub.dept_id,
        subject_id: sub.id
      });
    }
    console.log('Teachers seeded.');

    // 5. Bulk Students (100 per department = 400 total)
    console.log('Generating 400 students...');
    const dummyDob = '2004-01-01';
    const birthYear = new Date(dummyDob).getFullYear();

    for (let dIdx = 0; dIdx < depts.length; dIdx++) {
      const dept = createdDepts[dIdx];
      const deptCode = depts[dIdx].code;
      
      for (let i = 1; i <= 100; i++) {
        const regNo = `CEC22${deptCode}${i.toString().padStart(3, '0')}`;
        const rollNo = `S6${deptCode}${i <= 50 ? 'A' : 'B'}${i.toString().padStart(2, '0')}`;
        const name = `${deptCode} Student ${i}`;
        const firstName = name.split(' ')[0];
        const password = `${firstName}@${birthYear}`.toLowerCase();

        const user = await User.create({
          name: name,
          email: `${regNo.toLowerCase()}@college.edu`,
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
      }
      console.log(`Seeded 100 students for ${deptCode}`);
    }

    // 6. Halls (8 Halls, each 7x3 layout)
    console.log('Generating 8 halls (7x3 layout)...');
    for (let i = 1; i <= 8; i++) {
      await Hall.create({
        name: `LH ${100 + i}`,
        rows: 7,
        cols: 3
      });
    }

    console.log('--- STRESS TEST SEEDING COMPLETE ---');
    console.log('Total Students: 400');
    console.log('Total Halls: 8 (Total Benches: 168)');
    console.log('Max Capacity: 504 seats (or 336 if interleaved)');
    process.exit(0);
  } catch (error) {
    console.error(error);
    process.exit(1);
  }
};

seedStressTest();
