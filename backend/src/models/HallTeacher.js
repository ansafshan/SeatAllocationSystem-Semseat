const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/db');

const HallTeacher = sequelize.define('HallTeacher', {
  id: {
    type: DataTypes.INTEGER,
    autoIncrement: true,
    primaryKey: true
  },
  exam_day_id: {
    type: DataTypes.INTEGER,
    allowNull: false
  },
  hall_id: {
    type: DataTypes.INTEGER,
    allowNull: false
  },
  teacher_id: {
    type: DataTypes.INTEGER,
    allowNull: false
  }
}, {
  tableName: 'hall_teachers',
  timestamps: true,
  createdAt: 'created_at',
  updatedAt: false,
  indexes: [
    {
      unique: true,
      name: 'unique_teacher_session',
      fields: ['exam_day_id', 'teacher_id']
    }
  ]
});

module.exports = HallTeacher;
