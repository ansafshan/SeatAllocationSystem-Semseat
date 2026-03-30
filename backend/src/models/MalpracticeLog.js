const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/db');

const MalpracticeLog = sequelize.define('MalpracticeLog', {
  id: {
    type: DataTypes.INTEGER,
    autoIncrement: true,
    primaryKey: true
  },
  student_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: {
      model: 'students',
      key: 'id'
    }
  },
  exam_day_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: {
      model: 'exam_days',
      key: 'id'
    }
  },
  reported_by_teacher_id: {
    type: DataTypes.INTEGER,
    allowNull: true, // Allow null for admin reports if any, though usually teachers report
    references: {
      model: 'teachers',
      key: 'id'
    }
  },
  reason: {
    type: DataTypes.TEXT,
    allowNull: false
  }
}, {
  tableName: 'malpractice_logs',
  timestamps: true,
  createdAt: 'created_at',
  updatedAt: false
});

module.exports = MalpracticeLog;
