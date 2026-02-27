import 'package:flutter/material.dart';
import 'package:pawfect_care/services/api_service.dart';
import 'package:table_calendar/table_calendar.dart';

class VetAvailabilityCalendarPage extends StatefulWidget {
  const VetAvailabilityCalendarPage({super.key});

  @override
  State<VetAvailabilityCalendarPage> createState() => _VetAvailabilityCalendarPageState();
}

class _VetAvailabilityCalendarPageState extends State<VetAvailabilityCalendarPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<dynamic>> _events = {};
  List<dynamic> _availabilitySlots = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _fetchAvailability();
  }

  Future<void> _fetchAvailability() async {
    try {
      final userId = ApiService.getUserId();
      if (userId == null) {
        setState(() {
          _errorMessage = 'User not logged in';
          _isLoading = false;
        });
        return;
      }

      // For now, we'll create mock data since we need to implement the API endpoint
      setState(() {
        _availabilitySlots = [
          {
            'id': '1',
            'date': DateTime.now().toIso8601String(),
            'startTime': '09:00',
            'endTime': '17:00',
            'isAvailable': true,
          },
          {
            'id': '2',
            'date': DateTime.now().add(const Duration(days: 1)).toIso8601String(),
            'startTime': '09:00',
            'endTime': '17:00',
            'isAvailable': true,
          },
        ];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load availability: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _addAvailabilitySlot() async {
    if (_selectedDay == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date first')),
      );
      return;
    }

    final formKey = GlobalKey<FormState>();
    TimeOfDay selectedStartTime = TimeOfDay.now();
    TimeOfDay selectedEndTime = TimeOfDay.now();

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Availability'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Date: ${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                
                // Start time
                ListTile(
                  title: const Text('Start Time'),
                  subtitle: Text(selectedStartTime.format(context)),
                  trailing: const Icon(Icons.access_time),
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: selectedStartTime,
                    );
                    if (time != null) {
                      setState(() {
                        selectedStartTime = time;
                      });
                    }
                  },
                ),
                
                // End time
                ListTile(
                  title: const Text('End Time'),
                  subtitle: Text(selectedEndTime.format(context)),
                  trailing: const Icon(Icons.access_time),
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: selectedEndTime,
                    );
                    if (time != null) {
                      setState(() {
                        selectedEndTime = time;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  final availabilityData = {
                    'veterinarian': ApiService.getUserId(),
                    'date': _selectedDay!.toIso8601String(),
                    'startTime': '${selectedStartTime.hour.toString().padLeft(2, '0')}:${selectedStartTime.minute.toString().padLeft(2, '0')}',
                    'endTime': '${selectedEndTime.hour.toString().padLeft(2, '0')}:${selectedEndTime.minute.toString().padLeft(2, '0')}',
                    'isAvailable': true,
                  };
                  
                  await ApiService.setVeterinarianAvailability(availabilityData);
                  Navigator.pop(context);
                  await _fetchAvailability();
                  
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Availability added successfully!')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error adding availability: ${e.toString()}')),
                    );
                  }
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  List<dynamic> _getEventsForDay(DateTime day) {
    final dayKey = DateTime(day.year, day.month, day.day);
    return _events[dayKey] ?? [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(72, 189, 176, 151),
      appBar: AppBar(
        title: const Text('Availability Calendar'),
        backgroundColor: const Color(0xFF784830),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addAvailabilitySlot,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : Column(
                  children: [
                    // Calendar
                    Card(
                      margin: const EdgeInsets.all(16),
                      child: TableCalendar<dynamic>(
                        firstDay: DateTime.utc(2020, 1, 1),
                        lastDay: DateTime.utc(2030, 12, 31),
                        focusedDay: _focusedDay,
                        calendarFormat: _calendarFormat,
                        eventLoader: _getEventsForDay,
                        startingDayOfWeek: StartingDayOfWeek.monday,
                        calendarStyle: const CalendarStyle(
                          outsideDaysVisible: false,
                          weekendTextStyle: TextStyle(color: Colors.red),
                        ),
                        headerStyle: const HeaderStyle(
                          formatButtonVisible: true,
                          titleCentered: true,
                          formatButtonShowsNext: false,
                          formatButtonDecoration: BoxDecoration(
                            color: Color(0xFF784830),
                          ),
                          formatButtonTextStyle: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        selectedDayPredicate: (day) {
                          return isSameDay(_selectedDay, day);
                        },
                        onDaySelected: _onDaySelected,
                        onFormatChanged: (format) {
                          if (_calendarFormat != format) {
                            setState(() {
                              _calendarFormat = format;
                            });
                          }
                        },
                        onPageChanged: (focusedDay) {
                          _focusedDay = focusedDay;
                        },
                      ),
                    ),
                    
                    // Selected day info
                    if (_selectedDay != null) ...[
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Availability for ${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text('No availability slots set for this date'),
                            const SizedBox(height: 8),
                            ElevatedButton.icon(
                              onPressed: _addAvailabilitySlot,
                              icon: const Icon(Icons.add),
                              label: const Text('Add Availability'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF784830),
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
    );
  }
}
