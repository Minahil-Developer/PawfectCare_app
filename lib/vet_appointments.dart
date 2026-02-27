import 'package:flutter/material.dart';
import 'package:pawfect_care/services/api_service.dart';

class VetAppointmentsPage extends StatefulWidget {
  const VetAppointmentsPage({super.key});

  @override
  State<VetAppointmentsPage> createState() => _VetAppointmentsPageState();
}

class _VetAppointmentsPageState extends State<VetAppointmentsPage> {
  List<dynamic> _appointments = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _fetchAppointments();
  }

  Future<void> _fetchAppointments() async {
    try {
      final userId = ApiService.getUserId();
      if (userId == null) {
        setState(() {
          _errorMessage = 'User not logged in';
          _isLoading = false;
        });
        return;
      }

      final response = await ApiService.getAppointments();
      setState(() {
        _appointments = response is List ? response : [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load appointments: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _acceptAppointment(dynamic appointment) async {
    try {
      await ApiService.updateAppointment(appointment['_id'], {'status': 'Confirmed'});
      await _fetchAppointments();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Appointment accepted successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error accepting appointment: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _rejectAppointment(dynamic appointment) async {
    try {
      await ApiService.updateAppointment(appointment['_id'], {'status': 'Cancelled'});
      await _fetchAppointments();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Appointment rejected')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error rejecting appointment: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _completeAppointment(dynamic appointment) async {
    try {
      await ApiService.updateAppointment(appointment['_id'], {'status': 'Completed'});
      await _fetchAppointments();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Appointment marked as completed!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error completing appointment: ${e.toString()}')),
        );
      }
    }
  }

  List<dynamic> _getFilteredAppointments() {
    if (_selectedFilter == 'All') {
      return _appointments;
    }
    return _appointments.where((apt) => apt['status'] == _selectedFilter).toList();
  }

  String _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'scheduled':
        return 'orange';
      case 'confirmed':
        return 'blue';
      case 'completed':
        return 'green';
      case 'cancelled':
        return 'red';
      case 'rescheduled':
        return 'purple';
      default:
        return 'grey';
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredAppointments = _getFilteredAppointments();

    return Scaffold(
      backgroundColor: const Color.fromARGB(72, 189, 176, 151),
      appBar: AppBar(
        title: const Text('Appointments'),
        backgroundColor: const Color(0xFF784830),
        actions: [
          PopupMenuButton<String>(
            onSelected: (String value) {
              setState(() {
                _selectedFilter = value;
              });
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'All',
                child: Text('All Appointments'),
              ),
              const PopupMenuItem<String>(
                value: 'Scheduled',
                child: Text('Scheduled'),
              ),
              const PopupMenuItem<String>(
                value: 'Confirmed',
                child: Text('Confirmed'),
              ),
              const PopupMenuItem<String>(
                value: 'Completed',
                child: Text('Completed'),
              ),
              const PopupMenuItem<String>(
                value: 'Cancelled',
                child: Text('Cancelled'),
              ),
            ],
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _selectedFilter,
                    style: const TextStyle(color: Colors.white),
                  ),
                  const Icon(Icons.arrow_drop_down, color: Colors.white),
                ],
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : filteredAppointments.isEmpty
                  ? const Center(child: Text('No appointments found'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredAppointments.length,
                      itemBuilder: (context, index) {
                        final appointment = filteredAppointments[index];
                        final date = DateTime.parse(appointment['date']);
                        final status = appointment['status'] ?? 'Scheduled';
                        final statusColor = _getStatusColor(status);
                        final pet = appointment['pet'] ?? {};
                        final owner = appointment['owner'] ?? {};

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
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade100,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}',
                                        style: TextStyle(
                                          color: Colors.blue.shade800,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: statusColor == 'orange' ? Colors.orange.shade100
                                            : statusColor == 'blue' ? Colors.blue.shade100
                                            : statusColor == 'green' ? Colors.green.shade100
                                            : statusColor == 'red' ? Colors.red.shade100
                                            : statusColor == 'purple' ? Colors.purple.shade100
                                            : Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Text(
                                        status,
                                        style: TextStyle(
                                          color: statusColor == 'orange' ? Colors.orange.shade800
                                              : statusColor == 'blue' ? Colors.blue.shade800
                                              : statusColor == 'green' ? Colors.green.shade800
                                              : statusColor == 'red' ? Colors.red.shade800
                                              : statusColor == 'purple' ? Colors.purple.shade800
                                              : Colors.grey.shade800,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    const Icon(Icons.pets, color: Color(0xFF784830)),
                                    const SizedBox(width: 8),
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
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    const Icon(Icons.person, color: Color(0xFF784830)),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            owner['name'] ?? 'Unknown Owner',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                          Text(
                                            owner['phone'] ?? 'No phone',
                                            style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                if (appointment['reason'] != null) ...[
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      const Icon(Icons.note, color: Color(0xFF784830)),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          appointment['reason'],
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                                if (status == 'Scheduled') ...[
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton(
                                        onPressed: () => _rejectAppointment(appointment),
                                        child: const Text('Reject', style: TextStyle(color: Colors.red)),
                                      ),
                                      const SizedBox(width: 8),
                                      ElevatedButton(
                                        onPressed: () => _acceptAppointment(appointment),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                        ),
                                        child: const Text('Accept', style: TextStyle(color: Colors.white)),
                                      ),
                                    ],
                                  ),
                                ] else if (status == 'Confirmed') ...[
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      ElevatedButton(
                                        onPressed: () => _completeAppointment(appointment),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF784830),
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                        ),
                                        child: const Text('Mark Complete', style: TextStyle(color: Colors.white)),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
