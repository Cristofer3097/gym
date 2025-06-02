import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'database_exercise.dart';

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
      version: 8, // Actualizamos la versión a 4
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<Database> _initDB(String filePath) async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, filePath);
    return await openDatabase(
      path,
      version: 8, // <--- ASEGÚRATE QUE ESTA VERSIÓN SEA LA CORRECTA (EJ. 6)
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
        name TEXT NOT NULL UNIQUE 
      );
    ''');

    // Tabla categories
    await db.execute('''
      CREATE TABLE IF NOT EXISTS categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        original_id INTEGER,
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
        is_predefined INTEGER DEFAULT 0,
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
  Future<void> _insertDefaultData(Database db) async {
    Map<String, Map<String, dynamic>> exerciseDetailsCache = {};
    // Insertar ejercicios predefinidos desde database_exercise.dart
    for (final exerciseData in predefinedExerciseList) { // predefinedExerciseList vendrá de database_exercise.dart
      try {
        await db.insert(
          'categories',
          {
            'name': exerciseData['name'],
            'muscle_group': exerciseData['muscle_group'],
            'image': exerciseData['image'] ?? 'assets/exercises/placeholder.png',
            'description': exerciseData['description'] ?? 'Descripción no disponible.',
            'is_predefined': 1, // Marcar como predefinido
            'original_id': exerciseData['id'],
            // Asegúrate que otros campos NOT NULL tengan un valor por defecto o sean nullable
          },
          conflictAlgorithm: ConflictAlgorithm.ignore, // Ignorar si ya existe (por el UNIQUE name)
        );
        exerciseDetailsCache[exerciseData['name'] as String] = {
          'image': exerciseData['image'] ?? 'assets/exercises/placeholder.png',
          'description': exerciseData['description'] ??
              'Descripción no disponible.'
        };
        } catch (e) {
        print("Error insertando ejercicio predefinido ${exerciseData['name']}: $e");
      }
    }
    print("${predefinedExerciseList.length} ejercicios predefinidos procesados para inserción.");
    // Ya no insertamos la plantilla "Pierna" ni sus ejercicios en template_exercises aquí,
    // ya que los ejercicios predefinidos ahora están directamente en 'categories'.
    Map<int, String> sourceIdToNameMap = {};
    for (var ex in predefinedExerciseList) { //
      sourceIdToNameMap[ex['id'] as int] = ex['name'] as String; //
    }

    for (var templateData in predefinedTemplatesData) {
      try {
        String templateNameStr = templateData['templateName'] as String;
        List<int> exerciseSourceIds = templateData['exerciseSourceIds'] as List<int>;
        int templateId = await db.insert(
          'templates',
          {'name': templateNameStr},
          conflictAlgorithm: ConflictAlgorithm.ignore, // Ignorar si ya existe una plantilla con ese nombre
        );

        if (templateId > 0) { // Si la plantilla se insertó (o ya existía y se ignoró)
          print("Plantilla '$templateNameStr' insertada/encontrada con ID: $templateId");

          for (int sourceId in exerciseSourceIds) {
            String? exerciseName = sourceIdToNameMap[sourceId];
            if (exerciseName == null) {
              print("Advertencia: Ejercicio con source_id $sourceId no encontrado en sourceIdToNameMap.");
              continue;
            }

            // Buscar el ejercicio en la tabla 'categories' por su nombre para obtener su ID real
            final List<Map<String, dynamic>> exerciseEntry = await db.query(
              'categories',
              columns: ['id'], // Solo necesitamos el id de la tabla categories
              where: 'name = ?',
              whereArgs: [exerciseName],
              limit: 1,
            );

            if (exerciseEntry.isNotEmpty) {
              int categoryDbId = exerciseEntry.first['id'] as int;
              Map<String, dynamic> details = exerciseDetailsCache[exerciseName] ?? {};

              await db.insert(
                'template_exercises',
                {
                  'template_id': templateId,
                  'category_id': categoryDbId, // Este es el ID real de la tabla 'categories'
                  'name': exerciseName, // Guardamos el nombre para fácil acceso
                  'image': details['image'], // Guardamos la imagen
                  'description': details['description'], // Puedes poner una descripción general o específica para la plantilla
                },
                conflictAlgorithm: ConflictAlgorithm.replace,
              );
            } else {
              print("Advertencia: Ejercicio '$exerciseName' (source_id $sourceId) no encontrado en la tabla 'categories' al crear la plantilla '$templateNameStr'.");
            }
          }
        } else {
          print("Plantilla '$templateNameStr' ya existía y no se reinsertó debido a UNIQUE constraint.");
          // Si quieres actualizar una plantilla existente, necesitarías otra lógica (borrar y reinsertar o update)
        }
      } catch (e) {
        print("Error insertando plantilla predefinida '${templateData['templateName']}': $e");
      }
    }
    print("Plantillas predefinidas procesadas.");
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
    if (oldVersion < 8) { // Se ejecutará al pasar de versión 7 a 8
      try {
        await db.execute('ALTER TABLE categories ADD COLUMN original_id INTEGER');
        print("Columna original_id añadida a categories.");
        // Opcional: Poblar original_id para datos predefinidos existentes
        for (final exerciseDataInList in predefinedExerciseList) {
          await db.update(
            'categories',
            {'original_id': exerciseDataInList['id']},
            where: 'name = ? AND is_predefined = 1 AND original_id IS NULL',
            whereArgs: [exerciseDataInList['name']],
          );
        }
        print("original_id poblado para ejercicios predefinidos existentes si aplica.");
      } catch (e) {
        print("Error añadiendo/poblando columna original_id (puede que ya exista): $e");
      }
      // Logic to make templates.name UNIQUE
      try {
        await db.execute('DROP TABLE IF EXISTS templates_old_for_unique_constraint'); // Temporary name
        await db.execute('ALTER TABLE templates RENAME TO templates_old_for_unique_constraint');
        await db.execute('''
          CREATE TABLE templates (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL UNIQUE
          );
        ''');
        await db.execute(
            'INSERT OR IGNORE INTO templates (id, name) SELECT id, name FROM templates_old_for_unique_constraint'); //
        await db.execute('DROP TABLE templates_old_for_unique_constraint'); //
        print("Tabla templates actualizada con constraint UNIQUE en name.");
      } catch (e) {
        print(
            "Error actualizando tabla templates para constraint UNIQUE: $e"); //
        // Fallback: Recreate if critical error
        await db.execute('DROP TABLE IF EXISTS templates');
        await db.execute('''
            CREATE TABLE templates (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT NOT NULL UNIQUE
            );
          ''');
      }

      // Logic to make categories.name UNIQUE (if it wasn't already from _createDB)
      // This is more complex due to existing data and potential duplicates.
      // For new installs, _createDB handles it. For upgrades:
      try {
        // Similar to templates, ensure categories.name is UNIQUE
        await db.execute(
            'DROP TABLE IF EXISTS categories_old_for_unique_constraint');
        await db.execute(
            'ALTER TABLE categories RENAME TO categories_old_for_unique_constraint');
        // Recreate categories table using the definition from _createDB which includes UNIQUE name and is_predefined
        await db.execute('''
            CREATE TABLE categories (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT NOT NULL UNIQUE,
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
              is_predefined INTEGER DEFAULT 0,
              FOREIGN KEY (workout_id) REFERENCES workouts (id) ON DELETE CASCADE,
              FOREIGN KEY (category_id) REFERENCES categories (id)
            );
        ''');
        // Copy data, ignoring duplicates in 'name'
        await db.execute('''
            INSERT OR IGNORE INTO categories
            (id, name, date, muscle_group, workout_id, category_id, image, weight, weightUnit, reps, sets, notes, description, dateTime, is_predefined)
        SELECT id, name, date, muscle_group, workout_id, category_id, image, weight, weightUnit, reps, sets, notes, description, dateTime, COALESCE(is_predefined, 0)
        FROM categories_old_for_unique_constraint
        ''');
    await db.execute('DROP TABLE categories_old_for_unique_constraint');
    print("Tabla categories actualizada con constraint UNIQUE en name.");
      } catch (e) {
        print("Error actualizando tabla categories para constraint UNIQUE: $e");
        // Fallback: Recreate categories if critical error, using the full schema
        await db.execute('DROP TABLE IF EXISTS categories');
        await db.execute('''
            CREATE TABLE categories (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT NOT NULL UNIQUE,
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
              is_predefined INTEGER DEFAULT 0,
              original_id INTEGER,
              FOREIGN KEY (workout_id) REFERENCES workouts (id) ON DELETE CASCADE,
              FOREIGN KEY (category_id) REFERENCES categories (id)
            );
        ''');
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

  Future<void> deleteTemplate(int templateId) async {
    final db = await database;
    await db.delete('templates', where: 'id = ?', whereArgs: [templateId]);
  }

  Future<List<Map<String, dynamic>>> getCategories() async {
    final db = await database;
    // Devuelve todos los campos, incluyendo is_predefined
    return await db.query('categories', orderBy: 'name ASC');
  }



  Future<List<Map<String, dynamic>>> getWorkouts() async {
    final db = await database;
    return await db.query('workouts');
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
  Future<void> updateExerciseNameInTemplateExercises(String oldName, String newName) async {
    final db = await database;
    int count = await db.update(
      'template_exercises', // Nombre de la tabla
      {'name': newName},    // Columna a actualizar y nuevo valor
      where: 'name = ?',    // Condición para encontrar los registros
      whereArgs: [oldName], // Argumento para la condición
    );
    print('Nombres de ejercicio actualizados en template_exercises: $count registros de "$oldName" a "$newName"');
  }
// Agrega este método para obtener todas las plantillas
  Future<List<Map<String, dynamic>>> getAllTemplates() async {
    final db = await database;
    return await db.query('templates', orderBy: 'id DESC');
  }

// Agrega este método para obtener los ejercicios de una plantilla
  Future<List<Map<String, dynamic>>> getTemplateExercises(int templateId) async {
    final db = await database;
    final String sql = '''
    SELECT
      te.id,
      te.template_id,
      te.name,
      te.image,
      te.description,
      te.category_id,
      c.muscle_group,  -- Obtener el nombre del grupo muscular de la tabla categories
      c.original_id,    
      c.is_predefined 
    FROM template_exercises te
    LEFT JOIN categories c ON te.category_id = c.id
    WHERE te.template_id = ?
      ''';
    final List<Map<String, dynamic>> result = await db.rawQuery(sql, [templateId]);
    return result;
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

