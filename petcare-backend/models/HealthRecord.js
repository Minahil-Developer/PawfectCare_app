const mongoose = require('mongoose');

const healthRecordSchema = new mongoose.Schema({
  pet: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Pet',
    required: true
  },
  recordType: {
    type: String,
    enum: ['Vaccination', 'Deworming', 'Allergy', 'Medication', 'Checkup'],
    required: true
  },
  title: {
    type: String,
    required: true
  },
  description: {
    type: String,
    default: ''
  },
  date: {
    type: Date,
    required: true
  },
  nextDueDate: {
    type: Date
  },
  veterinarian: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User'
  },
  // Additional fields for medical records
  diagnosis: {
    type: String,
    default: ''
  },
  treatmentNotes: {
    type: String,
    default: ''
  },
  prescription: {
    type: String,
    default: ''
  },
  xrayImages: [{
    type: String
  }],
  createdAt: {
    type: Date,
    default: Date.now
  }
});

module.exports = mongoose.model('HealthRecord', healthRecordSchema);