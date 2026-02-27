// File: vet_patient_profiles.dart
import 'package:flutter/material.dart';

class VetPatientProfilesPage extends StatelessWidget {
  const VetPatientProfilesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(72, 189, 176, 151),
      appBar: AppBar(
        title: const Text('Patient Profiles'),
        backgroundColor: const Color(0xFF784830),
      ),
      body: const Center(
        child: Text('Patient Profiles Page'),
      ),
    );
  }
}