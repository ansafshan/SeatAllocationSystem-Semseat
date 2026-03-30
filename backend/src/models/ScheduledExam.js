const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/db');

const ScheduledExam = sequelize.define('ScheduledExam', {
  id: {
    type: DataTypes.INTEGER,
    autoIncrement: true,
    primaryKey: true
  },
  exam_day_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: {
      model: 'exam_days',
      key: 'id'
    }
  },
  subject_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: {
      model: 'subjects',
      key: 'id'
    }
  }
}, {
  tableName: 'scheduled_exams',
  timestamps: false
});

module.exports = ScheduledExam;
