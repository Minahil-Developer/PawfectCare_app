const express = require('express');
const AdoptionRequest = require('../models/AdoptionRequest');
const Pet = require('../models/Pet');
const User = require('../models/User');

const router = express.Router();

// Get adoption requests for a shelter
router.get('/shelter/:shelterId', async (req, res) => {
  try {
    const requests = await AdoptionRequest.find({ shelter: req.params.shelterId })
      .populate('pet')
      .populate('requester')
      .sort({ createdAt: -1 });
    res.json(requests);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Get adoption requests by a user
router.get('/user/:userId', async (req, res) => {
  try {
    const requests = await AdoptionRequest.find({ requester: req.params.userId })
      .populate('pet')
      .populate('shelter')
      .sort({ createdAt: -1 });
    res.json(requests);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Create adoption request
router.post('/', async (req, res) => {
  try {
    const { petId, requesterId, shelterId, message, requesterInfo } = req.body;
    
    const request = await AdoptionRequest.create({
      pet: petId,
      requester: requesterId,
      shelter: shelterId,
      message,
      requesterInfo
    });
    
    const populatedRequest = await AdoptionRequest.findById(request._id)
      .populate('pet')
      .populate('requester')
      .populate('shelter');
    
    res.status(201).json(populatedRequest);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Update adoption request status
router.put('/:id', async (req, res) => {
  try {
    const { status } = req.body;
    
    const request = await AdoptionRequest.findByIdAndUpdate(
      req.params.id,
      { status, updatedAt: new Date() },
      { new: true }
    ).populate('pet').populate('requester').populate('shelter');
    
    if (request) {
      res.json(request);
    } else {
      res.status(404).json({ message: 'Adoption request not found' });
    }
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Delete adoption request
router.delete('/:id', async (req, res) => {
  try {
    const request = await AdoptionRequest.findByIdAndDelete(req.params.id);
    
    if (request) {
      res.json({ message: 'Adoption request deleted' });
    } else {
      res.status(404).json({ message: 'Adoption request not found' });
    }
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

module.exports = router;
