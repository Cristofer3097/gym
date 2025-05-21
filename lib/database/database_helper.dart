import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('gym_diary.db');
    return _database!;
  }

  Future<Database> getDb() async {
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'gym_diary.db');

    return await openDatabase(
      path,
      version: 4, // Actualizamos la versión a 4
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<Database> _initDB(String filePath) async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, filePath);
    return await openDatabase(
      path,
      version: 4,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Tabla workouts (debes tenerla definida para las llaves foráneas)
    await db.execute('''
      CREATE TABLE IF NOT EXISTS workouts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL
      );
    ''');

    // Tabla templates
    await db.execute('''
      CREATE TABLE IF NOT EXISTS templates (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL
      );
    ''');

    // Tabla categories
    await db.execute('''
      CREATE TABLE IF NOT EXISTS categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        date TEXT,
        muscle_group TEXT,
        workout_id INTEGER,
        category_id INTEGER,
        image TEXT,
        weight REAL,
        weightUnit TEXT,
        reps INTEGER,
        sets INTEGER,
        notes TEXT,
        description TEXT,
        dateTime TEXT,
        FOREIGN KEY (workout_id) REFERENCES workouts (id) ON DELETE CASCADE,
        FOREIGN KEY (category_id) REFERENCES categories (id)
      );
    ''');

    // Tabla template_exercises
    await db.execute('''
      CREATE TABLE IF NOT EXISTS template_exercises (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    template_id INTEGER NOT NULL,
    category_id INTEGER,
    name TEXT NOT NULL,
    image TEXT,
    FOREIGN KEY (template_id) REFERENCES templates(id) ON DELETE CASCADE
  );
''');

    // Tabla exercise_logs
    await db.execute('''
      CREATE TABLE IF NOT EXISTS exercise_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        exercise_name TEXT NOT NULL,
        dateTime TEXT NOT NULL,
        series TEXT,
        reps TEXT,
        weight TEXT,
        weightUnit TEXT,
        notes TEXT
      );
    ''');
    // Insertar datos de ejemplo
    await _insertDefaultData(db);
  }
  Future<void> insertExerciseLog(Map<String, dynamic> log) async {
    final db = await database;
    await db.insert('exercise_logs', log);
  }
  Future<List<Map<String, dynamic>>> getExerciseLogs(String exerciseName) async {
    final db = await database;
    return await db.query(
      'exercise_logs',
      where: 'exercise_name = ?',
      whereArgs: [exerciseName],
      orderBy: 'dateTime DESC',
    );
  }
  Future<Map<String, dynamic>?> getLastExerciseLog(String exerciseName) async {
    final db = await database;
    final res = await db.query(
      'exercise_logs',
      where: 'exercise_name = ?',
      whereArgs: [exerciseName],
      orderBy: 'dateTime DESC',
      limit: 1,
    );
    if (res.isNotEmpty) return res.first;
    return null;
  }
  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 4) {
      // Para la versión 4 agregamos nuevos campos a la tabla exercises
      await db.execute(
          'ALTER TABLE exercises ADD COLUMN weightUnit TEXT DEFAULT "kg"');
      await db.execute('ALTER TABLE exercises ADD COLUMN description TEXT');
      await db.execute('ALTER TABLE exercises ADD COLUMN dateTime TEXT');
    }
  }

  Future<void> _insertDefaultData(Database db) async {
    int piernaId = await db.insert('categories', {'name': 'Pierna'});
    int templateId = await db.insert('templates', {'name': 'Pierna'});
    await db.insert('template_exercises', {
      'template_id': templateId,
      'category_id': piernaId,
      'name': 'Sentadilla',
      'image': 'assets/sentadilla.png'
    });
    await db.insert('template_exercises', {
      'template_id': templateId,
      'category_id': piernaId,
      'name': 'Extensiones',
      'image': 'assets/extensiones.png'
    });
    await db.insert('template_exercises', {
      'template_id': templateId,
      'category_id': piernaId,
      'name': 'Prens',
      'image': 'assets/prens.png'
    });
  }

  // Métodos de inserción y consulta
  Future<int> insertCategory(Map<String, dynamic> category) async {
    final db = await database;
    return await db.insert('categories', category);
  }

  Future<int> insertWorkout(Map<String, dynamic> workout) async {
    final db = await database;
    return await db.insert('workouts', workout);
  }

  Future<int> insertExercise(Map<String, dynamic> exercise) async {
    final db = await database;
    return await db.insert('exercises', exercise);
  }
  Future<void> deleteTemplate(int templateId) async {
    final db = await database;
    await db.delete('templates', where: 'id = ?', whereArgs: [templateId]);
  }

  Future<List<Map<String, dynamic>>> getCategories() async {
    final db = await database;
    return await db.query('categories');
  }

  Future<List<Map<String, dynamic>>> getWorkouts() async {
    final db = await database;
    return await db.query('workouts');
  }

  Future<List<Map<String, dynamic>>> getExercises(int workoutId) async {
    final db = await database;
    return await db.query(
        'exercises', where: 'workout_id = ?', whereArgs: [workoutId]);
  }

  Future<List<Map<String, dynamic>>> getTemplates() async {
    final db = await database;
    return await db.query('templates');
  }


  Future<int> insertTemplate(String name) async {
    final db = await database;
    return await db.insert(
      'templates',
      {'name': name},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

// Agrega este método para guardar los ejercicios de la plantilla
  Future<void> insertTemplateExercises(int templateId, List<Map<String, dynamic>> exercises) async {
    final db = await database;
    for (final exercise in exercises) {
      await db.insert(
        'template_exercises',
        {
          'template_id': templateId,
          'exercise_name': exercise['name'],
          // Agrega aquí más campos si los tienes, por ejemplo:
          // 'series': exercise['series'],
          // 'reps': exercise['reps'],
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

// Agrega este método para obtener todas las plantillas
  Future<List<Map<String, dynamic>>> getAllTemplates() async {
    final db = await database;
    return await db.query('templates', orderBy: 'id DESC');
  }

// Agrega este método para obtener los ejercicios de una plantilla
  Future<List<Map<String, dynamic>>> getTemplateExercises(int templateId) async {
    final db = await database;
    return await db.query(
      'template_exercises',
      where: 'template_id = ?',
      whereArgs: [templateId],
    );
  }
}

