const { Department } = require('../models');

// @desc    Get all departments
// @route   GET /api/departments
// @access  Private/Admin
const getDepartments = async (req, res) => {
  try {
    const departments = await Department.findAll({
      order: [['created_at', 'DESC']]
    });
    res.json(departments);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// @desc    Create a department
// @route   POST /api/departments
// @access  Private/Admin
const createDepartment = async (req, res) => {
  const { name } = req.body;
  try {
    const department = await Department.create({ name });
    res.status(201).json(department);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

// @desc    Update a department
// @route   PUT /api/departments/:id
// @access  Private/Admin
const updateDepartment = async (req, res) => {
  try {
    const department = await Department.findByPk(req.params.id);
    if (department) {
      department.name = req.body.name || department.name;
      const updatedDepartment = await department.save();
      res.json(updatedDepartment);
    } else {
      res.status(404).json({ message: 'Department not found' });
    }
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

// @desc    Delete a department
// @route   DELETE /api/departments/:id
// @access  Private/Admin
const deleteDepartment = async (req, res) => {
  try {
    const department = await Department.findByPk(req.params.id);
    if (department) {
      await department.destroy();
      res.json({ message: 'Department removed' });
    } else {
      res.status(404).json({ message: 'Department not found' });
    }
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

module.exports = {
  getDepartments,
  createDepartment,
  updateDepartment,
  deleteDepartment
};
