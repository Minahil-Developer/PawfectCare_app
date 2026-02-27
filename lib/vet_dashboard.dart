import 'package:flutter/material.dart';
import 'package:pawfect_care/services/api_service.dart';
import 'vet_medical_records.dart';
import 'vet_appointments.dart';
import 'vet_patients_profiles.dart';

class VetDashboardPage extends StatefulWidget {
  const VetDashboardPage({super.key});

  @override
  State<VetDashboardPage> createState() => _VetDashboardPageState();
}

class _VetDashboardPageState extends State<VetDashboardPage> {
  int _selectedIndex = 0;
  String _filterValue = 'Today';
  List<dynamic> _appointments = [];
  List<dynamic> _allAppointments = [];
  bool _isLoading = true;
  String? _errorMessage;

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
        _allAppointments = response is List ? response : [];
        _filterAppointments();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load appointments: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _filterAppointments() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    setState(() {
      switch (_filterValue) {
        case 'Today':
          _appointments = _allAppointments.where((apt) {
            final aptDate = DateTime.parse(apt['date']);
            final aptDay = DateTime(aptDate.year, aptDate.month, aptDate.day);
            return aptDay.isAtSameMomentAs(today);
          }).toList();
          break;
        case 'Tomorrow':
          final tomorrow = today.add(const Duration(days: 1));
          _appointments = _allAppointments.where((apt) {
            final aptDate = DateTime.parse(apt['date']);
            final aptDay = DateTime(aptDate.year, aptDate.month, aptDate.day);
            return aptDay.isAtSameMomentAs(tomorrow);
          }).toList();
          break;
        case 'This Week':
          final weekStart = today.subtract(Duration(days: today.weekday - 1));
          final weekEnd = weekStart.add(const Duration(days: 6));
          _appointments = _allAppointments.where((apt) {
            final aptDate = DateTime.parse(apt['date']);
            return aptDate.isAfter(weekStart.subtract(const Duration(days: 1))) &&
                   aptDate.isBefore(weekEnd.add(const Duration(days: 1)));
          }).toList();
          break;
        default:
          _appointments = _allAppointments;
      }
    });
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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onFilterChanged(String? value) {
    if (value != null) {
      setState(() {
        _filterValue = value;
        _filterAppointments();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(72, 189, 176, 151),
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: const Color(0xFF784830),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterDialog(context);
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Stats Overview
                      _buildStatsOverview(),
                      const SizedBox(height: 20),
                      
                      // Today's Appointments Section
                      _buildAppointmentsSection(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
      bottomNavigationBar: _buildModernNavBar(),
    );
  }

  Widget _buildStatsOverview() {
    final totalAppointments = _allAppointments.length;
    final completedAppointments = _allAppointments.where((apt) => apt['status'] == 'Completed').length;
    final pendingAppointments = _allAppointments.where((apt) => apt['status'] == 'Scheduled').length;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFBDB097),
          borderRadius: BorderRadius.circular(15.0),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(totalAppointments.toString(), 'Total Appointments', Icons.calendar_today),
            _buildStatItem(completedAppointments.toString(), 'Completed', Icons.check_circle),
            _buildStatItem(pendingAppointments.toString(), 'Pending', Icons.access_time),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF784830), size: 30),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF784830),
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF784830),
          ),
        ),
      ],
    );
  }

  Widget _buildAppointmentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "$_filterValue Appointments",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF784830),
              ),
            ),
            DropdownButton<String>(
              value: _filterValue,
              items: ['Today', 'Tomorrow', 'This Week', 'All']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: _onFilterChanged,
            ),
          ],
        ),
        const SizedBox(height: 10),
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15.0),
            ),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                if (_appointments.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('No appointments scheduled'),
                  )
                else
                  ..._appointments.map((appointment) {
                    return _buildAppointmentItem(appointment);
                  }).toList(),
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const VetAppointmentsPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF784830),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: const Text('View All Appointments'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAppointmentItem(Map<String, dynamic> appointment) {
    final date = DateTime.parse(appointment['date']);
    final status = appointment['status'] ?? 'Scheduled';
    final pet = appointment['pet'] ?? {};
    final owner = appointment['owner'] ?? {};

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
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
                  '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}',
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
                      '${pet['breed'] ?? 'Unknown'} • ${owner['name'] ?? 'Unknown Owner'}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    if (appointment['reason'] != null)
                      Text(
                        'Purpose: ${appointment['reason']}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: status == 'Confirmed' || status == 'Completed'
                      ? Colors.green[100]
                      : status == 'Cancelled'
                      ? Colors.red[100]
                      : Colors.orange[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: status == 'Confirmed' || status == 'Completed'
                        ? Colors.green[800]
                        : status == 'Cancelled'
                        ? Colors.red[800]
                        : Colors.orange[800],
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          if (status == 'Scheduled') ...[
            const SizedBox(height: 8),
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
          ],
        ],
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Filter Appointments'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: [
                ListTile(
                  title: const Text('By Date'),
                  leading: const Icon(Icons.calendar_today),
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  title: const Text('By Owner'),
                  leading: const Icon(Icons.person),
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  title: const Text('By Pet'),
                  leading: const Icon(Icons.pets),
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildModernNavBar() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
        child: BottomNavigationBar(
          items: [
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _selectedIndex == 0 
                      ? const Color(0xFFBDB097) 
                      : Colors.transparent,
                ),
                child: Icon(
                  Icons.dashboard_rounded,
                  size: 28,
                  color: _selectedIndex == 0 
                      ? const Color(0xFF784830) 
                      : Colors.grey,
                ),
              ),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _selectedIndex == 1 
                      ? const Color(0xFFBDB097) 
                      : Colors.transparent,
                ),
                child: Icon(
                  Icons.person_rounded,
                  size: 28,
                  color: _selectedIndex == 1 
                      ? const Color(0xFF784830) 
                      : Colors.grey,
                ),
              ),
              label: 'Profile',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: const Color(0xFF784830),
          unselectedItemColor: Colors.grey,
          onTap: _onItemTapped,
          backgroundColor: Colors.white,
          elevation: 5,
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 12,
          ),
          iconSize: 24,
        ),
      ),
    );
  }
}