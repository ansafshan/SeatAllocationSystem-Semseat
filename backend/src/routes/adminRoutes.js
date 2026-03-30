const express = require('express');
const router = express.Router();
const { getDashboardStats, getRecentMalpractices } = require('../controllers/adminController');
const { protect, authorize } = require('../middleware/auth');

router.use(protect);
router.use(authorize('admin'));

router.get('/stats', getDashboardStats);
router.get('/malpractices', getRecentMalpractices);

module.exports = router;
