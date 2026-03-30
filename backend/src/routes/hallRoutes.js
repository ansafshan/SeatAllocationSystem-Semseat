const express = require('express');
const router = express.Router();
const { getHalls, createHall, updateHall, deleteHall, getDisabledBenches, toggleDisabledBench } = require('../controllers/hallController');
const { protect, authorize } = require('../middleware/auth');

router.use(protect);
router.use(authorize('admin'));

router.route('/')
    .get(getHalls)
    .post(createHall);

router.route('/:id')
    .put(updateHall)
    .delete(deleteHall);

router.get('/disabled-benches/:hallId', getDisabledBenches);
router.post('/disabled-benches/toggle', toggleDisabledBench);

module.exports = router;
