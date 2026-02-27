import 'package:flutter/material.dart';
import 'package:pawfect_care/services/api_service.dart';
import 'vet_medical_records.dart';
import 'vet_appointments.dart';
import 'vet_patients_profiles.dart';
import 'vet_dashboard.dart';
import 'vet_upload_reports.dart';
import 'vet_reminders.dart';
import 'login_page.dart';

class VetHomePage extends StatefulWidget {
  const VetHomePage({super.key});

  @override
  State<VetHomePage> createState() => _VetHomePageState();
}

class _VetHomePageState extends State<VetHomePage> {
  int _selectedIndex = 0;
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final token = await ApiService.getToken();
      if (token == null) {
        setState(() {
          _errorMessage = 'Please login again';
          _isLoading = false;
        });
        // Redirect to login page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
        return;
      }
      
      final response = await ApiService.getUserProfile();
      print('User data response: $response'); // Debug print
      
      if (response != null && response.containsKey('id')) {
        setState(() {
          _userData = response;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'User data not found or incomplete';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load user data: ${e.toString()}';
        _isLoading = false;
      });
      
      // If it's an authentication error, redirect to login
      if (e.toString().contains('401') || e.toString().contains('403') || e.toString().contains('User not found')) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    }
  }

  String _getUserName() {
    if (_userData == null) return '';
    
    // Try different possible field names for the user's name
    final name = _userData!['name'] ?? 
                 _userData!['fullName'] ?? 
                 _userData!['username'] ?? 
                 _userData!['firstName'] ??
                 _userData!['email']?.split('@').first ?? 
                 '';
    
    // If we have a full name, get just the first part
    if (name.contains(' ')) {
      return name.split(' ').first;
    }
    
    return name;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(72, 189, 176, 151),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 0),
            child: AppBar(
              backgroundColor: const Color.fromARGB(128, 189, 176, 151),
              elevation: 0,
              title: Container(
                margin: const EdgeInsets.only(top: 20),
                child: Center(
                  child: Image.asset(
                    'assets/images/logo.png', 
                    height: 100,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_errorMessage != null)
              Center(
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              )
            else
              Center(
                child: Text(
                  'Welcome Dr. ${_getUserName()}!',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF784830),
                  ),
                ),
              ),
            const SizedBox(height: 10),
            const Center(
              child: Text(
                'Manage your veterinary practice efficiently',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 30),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                _buildFeatureCard(
                  icon: Icons.dashboard,
                  title: 'Dashboard',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const VetDashboardPage(),
                      ),
                    );
                  },
                ),
                _buildFeatureCard(
                  icon: Icons.medical_services,
                  title: 'Medical Records',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const VetMedicalRecordsPage(),
                      ),
                    );
                  },
                ),
                _buildFeatureCard(
                  icon: Icons.calendar_today,
                  title: 'Appointments',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const VetAppointmentsPage(),
                      ),
                    );
                  },
                ),
                _buildFeatureCard(
                  icon: Icons.pets,
                  title: 'Patient Profiles',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const VetPatientProfilesPage(),
                      ),
                    );
                  },
                ),
                _buildFeatureCard(
                  icon: Icons.upload_file,
                  title: 'Upload Reports',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const VetUploadReportsPage(),
                      ),
                    );
                  },
                ),
                _buildFeatureCard(
                  icon: Icons.notifications,
                  title: 'Reminders',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const VetReminderPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildModernNavBar(),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15.0),
        child: Container(
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 255, 255, 255),
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: const Color(0xFF784830)),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF784830),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
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
                  Icons.home_rounded,
                  size: 28,
                  color: _selectedIndex == 0
                      ? const Color(0xFF784830)
                      : Colors.grey,
                ),
              ),
              label: 'Home',
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