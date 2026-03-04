import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/diary_entry.dart';
import '../models/user_profile.dart';
import '../models/water_log.dart';
import '../models/food_item.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'food_diary.db');
    return await openDatabase(
      path,
      version: 2, // Incremented version to add description field
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE food_items ADD COLUMN description TEXT');
      // Update existing items or re-populate
      await db.delete('food_items');
      _insertInitialFood(db);
    }
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE diary_entries(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        imagePath TEXT,
        comment TEXT,
        dateTime TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE user_profile(
        id INTEGER PRIMARY KEY CHECK (id = 0),
        name TEXT,
        age INTEGER,
        weight REAL,
        height REAL
      )
    ''');
    await db.execute('''
      CREATE TABLE water_logs(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount REAL,
        dateTime TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE food_items(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        calories REAL,
        description TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE recipes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        description TEXT,
        ingredients TEXT,
        steps TEXT
      )
    ''');

    await _insertInitialFood(db);
    await _insertInitialRecipes(db);
  }

  Future _insertInitialFood(Database db) async {
    List<FoodItem> initialFood = [
      FoodItem(name: 'Chicken Salad', calories: 350, description: 'Fresh chicken with Avocado and greens.'),
      FoodItem(name: 'Mixed Salad', calories: 200, description: 'Assorted seasonal vegetables with vinaigrette.'),
      FoodItem(name: 'Quinoa Salad', calories: 280, description: 'Protein-rich quinoa with spicy garlic dressing.'),
      FoodItem(name: 'Apple', calories: 95, description: 'Crisp and sweet organic apple.'),
      FoodItem(name: 'Banana', calories: 105, description: 'Energy-boosting potassium-rich fruit.'),
      FoodItem(name: 'Grilled Salmon', calories: 400, description: 'Omega-3 rich Atlantic salmon grilled to perfection.'),
      FoodItem(name: 'Broccoli', calories: 31, description: 'Steamed green florets, high in fiber.'),
      FoodItem(name: 'Greek Yogurt', calories: 100, description: 'Creamy yogurt with active cultures.'),
      FoodItem(name: 'Almonds', calories: 164, description: 'Handful of raw, unsalted energy nuts.'),
      FoodItem(name: 'Brown Rice', calories: 216, description: 'Whole grain goodness for lasting energy.'),
    ];

    for (var food in initialFood) {
      await db.insert('food_items', food.toMap());
    }
  }

  Future _insertInitialRecipes(Database db) async {
     final List<Map<String, dynamic>> initialRecipes = [
      {'title': 'Avocado Toast', 'description': 'Healthy morning toast', 'ingredients': 'Avocado, Whole grain bread, Salt', 'steps': 'Toast bread, mash avocado on top.'},
      {'title': 'Quinoa Salad', 'description': 'Refreshing lunch', 'ingredients': 'Quinoa, Cucumber, Tomato, Feta', 'steps': 'Cook quinoa, mix with chopped veggies.'},
      {'title': 'Baked Salmon', 'description': 'Rich in Omega-3', 'ingredients': 'Salmon, Lemon, Garlic', 'steps': 'Season salmon, bake at 200C for 15 mins.'},
      {'title': 'Greek Yogurt Bowl', 'description': 'Protein-packed snack', 'ingredients': 'Yogurt, Berries, Honey', 'steps': 'Top yogurt with fresh berries.'},
      {'title': 'Chicken Stir-fry', 'description': 'Quick healthy dinner', 'ingredients': 'Chicken, Bell peppers, Soy sauce', 'steps': 'Sauté chicken and peppers in wok.'},
      {'title': 'Smoothie Bowl', 'description': 'Fruity goodness', 'ingredients': 'Banana, Spinach, Almond milk', 'steps': 'Blend and top with seeds.'},
      {'title': 'Lentil Soup', 'description': 'Hearty and warm', 'ingredients': 'Lentils, Carrots, Onion', 'steps': 'Simmer lentils with veggies until soft.'},
      {'title': 'Grilled Veggies', 'description': 'Simple side dish', 'ingredients': 'Zucchini, Eggplant, Olive oil', 'steps': 'Grill sliced veggies with oil.'},
      {'title': 'Egg White Omelet', 'description': 'Low calorie breakfast', 'ingredients': 'Egg whites, Spinach, Mushrooms', 'steps': 'Cook in non-stick pan.'},
      {'title': 'Berry Chia Pudding', 'description': 'Make ahead breakfast', 'ingredients': 'Chia seeds, Coconut milk, Berries', 'steps': 'Soak seeds overnight, top with berries.'},
    ];

    for (var recipe in initialRecipes) {
      await db.insert('recipes', recipe);
    }
  }

  // Diary Entry operations
  Future<int> insertDiaryEntry(DiaryEntry entry) async {
    Database db = await database;
    return await db.insert('diary_entries', entry.toMap());
  }

  Future<List<DiaryEntry>> getDiaryEntries() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('diary_entries', orderBy: 'dateTime DESC');
    return List.generate(maps.length, (i) => DiaryEntry.fromMap(maps[i]));
  }

  Future<int> deleteDiaryEntry(int id) async {
    Database db = await database;
    return await db.delete('diary_entries', where: 'id = ?', whereArgs: [id]);
  }

  // User Profile operations
  Future<int> saveUserProfile(UserProfile profile) async {
    Database db = await database;
    return await db.insert('user_profile', {'id': 0, ...profile.toMap()}, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<UserProfile?> getUserProfile() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('user_profile', where: 'id = 0');
    if (maps.isEmpty) return null;
    return UserProfile.fromMap(maps[0]);
  }

  // Water Log operations
  Future<int> insertWaterLog(WaterLog log) async {
    Database db = await database;
    return await db.insert('water_logs', log.toMap());
  }

  Future<List<WaterLog>> getWaterLogs() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('water_logs', orderBy: 'dateTime DESC');
    return List.generate(maps.length, (i) => WaterLog.fromMap(maps[i]));
  }

  // Food Items operations
  Future<List<FoodItem>> getFoodItems() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('food_items');
    return List.generate(maps.length, (i) => FoodItem.fromMap(maps[i]));
  }

  // Recipe operations
  Future<List<Map<String, dynamic>>> getRecipes() async {
    Database db = await database;
    return await db.query('recipes');
  }
}
