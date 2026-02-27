import 'package:flutter/material.dart';
import 'package:pawfect_care/services/api_service.dart';

class AdoptionRequestsPage extends StatefulWidget {
  const AdoptionRequestsPage({super.key});

  @override
  State<AdoptionRequestsPage> createState() => _AdoptionRequestsPageState();
}

class _AdoptionRequestsPageState extends State<AdoptionRequestsPage> {
  List<dynamic> _adoptionRequests = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _fetchAdoptionRequests();
  }

  Future<void> _fetchAdoptionRequests() async {
    try {
      final userId = ApiService.getUserId();
      if (userId == null) {
        setState(() {
          _errorMessage = 'User not logged in';
          _isLoading = false;
        });
        return;
      }

      final response = await ApiService.getAdoptionRequestsByShelter(userId);
      setState(() {
        _adoptionRequests = response is List ? response : [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load adoption requests: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _approveRequest(dynamic request) async {
    try {
      await ApiService.updateAdoptionRequestStatus(request['_id'], 'Approved');
      await _fetchAdoptionRequests();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Adoption request approved!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error approving request: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _rejectRequest(dynamic request) async {
    try {
      await ApiService.updateAdoptionRequestStatus(request['_id'], 'Rejected');
      await _fetchAdoptionRequests();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Adoption request rejected')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error rejecting request: ${e.toString()}')),
        );
      }
    }
  }

  void _showRequestDetails(dynamic request) {
    final pet = request['pet'] ?? {};
    final requester = request['requester'] ?? {};
    final requesterInfo = request['requesterInfo'] ?? {};

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adoption Request Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Pet information
              const Text('Pet Information:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Name: ${pet['name'] ?? 'Unknown'}'),
              Text('Species: ${pet['species'] ?? 'Unknown'}'),
              Text('Breed: ${pet['breed'] ?? 'Unknown'}'),
              Text('Age: ${pet['age'] ?? 'Unknown'}'),
              Text('Gender: ${pet['gender'] ?? 'Unknown'}'),
              const SizedBox(height: 16),
              
              // Requester information
              const Text('Requester Information:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Name: ${requester['name'] ?? requesterInfo['name'] ?? 'Unknown'}'),
              Text('Email: ${requester['email'] ?? requesterInfo['email'] ?? 'Unknown'}'),
              Text('Phone: ${requester['phone'] ?? requesterInfo['phone'] ?? 'Unknown'}'),
              if (requesterInfo['address'] != null)
                Text('Address: ${requesterInfo['address']}'),
              const SizedBox(height: 16),
              
              // Request details
              const Text('Request Details:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Date: ${DateTime.parse(request['createdAt']).day}/${DateTime.parse(request['createdAt']).month}/${DateTime.parse(request['createdAt']).year}'),
              Text('Status: ${request['status']}'),
              if (request['message'] != null && request['message'].isNotEmpty) ...[
                const SizedBox(height: 8),
                const Text('Message:'),
                Text(request['message']),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (request['status'] == 'Pending') ...[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _rejectRequest(request);
              },
              child: const Text('Reject', style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _approveRequest(request);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Approve', style: TextStyle(color: Colors.white)),
            ),
          ],
        ],
      ),
    );
  }

  List<dynamic> _getFilteredRequests() {
    if (_selectedFilter == 'All') {
      return _adoptionRequests;
    }
    return _adoptionRequests.where((req) => req['status'] == _selectedFilter).toList();
  }

  String _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'orange';
      case 'approved':
        return 'green';
      case 'rejected':
        return 'red';
      default:
        return 'grey';
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredRequests = _getFilteredRequests();

    return Scaffold(
      backgroundColor: const Color.fromARGB(72, 189, 176, 151),
      appBar: AppBar(
        title: const Text('Adoption Requests'),
        backgroundColor: const Color(0xFF784830),
        actions: [
          PopupMenuButton<String>(
            onSelected: (String value) {
              setState(() {
                _selectedFilter = value;
              });
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'All',
                child: Text('All Requests'),
              ),
              const PopupMenuItem<String>(
                value: 'Pending',
                child: Text('Pending'),
              ),
              const PopupMenuItem<String>(
                value: 'Approved',
                child: Text('Approved'),
              ),
              const PopupMenuItem<String>(
                value: 'Rejected',
                child: Text('Rejected'),
              ),
            ],
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _selectedFilter,
                    style: const TextStyle(color: Colors.white),
                  ),
                  const Icon(Icons.arrow_drop_down, color: Colors.white),
                ],
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : filteredRequests.isEmpty
                  ? const Center(child: Text('No adoption requests found'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredRequests.length,
                      itemBuilder: (context, index) {
                        final request = filteredRequests[index];
                        final pet = request['pet'] ?? {};
                        final requester = request['requester'] ?? {};
                        final requesterInfo = request['requesterInfo'] ?? {};
                        final status = request['status'] ?? 'Pending';
                        final statusColor = _getStatusColor(status);
                        final requestDate = DateTime.parse(request['createdAt']);

                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    // Pet image
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: pet['photo'] != null && pet['photo'].isNotEmpty
                                          ? Image.network(
                                              'http://localhost:5000/uploads/${pet['photo']}',
                                              width: 60,
                                              height: 60,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) {
                                                return Container(
                                                  width: 60,
                                                  height: 60,
                                                  color: Colors.grey.shade300,
                                                  child: const Icon(Icons.pets, size: 30),
                                                );
                                              },
                                            )
                                          : Container(
                                              width: 60,
                                              height: 60,
                                              color: Colors.grey.shade300,
                                              child: const Icon(Icons.pets, size: 30),
                                            ),
                                    ),
                                    const SizedBox(width: 16),
                                    
                                    // Request details
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            pet['name'] ?? 'Unknown Pet',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${pet['species'] ?? 'Unknown'} • ${pet['breed'] ?? 'Unknown'}',
                                            style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Requested by: ${requester['name'] ?? requesterInfo['name'] ?? 'Unknown'}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 14,
                                            ),
                                          ),
                                          Text(
                                            'Date: ${requestDate.day}/${requestDate.month}/${requestDate.year}',
                                            style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    
                                    // Status and actions
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: statusColor == 'orange' ? Colors.orange.shade100
                                                : statusColor == 'green' ? Colors.green.shade100
                                                : statusColor == 'red' ? Colors.red.shade100
                                                : Colors.grey.shade100,
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                          child: Text(
                                            status,
                                            style: TextStyle(
                                              color: statusColor == 'orange' ? Colors.orange.shade800
                                                  : statusColor == 'green' ? Colors.green.shade800
                                                  : statusColor == 'red' ? Colors.red.shade800
                                                  : Colors.grey.shade800,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.visibility),
                                              onPressed: () => _showRequestDetails(request),
                                            ),
                                            if (status == 'Pending') ...[
                                              IconButton(
                                                icon: const Icon(Icons.check, color: Colors.green),
                                                onPressed: () => _approveRequest(request),
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.close, color: Colors.red),
                                                onPressed: () => _rejectRequest(request),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                
                                if (request['message'] != null && request['message'].isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  const Divider(),
                                  const SizedBox(height: 8),
                                  const Text('Message:', style: TextStyle(fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  Text(request['message']),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}