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
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadEntries();
    AnalyticsService.logScreenView('DiaryScreen');
  }

  Future<void> _loadEntries() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final entries = await _dbService.getDiaryEntries();
      if (mounted) {
        setState(() {
          _entries = entries;
        });
      }
    } catch (e) {
      debugPrint("Error loading entries: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _addEntry() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      
      if (image == null) return;

      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'img_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedImagePath = p.join(directory.path, fileName);
      
      await File(image.path).copy(savedImagePath);

      if (!mounted) return;
      
      final commentController = TextEditingController();

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text('New Journal Entry', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D2E42))),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: SizedBox(
                    height: 200,
                    width: double.infinity,
                    child: Image.file(
                      File(savedImagePath), 
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: commentController,
                  decoration: InputDecoration(
                    hintText: "What's the meal?",
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
          actionsPadding: const EdgeInsets.only(bottom: 16, right: 16),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6A5AE0),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              onPressed: () async {
                final now = DateTime.now();
                final entryDate = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, now.hour, now.minute);
                final entry = DiaryEntry(imagePath: savedImagePath, comment: commentController.text, dateTime: entryDate);
                await _dbService.insertDiaryEntry(entry);
                await AnalyticsService.logEvent(name: 'add_diary_entry');
                if (mounted) {
                  Navigator.pop(context);
                  _loadEntries();
                }
              },
              child: const Text('Save Entry', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    } catch (e) {
      debugPrint("Error adding entry: $e");
    }
  }

  Future<void> _deleteEntry(int id, String imagePath) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Entry?'),
        content: const Text('Remove this entry permanently?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.redAccent))),
        ],
      ),
    );

    if (confirmed == true) {
      await _dbService.deleteDiaryEntry(id);
      try {
        final file = File(imagePath);
        if (await file.exists()) await file.delete();
      } catch (e) {}
      await AnalyticsService.logEvent(name: 'delete_diary_entry', parameters: {'id': id});
      _loadEntries();
    }
  }

  @override
  Widget build(BuildContext context) {
    final dailyEntries = _entries.where((e) => 
      e.dateTime.year == _selectedDate.year && 
      e.dateTime.month == _selectedDate.month && 
      e.dateTime.day == _selectedDate.day).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: Text(
          DateFormat('d MMMM').format(_selectedDate),
          style: const TextStyle(color: Color(0xFF2D2E42), fontSize: 28, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF2D2E42), size: 18),
            onPressed: () => setState(() => _selectedDate = _selectedDate.subtract(const Duration(days: 1))),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios, color: Color(0xFF2D2E42), size: 18),
            onPressed: () => setState(() => _selectedDate = _selectedDate.add(const Duration(days: 1))),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Stack(
        children: [
          _isLoading 
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF6A5AE0)))
              : dailyEntries.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 120), // Bottom padding for FAB and Nav
                      itemCount: dailyEntries.length,
                      itemBuilder: (context, index) => _buildEntryCard(dailyEntries[index]),
                    ),
          Positioned(
            right: 20,
            bottom: 120, // Positioned above the nav bar overlay
            child: FloatingActionButton(
              onPressed: _addEntry,
              backgroundColor: const Color(0xFF3E5444),
              elevation: 6,
              child: const Icon(Icons.camera_alt, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_stories, size: 80, color: Colors.grey[200]),
          const SizedBox(height: 16),
          const Text('Journal is empty', style: TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildEntryCard(DiaryEntry entry) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: SizedBox(
                  height: 240,
                  width: double.infinity,
                  child: Image.file(
                    File(entry.imagePath),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[100], child: const Icon(Icons.broken_image)),
                  ),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: GestureDetector(
                  onTap: () => _deleteEntry(entry.id!, entry.imagePath),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.8), shape: BoxShape.circle),
                    child: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                entry.comment.isEmpty ? 'Meal' : entry.comment,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2D2E42)),
              ),
              Text(DateFormat('h:mm a').format(entry.dateTime), style: TextStyle(color: Colors.grey[600], fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }
}
