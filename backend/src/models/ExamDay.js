const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/db');

const ExamDay = sequelize.define('ExamDay', {
  id: {
    type: DataTypes.INTEGER,
    autoIncrement: true,
    primaryKey: true
  },
  session_id: {
    type: DataTypes.INTEGER,
    allowNull: false
  },
  date: {
    type: DataTypes.DATEONLY,
    allowNull: false
  },
  slot: {
    type: DataTypes.ENUM('FN', 'AN'),
    allowNull: false
  }
}, {
  tableName: 'exam_days',
  timestamps: true,
  createdAt: 'created_at',
  updatedAt: false,
  indexes: [
    {
      unique: false,
      fields: ['date', 'slot']
    }
  ]
});

module.exports = ExamDay;
