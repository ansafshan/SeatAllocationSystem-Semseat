const { Subject, Department, Batch } = require('../models');

const getSubjects = async (req, res) => {
  try {
    const subjects = await Subject.findAll({
      include: [
        { model: Department, attributes: ['name'] },
        { model: Batch, attributes: ['name'] }
      ],
      order: [['created_at', 'DESC']]
    });
    res.json(subjects);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const createSubject = async (req, res) => {
  const { name, code, dept_id, batch_id } = req.body;
  try {
    const subject = await Subject.create({ name, code, dept_id, batch_id });
    const fullSubject = await Subject.findByPk(subject.id, {
      include: [
        { model: Department, attributes: ['name'] },
        { model: Batch, attributes: ['name'] }
      ]
    });
    res.status(201).json(fullSubject);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

const updateSubject = async (req, res) => {
  try {
    const subject = await Subject.findByPk(req.params.id);
    if (subject) {
      subject.name = req.body.name || subject.name;
      subject.code = req.body.code || subject.code;
      subject.dept_id = req.body.dept_id || subject.dept_id;
      subject.batch_id = req.body.batch_id || subject.batch_id;
      await subject.save();
      
      const updatedSubject = await Subject.findByPk(subject.id, {
        include: [
          { model: Department, attributes: ['name'] },
          { model: Batch, attributes: ['name'] }
        ]
      });
      res.json(updatedSubject);
    } else {
      res.status(404).json({ message: 'Subject not found' });
    }
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

const deleteSubject = async (req, res) => {
  try {
    const subject = await Subject.findByPk(req.params.id);
    if (subject) {
      await subject.destroy();
      res.json({ message: 'Subject removed' });
    } else {
      res.status(404).json({ message: 'Subject not found' });
    }
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

module.exports = { getSubjects, createSubject, updateSubject, deleteSubject };
