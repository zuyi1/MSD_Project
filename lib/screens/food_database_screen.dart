import 'package:flutter/material.dart';
import '../models/food_item.dart';
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

  @override
  void initState() {
    super.initState();
    _loadFoodItems();
    AnalyticsService.logScreenView('FoodDatabaseScreen');
  }

  Future<void> _loadFoodItems() async {
    final items = await _dbService.getFoodItems();
    setState(() {
      _foodItems = items;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Food Database')),
      body: ListView.builder(
        itemCount: _foodItems.length,
        itemBuilder: (context, index) {
          final item = _foodItems[index];
          return ListTile(
            title: Text(item.name),
            trailing: Text('${item.calories} kcal'),
            leading: const Icon(Icons.fastfood),
          );
        },
      ),
    );
  }
}
