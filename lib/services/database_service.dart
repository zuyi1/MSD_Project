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
      version: 1,
      onCreate: _onCreate,
    );
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
        calories REAL
      )
    ''');

    // Pre-populate food items
    List<FoodItem> initialFood = [
      FoodItem(name: 'Apple', calories: 95),
      FoodItem(name: 'Banana', calories: 105),
      FoodItem(name: 'Chicken Breast (100g)', calories: 165),
      FoodItem(name: 'Rice (1 cup)', calories: 205),
      FoodItem(name: 'Egg', calories: 78),
      FoodItem(name: 'Broccoli (1 cup)', calories: 31),
      FoodItem(name: 'Salmon (100g)', calories: 208),
      FoodItem(name: 'Almonds (28g)', calories: 164),
      FoodItem(name: 'Greek Yogurt (170g)', calories: 100),
      FoodItem(name: 'Oatmeal (1 cup)', calories: 158),
    ];

    for (var food in initialFood) {
      await db.insert('food_items', food.toMap());
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
}
