import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('gym_diary.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    // Obtener el directorio de documentos del dispositivo
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, filePath);

    return await openDatabase(
        path,
        version: 3,
        onCreate: _createDB,
        onUpgrade: _upgradeDB
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Tabla para categorías
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL
      );
    ''');

    // Tabla para entrenamientos (workouts)
    await db.execute('''
      CREATE TABLE workouts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        muscle_group TEXT NOT NULL
      );
    ''');

    // Tabla para ejercicios registrados en un entrenamiento
    await db.execute('''
      CREATE TABLE exercises (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        workout_id INTEGER,
        category_id INTEGER,
        name TEXT NOT NULL,
        image TEXT,
        weight REAL NOT NULL,
        reps INTEGER NOT NULL,
        sets INTEGER NOT NULL,
        notes TEXT,
        FOREIGN KEY (workout_id) REFERENCES workouts (id) ON DELETE CASCADE,
        FOREIGN KEY (category_id) REFERENCES categories (id)
      );
    ''');

    // Tabla para plantillas
    await db.execute('''
      CREATE TABLE templates (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL
      );
    ''');

    // Tabla para ejercicios de plantillas
    await db.execute('''
      CREATE TABLE template_exercises (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        template_id INTEGER NOT NULL,
        category_id INTEGER,
        name TEXT NOT NULL,
        image TEXT,
        FOREIGN KEY (template_id) REFERENCES templates (id) ON DELETE CASCADE,
        FOREIGN KEY (category_id) REFERENCES categories (id)
      );
    ''');

    // Insertar datos de ejemplo
    await _insertDefaultData(db);
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      // Si se requiere actualizar tablas en versiones previas
      await db.execute('''
        CREATE TABLE categories (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL
        );
      ''');

      await db.execute('''
        ALTER TABLE exercises ADD COLUMN category_id INTEGER REFERENCES categories(id);
      ''');

      await db.execute('''
        ALTER TABLE template_exercises ADD COLUMN category_id INTEGER REFERENCES categories(id);
      ''');
    }
  }

  Future<void> _insertDefaultData(Database db) async {
    // Insertar una categoría de ejemplo: Pierna
    int piernaId = await db.insert('categories', {'name': 'Pierna'});

    // Insertar ejercicios para la categoría "Pierna" en la tabla de plantillas
    // Ejemplo: plantilla "Pierna" con ejercicios predeterminados
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
      'name': 'Prensa',
      'image': 'assets/prensa.png'
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

  Future<int> insertTemplate(Map<String, dynamic> template) async {
    final db = await database;
    return await db.insert('templates', template);
  }

  Future<int> insertTemplateExercise(Map<String, dynamic> templateExercise) async {
    final db = await database;
    return await db.insert('template_exercises', templateExercise);
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
    return await db.query('exercises', where: 'workout_id = ?', whereArgs: [workoutId]);
  }

  Future<List<Map<String, dynamic>>> getTemplates() async {
    final db = await database;
    return await db.query('templates');
  }

  Future<List<Map<String, dynamic>>> getTemplateExercises(int templateId) async {
    final db = await database;
    return await db.query('template_exercises', where: 'template_id = ?', whereArgs: [templateId]);
  }
}
