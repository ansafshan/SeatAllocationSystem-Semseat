const { Sequelize } = require('sequelize');
const dotenv = require('dotenv');

dotenv.config({ path: './.env' });

const sequelize = new Sequelize(
  process.env.DB_NAME,
  process.env.DB_USER,
  process.env.DB_PASSWORD,
  {
    host: process.env.DB_HOST,
    dialect: 'mysql'
  }
);

const connectDB = async () => {
  try {
    await sequelize.authenticate();
    console.log('MySQL Connected...');
    
    // This will sync models and create missing tables without losing data
    await sequelize.sync({ alter: true }); 
    console.log('Database synced!');

  } catch (error) {
    console.error('Unable to connect to the database:', error);
    process.exit(1);
  }
};

module.exports = { sequelize, connectDB };
