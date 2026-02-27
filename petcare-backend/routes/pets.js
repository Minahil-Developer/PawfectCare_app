const express = require('express');
const multer = require('multer');
const path = require('path');
const Pet = require('../models/Pet');

const router = express.Router();

// Configure multer for file uploads
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, 'uploads/');
  },
  filename: function (req, file, cb) {
    cb(null, Date.now() + '-' + Math.round(Math.random() * 1E9) + path.extname(file.originalname));
  }
});

const upload = multer({ storage: storage });

// Get all pets for a user
router.get('/', async (req, res) => {
  try {
    const { ownerId, shelterId, forAdoption } = req.query;
    let query = {};
    
    if (ownerId) {
      query.owner = ownerId;
    }
    if (shelterId) {
      query.shelter = shelterId;
    }
    if (forAdoption === 'true') {
      query.isForAdoption = true;
    }
    
    const pets = await Pet.find(query).populate('owner').populate('shelter');
    res.json(pets);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Get a single pet
router.get('/:id', async (req, res) => {
  try {
    const pet = await Pet.findById(req.params.id).populate('owner');
    if (pet) {
      res.json(pet);
    } else {
      res.status(404).json({ message: 'Pet not found' });
    }
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Create a new pet
router.post('/', upload.single('photo'), async (req, res) => {
  try {
    const { name, age, breed, species, gender, owner, isForAdoption, healthStatus, shelter } = req.body;
    
    const petData = {
      name,
      age,
      breed,
      species,
      gender,
      photo: req.file ? req.file.filename : ''
    };
    
    if (owner) petData.owner = owner;
    if (isForAdoption === 'true') {
      petData.isForAdoption = true;
      petData.shelter = shelter;
    }
    if (healthStatus) petData.healthStatus = healthStatus;
    
    const pet = await Pet.create(petData);
    
    res.status(201).json(pet);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Update a pet
router.put('/:id', upload.single('photo'), async (req, res) => {
  try {
    const { name, age, breed, species, gender } = req.body;
    const updateData = { name, age, breed, species, gender };
    
    if (req.file) {
      updateData.photo = req.file.filename;
    }
    
    const pet = await Pet.findByIdAndUpdate(
      req.params.id,
      updateData,
      { new: true, runValidators: true }
    );
    
    if (pet) {
      res.json(pet);
    } else {
      res.status(404).json({ message: 'Pet not found' });
    }
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Delete a pet
router.delete('/:id', async (req, res) => {
  try {
    const pet = await Pet.findByIdAndDelete(req.params.id);
    
    if (pet) {
      res.json({ message: 'Pet removed' });
    } else {
      res.status(404).json({ message: 'Pet not found' });
    }
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

module.exports = router;