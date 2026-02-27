const express = require('express');
const VeterinarianAvailability = require('../models/VeterinarianAvailability');
const User = require('../models/User');

const router = express.Router();

// Get veterinarian availability
router.get('/:vetId', async (req, res) => {
  try {
    const { date } = req.query;
    let query = { veterinarian: req.params.vetId };
    
    if (date) {
      const startOfDay = new Date(date);
      startOfDay.setHours(0, 0, 0, 0);
      const endOfDay = new Date(date);
      endOfDay.setHours(23, 59, 59, 999);
      
      query.date = {
        $gte: startOfDay,
        $lte: endOfDay
      };
    }
    
    const availability = await VeterinarianAvailability.find(query)
      .sort({ date: 1, startTime: 1 });
    res.json(availability);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Set veterinarian availability
router.post('/', async (req, res) => {
  try {
    const { veterinarian, date, startTime, endTime, isAvailable } = req.body;
    
    const availability = await VeterinarianAvailability.create({
      veterinarian,
      date,
      startTime,
      endTime,
      isAvailable: isAvailable !== false
    });
    
    res.status(201).json(availability);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Update availability
router.put('/:id', async (req, res) => {
  try {
    const { startTime, endTime, isAvailable } = req.body;
    
    const availability = await VeterinarianAvailability.findByIdAndUpdate(
      req.params.id,
      { startTime, endTime, isAvailable },
      { new: true }
    );
    
    if (availability) {
      res.json(availability);
    } else {
      res.status(404).json({ message: 'Availability not found' });
    }
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Delete availability
router.delete('/:id', async (req, res) => {
  try {
    const availability = await VeterinarianAvailability.findByIdAndDelete(req.params.id);
    
    if (availability) {
      res.json({ message: 'Availability deleted' });
    } else {
      res.status(404).json({ message: 'Availability not found' });
    }
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Get available veterinarians for a specific date and time
router.get('/available/:date/:time', async (req, res) => {
  try {
    const { date, time } = req.params;
    const targetDate = new Date(date);
    
    const availableVets = await VeterinarianAvailability.find({
      date: {
        $gte: new Date(targetDate.setHours(0, 0, 0, 0)),
        $lte: new Date(targetDate.setHours(23, 59, 59, 999))
      },
      startTime: { $lte: time },
      endTime: { $gte: time },
      isAvailable: true
    }).populate('veterinarian');
    
    res.json(availableVets);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

module.exports = router;
