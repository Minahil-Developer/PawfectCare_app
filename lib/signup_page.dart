import 'package:flutter/material.dart';
import 'package:pawfect_care/services/api_service.dart';
import 'login_page.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _qualificationController = TextEditingController();
  final TextEditingController _shelterNameController = TextEditingController();
  final TextEditingController _shelterAddressController = TextEditingController();

  String _selectedUserType = 'Pet Owner';
  String? _selectedQualification;

  // User type options
  final List<String> _userTypes = ['Pet Owner', 'Veterinarian', 'Animal Shelter'];
  
  // Qualification options (for veterinarians)
  final List<String> _qualifications = ['BSc', 'MSc', 'PhD'];

  Future<void> _signup() async {
    if (_formKey.currentState!.validate()) {
      try {
        final response = await ApiService.registerUser(
          name: _nameController.text,
          email: _emailController.text,
          phone: _phoneController.text,
          password: _passwordController.text,
          userType: _selectedUserType,
          qualification: _selectedUserType == 'Veterinarian' 
              ? _selectedQualification 
              : null,
          shelterName: _selectedUserType == 'Animal Shelter'
              ? _shelterNameController.text
              : null,
          shelterAddress: _selectedUserType == 'Animal Shelter'
              ? _shelterAddressController.text
              : null,
        );

        // Show success message and redirect to login
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Signup successful! Please login.')),
        );
        
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Signup failed: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(72, 189, 176, 151),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              // Logo
              Center(
                child: Image.asset(
                  'assets/images/logo.png',
                  height: 100,
                ),
              ),
              const SizedBox(height: 20),
              // Create account text
              const Text(
                'Create Account',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF784830),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Sign up to get started',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 30),
              // Signup form
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // User type dropdown
                    DropdownButtonFormField<String>(
                      value: _selectedUserType,
                      decoration: InputDecoration(
                        labelText: 'User Type',
                        labelStyle: const TextStyle(color: Color(0xFF784830)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Color(0xFF784830)),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        prefixIcon: const Icon(Icons.person, color: Color(0xFF784830)),
                      ),
                      items: _userTypes.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedUserType = value!;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a user type';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    // Name field
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Name',
                        labelStyle: const TextStyle(color: Color(0xFF784830)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Color(0xFF784830)),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF784830)),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    // Email field
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: const TextStyle(color: Color(0xFF784830)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Color(0xFF784830)),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        prefixIcon: const Icon(Icons.email, color: Color(0xFF784830)),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!value.contains('@')) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    // Phone field
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'Phone',
                        labelStyle: const TextStyle(color: Color(0xFF784830)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Color(0xFF784830)),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        prefixIcon: const Icon(Icons.phone, color: Color(0xFF784830)),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your phone number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    // Shelter Name field (only for Animal Shelter)
                    if (_selectedUserType == 'Animal Shelter')
                      TextFormField(
                        controller: _shelterNameController,
                        decoration: InputDecoration(
                          labelText: 'Shelter Name',
                          labelStyle: const TextStyle(color: Color(0xFF784830)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Color(0xFF784830)),
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          prefixIcon: const Icon(Icons.business, color: Color(0xFF784830)),
                        ),
                        validator: (value) {
                          if (_selectedUserType == 'Animal Shelter' && 
                              (value == null || value.isEmpty)) {
                            return 'Please enter shelter name';
                          }
                          return null;
                        },
                      ),
                    if (_selectedUserType == 'Animal Shelter') const SizedBox(height: 20),
                    // Shelter Address field (only for Animal Shelter)
                    if (_selectedUserType == 'Animal Shelter')
                      TextFormField(
                        controller: _shelterAddressController,
                        decoration: InputDecoration(
                          labelText: 'Shelter Address',
                          labelStyle: const TextStyle(color: Color(0xFF784830)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Color(0xFF784830)),
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          prefixIcon: const Icon(Icons.location_on, color: Color(0xFF784830)),
                        ),
                        validator: (value) {
                          if (_selectedUserType == 'Animal Shelter' && 
                              (value == null || value.isEmpty)) {
                            return 'Please enter shelter address';
                          }
                          return null;
                        },
                      ),
                    if (_selectedUserType == 'Animal Shelter') const SizedBox(height: 20),
                    // Qualification field (only for veterinarians)
                    if (_selectedUserType == 'Veterinarian')
                      DropdownButtonFormField<String>(
                        value: _selectedQualification,
                        decoration: InputDecoration(
                          labelText: 'Qualification',
                          labelStyle: const TextStyle(color: Color(0xFF784830)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Color(0xFF784830)),
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          prefixIcon: const Icon(Icons.school, color: Color(0xFF784830)),
                        ),
                        items: _qualifications.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedQualification = value;
                          });
                        },
                        validator: (value) {
                          if (_selectedUserType == 'Veterinarian' && 
                              (value == null || value.isEmpty)) {
                            return 'Please select your qualification';
                          }
                          return null;
                        },
                      ),
                    if (_selectedUserType == 'Veterinarian') const SizedBox(height: 20),
                    // Password field
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: const TextStyle(color: Color(0xFF784830)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Color(0xFF784830)),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        prefixIcon: const Icon(Icons.lock, color: Color(0xFF784830)),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 30),
                    // Sign up button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _signup,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF784830),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                        ),
                        child: const Text(
                          'Sign up',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Login link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Already have an account? ",
                          style: TextStyle(color: Colors.grey),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const LoginPage()),
                            );
                          },
                          child: const Text(
                            'Login',
                            style: TextStyle(
                              color: Color(0xFF784830),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}