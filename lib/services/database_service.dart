import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user_profile.dart';
import '../models/food_item.dart';
import '../models/meal_entry.dart';
import '../models/workout_models.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('fitness_nutrition.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Table User Profile
    await db.execute('''
      CREATE TABLE user_profile (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        age INTEGER NOT NULL,
        current_weight REAL NOT NULL,
        target_weight REAL NOT NULL,
        height REAL NOT NULL,
        gender TEXT NOT NULL,
        activity_level TEXT NOT NULL,
        goal TEXT NOT NULL,
        daily_calories_target INTEGER NOT NULL,
        protein_target INTEGER NOT NULL,
        carbs_target INTEGER NOT NULL,
        fat_target INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Table Food Items
    await db.execute('''
      CREATE TABLE food_items (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        brand TEXT,
        barcode TEXT,
        serving_size REAL NOT NULL,
        serving_unit TEXT NOT NULL,
        calories_per_100g REAL NOT NULL,
        protein_per_100g REAL NOT NULL,
        carbs_per_100g REAL NOT NULL,
        fat_per_100g REAL NOT NULL,
        fiber_per_100g REAL DEFAULT 0,
        sugar_per_100g REAL DEFAULT 0,
        sodium_per_100g REAL,
        calcium_per_100g REAL,
        iron_per_100g REAL,
        is_favorite INTEGER DEFAULT 0,
        last_used TEXT,
        usage_count INTEGER DEFAULT 0,
        category TEXT NOT NULL
      )
    ''');

    // Table Meal Entries
    await db.execute('''
      CREATE TABLE meal_entries (
        id TEXT PRIMARY KEY,
        food_id TEXT NOT NULL,
        quantity REAL NOT NULL,
        consumed_at TEXT NOT NULL,
        meal_type TEXT NOT NULL,
        FOREIGN KEY (food_id) REFERENCES food_items (id)
      )
    ''');

    // Table Weight History
    await db.execute('''
      CREATE TABLE weight_history (
        id TEXT PRIMARY KEY,
        weight REAL NOT NULL,
        recorded_at TEXT NOT NULL
      )
    ''');

    // Table Exercises
    await db.execute('''
      CREATE TABLE exercises (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        muscle_groups TEXT NOT NULL,
        equipment TEXT NOT NULL,
        difficulty TEXT NOT NULL,
        description TEXT,
        video_url TEXT,
        thumbnail_url TEXT,
        is_favorite INTEGER DEFAULT 0,
        is_time_based INTEGER DEFAULT 0
      )
    ''');

    // Table Workouts
    await db.execute('''
      CREATE TABLE workouts (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        started_at TEXT,
        completed_at TEXT,
        duration_minutes INTEGER DEFAULT 0,
        notes TEXT
      )
    ''');

    // Table Workout Exercises (liaison)
    await db.execute('''
      CREATE TABLE workout_exercises (
        id TEXT PRIMARY KEY,
        workout_id TEXT NOT NULL,
        exercise_id TEXT NOT NULL,
        exercise_order INTEGER NOT NULL,
        notes TEXT,
        FOREIGN KEY (workout_id) REFERENCES workouts (id),
        FOREIGN KEY (exercise_id) REFERENCES exercises (id)
      )
    ''');

    // Table Workout Sets
    await db.execute('''
      CREATE TABLE workout_sets (
        id TEXT PRIMARY KEY,
        workout_exercise_id TEXT NOT NULL,
        weight REAL NOT NULL,
        reps INTEGER NOT NULL,
        rest_seconds INTEGER,
        completed INTEGER DEFAULT 0,
        notes TEXT,
        is_rest_time_modified INTEGER DEFAULT 0,
        FOREIGN KEY (workout_exercise_id) REFERENCES workout_exercises (id)
      )
    ''');

    // Table Workout History
    await db.execute('''
      CREATE TABLE workout_history (
        id TEXT PRIMARY KEY,
        exercise_id TEXT NOT NULL,
        exercise_name TEXT NOT NULL,
        performed_at TEXT NOT NULL,
        total_volume REAL NOT NULL,
        FOREIGN KEY (exercise_id) REFERENCES exercises (id)
      )
    ''');

    // Table Workout History Sets
    await db.execute('''
      CREATE TABLE workout_history_sets (
        id TEXT PRIMARY KEY,
        history_id TEXT NOT NULL,
        weight REAL NOT NULL,
        reps INTEGER NOT NULL,
        FOREIGN KEY (history_id) REFERENCES workout_history (id)
      )
    ''');

    // Table Workout Programs
    await db.execute('''
      CREATE TABLE workout_programs (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        frequency TEXT NOT NULL,
        created_at TEXT NOT NULL,
        is_active INTEGER DEFAULT 0
      )
    ''');

    // Créer des index pour améliorer les performances
    await db.execute('CREATE INDEX idx_meal_entries_consumed_at ON meal_entries(consumed_at)');
    await db.execute('CREATE INDEX idx_workout_history_performed_at ON workout_history(performed_at)');
    await db.execute('CREATE INDEX idx_food_items_favorite ON food_items(is_favorite)');
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Ajouter le champ is_rest_time_modified à la table workout_sets
      await db.execute('ALTER TABLE workout_sets ADD COLUMN is_rest_time_modified INTEGER DEFAULT 0');

      // Ajouter les colonnes manquantes à la table exercises
      try {
        await db.execute('ALTER TABLE exercises ADD COLUMN thumbnail_url TEXT');
      } catch (e) {
        print('Column thumbnail_url already exists or error: $e');
      }

      try {
        await db.execute('ALTER TABLE exercises ADD COLUMN is_time_based INTEGER DEFAULT 0');
      } catch (e) {
        print('Column is_time_based already exists or error: $e');
      }
    }
  }

  // ==================== USER PROFILE ====================
  
  Future<void> insertUserProfile(UserProfile profile) async {
    final db = await database;
    await db.insert('user_profile', profile.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<UserProfile?> getUserProfile() async {
    final db = await database;
    final maps = await db.query('user_profile', limit: 1);
    if (maps.isEmpty) return null;
    return UserProfile.fromMap(maps.first);
  }

  Future<void> updateUserProfile(UserProfile profile) async {
    final db = await database;
    await db.update('user_profile', profile.toMap(),
        where: 'id = ?', whereArgs: [profile.id]);
  }

  // ==================== FOOD ITEMS ====================
  
  Future<void> insertFoodItem(FoodItem food) async {
    final db = await database;
    await db.insert('food_items', food.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<FoodItem>> getAllFoodItems() async {
    final db = await database;
    final maps = await db.query('food_items', orderBy: 'name ASC');
    return maps.map((map) => FoodItem.fromMap(map)).toList();
  }

  Future<List<FoodItem>> getFavoriteFoods() async {
    final db = await database;
    final maps = await db.query('food_items',
        where: 'is_favorite = ?', whereArgs: [1], orderBy: 'name ASC');
    return maps.map((map) => FoodItem.fromMap(map)).toList();
  }

  Future<List<FoodItem>> getRecentFoods({int limit = 10}) async {
    final db = await database;
    final maps = await db.query('food_items',
        where: 'last_used IS NOT NULL',
        orderBy: 'last_used DESC',
        limit: limit);
    return maps.map((map) => FoodItem.fromMap(map)).toList();
  }

  Future<List<FoodItem>> searchFoodItems(String query) async {
    final db = await database;
    final maps = await db.query('food_items',
        where: 'name LIKE ? OR brand LIKE ?',
        whereArgs: ['%$query%', '%$query%'],
        orderBy: 'name ASC');
    return maps.map((map) => FoodItem.fromMap(map)).toList();
  }

  Future<void> updateFoodItem(FoodItem food) async {
    final db = await database;
    await db.update('food_items', food.toMap(),
        where: 'id = ?', whereArgs: [food.id]);
  }

  // ==================== MEAL ENTRIES ====================
  
  Future<void> insertMealEntry(MealEntry entry) async {
    final db = await database;
    await db.insert('meal_entries', entry.toMap());
  }

  Future<List<MealEntry>> getMealEntriesForDate(DateTime date) async {
    final db = await database;
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final maps = await db.query('meal_entries',
        where: 'consumed_at >= ? AND consumed_at < ?',
        whereArgs: [startOfDay.toIso8601String(), endOfDay.toIso8601String()],
        orderBy: 'consumed_at ASC');

    final List<MealEntry> entries = [];
    for (var map in maps) {
      final foodMaps = await db.query('food_items',
          where: 'id = ?', whereArgs: [map['food_id']]);
      if (foodMaps.isNotEmpty) {
        final food = FoodItem.fromMap(foodMaps.first);
        entries.add(MealEntry(
          id: map['id'] as String,
          foodItem: food,
          quantity: map['quantity'] as double,
          consumedAt: DateTime.parse(map['consumed_at'] as String),
          mealType: map['meal_type'] as String,
        ));
      }
    }
    return entries;
  }

  Future<List<MealEntry>> getMealEntriesByDateRange(DateTime startDate, DateTime endDate) async {
    final db = await database;

    final maps = await db.query('meal_entries',
        where: 'consumed_at >= ? AND consumed_at < ?',
        whereArgs: [startDate.toIso8601String(), endDate.toIso8601String()],
        orderBy: 'consumed_at ASC');

    final List<MealEntry> entries = [];
    for (var map in maps) {
      final foodMaps = await db.query('food_items',
          where: 'id = ?', whereArgs: [map['food_id']]);
      if (foodMaps.isNotEmpty) {
        final food = FoodItem.fromMap(foodMaps.first);
        entries.add(MealEntry(
          id: map['id'] as String,
          foodItem: food,
          quantity: map['quantity'] as double,
          consumedAt: DateTime.parse(map['consumed_at'] as String),
          mealType: map['meal_type'] as String,
        ));
      }
    }
    return entries;
  }

  Future<void> updateMealEntry(MealEntry entry) async {
    final db = await database;
    await db.update(
      'meal_entries',
      entry.toMap(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  Future<void> deleteMealEntry(String id) async {
    final db = await database;
    await db.delete('meal_entries', where: 'id = ?', whereArgs: [id]);
  }

  // ==================== WEIGHT HISTORY ====================
  
  Future<void> insertWeightEntry(String id, double weight, DateTime date) async {
    final db = await database;
    await db.insert('weight_history', {
      'id': id,
      'weight': weight,
      'recorded_at': date.toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getWeightHistory({int? limit}) async {
    final db = await database;
    final maps = await db.query('weight_history',
        orderBy: 'recorded_at DESC', limit: limit);
    return maps;
  }

  // ==================== EXERCISES ====================
  
  Future<void> insertExercise(Exercise exercise) async {
    final db = await database;
    await db.insert('exercises', exercise.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Exercise>> getAllExercises() async {
    final db = await database;
    final maps = await db.query('exercises', orderBy: 'name ASC');
    return maps.map((map) => Exercise.fromMap(map)).toList();
  }

  Future<List<Exercise>> getExercisesByCategory(String category) async {
    final db = await database;
    final maps = await db.query('exercises',
        where: 'category = ?', whereArgs: [category], orderBy: 'name ASC');
    return maps.map((map) => Exercise.fromMap(map)).toList();
  }

  Future<void> updateExercise(Exercise exercise) async {
    final db = await database;
    await db.update('exercises', exercise.toMap(),
        where: 'id = ?', whereArgs: [exercise.id]);
  }

  // ==================== WORKOUT HISTORY ====================
  
  Future<List<WorkoutHistory>> getExerciseHistory(String exerciseId, {int limit = 5}) async {
    final db = await database;
    final maps = await db.query('workout_history',
        where: 'exercise_id = ?',
        whereArgs: [exerciseId],
        orderBy: 'performed_at DESC',
        limit: limit);
    
    final List<WorkoutHistory> history = [];
    for (var map in maps) {
      final setMaps = await db.query('workout_history_sets',
          where: 'history_id = ?', whereArgs: [map['id']]);
      final sets = setMaps.map((setMap) => WorkoutSet(
        id: setMap['id'] as String,
        weight: setMap['weight'] as double,
        reps: setMap['reps'] as int,
        completed: true,
      )).toList();
      
      history.add(WorkoutHistory(
        id: map['id'] as String,
        exerciseId: map['exercise_id'] as String,
        exerciseName: map['exercise_name'] as String,
        sets: sets,
        performedAt: DateTime.parse(map['performed_at'] as String),
        totalVolume: map['total_volume'] as double,
      ));
    }
    return history;
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
