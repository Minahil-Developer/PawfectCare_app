const express = require('express');
const User = require('../models/User');

const router = express.Router();

// Get all veterinarians
router.get('/', async (req, res) => {
  try {
    const veterinarians = await User.find({ userType: 'Veterinarian' });
    res.json(veterinarians);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

module.exports = router;