import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

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
      version: 6, // Actualizamos la versión a 4
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<Database> _initDB(String filePath) async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, filePath);
    return await openDatabase(
      path,
      version: 6, // <--- ASEGÚRATE QUE ESTA VERSIÓN SEA LA CORRECTA (EJ. 6)
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

    await db.execute('''
    CREATE TABLE IF NOT EXISTS training_sessions (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      session_title TEXT NOT NULL,
      session_dateTime TEXT NOT NULL 
    );
  ''');

    await db.execute('''
    CREATE TABLE IF NOT EXISTS exercise_logs (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      session_id INTEGER, 
      exercise_name TEXT NOT NULL,
      dateTime TEXT NOT NULL, 
      series TEXT,
      reps TEXT,
      weight TEXT,
      weightUnit TEXT,
      notes TEXT,
      FOREIGN KEY (session_id) REFERENCES training_sessions(id) ON DELETE CASCADE
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
    // ... (tus upgrades anteriores para version < 5)
    if (oldVersion < 6) { // Nueva versión para estos cambios
      print("Aplicando upgrade a V6: Creando tabla training_sessions y modificando exercise_logs...");
      await db.execute('''
      CREATE TABLE IF NOT EXISTS training_sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        session_title TEXT NOT NULL,
        session_dateTime TEXT NOT NULL
      );
    ''');
      try {
        // Verifica si la columna ya existe antes de intentar añadirla
        var tableInfo = await db.rawQuery('PRAGMA table_info(exercise_logs)');
        bool columnExists = tableInfo.any((column) => column['name'] == 'session_id');
        if (!columnExists) {
          await db.execute('ALTER TABLE exercise_logs ADD COLUMN session_id INTEGER REFERENCES training_sessions(id) ON DELETE CASCADE');
          print("Columna session_id añadida a exercise_logs.");
        } else {
          print("Columna session_id ya existe en exercise_logs.");
        }
      } catch (e) {
        print("Error en upgrade V6 (exercise_logs): $e");
      }
    }
  }

  Future<int> insertTrainingSession(String title, String dateTime) async {
    final db = await database;
    return await db.insert('training_sessions', {
      'session_title': title,
      'session_dateTime': dateTime,
    });
  }

  Future<void> _insertDefaultData(Database db) async {
    int piernaId = await db.insert('categories', {
    'name': 'Pierna',
    'muscle_group': 'Piernas', // Opcional: Define el grupo muscular para la categoría
    'description': 'Conjunto de ejercicios enfocados en el desarrollo de los músculos de las piernas.'
    })
    ;
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
  Future<void> insertExerciseLogWithSessionId(Map<String, dynamic> logData, int sessionId) async {
    final db = await database;
    Map<String, dynamic> logToInsert = Map.from(logData);
    logToInsert['session_id'] = sessionId;
    await db.insert('exercise_logs', logToInsert);
  }
  Future<void> deleteTrainingSessionAndLogs(int sessionId) async {
    final db = await database;
    int count = await db.delete('training_sessions', where: 'id = ?', whereArgs: [sessionId]);
    if (count > 0) {
      print("Sesión con ID $sessionId y sus logs asociados eliminados.");
    } else {
      print("No se encontró sesión con ID $sessionId para eliminar.");
    }
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
  Future<List<DateTime>> getDatesWithTrainingSessions() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery(
        "SELECT DISTINCT SUBSTR(session_dateTime, 1, 10) as training_date FROM training_sessions WHERE training_date IS NOT NULL ORDER BY training_date DESC"
    );
    return result.map((map) => DateTime.parse(map['training_date'] as String)).toList();
  }

  Future<List<Map<String, dynamic>>> getTrainingSessionsForDate(DateTime date) async {
    final db = await database;
    String dateString = DateFormat('yyyy-MM-dd').format(date); // Esto ahora es válido
    return await db.query(
      'training_sessions',
      where: "SUBSTR(session_dateTime, 1, 10) = ?",
      whereArgs: [dateString],
      orderBy: 'session_dateTime ASC',
    );
  }

  Future<List<Map<String, dynamic>>> getExerciseLogsForSession(int sessionId) async {
    final db = await database;
    return await db.query(
      'exercise_logs',
      where: "session_id = ?",
      whereArgs: [sessionId],
      orderBy: 'id ASC', // O el orden que prefieras para los ejercicios dentro de una sesión
    );
  }
  Future<void> deleteExerciseLog(int logId) async {
    final db = await database;
    int count = await db.delete(
      'exercise_logs',
      where: 'id = ?',
      whereArgs: [logId],
    );
    if (count > 0) {
      print("Log con ID $logId eliminado de exercise_logs.");
    } else {
      print("No se encontró log con ID $logId para eliminar.");
    }
  }

}

