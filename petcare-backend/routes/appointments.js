const express = require('express');
const Appointment = require('../models/Appointment');

const router = express.Router();

// Get all appointments for a user
router.get('/', async (req, res) => {
  try {
    let query = {};
    
    if (req.query.ownerId) {
      query.owner = req.query.ownerId;
    } else if (req.query.veterinarianId) {
      query.veterinarian = req.query.veterinarianId;
    }
    
    const appointments = await Appointment.find(query)
      .populate('pet')
      .populate('owner')
      .populate('veterinarian')
      .sort({ date: 1 });
      
    res.json(appointments);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Get appointments by status
router.get('/status/:status', async (req, res) => {
  try {
    const appointments = await Appointment.find({ status: req.params.status })
      .populate('pet')
      .populate('owner')
      .populate('veterinarian')
      .sort({ date: 1 });
      
    res.json(appointments);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Create a new appointment
router.post('/', async (req, res) => {
  try {
    const { pet, owner, veterinarian, date, reason } = req.body;
    
    const appointment = await Appointment.create({
      pet,
      owner,
      veterinarian,
      date,
      reason
    });
    
    res.status(201).json(appointment);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Update an appointment
router.put('/:id', async (req, res) => {
  try {
    const { date, reason, status, notes } = req.body;
    
    const appointment = await Appointment.findByIdAndUpdate(
      req.params.id,
      { date, reason, status, notes },
      { new: true, runValidators: true }
    );
    
    if (appointment) {
      res.json(appointment);
    } else {
      res.status(404).json({ message: 'Appointment not found' });
    }
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Delete an appointment
router.delete('/:id', async (req, res) => {
  try {
    const appointment = await Appointment.findByIdAndDelete(req.params.id);
    
    if (appointment) {
      res.json({ message: 'Appointment removed' });
    } else {
      res.status(404).json({ message: 'Appointment not found' });
    }
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

module.exports = router;