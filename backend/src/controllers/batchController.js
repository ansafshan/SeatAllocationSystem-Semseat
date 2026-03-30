const { Batch, Department } = require('../models');

// @desc    Get all batches
// @route   GET /api/batches
// @access  Private/Admin
const getBatches = async (req, res) => {
  try {
    const batches = await Batch.findAll({
      include: [{ model: Department, attributes: ['name'] }],
      order: [['created_at', 'DESC']]
    });
    res.json(batches);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// @desc    Create a batch
// @route   POST /api/batches
// @access  Private/Admin
const createBatch = async (req, res) => {
  const { name, dept_id } = req.body;
  try {
    const batch = await Batch.create({ name, dept_id });
    const fullBatch = await Batch.findByPk(batch.id, {
      include: [{ model: Department, attributes: ['name'] }]
    });
    res.status(201).json(fullBatch);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

// @desc    Update a batch
// @route   PUT /api/batches/:id
// @access  Private/Admin
const updateBatch = async (req, res) => {
  try {
    const batch = await Batch.findByPk(req.params.id);
    if (batch) {
      batch.name = req.body.name || batch.name;
      batch.dept_id = req.body.dept_id || batch.dept_id;
      await batch.save();
      
      const updatedBatch = await Batch.findByPk(batch.id, {
        include: [{ model: Department, attributes: ['name'] }]
      });
      res.json(updatedBatch);
    } else {
      res.status(404).json({ message: 'Batch not found' });
    }
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

// @desc    Delete a batch
// @route   DELETE /api/batches/:id
// @access  Private/Admin
const deleteBatch = async (req, res) => {
  try {
    const batch = await Batch.findByPk(req.params.id);
    if (batch) {
      await batch.destroy();
      res.json({ message: 'Batch removed' });
    } else {
      res.status(404).json({ message: 'Batch not found' });
    }
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

module.exports = {
  getBatches,
  createBatch,
  updateBatch,
  deleteBatch
};
