const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/db');

const Hall = sequelize.define('Hall', {
  id: {
    type: DataTypes.INTEGER,
    autoIncrement: true,
    primaryKey: true
  },
  name: {
    type: DataTypes.STRING(255),
    allowNull: false,
    unique: true
  },
  rows: {
    type: DataTypes.INTEGER,
    allowNull: false
  },
  cols: {
    type: DataTypes.INTEGER,
    allowNull: false
  }
}, {
  tableName: 'halls',
  timestamps: true,
  createdAt: 'created_at',
  updatedAt: false
});

module.exports = Hall;
