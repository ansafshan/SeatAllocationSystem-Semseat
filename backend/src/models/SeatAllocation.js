const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/db');

const SeatAllocation = sequelize.define('SeatAllocation', {
  id: {
    type: DataTypes.INTEGER,
    autoIncrement: true,
    primaryKey: true
  },
  exam_day_id: {
    type: DataTypes.INTEGER,
    allowNull: false
  },
  student_id: {
    type: DataTypes.INTEGER,
    allowNull: false
  },
  hall_id: {
    type: DataTypes.INTEGER,
    allowNull: false
  },
  bench_row: {
    type: DataTypes.INTEGER,
    allowNull: false
  },
  bench_col: {
    type: DataTypes.INTEGER,
    allowNull: false
  },
  seat_position: {
    type: DataTypes.ENUM('L', 'M', 'R'),
    allowNull: false
  }
}, {
  tableName: 'seat_allocations',
  timestamps: true,
  createdAt: 'created_at',
  updatedAt: false,
  indexes: [
    {
      unique: true,
      name: 'unique_seat',
      fields: ['exam_day_id', 'hall_id', 'bench_row', 'bench_col', 'seat_position']
    },
    {
      unique: true,
      name: 'unique_student_session',
      fields: ['exam_day_id', 'student_id']
    }
  ]
});

module.exports = SeatAllocation;
