import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../models/diary_entry.dart';
import '../services/database_service.dart';
import '../services/analytics_service.dart';
import 'package:intl/intl.dart';

class DiaryScreen extends StatefulWidget {
  const DiaryScreen({super.key});

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  final DatabaseService _dbService = DatabaseService();
  final ImagePicker _picker = ImagePicker();
  List<DiaryEntry> _entries = [];

  @override
  void initState() {
    super.initState();
    _loadEntries();
    AnalyticsService.logScreenView('DiaryScreen');
  }

  Future<void> _loadEntries() async {
    final entries = await _dbService.getDiaryEntries();
    setState(() {
      _entries = entries;
    });
  }

  Future<void> _addEntry() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image == null) return;

    // Save image to permanent storage
    final directory = await getApplicationDocumentsDirectory();
    final fileName = p.basename(image.path);
    final savedImage = await File(image.path).copy('${directory.path}/$fileName');

    final commentController = TextEditingController();

    if (!mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Comment'),
        content: TextField(
          controller: commentController,
          decoration: const InputDecoration(hintText: "How was your meal?"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final entry = DiaryEntry(
                imagePath: savedImage.path,
                comment: commentController.text,
                dateTime: DateTime.now(),
              );
              await _dbService.insertDiaryEntry(entry);
              AnalyticsService.logEvent('add_diary_entry');
              if (mounted) {
                Navigator.pop(context);
                _loadEntries();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteEntry(int id, String imagePath) async {
    await _dbService.deleteDiaryEntry(id);
    // Optionally delete the image file too
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      // Ignore errors deleting file
    }
    AnalyticsService.logEvent('delete_diary_entry', parameters: {'id': id});
    _loadEntries();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Food Diary')),
      body: _entries.isEmpty
          ? const Center(child: Text('No entries yet. Tap + to add one!'))
          : ListView.builder(
              itemCount: _entries.length,
              itemBuilder: (context, index) {
                final entry = _entries[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.file(
                        File(entry.imagePath),
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const SizedBox(
                              height: 200,
                              child: Center(child: Icon(Icons.broken_image, size: 50)),
                            ),
                      ),
                      ListTile(
                        title: Text(entry.comment),
                        subtitle: Text(DateFormat('yyyy-MM-dd HH:mm').format(entry.dateTime)),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteEntry(entry.id!, entry.imagePath),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addEntry,
        child: const Icon(Icons.add_a_photo),
      ),
    );
  }
}
