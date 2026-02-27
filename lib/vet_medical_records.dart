import 'package:flutter/material.dart';
import 'package:pawfect_care/services/api_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class VetMedicalRecordsPage extends StatefulWidget {
  const VetMedicalRecordsPage({super.key});

  @override
  State<VetMedicalRecordsPage> createState() => _VetMedicalRecordsPageState();
}

class _VetMedicalRecordsPageState extends State<VetMedicalRecordsPage> {
  List<dynamic> _medicalRecords = [];
  List<dynamic> _pets = [];
  bool _isLoading = true;
  String? _errorMessage;
  String? _selectedPetId;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final futures = await Future.wait([
        ApiService.getHealthRecords(''),
        ApiService.getPets(),
      ]);

      setState(() {
        _medicalRecords = futures[0] is List ? futures[0] : [];
        _pets = futures[1] is List ? futures[1] : [];
        if (_pets.isNotEmpty) {
          _selectedPetId = _pets.first['_id'];
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load data: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _addMedicalRecord() async {
    if (_pets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No pets available')),
      );
      return;
    }

    final formKey = GlobalKey<FormState>();
    final diagnosisController = TextEditingController();
    final treatmentNotesController = TextEditingController();
    final prescriptionController = TextEditingController();
    String? selectedPetId = _selectedPetId;
    DateTime selectedDate = DateTime.now();
    List<File> selectedImages = [];

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Medical Record'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Pet selection
                  DropdownButtonFormField<String>(
                    value: selectedPetId,
                    decoration: const InputDecoration(
                      labelText: 'Select Pet',
                      border: OutlineInputBorder(),
                    ),
                    items: _pets.map((pet) {
                      return DropdownMenuItem<String>(
                        value: pet['_id'],
                        child: Text(pet['name']),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedPetId = newValue;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a pet';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Diagnosis field
                  TextFormField(
                    controller: diagnosisController,
                    decoration: const InputDecoration(
                      labelText: 'Diagnosis',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter diagnosis';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Treatment notes field
                  TextFormField(
                    controller: treatmentNotesController,
                    decoration: const InputDecoration(
                      labelText: 'Treatment Notes',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter treatment notes';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Prescription field
                  TextFormField(
                    controller: prescriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Prescription',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  
                  // Date field
                  ListTile(
                    title: const Text('Date'),
                    subtitle: Text('${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setState(() {
                          selectedDate = date;
                        });
                      }
                    },
                  ),
                  
                  // X-ray images upload
                  const SizedBox(height: 16),
                  const Text('X-ray Images:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () async {
                          final picker = ImagePicker();
                          final pickedFiles = await picker.pickMultiImage();
                          if (pickedFiles.isNotEmpty) {
                            setState(() {
                              selectedImages.addAll(pickedFiles.map((file) => File(file.path)));
                            });
                          }
                        },
                        icon: const Icon(Icons.add_photo_alternate),
                        label: const Text('Add Images'),
                      ),
                      const SizedBox(width: 8),
                      if (selectedImages.isNotEmpty)
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              selectedImages.clear();
                            });
                          },
                          icon: const Icon(Icons.clear),
                          label: const Text('Clear'),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        ),
                    ],
                  ),
                  
                  // Display selected images
                  if (selectedImages.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: selectedImages.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.only(right: 8),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                selectedImages[index],
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  try {
                    final recordData = {
                      'pet': selectedPetId,
                      'recordType': 'Checkup',
                      'title': 'Medical Record',
                      'description': 'Medical examination record',
                      'date': selectedDate.toIso8601String(),
                      'diagnosis': diagnosisController.text,
                      'treatmentNotes': treatmentNotesController.text,
                      'prescription': prescriptionController.text,
                      'veterinarian': ApiService.getUserId(),
                      'xrayImages': [], // TODO: Upload images to server
                    };
                    
                    await ApiService.createHealthRecord(recordData);
                    Navigator.pop(context);
                    await _fetchData();
                    
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Medical record added successfully!')),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error adding medical record: ${e.toString()}')),
                      );
                    }
                  }
                }
              },
              child: const Text('Add Record'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editMedicalRecord(dynamic record) async {
    final formKey = GlobalKey<FormState>();
    final diagnosisController = TextEditingController(text: record['diagnosis'] ?? '');
    final treatmentNotesController = TextEditingController(text: record['treatmentNotes'] ?? '');
    final prescriptionController = TextEditingController(text: record['prescription'] ?? '');
    DateTime selectedDate = DateTime.parse(record['date']);

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Medical Record'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: diagnosisController,
                    decoration: const InputDecoration(
                      labelText: 'Diagnosis',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter diagnosis';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    controller: treatmentNotesController,
                    decoration: const InputDecoration(
                      labelText: 'Treatment Notes',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter treatment notes';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    controller: prescriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Prescription',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  
                  ListTile(
                    title: const Text('Date'),
                    subtitle: Text('${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setState(() {
                          selectedDate = date;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  try {
                    final recordData = {
                      'diagnosis': diagnosisController.text,
                      'treatmentNotes': treatmentNotesController.text,
                      'prescription': prescriptionController.text,
                      'date': selectedDate.toIso8601String(),
                    };
                    
                    await ApiService.updateHealthRecord(record['_id'], recordData);
                    Navigator.pop(context);
                    await _fetchData();
                    
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Medical record updated successfully!')),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error updating medical record: ${e.toString()}')),
                      );
                    }
                  }
                }
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteMedicalRecord(dynamic record) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Medical Record'),
        content: const Text('Are you sure you want to delete this medical record?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ApiService.deleteHealthRecord(record['_id']);
        await _fetchData();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Medical record deleted successfully!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting medical record: ${e.toString()}')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(72, 189, 176, 151),
      appBar: AppBar(
        title: const Text('Medical Records'),
        backgroundColor: const Color(0xFF784830),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addMedicalRecord,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : _medicalRecords.isEmpty
                  ? const Center(child: Text('No medical records found'))
                  : Column(
                      children: [
                        // Pet selector
                        Container(
                          padding: const EdgeInsets.all(16),
                          child: DropdownButtonFormField<String>(
                            value: _selectedPetId,
                            decoration: const InputDecoration(
                              labelText: 'Select Pet',
                              border: OutlineInputBorder(),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            items: _pets.map((pet) {
                              return DropdownMenuItem<String>(
                                value: pet['_id'],
                                child: Text(pet['name']),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedPetId = newValue;
                              });
                            },
                          ),
                        ),
                        
                        // Medical records list
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _medicalRecords.length,
                            itemBuilder: (context, index) {
                              final record = _medicalRecords[index];
                              final date = DateTime.parse(record['date']);
                              final pet = record['pet'] ?? {};
                              
                              return Card(
                                margin: const EdgeInsets.only(bottom: 16),
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF784830),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              '${date.day}/${date.month}/${date.year}',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  pet['name'] ?? 'Unknown Pet',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                Text(
                                                  '${pet['breed'] ?? 'Unknown'} • ${pet['species'] ?? 'Unknown'}',
                                                  style: const TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                icon: const Icon(Icons.edit),
                                                onPressed: () => _editMedicalRecord(record),
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.delete),
                                                onPressed: () => _deleteMedicalRecord(record),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      
                                      if (record['diagnosis'] != null && record['diagnosis'].isNotEmpty) ...[
                                        const Text('Diagnosis:', style: TextStyle(fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 4),
                                        Text(record['diagnosis']),
                                        const SizedBox(height: 12),
                                      ],
                                      
                                      if (record['treatmentNotes'] != null && record['treatmentNotes'].isNotEmpty) ...[
                                        const Text('Treatment Notes:', style: TextStyle(fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 4),
                                        Text(record['treatmentNotes']),
                                        const SizedBox(height: 12),
                                      ],
                                      
                                      if (record['prescription'] != null && record['prescription'].isNotEmpty) ...[
                                        const Text('Prescription:', style: TextStyle(fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 4),
                                        Text(record['prescription']),
                                        const SizedBox(height: 12),
                                      ],
                                      
                                      if (record['xrayImages'] != null && record['xrayImages'].isNotEmpty) ...[
                                        const Text('X-ray Images:', style: TextStyle(fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 8),
                                        SizedBox(
                                          height: 100,
                                          child: ListView.builder(
                                            scrollDirection: Axis.horizontal,
                                            itemCount: record['xrayImages'].length,
                                            itemBuilder: (context, imgIndex) {
                                              return Container(
                                                margin: const EdgeInsets.only(right: 8),
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.circular(8),
                                                  child: Image.network(
                                                    'http://localhost:5000/uploads/${record['xrayImages'][imgIndex]}',
                                                    width: 100,
                                                    height: 100,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context, error, stackTrace) {
                                                      return Container(
                                                        width: 100,
                                                        height: 100,
                                                        color: Colors.grey.shade300,
                                                        child: const Icon(Icons.image_not_supported),
                                                      );
                                                    },
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
    );
  }
}