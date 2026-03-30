const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/db');

const Student = sequelize.define('Student', {
  id: {
    type: DataTypes.INTEGER,
    autoIncrement: true,
    primaryKey: true
  },
  user_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
    unique: true
  },
  reg_no: {
    type: DataTypes.STRING(255),
    allowNull: false,
    unique: true
  },
  roll_no: {
    type: DataTypes.STRING(255),
    allowNull: false
  },
  dob: {
    type: DataTypes.DATEONLY,
    allowNull: false
  },
  dept_id: {
    type: DataTypes.INTEGER,
    allowNull: false
  },
  batch_id: {
    type: DataTypes.INTEGER,
    allowNull: false
  }
}, {
  tableName: 'students',
  timestamps: true,
  createdAt: 'created_at',
  updatedAt: false,
  indexes: [
    {
      unique: false,
      fields: ['reg_no']
    },
    {
      unique: false,
      fields: ['roll_no']
    }
  ]
});

module.exports = Student;
