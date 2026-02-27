import 'package:flutter/material.dart';
import 'package:pawfect_care/services/api_service.dart';
import 'login_page.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  Map<String, dynamic>? userData;
  bool isLoading = true;
  String errorMessage = '';

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
          errorMessage = 'Please login again';
          isLoading = false;
        });
        // Redirect to login page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
        return;
      }
      
      final response = await ApiService.getUserProfile();
      if (response != null && response.containsKey('id')) {
        setState(() {
          userData = response;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'User data not found or incomplete';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load user data: ${e.toString()}';
        isLoading = false;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(72, 189, 176, 151),
      appBar: AppBar(
        title: const Text(
          'My Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF784830),
        foregroundColor: Colors.white,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(
                  child: Text(
                    errorMessage,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Profile Avatar with Decorative Background
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFBDB097),
                            width: 3,
                          ),
                        ),
                        child: const CircleAvatar(
                          radius: 60,
                          backgroundColor: Color(0xFFBDB097),
                          child: Icon(
                            Icons.person,
                            size: 60,
                            color: Color(0xFF784830),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // User Name
                      Text(
                        userData?['name'] ?? ApiService.getUserName() ?? 'No Name',
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF784830),
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      // User Email - Try multiple sources
                      Text(
                        _getUserEmail(),
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 30),
                      
                      // Stats Cards Row
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard("Pets", userData?['pets_count']?.toString() ?? '0', Icons.pets),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard("Appointments", userData?['appointments_count']?.toString() ?? '0', Icons.calendar_today),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      
                      // Profile Information Card
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              _buildInfoRow(Icons.phone, "Phone", _getUserPhone()),
                              const Divider(height: 30),
                              _buildInfoRow(Icons.email, "Email", _getUserEmail()),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      
                      // Edit Profile Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            _showEditDialog();
                          },
                          icon: const Icon(Icons.edit, size: 20),
                          label: const Text(
                            'Edit Profile',
                            style: TextStyle(fontSize: 16),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF784830),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      
                      // Settings Button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // Navigate to settings
                          },
                          icon: const Icon(Icons.settings, size: 20),
                          label: const Text(
                            'Settings',
                            style: TextStyle(fontSize: 16),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            side: const BorderSide(color: Color(0xFF784830)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      
                      // Logout Button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            _handleLogout();
                          },
                          icon: const Icon(Icons.logout, size: 20),
                          label: const Text(
                            'Logout',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.red,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            side: const BorderSide(color: Colors.red),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
      bottomNavigationBar: _buildModernNavBar(),
    );
  }

  String _getUserEmail() {
    // Try multiple sources for email
    if (userData?['email'] != null) return userData!['email'];
    
    // You might need to store email during login if it's not in profile response
    final prefsData = _getStoredUserData();
    if (prefsData['email'] != null) return prefsData['email']!;
    
    return 'Email not available';
  }

  String _getUserPhone() {
    // Try multiple sources for phone
    if (userData?['phone'] != null) return userData!['phone'];
    
    // You might need to store phone during login if it's not in profile response
    final prefsData = _getStoredUserData();
    if (prefsData['phone'] != null) return prefsData['phone']!;
    
    return 'Phone not available';
  }

  Map<String, String> _getStoredUserData() {
    return {
      'email': ApiService.getUserEmail() ?? '',
      'phone': ApiService.getUserPhone() ?? '',
    };
  }

  Future<void> _handleLogout() async {
    await ApiService.logout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFBDB097).withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFF784830), size: 22),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFBDB097).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF784830), size: 24),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF784830),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog() {
    TextEditingController nameController = TextEditingController(text: userData?['name'] ?? ApiService.getUserName() ?? '');
    TextEditingController phoneController = TextEditingController(text: userData?['phone'] ?? ApiService.getUserPhone() ?? '');
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Edit Profile',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF784830),
                  ),
                ),
                const SizedBox(height: 20),
                
                // Name Field
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 15),
                
                // Phone Field
                TextFormField(
                  controller: phoneController,
                  decoration: InputDecoration(
                    labelText: 'Phone',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 20),
                
                // Update Button
                ElevatedButton(
                  onPressed: () async {
                    // Show loading indicator
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) {
                        return const Dialog(
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                          child: Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF784830)),
                            ),
                          ),
                        );
                      },
                    );
                    
                    try {
                      // Use the updateUserProfile method from ApiService
                      final response = await ApiService.updateUserProfile({
                        'name': nameController.text,
                        'phone': phoneController.text,
                      });
                      
                      // Dismiss loading indicator
                      Navigator.of(context).pop();
                      
                      // Update local state
                      setState(() {
                        userData?['name'] = nameController.text;
                        userData?['phone'] = phoneController.text;
                      });
                      
                      // Show success message
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Profile updated successfully!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      
                      // Close the dialog
                      Navigator.of(context).pop();
                    } catch (e) {
                      // Dismiss loading indicator
                      Navigator.of(context).pop();
                      
                      // Show error message
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: ${e.toString()}'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF784830),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  ),
                  child: const Text('Update'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Modern Bottom Navigation Bar for Profile Page
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
          items: const [
            BottomNavigationBarItem(
              icon: Icon(
                Icons.home_rounded,
                size: 28,
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.person_rounded,
                size: 28,
              ),
              label: 'Profile',
            ),
          ],
          currentIndex: 1,
          selectedItemColor: const Color(0xFF784830),
          unselectedItemColor: Colors.grey,
          onTap: (index) {
            if (index == 0) {
              Navigator.pop(context);
            }
          },
          backgroundColor: Colors.white,
          elevation: 10,
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