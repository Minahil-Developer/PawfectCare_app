import 'package:flutter/material.dart';
import 'package:pawfect_care/services/api_service.dart';

class AppointmentsPage extends StatefulWidget {
  const AppointmentsPage({super.key});

  @override
  State<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage> {
  List<dynamic> _appointments = [];
  List<dynamic> _pets = [];
  List<dynamic> _veterinarians = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final userId = ApiService.getUserId();
      if (userId == null) {
        setState(() {
          _errorMessage = 'User not logged in';
          _isLoading = false;
        });
        return;
      }

      // Fetch appointments, pets, and veterinarians in parallel
      final futures = await Future.wait([
        ApiService.getAppointments(),
        ApiService.getPets(),
        ApiService.getVeterinarians(),
      ]);

      setState(() {
        _appointments = futures[0] is List ? futures[0] : [];
        _pets = futures[1] is List ? futures[1] : [];
        _veterinarians = futures[2] is List ? futures[2] : [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load data: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _addAppointment() async {
    if (_pets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a pet first')),
      );
      return;
    }

    final formKey = GlobalKey<FormState>();
    final messageController = TextEditingController();
    String? selectedPetId = _pets.first['_id'];
    String? selectedVetId;
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.now();

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Book Appointment'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Veterinarian selection
                  DropdownButtonFormField<String>(
                    value: selectedVetId,
                    decoration: const InputDecoration(
                      labelText: 'Select Veterinarian',
                      border: OutlineInputBorder(),
                    ),
                    items: _veterinarians.map((vet) {
                      return DropdownMenuItem<String>(
                        value: vet['_id'],
                        child: Text(vet['name']),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedVetId = newValue;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a veterinarian';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
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
                  
                  // Date selection
                  ListTile(
                    title: const Text('Date'),
                    subtitle: Text('${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 90)),
                      );
                      if (date != null) {
                        setState(() {
                          selectedDate = date;
                        });
                      }
                    },
                  ),
                  
                  // Time selection
                  ListTile(
                    title: const Text('Time'),
                    subtitle: Text(selectedTime.format(context)),
                    trailing: const Icon(Icons.access_time),
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: selectedTime,
                      );
                      if (time != null) {
                        setState(() {
                          selectedTime = time;
                        });
                      }
                    },
                  ),
                  
                  // Message field
                  TextFormField(
                    controller: messageController,
                    decoration: const InputDecoration(
                      labelText: 'Purpose of Visit',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter purpose of visit';
                      }
                      return null;
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
                    final appointmentData = {
                      'pet': selectedPetId,
                      'owner': ApiService.getUserId(),
                      'veterinarian': selectedVetId,
                      'date': selectedDate.toIso8601String(),
                      'reason': messageController.text,
                      'status': 'Scheduled',
                    };
                    
                    await ApiService.createAppointment(appointmentData);
                    Navigator.pop(context);
                    await _fetchData();
                    
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Appointment booked successfully!')),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error booking appointment: ${e.toString()}')),
                      );
                    }
                  }
                }
              },
              child: const Text('Book Appointment'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _cancelAppointment(dynamic appointment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Appointment'),
        content: const Text('Are you sure you want to cancel this appointment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ApiService.updateAppointment(appointment['_id'], {'status': 'Cancelled'});
        await _fetchData();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Appointment cancelled successfully!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error cancelling appointment: ${e.toString()}')),
          );
        }
      }
    }
  }

  String _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'scheduled':
        return 'blue';
      case 'completed':
        return 'green';
      case 'cancelled':
        return 'red';
      case 'rescheduled':
        return 'orange';
      default:
        return 'grey';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(72, 189, 176, 151),
      appBar: AppBar(
        title: const Text('Appointments'),
        backgroundColor: const Color(0xFF784830),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addAppointment,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : _appointments.isEmpty
                  ? const Center(child: Text('No appointments found'))
                  : ListView.builder(
                      itemCount: _appointments.length,
                      itemBuilder: (context, index) {
                        final appointment = _appointments[index];
                        final date = DateTime.parse(appointment['date']);
                        final status = appointment['status'] ?? 'Scheduled';
                        final statusColor = _getStatusColor(status);
                        
                        return Card(
                          margin: const EdgeInsets.all(8),
                          child: ListTile(
                            leading: const Icon(Icons.calendar_today,
                                color: Color(0xFF784830)),
                            title: Text(appointment['pet']?['name'] ?? 'Unknown Pet'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${date.day}/${date.month}/${date.year}'),
                                Text('Vet: ${appointment['veterinarian']?['name'] ?? 'Unknown'}'),
                                Text('Purpose: ${appointment['reason'] ?? 'No reason provided'}'),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: statusColor == 'blue' ? Colors.blue.shade100
                                        : statusColor == 'green' ? Colors.green.shade100
                                        : statusColor == 'red' ? Colors.red.shade100
                                        : statusColor == 'orange' ? Colors.orange.shade100
                                        : Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    status,
                                    style: TextStyle(
                                      color: statusColor == 'blue' ? Colors.blue.shade800
                                          : statusColor == 'green' ? Colors.green.shade800
                                          : statusColor == 'red' ? Colors.red.shade800
                                          : statusColor == 'orange' ? Colors.orange.shade800
                                          : Colors.grey.shade800,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                if (status == 'Scheduled')
                                  IconButton(
                                    icon: const Icon(Icons.cancel),
                                    onPressed: () => _cancelAppointment(appointment),
                                  ),
                              ],
                            ),
                            onTap: () {
                              // TODO: Navigate to appointment details
                            },
                          ),
                        );
                      },
                    ),
    );
  }
}