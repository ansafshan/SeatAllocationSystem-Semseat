const { sequelize } = require('../config/db'); // Import sequelize
const User = require('./User');
const Department = require('./Department');
const Batch = require('./Batch');
const Subject = require('./Subject');
const Student = require('./Student');
const Teacher = require('./Teacher');
const Hall = require('./Hall');
const Session = require('./Session');
const ExamDay = require('./ExamDay');
const ExamDaySubject = require('./ExamDaySubject');
const SeatAllocation = require('./SeatAllocation');
const HallTeacher = require('./HallTeacher');
const MalpracticeLog = require('./MalpracticeLog');
const ScheduledExam = require('./ScheduledExam');
const InvigilatorAssignment = require('./InvigilatorAssignment');
const DisabledBench = require('./DisabledBench');

// Department - Batch
Department.hasMany(Batch, { foreignKey: 'dept_id', onDelete: 'CASCADE' });
Batch.belongsTo(Department, { foreignKey: 'dept_id' });

// Department - Subject
Department.hasMany(Subject, { foreignKey: 'dept_id', onDelete: 'CASCADE' });
Subject.belongsTo(Department, { foreignKey: 'dept_id' });

// Batch - Subject
Batch.hasMany(Subject, { foreignKey: 'batch_id', onDelete: 'CASCADE' });
Subject.belongsTo(Batch, { foreignKey: 'batch_id' });

// User - Student
User.hasOne(Student, { foreignKey: 'user_id', onDelete: 'CASCADE' });
Student.belongsTo(User, { foreignKey: 'user_id', onDelete: 'CASCADE' });

// Department - Student
Department.hasMany(Student, { foreignKey: 'dept_id', onDelete: 'CASCADE' });
Student.belongsTo(Department, { foreignKey: 'dept_id' });

// Batch - Student
Batch.hasMany(Student, { foreignKey: 'batch_id', onDelete: 'CASCADE' });
Student.belongsTo(Batch, { foreignKey: 'batch_id' });

// User - Teacher
User.hasOne(Teacher, { foreignKey: 'user_id', onDelete: 'CASCADE' });
Teacher.belongsTo(User, { foreignKey: 'user_id' });

// Department - Teacher
Department.hasMany(Teacher, { foreignKey: 'dept_id', onDelete: 'CASCADE' });
Teacher.belongsTo(Department, { foreignKey: 'dept_id' });

// Subject - Teacher
Subject.hasMany(Teacher, { foreignKey: 'subject_id', onDelete: 'SET NULL' });
Teacher.belongsTo(Subject, { foreignKey: 'subject_id' });

// Session - ExamDay
Session.hasMany(ExamDay, { foreignKey: 'session_id', onDelete: 'CASCADE' });
ExamDay.belongsTo(Session, { foreignKey: 'session_id' });

// ExamDay - ExamDaySubject
ExamDay.hasMany(ExamDaySubject, { foreignKey: 'exam_day_id', onDelete: 'CASCADE' });
ExamDaySubject.belongsTo(ExamDay, { foreignKey: 'exam_day_id' });

// Subject - ExamDaySubject
Subject.hasMany(ExamDaySubject, { foreignKey: 'subject_id', onDelete: 'CASCADE' });
ExamDaySubject.belongsTo(Subject, { foreignKey: 'subject_id' });

// ExamDay - ScheduledExam
ExamDay.hasMany(ScheduledExam, { foreignKey: 'exam_day_id', onDelete: 'CASCADE' });
ScheduledExam.belongsTo(ExamDay, { foreignKey: 'exam_day_id' });

// Subject - ScheduledExam
Subject.hasMany(ScheduledExam, { foreignKey: 'subject_id', onDelete: 'CASCADE' });
ScheduledExam.belongsTo(Subject, { foreignKey: 'subject_id' });

// Teacher - InvigilatorAssignment
Teacher.hasMany(InvigilatorAssignment, { foreignKey: 'teacher_id', onDelete: 'CASCADE' });
InvigilatorAssignment.belongsTo(Teacher, { foreignKey: 'teacher_id' });

// ScheduledExam - InvigilatorAssignment
ScheduledExam.hasMany(InvigilatorAssignment, { foreignKey: 'scheduled_exam_id', onDelete: 'CASCADE' });
InvigilatorAssignment.belongsTo(ScheduledExam, { foreignKey: 'scheduled_exam_id' });

// ExamDay - SeatAllocation
ExamDay.hasMany(SeatAllocation, { foreignKey: 'exam_day_id', onDelete: 'CASCADE' });
SeatAllocation.belongsTo(ExamDay, { foreignKey: 'exam_day_id' });

// Student - SeatAllocation
Student.hasMany(SeatAllocation, { foreignKey: 'student_id', onDelete: 'CASCADE' });
SeatAllocation.belongsTo(Student, { foreignKey: 'student_id' });

// Hall - SeatAllocation
Hall.hasMany(SeatAllocation, { foreignKey: 'hall_id', onDelete: 'CASCADE' });
SeatAllocation.belongsTo(Hall, { foreignKey: 'hall_id' });

// ExamDay - HallTeacher
ExamDay.hasMany(HallTeacher, { foreignKey: 'exam_day_id', onDelete: 'CASCADE' });
HallTeacher.belongsTo(ExamDay, { foreignKey: 'exam_day_id' });

// Hall - HallTeacher
Hall.hasMany(HallTeacher, { foreignKey: 'hall_id', onDelete: 'CASCADE' });
HallTeacher.belongsTo(Hall, { foreignKey: 'hall_id' });

// Teacher - HallTeacher
Teacher.hasMany(HallTeacher, { foreignKey: 'teacher_id', onDelete: 'CASCADE' });
HallTeacher.belongsTo(Teacher, { foreignKey: 'teacher_id' });

// Student - MalpracticeLog
Student.hasMany(MalpracticeLog, { foreignKey: 'student_id', onDelete: 'CASCADE' });
MalpracticeLog.belongsTo(Student, { foreignKey: 'student_id' });

// ExamDay - MalpracticeLog
ExamDay.hasMany(MalpracticeLog, { foreignKey: 'exam_day_id', onDelete: 'CASCADE' });
MalpracticeLog.belongsTo(ExamDay, { foreignKey: 'exam_day_id' });

// Teacher - MalpracticeLog
Teacher.hasMany(MalpracticeLog, { foreignKey: 'reported_by_teacher_id', onDelete: 'SET NULL' });
MalpracticeLog.belongsTo(Teacher, { foreignKey: 'reported_by_teacher_id' });

// ExamDay - DisabledBench
ExamDay.hasMany(DisabledBench, { foreignKey: 'exam_day_id', onDelete: 'CASCADE' });
DisabledBench.belongsTo(ExamDay, { foreignKey: 'exam_day_id' });

// Hall - DisabledBench
Hall.hasMany(DisabledBench, { foreignKey: 'hall_id', onDelete: 'CASCADE' });
DisabledBench.belongsTo(Hall, { foreignKey: 'hall_id' });

module.exports = {
  sequelize, // Export the instance
  User,
  Department,
  Batch,
  Subject,
  Student,
  Teacher,
  Hall,
  Session,
  ExamDay,
  ExamDaySubject,
  SeatAllocation,
  HallTeacher,
  MalpracticeLog,
  ScheduledExam,
  InvigilatorAssignment,
  DisabledBench
};
