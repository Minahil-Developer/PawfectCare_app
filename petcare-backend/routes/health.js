const express = require('express');
const HealthRecord = require('../models/HealthRecord');

const router = express.Router();

// Get all health records for a pet
router.get('/', async (req, res) => {
  try {
    const { petId, veterinarianId } = req.query;
    let query = {};
    
    if (petId) {
      query.pet = petId;
    }
    if (veterinarianId) {
      query.veterinarian = veterinarianId;
    }
    
    const records = await HealthRecord.find(query)
      .populate('pet')
      .populate('veterinarian')
      .sort({ date: -1 });
    res.json(records);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Create a new health record
router.post('/', async (req, res) => {
  try {
    const { 
      pet, 
      recordType, 
      title, 
      description, 
      date, 
      nextDueDate, 
      veterinarian,
      diagnosis,
      treatmentNotes,
      prescription,
      xrayImages
    } = req.body;
    
    const record = await HealthRecord.create({
      pet,
      recordType,
      title,
      description,
      date,
      nextDueDate,
      veterinarian,
      diagnosis,
      treatmentNotes,
      prescription,
      xrayImages: xrayImages || []
    });
    
    const populatedRecord = await HealthRecord.findById(record._id)
      .populate('pet')
      .populate('veterinarian');
    
    res.status(201).json(populatedRecord);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Update a health record
router.put('/:id', async (req, res) => {
  try {
    const { 
      recordType, 
      title, 
      description, 
      date, 
      nextDueDate, 
      veterinarian,
      diagnosis,
      treatmentNotes,
      prescription,
      xrayImages
    } = req.body;
    
    const updateData = {
      recordType, 
      title, 
      description, 
      date, 
      nextDueDate, 
      veterinarian
    };
    
    if (diagnosis !== undefined) updateData.diagnosis = diagnosis;
    if (treatmentNotes !== undefined) updateData.treatmentNotes = treatmentNotes;
    if (prescription !== undefined) updateData.prescription = prescription;
    if (xrayImages !== undefined) updateData.xrayImages = xrayImages;
    
    const record = await HealthRecord.findByIdAndUpdate(
      req.params.id,
      updateData,
      { new: true, runValidators: true }
    ).populate('pet').populate('veterinarian');
    
    if (record) {
      res.json(record);
    } else {
      res.status(404).json({ message: 'Record not found' });
    }
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Delete a health record
router.delete('/:id', async (req, res) => {
  try {
    const record = await HealthRecord.findByIdAndDelete(req.params.id);
    
    if (record) {
      res.json({ message: 'Record removed' });
    } else {
      res.status(404).json({ message: 'Record not found' });
    }
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

module.exports = router;