const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/db');

const Batch = sequelize.define('Batch', {
  id: {
    type: DataTypes.INTEGER,
    autoIncrement: true,
    primaryKey: true
  },
  name: {
    type: DataTypes.STRING(255),
    allowNull: false
  },
  dept_id: {
    type: DataTypes.INTEGER,
    allowNull: false
  }
}, {
  tableName: 'batches',
  timestamps: true,
  createdAt: 'created_at',
  updatedAt: false
});

module.exports = Batch;
