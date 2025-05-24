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
      version: 5, // Actualizamos la versión a 4
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<Database> _initDB(String filePath) async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, filePath);
    return await openDatabase(
      path,
      version: 5,
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
    description TEXT, 
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
  Future<void> deleteCategory(int id) async {
    final db = await database;
    await db.delete('categories', where: 'id = ?', whereArgs: [id]);
    // Opcional: borra también logs relacionados si lo deseas
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
      // Tu lógica existente para la versión 4.
      // ¡CUIDADO! Esta lógica altera una tabla llamada 'exercises'.
      // En tu _createDB, no tienes una tabla llamada 'exercises'.
      // Tienes 'categories', 'template_exercises', 'exercise_logs'.
      // Debes revisar si 'exercises' aquí es un error y debería ser, por ejemplo, 'categories'.
      // Si la tabla 'exercises' realmente no existe, estas líneas causarán un error.
      try {
        print("Aplicando upgrade a V4: Modificando tabla 'exercises' (o la tabla que corresponda)...");
        await db.execute('ALTER TABLE exercises ADD COLUMN weightUnit TEXT DEFAULT "kg"');
        await db.execute('ALTER TABLE exercises ADD COLUMN description TEXT');
        await db.execute('ALTER TABLE exercises ADD COLUMN dateTime TEXT');
      } catch (e) {
        print("Error durante la actualización a V4 (revisar nombre de tabla 'exercises'): $e");
      }
    }
    if (oldVersion < 5) {
      // Lógica para la versión 5: Añadir columna 'description' a 'template_exercises'
      try {
        print("Aplicando upgrade a V5: Añadiendo columna 'description' a 'template_exercises'...");
        await db.execute('ALTER TABLE template_exercises ADD COLUMN description TEXT');
      } catch (e) {
        print("Error añadiendo columna 'description' a 'template_exercises' en V5: $e");
        // Podrías querer manejar esto de forma más robusta si la columna ya existe por alguna razón
      }
    }
    // ... más upgrades si tienes oldVersion < 6, etc.
  }

  Future<void> _insertDefaultData(Database db) async {
    int piernaId = await db.insert('categories', {'name': 'Pierna'});
    int templateId = await db.insert('templates', {'name': 'Pierna'});
    await db.insert('template_exercises', {
      'template_id': templateId,
      'category_id': piernaId, // Asumiendo que esto es relevante
      'name': 'Sentadilla',
      'image': 'assets/sentadilla.png',
      'description': 'Descripción detallada de la sentadilla...' // Añadir descripción
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
  Future<int> updateCategory(int id, Map<String, dynamic> category) async {
    final db = await database;
    return await db.update('categories', category, where: 'id = ?', whereArgs: [id]);
  }

  Future<Map<String, dynamic>?> getCategoryById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  Future<void> updateExerciseLogsName(String oldName, String newName) async {
    final db = await database;
    await db.update(
      'exercise_logs',
      {'exercise_name': newName},
      where: 'exercise_name = ?',
      whereArgs: [oldName],
    );
    print('Nombres de ejercicio actualizados en logs: de "$oldName" a "$newName"');
  }
  // Métodos de inserción y consulta
  Future<int> insertCategory(Map<String, dynamic> categoryData) async {
    final db = await database;
    // Prepara el mapa asegurando que todos los campos de la tabla 'categories'
    // que no vienen de categoryData se establezcan explícitamente a null o un valor por defecto.
    Map<String, dynamic> completeCategoryData = {
      'name': categoryData['name'],
      'muscle_group': categoryData['muscle_group'],
      'image': categoryData['image'],
      'description': categoryData['description'],
      // Campos que podrían no venir del formulario de definición pero existen en la tabla:
      'date': categoryData['date'], // o null si no se maneja
      'workout_id': categoryData['workout_id'], // o null
      'category_id': categoryData['category_id'], // o null
      'weight': categoryData['weight'], // o null
      'weightUnit': categoryData['weightUnit'], // o null
      'reps': categoryData['reps'], // o null
      'sets': categoryData['sets'], // o null
      'notes': categoryData['notes'], // o null
      'dateTime': categoryData['dateTime'], // o null
    };
    return await db.insert('categories', completeCategoryData);
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
          'name': exercise['name'],
          'image': exercise['image'],
          'category_id': exercise['category_id'],
          'description': exercise['description'], // <--- AÑADE ESTA LÍNEA para guardar la descripción
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

