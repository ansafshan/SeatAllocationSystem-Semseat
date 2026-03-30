const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/db');

const ExamDaySubject = sequelize.define('ExamDaySubject', {
  id: {
    type: DataTypes.INTEGER,
    autoIncrement: true,
    primaryKey: true
  },
  exam_day_id: {
    type: DataTypes.INTEGER,
    allowNull: false
  },
  subject_id: {
    type: DataTypes.INTEGER,
    allowNull: false
  }
}, {
  tableName: 'exam_day_subjects',
  timestamps: true,
  createdAt: 'created_at',
  updatedAt: false
});

module.exports = ExamDaySubject;
