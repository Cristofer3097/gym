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


  Future<Database> _initDB(String filePath) async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, filePath);
    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> closeDB() async {
    if (_database != null && _database!.isOpen) {
      await _database!.close();
      _database = null; // Marcar como nulo para que se reinicialice en el próximo acceso
      print("Database connection closed.");
    }
  }

  Future<void> _createDB(Database db, int version) async {

    // Tabla templates
    await db.execute('''
      CREATE TABLE IF NOT EXISTS templates (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        template_key TEXT
      );
    ''');

    // Tabla categories
    await db.execute('''
      CREATE TABLE IF NOT EXISTS categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        original_id INTEGER,
        muscle_group TEXT,
        image TEXT,
        description TEXT,
        is_predefined INTEGER DEFAULT 0
      );
    ''');

    // Tabla template_exercises
    await db.execute('''
  CREATE TABLE IF NOT EXISTS template_exercises (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  template_id INTEGER NOT NULL,
  category_id INTEGER NOT NULL,
  FOREIGN KEY (template_id) REFERENCES templates(id) ON DELETE CASCADE,
  FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE
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
    CREATE TABLE IF NOT EXISTS exercise_name_history (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  old_name TEXT NOT NULL,
  new_name TEXT NOT NULL,
  changed_at TEXT DEFAULT CURRENT_TIMESTAMP
);
  ''');

    await db.execute('''
    CREATE TABLE IF NOT EXISTS exercise_logs (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      session_id INTEGER, 
      exercise_name TEXT NOT NULL,
      exercise_id INTEGER,
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
  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    print("Ejecutando _upgradeDB de v$oldVersion a v$newVersion.");

    // Migración para cambios en nombres de ejercicios (sin incrementar versión)
    if (oldVersion <= 1) {
      await _migrateExerciseNames(db);
    }

    // Migración para nuevos campos (requiere incrementar versión solo si es crítico)
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE categories ADD COLUMN is_favorite INTEGER DEFAULT 0');
      print("Nueva columna 'is_favorite' añadida.");
    }
  }

  Future<void> _migrateExerciseNames(Database db) async {
    // Ejemplo: Actualizar nombres de ejercicios sin cambiar la versión de la DB
    await db.update(
      'categories',
      {'name': 'Nuevo nombre'},
      where: 'name = ?',
      whereArgs: ['Nombre antiguo'],
    );
    print("Nombres de ejercicios actualizados sin incrementar versión.");
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
        String templateKeyStr = templateData['templateKey'] as String;
        String templateNameStr = templateData['templateName'] as String;
        List<int> exerciseSourceIds = templateData['exerciseSourceIds'] as List<int>;
        int templateId = await db.insert(
          'templates',
          {'name': templateNameStr,
          'template_key': templateKeyStr
          },
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


  Future<void> deleteTemplate(int templateId) async {
    final db = await database;
    await db.delete('templates', where: 'id = ?', whereArgs: [templateId]);
  }

  Future<List<Map<String, dynamic>>> getCategories() async {
    final db = await database;
    // Devuelve todos los campos, incluyendo is_predefined
    return await db.query('categories', orderBy: 'name ASC');
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
  Future<void> insertTemplateExercises(int templateId, List<int> categoryIds) async {
    final db = await database;
    for (final categoryId in categoryIds) {
      await db.insert(
        'template_exercises',
        {
          'template_id': templateId,
          'category_id': categoryId,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }
  Future<void> updateExerciseName(String oldName, String newName) async {
    final db = await database;
    await db.transaction((txn) async {
      // 1. Registrar el cambio en el historial
      await txn.insert('exercise_name_history', {
        'old_name': oldName,
        'new_name': newName,
      });

      // 2. Actualizar el nombre en todas las tablas afectadas
      await txn.update(
        'categories',
        {'name': newName},
        where: 'name = ?',
        whereArgs: [oldName],
      );

      await txn.update(
        'exercise_logs',
        {'exercise_name': newName},
        where: 'exercise_name = ?',
        whereArgs: [oldName],
      );

      await txn.update(
        'template_exercises',
        {'name': newName},
        where: 'name = ?',
        whereArgs: [oldName],
      );
    });
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
    return await db.query('templates', columns: ['id', 'name', 'template_key'], orderBy: 'id DESC'); // Añadir template_key
  }

// Agrega este método para obtener los ejercicios de una plantilla
  Future<List<Map<String, dynamic>>> getTemplateExercises(int templateId) async {
    final db = await database;
    final String sql = '''
    SELECT
      te.id,
      te.template_id,
      te.category_id,
      c.name,
      c.image,
      c.description,
      c.muscle_group,
      c.is_predefined,
      c.original_id        -- <--- AGREGA ESTA LÍNEA
    FROM template_exercises te
    JOIN categories c ON te.category_id = c.id
    WHERE te.template_id = ?
    ORDER BY te.id ASC
  ''';
    return await db.rawQuery(sql, [templateId]);
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
  Future<Map<String, dynamic>?> getExerciseDefinitionByName(String name) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'categories', // Este es el nombre de tu tabla de definición de ejercicios
      where: 'name = ?',
      whereArgs: [name],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  // Nueva función para actualizar el título y fecha de una sesión
  Future<void> updateTrainingSession(int sessionId, String newTitle, String newDateTime) async {
    final db = await database;
    await db.update(
      'training_sessions',
      {'session_title': newTitle, 'session_dateTime': newDateTime},
      where: 'id = ?',
      whereArgs: [sessionId],
    );
  }

  // Nueva función para borrar todos los logs de una sesión (para luego reinsertarlos)
  Future<void> clearExerciseLogsForSession(int sessionId) async {
    final db = await database;
    await db.delete(
      'exercise_logs',
      where: 'session_id = ?',
      whereArgs: [sessionId],
    );
  }

  Future<List<String>> getAllUserImagePaths() async {
    final db = await database;
    // Selecciona la columna 'image' de los ejercicios que NO son predefinidos
    // y cuyo path de imagen no es nulo ni está vacío.
    final List<Map<String, dynamic>> result = await db.query(
      'categories',
      columns: ['image'],
      where: 'is_predefined = ? AND image IS NOT NULL AND image != ?',
      whereArgs: [0, ''],
    );
    // Convierte el resultado en una lista de strings (rutas)
    return result.map((row) => row['image'] as String).toList();
  }
  Future<List<Map<String, dynamic>>> getFullExerciseLogsForSession(int sessionId) async {
    final db = await database;
    // Este query une los logs con las definiciones de los ejercicios para obtener todo en una sola consulta.
    final String sql = '''
    SELECT
      l.*,
      c.id as exercise_definition_id,
      c.muscle_group,
      c.image,
      c.description,
      c.is_predefined
    FROM exercise_logs l
    LEFT JOIN categories c ON l.exercise_name = c.name
    WHERE l.session_id = ?
  ''';
    return await db.rawQuery(sql, [sessionId]);
  }


}

