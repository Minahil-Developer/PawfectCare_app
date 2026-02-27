// File: vet_reminder.dart
import 'package:flutter/material.dart';

class VetReminderPage extends StatefulWidget {
  const VetReminderPage({super.key});

  @override
  State<VetReminderPage> createState() => _VetReminderPageState();
}

class _VetReminderPageState extends State<VetReminderPage> {
  final List<Map<String, dynamic>> _reminders = [
    {
      'title': 'Vaccination Due',
      'pet': 'Max (Golden Retriever)',
      'owner': 'Sarah Johnson',
      'date': '2023-11-15',
      'time': '10:00 AM',
      'completed': false
    },
    {
      'title': 'Follow-up Checkup',
      'pet': 'Bella (Siamese Cat)',
      'owner': 'Michael Chen',
      'date': '2023-11-16',
      'time': '2:30 PM',
      'completed': true
    },
    {
      'title': 'Annual Health Check',
      'pet': 'Charlie (Labrador)',
      'owner': 'Emma Williams',
      'date': '2023-11-17',
      'time': '11:15 AM',
      'completed': false
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(72, 189, 176, 151),
      appBar: AppBar(
        title: const Text(
          'Reminders',
          style: TextStyle(
            color: Color(0xFF784830),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF784830)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAddReminderButton(),
            const SizedBox(height: 20),
            const Text(
              'Upcoming Reminders',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF784830),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: _reminders.length,
                itemBuilder: (context, index) {
                  return _buildReminderCard(_reminders[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddReminderButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // Add new reminder functionality
          _showAddReminderDialog();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFBDB097),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Add New Reminder',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF784830),
          ),
        ),
      ),
    );
  }

  Widget _buildReminderCard(Map<String, dynamic> reminder) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  reminder['title'],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF784830),
                  ),
                ),
                Switch(
                  value: reminder['completed'],
                  onChanged: (value) {
                    setState(() {
                      reminder['completed'] = value;
                    });
                  },
                  activeColor: const Color(0xFFBDB097),
                  activeTrackColor: const Color(0xFF784830).withOpacity(0.5),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Pet: ${reminder['pet']}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              'Owner: ${reminder['owner']}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              'Date: ${reminder['date']} at ${reminder['time']}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    // Edit reminder functionality
                  },
                  child: const Text(
                    'Edit',
                    style: TextStyle(color: Color(0xFF784830)),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () {
                    // Delete reminder functionality
                  },
                  child: const Text(
                    'Delete',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddReminderDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Add New Reminder',
            style: TextStyle(color: Color(0xFF784830)),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Pet Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Owner Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Date',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Time',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
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
            ElevatedButton(
              onPressed: () {
                // Save reminder functionality
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFBDB097),
              ),
              child: const Text(
                'Save',
                style: TextStyle(color: Color(0xFF784830)),
              ),
            ),
          ],
        );
      },
    );
  }
}