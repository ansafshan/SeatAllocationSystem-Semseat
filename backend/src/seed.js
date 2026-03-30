const { User, Department, Batch, Subject, Student, Hall, Teacher, sequelize } = require('./models');

const seedDatabase = async () => {
  try {
    console.log('Clearing database and seeding with correct CSE & ECE data...');

    // 0. Clear all existing tables
    await sequelize.sync({ force: true });
    console.log('All tables cleared and recreated.');

    // 1. Departments
    const noDept = await Department.create({ name: 'No department' });
    const cse = await Department.create({ name: 'Computer Science & Engineering' });
    const ece = await Department.create({ name: 'Electronics & Communication' });
    const civil = await Department.create({ name: 'Civil Engineering' });
    const mech = await Department.create({ name: 'Mechanical Engineering' });
    console.log('Departments seeded');

    // 2. Batches
    const noBatch = await Batch.create({ name: 'No batch', dept_id: noDept.id });
    const cseBatch = await Batch.create({ name: '2023-27', dept_id: cse.id });
    const eceBatch = await Batch.create({ name: '2023-27', dept_id: ece.id });
    console.log('Batches seeded');

    // 3. Subjects
    const noSubject = await Subject.create({ name: 'No subject', code: 'NONE', dept_id: noDept.id, batch_id: noBatch.id });
    const compilerDesign = await Subject.create({ name: 'Compiler Design', code: 'CST302', dept_id: cse.id, batch_id: cseBatch.id });
    const microProcessors = await Subject.create({ name: 'Micro Processors and Controllers', code: 'ECT306', dept_id: ece.id, batch_id: eceBatch.id });
    console.log('Subjects seeded');

    // 4. Admin & Teachers
    const admin = await User.create({ 
      name: 'Super Admin', 
      email: 'admin@semseat.com', 
      password_hash: 'admin', 
      role: 'admin' 
    });
    console.log('Admin seeded');

    const teachers = [
      { name: 'Dr. Smith', email: 'smith@college.edu', staff_id: 'TCH001', dept_id: cse.id, subject_id: compilerDesign.id }, 
      { name: 'Prof. Miller', email: 'miller@college.edu', staff_id: 'TCH002', dept_id: ece.id, subject_id: microProcessors.id },
      { name: 'Sajeev', email: 'sajeev@college.edu', staff_id: 'NT001', dept_id: noDept.id, subject_id: noSubject.id },
      { name: 'Hari', email: 'hari@college.edu', staff_id: 'NT002', dept_id: noDept.id, subject_id: noSubject.id },
      { name: 'Sumathi', email: 'sumathi@college.edu', staff_id: 'NT003', dept_id: noDept.id, subject_id: noSubject.id },
    ];

    for (const t of teachers) {
      const password = `${t.staff_id}@edu`.toLowerCase();
      const user = await User.create({
        name: t.name,
        email: t.email,
        password_hash: password,
        role: 'teacher'
      });
      await Teacher.create({
        user_id: user.id,
        staff_id: t.staff_id,
        dept_id: t.dept_id,
        subject_id: t.subject_id
      });
    }
    console.log('Teachers seeded');

    // 5. Students (120 CSE, 60 ECE)
    console.log('Seeding students...');
    const dummyDob = '2005-05-15';
    
    // CSE Students
    for (let i = 1; i <= 120; i++) {
      const regNo = `CEC23CS${i.toString().padStart(3, '0')}`;
      const rollNo = `S6CSA${i.toString().padStart(2, '0')}`;
      const name = `CSE Student ${i}`;
      const birthYear = new Date(dummyDob).getFullYear();
      const firstName = name.split(' ')[0];
      const password = `${firstName}@${birthYear}`.toLowerCase();

      const user = await User.create({
        name: name,
        email: `cse_student${i}@college.edu`,
        password_hash: password,
        role: 'student'
      });
      await Student.create({
        user_id: user.id,
        reg_no: regNo,
        roll_no: rollNo,
        dob: dummyDob,
        dept_id: cse.id,
        batch_id: cseBatch.id
      });
    }

    // ECE Students
    for (let i = 1; i <= 60; i++) {
      const regNo = `CEC23EC${i.toString().padStart(3, '0')}`;
      const rollNo = `S4ECA${i.toString().padStart(2, '0')}`;
      const name = `ECE Student ${i}`;
      const birthYear = new Date(dummyDob).getFullYear();
      const firstName = name.split(' ')[0];
      const password = `${firstName}@${birthYear}`.toLowerCase();

      const user = await User.create({
        name: name,
        email: `ece_student${i}@college.edu`,
        password_hash: password,
        role: 'student'
      });
      await Student.create({
        user_id: user.id,
        reg_no: regNo,
        roll_no: rollNo,
        dob: dummyDob,
        dept_id: ece.id,
        batch_id: eceBatch.id
      });
    }
    console.log('Students seeded successfully');

    // 6. Halls
    const halls = [
      { name: 'LH 201', rows: 6, cols: 5 },
      { name: 'LH 202', rows: 6, cols: 5 },
      { name: 'LH 203', rows: 6, cols: 5 },
    ];
    for (const hall of halls) {
      await Hall.create(hall);
    }
    console.log('Halls seeded');

    console.log('Database seeding complete!');
  } catch (error) {
    console.error('Error seeding database:', error);
  } finally {
    await sequelize.close();
  }
};

seedDatabase();
