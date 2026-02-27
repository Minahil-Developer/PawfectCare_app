import 'package:flutter/material.dart';
import 'splash_screen.dart';
import 'home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pawfect Care',
      theme: ThemeData(
        primaryColor: const Color(0xFF784830),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: const Color(0xFFBDB097),
        ),
      ),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}