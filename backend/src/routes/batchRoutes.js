const express = require('express');
const router = express.Router();
const {
  getBatches,
  createBatch,
  updateBatch,
  deleteBatch
} = require('../controllers/batchController');
const { protect, authorize } = require('../middleware/auth');

router.use(protect);
router.use(authorize('admin'));

router.route('/')
  .get(getBatches)
  .post(createBatch);

router.route('/:id')
  .put(updateBatch)
  .delete(deleteBatch);

module.exports = router;
