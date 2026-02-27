const express = require('express');
const SuccessStory = require('../models/SuccessStory');
const Pet = require('../models/Pet');

const router = express.Router();

// Get all success stories
router.get('/', async (req, res) => {
  try {
    const stories = await SuccessStory.find()
      .populate('pet')
      .populate('adopter')
      .populate('shelter')
      .sort({ createdAt: -1 });
    res.json(stories);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Get success stories by shelter
router.get('/shelter/:shelterId', async (req, res) => {
  try {
    const stories = await SuccessStory.find({ shelter: req.params.shelterId })
      .populate('pet')
      .populate('adopter')
      .sort({ createdAt: -1 });
    res.json(stories);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Create success story
router.post('/', async (req, res) => {
  try {
    const { title, description, petId, adopterId, shelterId, images } = req.body;
    
    const story = await SuccessStory.create({
      title,
      description,
      pet: petId,
      adopter: adopterId,
      shelter: shelterId,
      images: images || []
    });
    
    const populatedStory = await SuccessStory.findById(story._id)
      .populate('pet')
      .populate('adopter')
      .populate('shelter');
    
    res.status(201).json(populatedStory);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Update success story
router.put('/:id', async (req, res) => {
  try {
    const { title, description, images } = req.body;
    
    const story = await SuccessStory.findByIdAndUpdate(
      req.params.id,
      { title, description, images },
      { new: true }
    ).populate('pet').populate('adopter').populate('shelter');
    
    if (story) {
      res.json(story);
    } else {
      res.status(404).json({ message: 'Success story not found' });
    }
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Delete success story
router.delete('/:id', async (req, res) => {
  try {
    const story = await SuccessStory.findByIdAndDelete(req.params.id);
    
    if (story) {
      res.json({ message: 'Success story deleted' });
    } else {
      res.status(404).json({ message: 'Success story not found' });
    }
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

module.exports = router;
