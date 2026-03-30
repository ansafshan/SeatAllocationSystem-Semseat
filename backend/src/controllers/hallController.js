const { Hall, DisabledBench } = require('../models');

const getHalls = async (req, res) => {
  try {
    const halls = await Hall.findAll({ order: [['name', 'ASC']] });
    res.json(halls);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const createHall = async (req, res) => {
  try {
    const hall = await Hall.create(req.body);
    res.status(201).json(hall);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

const updateHall = async (req, res) => {
  try {
    const hall = await Hall.findByPk(req.params.id);
    if (!hall) return res.status(404).json({ message: 'Hall not found' });
    await hall.update(req.body);
    res.json(hall);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

const deleteHall = async (req, res) => {
  try {
    const hall = await Hall.findByPk(req.params.id);
    if (!hall) return res.status(404).json({ message: 'Hall not found' });
    await hall.destroy();
    res.json({ message: 'Hall removed' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const getDisabledBenches = async (req, res) => {
  try {
    const benches = await DisabledBench.findAll({
      where: {
        hall_id: req.params.hallId,
      },
    });
    res.json(benches);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const toggleDisabledBench = async (req, res) => {
  const { hall_id, bench_row, bench_col } = req.body;
  try {
    const existing = await DisabledBench.findOne({
      where: { hall_id, bench_row, bench_col },
    });

    if (existing) {
      await existing.destroy();
      res.json({ message: 'Bench enabled.' });
    } else {
      const newDisabled = await DisabledBench.create({
        hall_id,
        bench_row,
        bench_col,
      });
      res.status(201).json(newDisabled);
    }
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

module.exports = { getHalls, createHall, updateHall, deleteHall, getDisabledBenches, toggleDisabledBench };
