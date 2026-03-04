import 'package:flutter/material.dart';
import '../models/food_item.dart';
import '../models/diary_entry.dart';
import '../services/database_service.dart';
import '../services/analytics_service.dart';

class FoodDatabaseScreen extends StatefulWidget {
  const FoodDatabaseScreen({super.key});

  @override
  State<FoodDatabaseScreen> createState() => _FoodDatabaseScreenState();
}

class _FoodDatabaseScreenState extends State<FoodDatabaseScreen> {
  final DatabaseService _dbService = DatabaseService();
  List<FoodItem> _foodItems = [];
  List<DiaryEntry> _diaryEntries = [];
  final double _dailyCalorieGoal = 2500.0;

  @override
  void initState() {
    super.initState();
    _loadData();
    AnalyticsService.logScreenView('FoodDatabaseScreen');
  }

  Future<void> _loadData() async {
    final items = await _dbService.getFoodItems();
    final entries = await _dbService.getDiaryEntries();
    setState(() {
      _foodItems = items;
      _diaryEntries = entries;
    });
  }

  double _calculateTodayCalories() {
    final now = DateTime.now();
    return _diaryEntries
        .where((e) => e.dateTime.year == now.year && e.dateTime.month == now.month && e.dateTime.day == now.day)
        .fold(0.0, (sum, item) => sum + item.calories);
  }

  String _getImageForFood(String name) {
    name = name.toLowerCase();
    if (name.contains('chicken')) return 'https://images.unsplash.com/photo-1604908176997-125f25cc6f3d?w=400';
    if (name.contains('mixed salad')) return 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400';
    if (name.contains('quinoa')) return 'https://images.unsplash.com/photo-1543339308-43e59d6b73a6?w=400';
    if (name.contains('apple')) return 'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=400';
    if (name.contains('banana')) return 'https://images.unsplash.com/photo-1528825871115-3581a5387919?w=400';
    if (name.contains('salmon')) return 'https://images.unsplash.com/photo-1467003909585-2f8a72700288?w=400';
    if (name.contains('broccoli')) return 'https://images.unsplash.com/photo-1584270354949-c26b0d5b4a0c?w=400';
    if (name.contains('yogurt')) return 'https://images.unsplash.com/photo-1488477181946-6428a0291777?w=400';
    if (name.contains('almond')) return 'https://images.unsplash.com/photo-1543208477-9807530e1227?w=400';
    if (name.contains('rice')) return 'https://images.unsplash.com/photo-1536304993881-ff6e9eefa2a6?w=400';
    return 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400';
  }

  void _showFoodDetails(FoodItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.65,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 30),
            Center(
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 25, offset: const Offset(0, 12))],
                  image: DecorationImage(image: NetworkImage(_getImageForFood(item.name)), fit: BoxFit.cover),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Text(item.name, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF2D2E42))),
            const SizedBox(height: 8),
            Text('${item.calories.toStringAsFixed(0)} kcal', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF4CAF50))),
            const Divider(height: 40),
            const Text('Nutritional Info', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2D2E42))),
            const SizedBox(height: 12),
            Text(item.description, style: TextStyle(fontSize: 16, color: Colors.grey[600], height: 1.5)),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: const Text('Close', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double todayCalories = _calculateTodayCalories();
    double progress = (todayCalories / _dailyCalorieGoal).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text('Nutrition & Food', style: TextStyle(color: Color(0xFF2D2E42), fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            // Calorie Tracker Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FE),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Daily Calories', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 4),
                          Text('${todayCalories.toStringAsFixed(0)} / ${_dailyCalorieGoal.toStringAsFixed(0)} kcal',
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2D2E42))),
                        ],
                      ),
                      Icon(Icons.local_fire_department, color: Colors.orange[700], size: 32),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 12,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(todayCalories > _dailyCalorieGoal ? Colors.red : const Color(0xFF4CAF50)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    todayCalories > _dailyCalorieGoal ? 'Goal exceeded!' : '${(_dailyCalorieGoal - todayCalories).toStringAsFixed(0)} kcal remaining',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500], fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text('Food Database', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2D2E42))),
            const SizedBox(height: 4),
            Text('Explore healthy food options', style: TextStyle(fontSize: 14, color: Colors.grey[500])),
            const SizedBox(height: 24),
            // Featured Main Card
            if (_foodItems.isNotEmpty) _buildMainFoodCard(_foodItems[0]),
            const SizedBox(height: 32),
            // Grid for the rest of items
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                childAspectRatio: 0.75,
              ),
              itemCount: _foodItems.length > 1 ? _foodItems.length - 1 : 0,
              itemBuilder: (context, index) => _buildSmallFoodCard(_foodItems[index + 1]),
            ),
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }

  Widget _buildMainFoodCard(FoodItem item) {
    return GestureDetector(
      onTap: () => _showFoodDetails(item),
      child: Container(
        height: 180,
        decoration: BoxDecoration(color: const Color(0xFFF8F9FE), borderRadius: BorderRadius.circular(90)),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: -10, top: -10,
              child: Container(
                width: 160, height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))],
                  image: DecorationImage(image: NetworkImage(_getImageForFood(item.name)), fit: BoxFit.cover),
                ),
              ),
            ),
            Positioned(
              left: 170, top: 45,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2D2E42))),
                  Text('View Details', style: TextStyle(fontSize: 13, color: Colors.grey[400])),
                  const SizedBox(height: 12),
                  Text('${item.calories.toStringAsFixed(0)} kcal', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF4CAF50))),
                ],
              ),
            ),
            Positioned(
              right: 20, top: 75,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: Color(0xFF2D2E42), shape: BoxShape.circle),
                child: const Icon(Icons.keyboard_arrow_right, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallFoodCard(FoodItem item) {
    return GestureDetector(
      onTap: () => _showFoodDetails(item),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: const Color(0xFFF8F9FE), borderRadius: BorderRadius.circular(30)),
        child: Column(
          children: [
            Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
                image: DecorationImage(image: NetworkImage(_getImageForFood(item.name)), fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 15),
            Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF2D2E42)), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text('${item.calories.toStringAsFixed(0)} kcal', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF4CAF50))),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(color: Color(0xFF2D2E42), shape: BoxShape.circle),
              child: const Icon(Icons.keyboard_arrow_right, color: Colors.white, size: 16),
            ),
          ],
        ),
      ),
    );
  }
}
