const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/db');

const InvigilatorAssignment = sequelize.define('InvigilatorAssignment', {
  id: {
    type: DataTypes.INTEGER,
    autoIncrement: true,
    primaryKey: true
  },
  teacher_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: {
      model: 'teachers',
      key: 'id'
    }
  },
  scheduled_exam_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: {
      model: 'scheduled_exams',
      key: 'id'
    }
  }
}, {
  tableName: 'invigilator_assignments',
  timestamps: false
});

module.exports = InvigilatorAssignment;
