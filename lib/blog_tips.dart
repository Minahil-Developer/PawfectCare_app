import 'package:flutter/material.dart';

class BlogTipsPage extends StatelessWidget {
  const BlogTipsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(72, 189, 176, 151),
      appBar: AppBar(
        title: const Text('Blog & Tips'),
        backgroundColor: const Color(0xFF784830),
      ),
      body: const Center(
        child: Text('Blog & Tips Page'),
      ),
    );
  }
}