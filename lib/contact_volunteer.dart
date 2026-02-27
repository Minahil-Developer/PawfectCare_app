import 'package:flutter/material.dart';

class ContactVolunteerPage extends StatefulWidget {
  const ContactVolunteerPage({super.key});

  @override
  State<ContactVolunteerPage> createState() => _ContactVolunteerPageState();
}

class _ContactVolunteerPageState extends State<ContactVolunteerPage> {
  int _selectedTab = 0;
  
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Contact & Volunteer'),
          backgroundColor: const Color(0xFF784830),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Messages'),
              Tab(text: 'Volunteers'),
              Tab(text: 'Donations'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Messages Tab
            ListView(
              children: const [
                ListTile(
                  leading: CircleAvatar(
                    child: Icon(Icons.person),
                  ),
                  title: Text('John Doe'),
                  subtitle: Text('I would like to inquire about adoption...'),
                  trailing: Text('2 days ago'),
                ),
                ListTile(
                  leading: CircleAvatar(
                    child: Icon(Icons.person),
                  ),
                  title: Text('Jane Smith'),
                  subtitle: Text('Is the vaccination included in the...'),
                  trailing: Text('5 days ago'),
                ),
              ],
            ),
            
            // Volunteers Tab
            ListView(
              children: const [
                ListTile(
                  leading: CircleAvatar(
                    child: Icon(Icons.person),
                  ),
                  title: Text('Robert Johnson'),
                  subtitle: Text('Applied for weekend volunteering'),
                  trailing: Chip(label: Text('Pending')),
                ),
                ListTile(
                  leading: CircleAvatar(
                    child: Icon(Icons.person),
                  ),
                  title: Text('Sarah Williams'),
                  subtitle: Text('Experienced with dogs'),
                  trailing: Chip(label: Text('Approved')),
                ),
              ],
            ),
            
            // Donations Tab
            ListView(
              children: const [
                ListTile(
                  leading: Icon(Icons.attach_money, color: Colors.green),
                  title: Text('Anonymous Donor'),
                  subtitle: Text('\$200 donation'),
                  trailing: Text('Oct 10, 2023'),
                ),
                ListTile(
                  leading: Icon(Icons.attach_money, color: Colors.green),
                  title: Text('Local Business'),
                  subtitle: Text('Pet food supplies'),
                  trailing: Text('Oct 5, 2023'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}