import 'package:flutter/material.dart';
import 'package:pawfect_care/services/api_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class SuccessStoriesPage extends StatefulWidget {
  const SuccessStoriesPage({super.key});

  @override
  State<SuccessStoriesPage> createState() => _SuccessStoriesPageState();
}

class _SuccessStoriesPageState extends State<SuccessStoriesPage> {
  List<dynamic> _successStories = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchSuccessStories();
  }

  Future<void> _fetchSuccessStories() async {
    try {
      final userId = ApiService.getUserId();
      if (userId == null) {
        setState(() {
          _errorMessage = 'User not logged in';
          _isLoading = false;
        });
        return;
      }

      final response = await ApiService.getSuccessStories();
      setState(() {
        _successStories = response is List ? response : [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load success stories: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _addSuccessStory() async {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    String? selectedPetId;
    String? selectedAdopterId;
    List<File> selectedImages = [];

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Success Story'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Story Title',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter story title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Story Description',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 4,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter story description';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    value: selectedPetId,
                    decoration: const InputDecoration(
                      labelText: 'Select Adopted Pet',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem<String>(
                        value: 'pet1',
                        child: Text('Luna - Golden Retriever'),
                      ),
                      const DropdownMenuItem<String>(
                        value: 'pet2',
                        child: Text('Max - Labrador'),
                      ),
                    ],
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedPetId = newValue;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a pet';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    value: selectedAdopterId,
                    decoration: const InputDecoration(
                      labelText: 'Select Adopter',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem<String>(
                        value: 'adopter1',
                        child: Text('The Johnson Family'),
                      ),
                      const DropdownMenuItem<String>(
                        value: 'adopter2',
                        child: Text('Michael Thompson'),
                      ),
                    ],
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedAdopterId = newValue;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select an adopter';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    'Story Images:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () async {
                          final picker = ImagePicker();
                          final pickedFiles = await picker.pickMultiImage();
                          if (pickedFiles.isNotEmpty) {
                            setState(() {
                              selectedImages.addAll(
                                pickedFiles.map((file) => File(file.path)),
                              );
                            });
                          }
                        },
                        icon: const Icon(Icons.add_photo_alternate),
                        label: const Text('Add Images'),
                      ),
                      const SizedBox(width: 8),
                      if (selectedImages.isNotEmpty)
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              selectedImages.clear();
                            });
                          },
                          icon: const Icon(Icons.clear),
                          label: const Text('Clear'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                        ),
                    ],
                  ),

                  if (selectedImages.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: selectedImages.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.only(right: 8),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                selectedImages[index],
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  try {
                    final storyData = {
                      'title': titleController.text,
                      'description': descriptionController.text,
                      'pet': selectedPetId,
                      'adopter': selectedAdopterId,
                      'shelter': ApiService.getUserId(),
                      'images': [],
                    };

                    await ApiService.createSuccessStory(storyData);
                    Navigator.pop(context);
                    await _fetchSuccessStories();

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Success story added successfully!'),
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Error adding success story: ${e.toString()}',
                          ),
                        ),
                      );
                    }
                  }
                }
              },
              child: const Text('Add Story'),
            ),
          ],
        ),
      ),
    );
  }

  void _showStoryDetails(dynamic story) {
    final pet = story['pet'] ?? {};
    final adopter = story['adopter'] ?? {};

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(story['title']),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(story['description'], style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Text('Pet: ${pet['name'] ?? 'Unknown'}'),
              Text('Adopter: ${adopter['name'] ?? 'Unknown'}'),
              Text(
                'Date: ${DateTime.parse(story['createdAt']).day}/${DateTime.parse(story['createdAt']).month}/${DateTime.parse(story['createdAt']).year}',
              ),

              if (story['images'] != null && story['images'].isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Images:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: story['images'].length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.only(right: 8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            'http://localhost:5000/uploads/${story['images'][index]}',
                            width: 150,
                            height: 200,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 150,
                                height: 200,
                                color: Colors.grey.shade300,
                                child: const Icon(Icons.image_not_supported),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(72, 189, 176, 151),
      appBar: AppBar(
        title: const Text('Success Stories'),
        backgroundColor: const Color(0xFF784830),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: _addSuccessStory),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(child: Text(_errorMessage!))
          : _successStories.isEmpty
          ? const Center(child: Text('No success stories found'))
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.8,
              ),
              itemCount: _successStories.length,
              itemBuilder: (context, index) {
                final story = _successStories[index];
                final pet = story['pet'] ?? {};
                final adopter = story['adopter'] ?? {};
                final storyDate = DateTime.parse(story['createdAt']);

                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                          child:
                              story['images'] != null &&
                                  story['images'].isNotEmpty
                              ? Image.network(
                                  'http://localhost:5000/uploads/${story['images'][0]}',
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: double.infinity,
                                      color: Colors.grey.shade300,
                                      child: const Icon(
                                        Icons.image_not_supported,
                                        size: 50,
                                      ),
                                    );
                                  },
                                )
                              : Container(
                                  width: double.infinity,
                                  color: Colors.grey.shade300,
                                  child: const Icon(
                                    Icons.image_not_supported,
                                    size: 50,
                                  ),
                                ),
                        ),
                      ),

                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                story['title'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${pet['name'] ?? 'Unknown'} with ${adopter['name'] ?? 'Unknown'}',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Adopted on ${storyDate.day}/${storyDate.month}/${storyDate.year}',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 10,
                                ),
                              ),
                              const Spacer(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.visibility,
                                      size: 16,
                                    ),
                                    onPressed: () => _showStoryDetails(story),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
