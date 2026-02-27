// File: vet_upload_reports.dart
import 'package:flutter/material.dart';

class VetUploadReportsPage extends StatefulWidget {
  const VetUploadReportsPage({super.key});

  @override
  State<VetUploadReportsPage> createState() => _VetUploadReportsPageState();
}

class _VetUploadReportsPageState extends State<VetUploadReportsPage> {
  final List<Map<String, dynamic>> _recentUploads = [
    {
      'name': 'Max_BloodTest_2023-11-10.pdf',
      'pet': 'Max (Golden Retriever)',
      'date': '2023-11-10',
      'size': '2.4 MB'
    },
    {
      'name': 'Bella_XRay_2023-11-05.jpg',
      'pet': 'Bella (Siamese Cat)',
      'date': '2023-11-05',
      'size': '4.7 MB'
    },
    {
      'name': 'Charlie_Vaccination_2023-11-01.pdf',
      'pet': 'Charlie (Labrador)',
      'date': '2023-11-01',
      'size': '1.8 MB'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(72, 189, 176, 151),
      appBar: AppBar(
        title: const Text(
          'Upload Reports',
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
            _buildUploadSection(),
            const SizedBox(height: 30),
            const Text(
              'Recent Uploads',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF784830),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: _recentUploads.length,
                itemBuilder: (context, index) {
                  return _buildFileCard(_recentUploads[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFBDB097),
          borderRadius: BorderRadius.circular(15.0),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(
              Icons.cloud_upload,
              size: 50,
              color: Color(0xFF784830),
            ),
            const SizedBox(height: 15),
            const Text(
              'Upload Medical Reports',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF784830),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Upload X-rays, test results, or other medical documents for your patients',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF784830),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildUploadButton(Icons.photo_library, 'Gallery'),
                _buildUploadButton(Icons.camera_alt, 'Camera'),
                _buildUploadButton(Icons.insert_drive_file, 'Files'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadButton(IconData icon, String label) {
    return Column(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: const Color(0xFF784830),
          child: IconButton(
            icon: Icon(icon, color: Colors.white),
            onPressed: () {
              // Handle upload from different sources
              _handleUploadSource(label);
            },
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF784830),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildFileCard(Map<String, dynamic> file) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: const Icon(
          Icons.picture_as_pdf,
          color: Color(0xFF784830),
          size: 40,
        ),
        title: Text(
          file['name'],
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF784830),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(file['pet']),
            const SizedBox(height: 4),
            Text('${file['date']} • ${file['size']}'),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.more_vert, color: Color(0xFF784830)),
          onPressed: () {
            // Show options menu
            _showFileOptions(file);
          },
        ),
      ),
    );
  }

  void _handleUploadSource(String source) {
    // Implement file upload functionality based on the source
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Uploading from $source'),
        backgroundColor: const Color(0xFFBDB097),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showFileOptions(Map<String, dynamic> file) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.visibility, color: Color(0xFF784830)),
                title: const Text('View File'),
                onTap: () {
                  Navigator.pop(context);
                  // Implement view file functionality
                },
              ),
              ListTile(
                leading: const Icon(Icons.share, color: Color(0xFF784830)),
                title: const Text('Share'),
                onTap: () {
                  Navigator.pop(context);
                  // Implement share functionality
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit, color: Color(0xFF784830)),
                title: const Text('Rename'),
                onTap: () {
                  Navigator.pop(context);
                  // Implement rename functionality
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  // Implement delete functionality
                },
              ),
            ],
          ),
        );
      },
    );
  }
}