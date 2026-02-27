import 'package:flutter/material.dart';
import 'package:pawfect_care/services/api_service.dart';

class HealthTrackingPage extends StatefulWidget {
  const HealthTrackingPage({super.key});

  @override
  State<HealthTrackingPage> createState() => _HealthTrackingPageState();
}

class _HealthTrackingPageState extends State<HealthTrackingPage> {
  List<dynamic> _healthRecords = [];
  List<dynamic> _pets = [];
  bool _isLoading = true;
  String? _errorMessage;
  String? _selectedPetId;

  @override
  void initState() {
    super.initState();
    _fetchPets();
  }

  Future<void> _fetchPets() async {
    try {
      final response = await ApiService.getPets();
      setState(() {
        _pets = response is List ? response : [];
        if (_pets.isNotEmpty) {
          _selectedPetId = _pets.first['_id'];
          _fetchHealthRecords();
        } else {
          _isLoading = false;
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load pets';
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchHealthRecords() async {
    if (_selectedPetId == null) return;
    
    try {
      final response = await ApiService.getHealthRecords(_selectedPetId!);
      setState(() {
        _healthRecords = response is List ? response : [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load health records';
        _isLoading = false;
      });
    }
  }

  Future<void> _addHealthRecord() async {
    if (_pets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a pet first')),
      );
      return;
    }

    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedType = 'Vaccination';
    String? selectedPetId = _selectedPetId;
    DateTime selectedDate = DateTime.now();
    DateTime? nextDueDate;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Health Record'),
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
                  
                  // Type selection
                  DropdownButtonFormField<String>(
                    value: selectedType,
                    decoration: const InputDecoration(
                      labelText: 'Type',
                      border: OutlineInputBorder(),
                    ),
                    items: ['Vaccination', 'Deworming'].map((String type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedType = newValue!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Title field
                  TextFormField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Description field
                  TextFormField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
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
                  
                  // Next due date field (only for Vaccination)
                  if (selectedType == 'Vaccination') ...[
                    const SizedBox(height: 16),
                    ListTile(
                      title: const Text('Next Due Date'),
                      subtitle: Text(nextDueDate != null 
                          ? '${nextDueDate!.day}/${nextDueDate!.month}/${nextDueDate!.year}'
                          : 'Select next due date'),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: selectedDate.add(const Duration(days: 365)),
                          firstDate: selectedDate,
                          lastDate: DateTime(2030),
                        );
                        if (date != null) {
                          setState(() {
                            nextDueDate = date;
                          });
                        }
                      },
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
                      'recordType': selectedType,
                      'title': titleController.text,
                      'description': descriptionController.text,
                      'date': selectedDate.toIso8601String(),
                      if (nextDueDate != null) 'nextDueDate': nextDueDate!.toIso8601String(),
                    };
                    
                    await ApiService.createHealthRecord(recordData);
                    Navigator.pop(context);
                    await _fetchHealthRecords();
                    
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Health record added successfully!')),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error adding health record: ${e.toString()}')),
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

  Future<void> _editHealthRecord(dynamic record) async {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController(text: record['title']);
    final descriptionController = TextEditingController(text: record['description']);
    String selectedType = record['recordType'] ?? 'Vaccination';
    DateTime selectedDate = DateTime.parse(record['date']);
    DateTime? nextDueDate = record['nextDueDate'] != null 
        ? DateTime.parse(record['nextDueDate']) 
        : null;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Health Record'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedType,
                    decoration: const InputDecoration(
                      labelText: 'Type',
                      border: OutlineInputBorder(),
                    ),
                    items: ['Vaccination', 'Deworming'].map((String type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedType = newValue!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
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
                  
                  if (selectedType == 'Vaccination') ...[
                    const SizedBox(height: 16),
                    ListTile(
                      title: const Text('Next Due Date'),
                      subtitle: Text(nextDueDate != null 
                          ? '${nextDueDate!.day}/${nextDueDate!.month}/${nextDueDate!.year}'
                          : 'Select next due date'),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: nextDueDate ?? selectedDate.add(const Duration(days: 365)),
                          firstDate: selectedDate,
                          lastDate: DateTime(2030),
                        );
                        if (date != null) {
                          setState(() {
                            nextDueDate = date;
                          });
                        }
                      },
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
                      'recordType': selectedType,
                      'title': titleController.text,
                      'description': descriptionController.text,
                      'date': selectedDate.toIso8601String(),
                      if (nextDueDate != null) 'nextDueDate': nextDueDate!.toIso8601String(),
                    };
                    
                    await ApiService.updateHealthRecord(record['_id'], recordData);
                    Navigator.pop(context);
                    await _fetchHealthRecords();
                    
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Health record updated successfully!')),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error updating health record: ${e.toString()}')),
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

  Future<void> _deleteHealthRecord(dynamic record) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Health Record'),
        content: Text('Are you sure you want to delete "${record['title']}"?'),
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
        await _fetchHealthRecords();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Health record deleted successfully!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting health record: ${e.toString()}')),
          );
        }
      }
    }
  }

  void _showHealthHistory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Health History'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: ListView.builder(
            itemCount: _healthRecords.length,
            itemBuilder: (context, index) {
              final record = _healthRecords[index];
              final date = DateTime.parse(record['date']);
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  leading: Icon(
                    record['recordType'] == 'Vaccination' 
                        ? Icons.vaccines 
                        : Icons.medical_services,
                    color: const Color(0xFF784830),
                  ),
                  title: Text(record['title']),
                  subtitle: Text(
                    '${record['recordType']} • ${date.day}/${date.month}/${date.year}',
                  ),
                  trailing: record['nextDueDate'] != null
                      ? Chip(
                          label: Text('Due: ${DateTime.parse(record['nextDueDate']).day}/${DateTime.parse(record['nextDueDate']).month}/${DateTime.parse(record['nextDueDate']).year}'),
                          backgroundColor: Colors.orange.shade100,
                        )
                      : null,
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(72, 189, 176, 151),
      appBar: AppBar(
        title: const Text('Health Tracking'),
        backgroundColor: const Color(0xFF784830),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addHealthRecord,
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: _showHealthHistory,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : _pets.isEmpty
                  ? const Center(child: Text('Please add a pet first'))
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
                                _fetchHealthRecords();
                              });
                            },
                          ),
                        ),
                        
                        // Health records list
                        Expanded(
                          child: _healthRecords.isEmpty
                              ? const Center(child: Text('No health records found'))
                              : ListView.builder(
                                  itemCount: _healthRecords.length,
                                  itemBuilder: (context, index) {
                                    final record = _healthRecords[index];
                                    final date = DateTime.parse(record['date']);
                                    return Card(
                                      margin: const EdgeInsets.all(8),
                                      child: ListTile(
                                        leading: Icon(
                                          record['recordType'] == 'Vaccination' 
                                              ? Icons.vaccines 
                                              : Icons.medical_services,
                                          color: const Color(0xFF784830),
                                        ),
                                        title: Text(record['title']),
                                        subtitle: Text(
                                          '${record['recordType']} • ${date.day}/${date.month}/${date.year}',
                                        ),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            if (record['nextDueDate'] != null)
                                              Chip(
                                                label: Text('Due: ${DateTime.parse(record['nextDueDate']).day}/${DateTime.parse(record['nextDueDate']).month}/${DateTime.parse(record['nextDueDate']).year}'),
                                                backgroundColor: Colors.orange.shade100,
                                              ),
                                            IconButton(
                                              icon: const Icon(Icons.edit),
                                              onPressed: () => _editHealthRecord(record),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete),
                                              onPressed: () => _deleteHealthRecord(record),
                                            ),
                                          ],
                                        ),
                                        onTap: () {
                                          // TODO: Navigate to health record details
                                        },
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