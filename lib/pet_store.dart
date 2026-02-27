import 'package:flutter/material.dart';

class PetStorePage extends StatelessWidget {
  const PetStorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(72, 189, 176, 151),
      appBar: AppBar(
        title: const Text('Pet Store'),
        backgroundColor: const Color.fromARGB(128, 189, 176, 151),
        foregroundColor: const Color(0xFF784830),
      ),
       body: const DefaultTextStyle(
        style: TextStyle(color: Color(0xFF784830)),
        child: Center(child: Text('Pet Store Page')),
      ),
    );
  }
}