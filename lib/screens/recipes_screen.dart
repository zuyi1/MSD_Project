import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../services/analytics_service.dart';

class RecipesScreen extends StatefulWidget {
  const RecipesScreen({super.key});

  @override
  State<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends State<RecipesScreen> {
  final DatabaseService _dbService = DatabaseService();
  List<Map<String, dynamic>> _recipes = [];

  @override
  void initState() {
    super.initState();
    _loadRecipes();
    AnalyticsService.logScreenView('RecipesScreen');
  }

  Future<void> _loadRecipes() async {
    final recipes = await _dbService.getRecipes();
    setState(() {
      _recipes = recipes;
    });
  }

  String _getRecipeImage(String title) {
    title = title.toLowerCase();
    if (title.contains('avocado toast')) return 'https://images.unsplash.com/photo-1525351484163-7529414344d8?w=400';
    if (title.contains('quinoa salad')) return 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400';
    if (title.contains('baked salmon')) return 'https://images.unsplash.com/photo-1467003909585-2f8a72700288?w=400';
    if (title.contains('greek yogurt bowl')) return 'https://images.unsplash.com/photo-1488477181946-6428a0291777?w=400';
    if (title.contains('chicken stir-fry')) return 'https://images.unsplash.com/photo-1604908176997-125f25cc6f3d?w=400';
    if (title.contains('smoothie bowl')) return 'https://images.unsplash.com/photo-1543339308-43e59d6b73a6?w=400';
    if (title.contains('lentil soup')) return 'https://images.unsplash.com/photo-1547592166-23ac45744acd?w=400';
    if (title.contains('grilled veggies')) return 'https://images.unsplash.com/photo-1452960962994-acf4fd70b632?w=400';
    if (title.contains('egg white omelet')) return 'https://images.unsplash.com/photo-1510629954389-c1e0da47d414?w=400';
    if (title.contains('berry chia pudding')) return 'https://images.unsplash.com/photo-1508029051792-6369144f7fe3?w=400';
    return 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400';
  }

  String _getRecipeTag(String title) {
    title = title.toLowerCase();
    if (title.contains('salad') || title.contains('chicken')) return 'full of protein';
    if (title.contains('bowl') || title.contains('pudding')) return 'vegan food';
    return 'healthy';
  }

  void _showRecipeDetails(Map<String, dynamic> recipe) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)))),
              const SizedBox(height: 20),
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(_getRecipeImage(recipe['title']), height: 250, width: double.infinity, fit: BoxFit.cover),
              ),
              const SizedBox(height: 20),
              Text(recipe['title'], style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF2D2E42))),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: const Color(0xFFEFFF5E), borderRadius: BorderRadius.circular(20)),
                child: Text(_getRecipeTag(recipe['title']), style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
              const SizedBox(height: 20),
              const Text('Ingredients', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2D2E42))),
              const SizedBox(height: 10),
              Text(recipe['ingredients'], style: const TextStyle(fontSize: 16, color: Colors.grey, height: 1.5)),
              const SizedBox(height: 20),
              const Text('Steps', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2D2E42))),
              const SizedBox(height: 10),
              Text(recipe['steps'], style: const TextStyle(fontSize: 16, color: Colors.grey, height: 1.5)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Container(
          height: 45,
          decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(15)),
          child: const TextField(
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.search, color: Colors.grey),
              hintText: 'Search more recipes',
              hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 10),
            ),
            style: TextStyle(color: Colors.black),
          ),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.tune, color: Color(0xFF2D2E42)), onPressed: () {}),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
        itemCount: _recipes.length,
        itemBuilder: (context, index) {
          final recipe = _recipes[index];
          return GestureDetector(
            onTap: () => _showRecipeDetails(recipe),
            child: Container(
              height: 140,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FE), 
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 24, top: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(recipe['title'], style: const TextStyle(color: Color(0xFF2D2E42), fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.access_time, color: Colors.grey, size: 14),
                            const SizedBox(width: 4),
                            const Text('15 min', style: TextStyle(color: Colors.grey, fontSize: 12)),
                            const SizedBox(width: 12),
                            const Icon(Icons.restaurant_menu, color: Colors.grey, size: 14),
                            const SizedBox(width: 4),
                            const Text('5 ingredients', style: TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: const Color(0xFFEFFF5E), borderRadius: BorderRadius.circular(20)),
                          child: Text(_getRecipeTag(recipe['title']), style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 10)),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    right: -10,
                    top: -10,
                    bottom: -10,
                    child: Container(
                      width: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
                        image: DecorationImage(image: NetworkImage(_getRecipeImage(recipe['title'])), fit: BoxFit.cover),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
