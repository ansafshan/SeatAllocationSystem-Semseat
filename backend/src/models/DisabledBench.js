const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/db');

const DisabledBench = sequelize.define('DisabledBench', {
  id: {
    type: DataTypes.INTEGER,
    autoIncrement: true,
    primaryKey: true
  },
  hall_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: {
      model: 'halls',
      key: 'id'
    }
  },
  bench_row: {
    type: DataTypes.INTEGER,
    allowNull: false
  },
  bench_col: {
    type: DataTypes.INTEGER,
    allowNull: false
  }
}, {
  tableName: 'disabled_benches',
  timestamps: false,
  indexes: [
    {
      unique: true,
      fields: ['hall_id', 'bench_row', 'bench_col']
    }
  ]
});

module.exports = DisabledBench;
