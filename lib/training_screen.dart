import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../database/database_helper.dart'; // Asegúrate que la ruta sea correcta
import 'package:device_info_plus/device_info_plus.dart';

// Clase principal de la pantalla de Entrenamiento
class TrainingScreen extends StatefulWidget {
  final List<Map<String, dynamic>>? initialExercises;
  final String? templateName;

  const TrainingScreen({
    Key? key,
    this.initialExercises,
    this.templateName, // <--- AÑADIR AL CONSTRUCTOR
  }) : super(key: key);

  @override
  State<TrainingScreen> createState() => _TrainingScreenState();
}

class _TrainingScreenState extends State<TrainingScreen> {
  String trainingTitle = "Entrenamiento de hoy";
  List<Map<String, dynamic>> selectedExercises = []; // Ejercicios en la sesión actual
  List<Map<String, dynamic>> availableExercises = []; // Todos los ejercicios disponibles (plantillas + manuales)
  bool _didDataChange = false;

  // CORRECCIÓN 4: Quitado @override innecesario
  void _removeExerciseFromTraining(int index) {
    if (mounted) {
      if (index >= 0 && index < selectedExercises.length) {
        final String exerciseNameToRemove =
            selectedExercises[index]['name']?.toString() ?? 'Ejercicio';

        setState(() {
          selectedExercises.removeAt(index);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
              Text("'$exerciseNameToRemove' quitado del entrenamiento")),
        );
      } else {
        debugPrint(
            "Error en _removeExerciseFromTraining: Índice $index está fuera de los límites para selectedExercises de tamaño ${selectedExercises.length}.");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Error al quitar el ejercicio. Índice inválido."),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.templateName != null && widget.templateName!.isNotEmpty) {
      trainingTitle = widget.templateName!; // <--- USA EL NOMBRE DE LA PLANTILLA
    }

    // Carga ejercicios iniciales si vienen de una plantilla
    if (widget.initialExercises != null) {
      selectedExercises = widget.initialExercises!.map((ex) { // ex es una fila de la tabla template_exercises
        var newEx = Map<String, dynamic>.from(ex);
        if (newEx['reps'] is String) {
          newEx['reps'] = (newEx['reps'] as String)
              .split(',')
              .map((s) => s.trim())
              .where((s) => s.isNotEmpty)
              .toList();
        } else if (newEx['reps'] == null || newEx['reps'] is! List) {
          newEx['reps'] = <String>[];
        }
        newEx['series'] = newEx['series']?.toString() ?? '';
        newEx['weight'] = newEx['weight']?.toString() ?? '';
        newEx['weightUnit'] = newEx['weightUnit']?.toString() ?? 'kg';
        newEx['notes'] = newEx['notes']?.toString() ?? '';

        // Aseguramos que 'db_category_id' esté presente para consistencia al guardar.
        // 'category_id' de template_exercises ya es la referencia a categories.id
        newEx['db_category_id'] = ex['category_id'];
        // 'isManual' para ejercicios de plantilla es false. 'id' es el de template_exercises.
        newEx['isManual'] = false; // Los ejercicios de plantilla no son 'manuales' en este contexto.
        // El 'id' aquí es de template_exercises.id
        return newEx;
      }).toList();
    }
    _loadAvailableExercises();
  }

  Future<List<Map<String, dynamic>>> _loadAvailableExercises() async {
    final db = DatabaseHelper.instance;
    debugPrint("Cargando ejercicios disponibles desde DB...");
    List<Map<String, dynamic>> templateExercises = [];
    List<Map<String, dynamic>> customExercises = [];

    try {
      templateExercises = await db.getTemplateExercises(1);
      customExercises = await db.getCategories();
    } catch (e) {
      debugPrint("Error cargando ejercicios de la DB: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Error al cargar ejercicios: $e"),
              backgroundColor: Colors.red),
        );
      }
      return availableExercises;
    }

    final templateMapped = templateExercises.map((ex) {
      final name = ex['name']?.toString() ?? ex['exercise_name']?.toString();
      return {...ex, 'name': name, 'isManual': false};
    }).toList();

    final customExercisesMapped = customExercises.map((ex) {
      final name = ex['name']?.toString();
      return {
        'name': name,
        'image': ex['image']?.toString() ?? '',
        'category': ex['muscle_group']?.toString() ?? '',
        'description': ex['description']?.toString() ?? '',
        'id': ex['id'],
        'isManual': true,
      };
    }).toList();

    final allAvailableExercises = [...templateMapped, ...customExercisesMapped];

    if (mounted) {
      setState(() {
        availableExercises = allAvailableExercises;
      });
    }
    debugPrint(
        "Total de ejercicios cargados para el overlay: ${allAvailableExercises.length}");
    if (allAvailableExercises.isEmpty) {
      debugPrint(
          "Advertencia: La lista de 'availableExercises' está vacía después de cargar.");
    }
    return allAvailableExercises;
  }

  void _onExerciseCheckedInOverlay(Map<String, dynamic> exercise) {
    setState(() {
      if (!selectedExercises.any((ex) => ex['name'] == exercise['name'])) {
        selectedExercises.add({
          'name': exercise['name'],
          'series': '',
          'weight': '',
          'weightUnit': 'kg',
          'reps': <String>[],
          'notes': '',
          'image': exercise['image'],
          'category': exercise['category'],
          'description': exercise['description'],
          'isManual': exercise['isManual'] ?? false, // Asegurar que isManual se propaga
          'id': exercise['id'], // Propagar id para la edición
          'db_category_id': (exercise['isManual'] == true)
              ? exercise['id'] // Si es manual, su 'id' es de 'categories'
              : exercise['category_id'], // Si no es manual (de plantilla de ejemplo), ya tiene 'category_id' que referencia 'categories'
        });
      }
    });
  }

  void _onExerciseUncheckedInOverlay(Map<String, dynamic> exercise) {
    setState(() {
      selectedExercises.removeWhere((ex) => ex['name'] == exercise['name']);
    });
  }

  void _openExerciseOverlay() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext sbfContext, StateSetter setDialogState) {
            return Dialog(
              insetPadding: EdgeInsets.all(
                  MediaQuery.of(sbfContext).size.width * 0.05),
              child: ExerciseOverlay(
                getAvailableExercises: _loadAvailableExercises,
                availableExercises: availableExercises,
                selectedExercisesForCheckboxes: selectedExercises,
                onNewExercise: (newExerciseMap) async {
                  await _loadAvailableExercises();
                  setDialogState(() {});
                  if (mounted) {
                    ScaffoldMessenger.of(sbfContext).showSnackBar(
                      SnackBar(
                          content:
                          Text("Ejercicio '${newExerciseMap['name']}' creado.")),
                    );
                  }
                },
                onExerciseChecked: (exercise) {
                  _onExerciseCheckedInOverlay(exercise);
                  setDialogState(() {});
                },
                onExerciseUnchecked: (exercise) {
                  _onExerciseUncheckedInOverlay(exercise);
                  setDialogState(() {});
                },
              ),
            );
          },
        );
      },
    );
  }

  Future<bool> _onWillPop() async {
    if (selectedExercises.isEmpty && !_didDataChange) {
      Navigator.of(context).pop(false); // Salir sin preguntar, no recargar HomeScreen
      return false; // Prevenir que WillPopScope o el caller hagan otro pop.
    }

    // Si hay datos en el log actual o se guardó algo (plantilla/definición de ejercicio).
    final String dialogMessage;
    if (_didDataChange) {
      if (selectedExercises.isEmpty) {
        dialogMessage = "Has guardado cambios (ej. una plantilla o definición de ejercicio). "
            "No hay datos en el entrenamiento actual. ¿Salir de todas formas?";
      } else {
        dialogMessage = "Has guardado cambios (ej. una plantilla o definición de ejercicio). "
            "Los datos del entrenamiento actual no finalizado también se perderán. ¿Seguro que quieres salir?";
      }
    } else { // Esto significa que !_didDataChange es true, pero selectedExercises NO está vacío.
      dialogMessage = "Los datos del entrenamiento actual no guardados se perderán. ¿Seguro que quieres salir?";
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Cancelar Entrenamiento"),
        content: Text("¿Seguro? Se perderán los datos no guardados."),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text("No")),
          TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text("Sí")),
        ],
      ),
    );
    if (result == true) { // Usuario confirmó "Sí, Salir" en el diálogo
      Navigator.of(context).pop(_didDataChange); // Pop TrainingScreen con el valor de _didDataChange
      return false; // Ya hicimos el pop, WillPopScope/caller no debe hacer otro.
    }
    return false; // Usuario dijo "No" o cerró el diálogo, no salir. WillPopScope/caller no hará pop.

  }

  Future<void> _saveTemplate(
      String name, List<Map<String, dynamic>> exercisesToSave) async {
    final db = DatabaseHelper.instance;
    final templateId = await db.insertTemplate(name);
    final exercisesForTemplateDb = exercisesToSave.map((ex) {
      return {
        'template_id': templateId,
        'name': ex['name'],
        'exercise_name': ex['name'],
        'image': ex['image'],
        'category_id': ex['db_category_id'],
        'description': ex['description'],
      };
    }).toList();
    await db.insertTemplateExercises(templateId, exercisesForTemplateDb);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Plantilla '$name' guardada")),
      );
      setState(() { // setState para que la UI pueda reaccionar si es necesario, y para _didDataChange
        _didDataChange = true; // <--- ACTUALIZAR AQUÍ
      });
    }
  }

  // CORRECCIÓN 1: Añadido el parámetro onExerciseDefinitionChanged
  void _openExerciseDataDialog(Map<String, dynamic> exercise, int index) {
    final db = DatabaseHelper.instance;
    showDialog(
      context: context,
      builder: (context) {
        return FutureBuilder<Map<String, dynamic>?>(
          future: db.getLastExerciseLog(exercise['name']?.toString() ?? ''),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            return ExerciseDataDialog(
              exercise: Map<String, dynamic>.from(selectedExercises[index]),
              lastLog: snapshot.data,
              onDataUpdated: (updatedExercise) {
                if (mounted) {
                  setState(() {
                    selectedExercises[index] = updatedExercise;
                    _didDataChange = true;
                  });
                }
              },
              onExerciseDefinitionChanged: () async {
                debugPrint(
                    "TrainingScreen: Definición de ejercicio cambiada. Recargando availableExercises...");
                await _loadAvailableExercises();
                if (mounted) {
                  // Actualizar el ejercicio en selectedExercises si el nombre ha cambiado
                  final String oldName = exercise['name'];
                  final updatedExerciseDefinition = availableExercises.firstWhere(
                        (ex) => ex['id'] == exercise['id'] && ex['isManual'] == true,
                    orElse: () => selectedExercises[index], // Mantener el actual si no se encuentra (poco probable)
                  );

                  if (selectedExercises[index]['name'] != updatedExerciseDefinition['name']) {
                    debugPrint("Nombre cambiado de '$oldName' a '${updatedExerciseDefinition['name']}'. Actualizando selectedExercises.");
                    selectedExercises[index]['name'] = updatedExerciseDefinition['name'];
                    selectedExercises[index]['description'] = updatedExerciseDefinition['description'];
                    selectedExercises[index]['image'] = updatedExerciseDefinition['image'];
                    selectedExercises[index]['category'] = updatedExerciseDefinition['category'];
                  }
                  setState(() {});
                }
              },
            );
          },
        );
      },
    );
  }

  void _editTrainingTitle() {
    TextEditingController controller = TextEditingController(text: trainingTitle);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Editar Título del Entrenamiento"),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(labelText: "Título"),
          autofocus: true,
          onSubmitted: (newTitle) {
            if (mounted && newTitle.trim().isNotEmpty) {
              setState(() {
                trainingTitle = newTitle.trim();
              });
            }
            Navigator.of(context).pop();
          },
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Cancelar")),
          TextButton(
            onPressed: () {
              if (mounted && controller.text.trim().isNotEmpty) {
                setState(() {
                  trainingTitle = controller.text.trim();
                });
              }
              Navigator.of(context).pop();
            },
            child: Text("Guardar"),
          ),
        ],
      ),
    );
  }

  void _confirmFinishTraining() async {
    if (selectedExercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Añade al menos un ejercicio para terminar el entrenamiento.")),
      );
      return;
    }
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Terminar Entrenamiento"),
        content: Text("¿Guardar y terminar el entrenamiento actual?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text("No")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text("Sí, Guardar")),
        ],
      ),
    );

    if (confirm == true) {
      final db = DatabaseHelper.instance;
      final String sessionDateTimeStr = DateTime.now().toIso8601String();
      // Usa el trainingTitle actual de la pantalla, que es editable
      final String currentSessionTitle = trainingTitle;

      try {
        // 1. Insertar la sesión de entrenamiento y obtener su ID
        int sessionId = await db.insertTrainingSession(currentSessionTitle, sessionDateTimeStr);
        print("Nueva sesión guardada con ID: $sessionId, Título: '$currentSessionTitle'");

        // 2. Insertar cada log de ejercicio con el session_id
        for (final exercise in selectedExercises) {
          await db.insertExerciseLogWithSessionId({ // Usamos el nuevo método
            'exercise_name': exercise['name'],
            'dateTime': DateTime.now().toIso8601String(), // Timestamp individual del log
            'series': exercise['series']?.toString() ?? '',
            'reps': (exercise['reps'] is List)
                ? (exercise['reps'] as List).join(',')
                : (exercise['reps']?.toString() ?? ''),
            'weight': exercise['weight']?.toString() ?? '',
            'weightUnit': exercise['weightUnit']?.toString() ?? 'kg',
            'notes': exercise['notes']?.toString() ?? '',
          }, sessionId);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Entrenamiento '$currentSessionTitle' guardado con éxito")));
          _didDataChange = true; // Marcar cambio para HomeScreen
          Navigator.pop(context, _didDataChange); // Indicar que algo se guardó
        }
      } catch (e) {
        print("Error al guardar la sesión de entrenamiento: $e");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("Error al guardar entrenamiento: $e"),
              backgroundColor: Colors.red));
        }
      }
    }
  }

  void _confirmSaveTemplate() async {
    if (selectedExercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                "Añade ejercicios al entrenamiento para guardarlo como plantilla.")),
      );
      return;
    }
    final nameController = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Guardar como Nueva Plantilla"),
        content: TextField(
          controller: nameController,
          decoration: InputDecoration(labelText: "Nombre de la plantilla"),
          autofocus: true,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancelar")),
          TextButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                Navigator.pop(context, nameController.text.trim());
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content:
                      Text("El nombre de la plantilla no puede estar vacío.")),
                );
              }
            },
            child: Text("Guardar Plantilla"),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      await _saveTemplate(result, selectedExercises);
    }
  }

  void _confirmCancelTraining() async {
    if (selectedExercises.isEmpty && !_didDataChange) {
      Navigator.pop(context, false); // Salir, no recargar HomeScreen.
      return;
    }

    final String dialogMessage;
    if (_didDataChange) {
      if (selectedExercises.isEmpty) {
        dialogMessage = "Has guardado cambios (ej. una plantilla o definición de ejercicio). "
            "No hay datos en el entrenamiento actual. ¿Cancelar y salir?";
      } else {
        dialogMessage = "Has guardado cambios (ej. una plantilla o definición de ejercicio). "
            "El entrenamiento actual no se guardará. ¿Seguro que quieres cancelar y salir?";
      }
    } else { // !_didDataChange es true, pero selectedExercises NO está vacío.
      dialogMessage = "Los datos no guardados del entrenamiento actual se perderán. ¿Seguro que quieres cancelar y salir?";
    }
    final confirmDialogResult = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Cancelar Entrenamiento"),
        content: Text(dialogMessage),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false), // No salir (cierra el diálogo)
              child: Text("No")),
          TextButton(
            onPressed: () => Navigator.pop(context, true),  // Sí, salir (cierra el diálogo)
            child: Text("Sí, Salir"),
          ),
        ],
      ),
    );
    if (confirmDialogResult == true) {
      // El usuario confirmó que quiere salir del entrenamiento.
      // Pop TrainingScreen y pasar _didDataChange para que HomeScreen sepa si recargar.
      Navigator.pop(context, _didDataChange);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Entrenamiento"),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () async {
              await _onWillPop();

            },
          ),
          actions: [
            TextButton(
              onPressed: _confirmCancelTraining,
              child: Text("Cancelar", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(children: [
                Expanded(
                    child: Text(trainingTitle,
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold))),
                IconButton(icon: Icon(Icons.edit), onPressed: _editTrainingTitle)
              ]),
              SizedBox(height: 10),
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                Expanded(
                    child: ElevatedButton.icon(
                        icon: Icon(Icons.add),
                        onPressed: _openExerciseOverlay,
                        label: Text("Añadir"))),
                SizedBox(width: 10),
                Expanded(
                    child: ElevatedButton.icon(
                        icon: Icon(Icons.save_alt),
                        onPressed: _confirmSaveTemplate,
                        label: Text("Crear Plantilla"),
                        style: ElevatedButton.styleFrom(
                            ))),
              ]),
              SizedBox(height: 10),
              if (selectedExercises.isEmpty)
                Expanded(
                    child: Center(
                        child: Text("Añade ejercicios a tu entrenamiento.",
                            style:
                            TextStyle(fontSize: 16, color: Colors.grey))))
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: selectedExercises.length,
                    itemBuilder: (context, index) {
                      final exercise = selectedExercises[index];
                      final exerciseName =
                          exercise['name']?.toString() ?? "Ejercicio";
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Dismissible(
                          key: UniqueKey(),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            color: Colors.red.shade400,
                            alignment: Alignment.centerRight,
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Icon(Icons.delete_sweep, color: Colors.white),
                          ),
                          confirmDismiss: (direction) async {
                            return await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: Text("Quitar Ejercicio"),
                                content: Text(
                                    "¿Quitar '$exerciseName' del entrenamiento?"),
                                actions: [
                                  TextButton(
                                      onPressed: () =>
                                          Navigator.pop(ctx, false),
                                      child: Text("No")),
                                  TextButton(
                                      onPressed: () =>
                                          Navigator.pop(ctx, true),
                                      child: Text("Sí, Quitar"),
                                      style: TextButton.styleFrom(
                                          foregroundColor: Colors.red)),
                                ],
                              ),
                            ) ??
                                false;
                          },
                          onDismissed: (direction) {
                            if (mounted) {
                              _removeExerciseFromTraining(index);
                            }
                          },
                          child: ListTile(
                            title: Text(exerciseName,
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(
                              'Series: ${exercise['series']?.toString() ?? "-"} | Peso: ${exercise['weight']?.toString() ?? "-"} ${exercise['weightUnit']?.toString() ?? "kg"} | Reps: ${(exercise['reps'] as List?)?.join(", ") ?? "-"}',
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.edit_note,
                                  color: Theme.of(context).primaryColor),
                              onPressed: () =>
                                  _openExerciseDataDialog(exercise, index),
                            ),
                            onTap: () =>
                                _openExerciseDataDialog(exercise, index),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              SizedBox(height: 10),
              ElevatedButton.icon(
                icon: Icon(Icons.check_circle, color: Colors.white),
                onPressed: _confirmFinishTraining,
                label: Text("Terminar y Guardar Entrenamiento"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ----------- ExerciseOverlay Widget -----------
class ExerciseOverlay extends StatefulWidget {
  final Future<List<Map<String, dynamic>>> Function() getAvailableExercises;
  final List<Map<String, dynamic>> availableExercises;
  final List<Map<String, dynamic>> selectedExercisesForCheckboxes;
  final Function(Map<String, dynamic> exerciseMap) onNewExercise;
  final Function(Map<String, dynamic> exercise) onExerciseChecked;
  final Function(Map<String, dynamic> exercise) onExerciseUnchecked;

  const ExerciseOverlay({
    Key? key,
    required this.getAvailableExercises,
    required this.availableExercises,
    required this.selectedExercisesForCheckboxes,
    required this.onNewExercise,
    required this.onExerciseChecked,
    required this.onExerciseUnchecked,
  }) : super(key: key);

  @override
  _ExerciseOverlayState createState() => _ExerciseOverlayState();
}

class _ExerciseOverlayState extends State<ExerciseOverlay> {
  List<Map<String, dynamic>> exercises = [];
  String searchQuery = '';
  String filterCategory = '';
  static const double iconButtonWidth = 48.0;

  @override
  void initState() {
    super.initState();
    exercises = List.from(widget.availableExercises);
    if (exercises.isEmpty) {
      debugPrint(
          "ExerciseOverlay initState: La lista inicial 'availableExercises' está vacía. Intentando refrescar...");
      refreshExercises();
    }
  }

  Future<void> refreshExercises() async {
    debugPrint("ExerciseOverlay: Refrescando ejercicios...");
    final freshList = await widget.getAvailableExercises();
    if (mounted) {
      setState(() {
        exercises = freshList;
      });
      debugPrint(
          "ExerciseOverlay refreshExercises: ${freshList.length} ejercicios cargados. Lista vacía: ${freshList.isEmpty}");
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredExercises = exercises.where((exercise) {
      final name = exercise['name']?.toString() ?? '';
      final nameMatch = name.toLowerCase().contains(searchQuery.toLowerCase());
      final categoryOfExercise =
          exercise['category']?.toString() ?? exercise['muscle_group']?.toString() ?? '';
      final categoryMatch =
          filterCategory.isEmpty || categoryOfExercise == filterCategory;
      return nameMatch && categoryMatch;
    }).toList();
    filteredExercises.sort((a, b) =>
        (a['name']?.toString() ?? '').compareTo(b['name']?.toString() ?? ''));

    return Container(
      constraints:
      BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Expanded(
                child: TextField(
                    decoration: InputDecoration(
                        labelText: "Buscar ejercicio",
                        prefixIcon: Icon(Icons.search)),
                    onChanged: (value) =>
                        setState(() => searchQuery = value))),
            IconButton(
                icon: Icon(Icons.close),
                onPressed: () => Navigator.pop(context))
          ]),
          Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(children: [
                Text("Categoría: "),
                SizedBox(width: 10),
                Expanded(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: filterCategory.isEmpty ? null : filterCategory,
                      hint: Text("Todas"),
                      items: <String>[
                        '', 'Pecho', 'Pierna', 'Espalda', 'Brazos', 'Cardio', 'Hombros', 'Abdomen', 'Otro'
                      ]
                          .map((cat) => DropdownMenuItem(
                          value: cat, child: Text(cat.isEmpty ? "Todas" : cat)))
                          .toList(),
                      onChanged: (value) =>
                          setState(() => filterCategory = value ?? ''),
                    )),
              ])),
          Flexible(
              child: filteredExercises.isEmpty
                  ? Center(
                  child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                          exercises.isEmpty
                              ? "Cargando o no hay ejercicios..."
                              : "No se encontraron ejercicios.",
                          textAlign: TextAlign.center)))
                  : ListView.builder(
                shrinkWrap: true,
                itemCount: filteredExercises.length,
                itemBuilder: (context, index) {
                  final exercise = filteredExercises[index];
                  final bool isSelected = widget
                      .selectedExercisesForCheckboxes
                      .any((selectedEx) =>
                  selectedEx['name'] == exercise['name']);
                  final String? exerciseImage =
                  exercise['image'] as String?;
                  final String exerciseName =
                      exercise['name']?.toString() ?? "Ejercicio sin nombre";

                  List<Widget> trailingItems = [];

                  if (exercise['isManual'] == true) {
                    trailingItems.add(SizedBox(
                        width: iconButtonWidth,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: Icon(Icons.delete_forever,
                              color: Colors.red.shade700),
                          tooltip: "Borrar permanentemente",
                          onPressed: () async {
                            final String exerciseNameForDialog =
                                exercise['name']?.toString() ??
                                    'Ejercicio sin nombre';
                            final confirmed =
                            await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: Text("¿Borrar Ejercicio?"),
                                  content: Text(
                                      "'$exerciseNameForDialog' se eliminará permanentemente."),
                                  actions: [
                                    TextButton(
                                        onPressed: () =>
                                            Navigator.pop(
                                                ctx, false),
                                        child: Text("Cancelar")),
                                    TextButton(
                                        onPressed: () =>
                                            Navigator.pop(
                                                ctx, true),
                                        child: Text("Borrar"),
                                        style: TextButton.styleFrom(
                                            foregroundColor:
                                            Colors.red))
                                  ],
                                ));
                            if (confirmed == true) {
                              bool wasSelected = widget
                                  .selectedExercisesForCheckboxes
                                  .any((ex) =>
                              ex['name'] == exercise['name']);
                              await DatabaseHelper.instance
                                  .deleteCategory(exercise['id']);
                              if (wasSelected)
                                widget.onExerciseUnchecked(exercise);
                              await refreshExercises();
                              if (mounted)
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                    content: Text(
                                        "Ejercicio '$exerciseNameForDialog' eliminado.")));
                            }
                          },
                        )));
                  } else {
                    trailingItems.add(SizedBox(width: iconButtonWidth));
                  }
                  trailingItems.add(Checkbox(
                      value: isSelected,
                      onChanged: (bool? newValue) {
                        if (newValue == true)
                          widget.onExerciseChecked(exercise);
                        else
                          widget.onExerciseUnchecked(exercise);
                      }));

                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 4.0),
                    child: ListTile(
                      leading: Container(
                        width: 50,
                        height: 50,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: (exerciseImage != null &&
                            exerciseImage.isNotEmpty)
                            ? (exerciseImage.startsWith('assets/'))
                            ? Image.asset(
                          exerciseImage,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (context, error, stackTrace) =>
                              Icon(Icons.fitness_center,
                                  color: Colors.grey[400],
                                  size: 30),
                        )
                            : Image.file(
                          File(exerciseImage),
                          fit: BoxFit.cover,
                          errorBuilder:
                              (context, error, stackTrace) =>
                              Icon(Icons.broken_image,
                                  color: Colors.grey[400],
                                  size: 30),
                        )
                            : Icon(Icons.fitness_center,
                            color: Colors.grey[400], size: 30),
                      ),
                      title: Text(exerciseName),
                      trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: trailingItems),
                      onTap: () {
                        if (isSelected) {
                          widget.onExerciseUnchecked(exercise);
                        } else {
                          widget.onExerciseChecked(exercise);
                        }
                      },
                    ),
                  );
                },
              )),
          Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: ElevatedButton.icon(
                icon: Icon(Icons.add_circle_outline),
                label: Text('Crear Nuevo Ejercicio '),
                style:
                ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 40)),
                onPressed: () async {
                  await showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (dialogCtx) => NewExerciseDialog(
                        // onExerciseCreated se pasa aquí
                        onExerciseCreated: (newExerciseData) {
                          widget.onNewExercise(newExerciseData);
                        },
                        // exerciseToEdit es opcional, no se pasa para "Crear Nuevo"
                      ));
                  await refreshExercises();
                },
              )),
        ],
      ),
    );
  }
}

// ----------- NewExerciseDialog Widget (ÚNICA DEFINICIÓN - MÁS COMPLETA)-----------
class NewExerciseDialog extends StatefulWidget {
  final Function(Map<String, dynamic> newExerciseData)? onExerciseCreated;
  final Map<String, dynamic>? exerciseToEdit; // Para modo edición

  const NewExerciseDialog({
    Key? key,
    this.onExerciseCreated,
    this.exerciseToEdit,
  }) : super(key: key);

  @override
  _NewExerciseDialogState createState() => _NewExerciseDialogState();
}

class _NewExerciseDialogState extends State<NewExerciseDialog> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  String? selectedMuscleGroup;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool _imageWasRemovedOrReplaced = false;
  String? _initialImagePathPreview;

  final List<String> muscleGroups = [
    'Pecho', 'Pierna', 'Espalda', 'Brazos', 'Hombros', 'Abdomen', 'Cardio', 'Otro'
  ];

  bool get isEditMode => widget.exerciseToEdit != null;

  @override
  void initState() {
    super.initState();
    if (isEditMode && widget.exerciseToEdit != null) {
      nameController.text = widget.exerciseToEdit!['name'] ?? '';
      descriptionController.text =
          widget.exerciseToEdit!['description'] ?? '';
      selectedMuscleGroup = widget.exerciseToEdit!['muscle_group'] ??
          widget.exerciseToEdit!['category'];

      final String? imagePath = widget.exerciseToEdit!['image'];
      if (imagePath != null && imagePath.isNotEmpty) {
        _initialImagePathPreview = imagePath;
        if (!imagePath.startsWith('assets/')) {
          _imageFile = File(imagePath); // Intenta cargar si es un archivo local
        }
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    debugPrint(" Iniciando _pickImage con fuente: $source");
    Map<Permission, PermissionStatus> statuses;
    if (source == ImageSource.camera) {
      debugPrint(" Solicitando permiso de CAMARA...");
      statuses = await [Permission.camera].request();
      debugPrint(" Estado del permiso de CAMARA: $statuses");
    } else {
      int? sdkVersion = await _getAndroidSDKVersion();
      debugPrint(" Versión SDK de Android obtenida: $sdkVersion");
      if (Platform.isAndroid) {
        if (sdkVersion != null && sdkVersion >= 33) {
          debugPrint(" Solicitando Permission.photos (Android 13+)...");
          statuses = await [Permission.photos].request();
          debugPrint(" Estado de Permission.photos: $statuses");
        } else {
          debugPrint(" Solicitando Permission.storage (Android < 13)...");
          statuses = await [Permission.storage].request();
          debugPrint(" Estado de Permission.storage: $statuses");
        }
      } else {
        debugPrint(" Solicitando Permission.photos (iOS u otra plataforma)...");
        statuses = await [Permission.photos].request();
        debugPrint(" Estado de Permission.photos (iOS u otra): $statuses");
      }
    }

    bool permissionsGranted = true;
    statuses.forEach((permission, permissionStatus) async {
      debugPrint(" Procesando permiso: $permission, Estado: $permissionStatus");
      if (permissionStatus.isPermanentlyDenied) {
        debugPrint(" ¡ALERTA! Permiso $permission DENEGADO PERMANENTEMENTE.");
        if (mounted) {
          await showDialog(
            context: context, // Usar el context del _NewExerciseDialogState
            builder: (BuildContext dialogContext) => AlertDialog( // Renombrar a dialogContext
              title: Text("Permiso Requerido"),
              content: Text(
                  "Esta función requiere permisos que fueron denegados permanentemente. Por favor, habilítalos en la configuración de la aplicación."),
              actions: <Widget>[
                TextButton(
                  child: Text("Cancelar"),
                  onPressed: () => Navigator.of(dialogContext).pop(),
                ),
                TextButton(
                  child: Text("Abrir Configuración"),
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    openAppSettings();
                  },
                ),
              ],
            ),
          );
        }
        permissionsGranted = false; // Marcar como no concedido si está permanentemente denegado
      } else if (!permissionStatus.isGranted) {
        permissionsGranted = false;
      }
    });

    if (!permissionsGranted) {
      debugPrint(" Permisos NO concedidos. Mostrando SnackBar.");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Se requieren permisos. Habilítalos en la configuración de la app.')),
        );
      }
      return;
    }

    debugPrint(" Permisos CONCEDIDOS. Procediendo a seleccionar imagen...");
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        debugPrint(" Imagen seleccionada: ${pickedFile.path}");
        if (mounted) {
          setState(() {
            _imageFile = File(pickedFile.path);
            _imageWasRemovedOrReplaced = true;
            _initialImagePathPreview = null;
          });
        }
      } else {
        debugPrint(" Selección de imagen cancelada o pickedFile es null.");
      }
    } catch (e) {
      debugPrint(" EXCEPCIÓN al seleccionar imagen: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al seleccionar imagen: $e')),
        );
      }
    }
  }

  Future<int?> _getAndroidSDKVersion() async {
    if (Platform.isAndroid) {
      final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      debugPrint(
          "Versión real del SDK de Android: ${androidInfo.version.sdkInt}");
      return androidInfo.version.sdkInt;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    Widget imagePreviewWidget;
    if (_imageFile != null) {
      imagePreviewWidget = Image.file(
        _imageFile!,
        height: 100,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => Container(
            height: 100,
            color: Colors.grey[200],
            child: Center(
                child: Text("Error al cargar preview",
                    style: TextStyle(color: Colors.red)))),
      );
    } else if (_initialImagePathPreview != null &&
        _initialImagePathPreview!.isNotEmpty) {
      if (_initialImagePathPreview!.startsWith('assets/')) {
        imagePreviewWidget = Image.asset(_initialImagePathPreview!,
            height: 100, fit: BoxFit.contain);
      } else {
        imagePreviewWidget = Image.file(File(_initialImagePathPreview!),
            height: 100,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => Container(
                height: 100,
                color: Colors.grey[200],
                child: Center(
                    child: Icon(Icons.broken_image,
                        color: Colors.grey[600], size: 40))));
      }
    } else {
      imagePreviewWidget = Container(
        height: 100,
        decoration: BoxDecoration(
            color: Colors.grey[200],
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8)),
        child: Center(
            child: Icon(Icons.image_not_supported,
                color: Colors.grey[600], size: 40)),
      );
    }
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
            key: _formKey,
            child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              isEditMode
                                  ? (widget.exerciseToEdit!['name'] ??
                                  'Editar Ejercicio')
                                  : "Crear Nuevo Ejercicio",
                              style: Theme.of(context).textTheme.titleLarge,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                              icon: Icon(Icons.close),
                              onPressed: () => Navigator.pop(context))
                        ]),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: nameController,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                          labelText: "Nombre del ejercicio *",
                          border: OutlineInputBorder(),
                          hintText: "Ej: Press de Banca"),
                      validator: (value) => (value == null ||
                          value.trim().isEmpty)
                          ? 'El nombre es requerido'
                          : null,
                    ),
                    SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedMuscleGroup,
                      decoration: InputDecoration(
                          labelText: "Grupo Muscular *",
                          border: OutlineInputBorder()),
                      hint: Text("Selecciona un grupo"),
                      items: muscleGroups
                          .map((group) =>
                          DropdownMenuItem(value: group, child: Text(group)))
                          .toList(),
                      onChanged: (value) =>
                          setState(() => selectedMuscleGroup = value),
                      validator: (value) =>
                      value == null ? 'Selecciona un grupo muscular' : null,
                    ),
                    SizedBox(height: 12),
                    TextFormField(
                      controller: descriptionController,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                          labelText: "Descripción (opcional)",
                          border: OutlineInputBorder(),
                          hintText: "Ej: Movimiento principal..."),
                      maxLines: 3,
                    ),
                    SizedBox(height: 12),
                    Text("Imagen del Ejercicio (opcional):",
                        style: Theme.of(context).textTheme.titleSmall),
                    SizedBox(height: 8),
                    Center(child: imagePreviewWidget),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton.icon(
                            icon: Icon(Icons.photo_library),
                            label: Text("Galería"),
                            onPressed: () => _pickImage(ImageSource.gallery)),
                        TextButton.icon(
                            icon: Icon(Icons.camera_alt),
                            label: Text("Cámara"),
                            onPressed: () => _pickImage(ImageSource.camera)),
                      ],
                    ),
                    if (_imageFile != null ||
                        (_initialImagePathPreview != null &&
                            _initialImagePathPreview!.isNotEmpty))
                      TextButton.icon(
                        icon: Icon(Icons.delete_outline, color: Colors.red),
                        label:
                        Text("Quitar Imagen", style: TextStyle(color: Colors.red)),
                        onPressed: () {
                          setState(() {
                            _imageFile = null;
                            _initialImagePathPreview = null;
                            _imageWasRemovedOrReplaced = true;
                          });
                        },
                      ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          minimumSize: Size(double.infinity, 40)),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          String trimmedName = nameController.text.trim();
                          String? imagePathToSave;
                          if (_imageFile != null) {
                            imagePathToSave = _imageFile!.path;
                          } else if (_imageWasRemovedOrReplaced) {
                            imagePathToSave = null;
                          } else if (isEditMode) {
                            imagePathToSave = widget.exerciseToEdit!['image'];
                          } else {
                            imagePathToSave = null;
                          }

                          Map<String, dynamic> exerciseDataForDb = {
                            'name': trimmedName,
                            'muscle_group': selectedMuscleGroup,
                            'image': imagePathToSave,
                            'description': descriptionController.text.trim(),
                          };

                          if (isEditMode) {
                            final id = widget.exerciseToEdit!['id'];
                            final String oldName = widget.exerciseToEdit!['name'];
                            await DatabaseHelper.instance
                                .updateCategory(id, exerciseDataForDb);
                            if (trimmedName != oldName) {
                              await DatabaseHelper.instance
                                  .updateExerciseLogsName(oldName, trimmedName);
                            }
                            Navigator.pop(context, {
                              'id': id,
                              ...exerciseDataForDb,
                              'category': selectedMuscleGroup,
                              'isManual': widget.exerciseToEdit!['isManual'] ?? true,
                            });
                          } else {
                            final id = await DatabaseHelper.instance
                                .insertCategory(exerciseDataForDb);
                            Map<String, dynamic> exerciseForCallback = {
                              ...exerciseDataForDb,
                              'id': id,
                              'isManual': true,
                              'category': selectedMuscleGroup,
                            };
                            if (widget.onExerciseCreated != null) {
                              widget.onExerciseCreated!(exerciseForCallback);
                            }
                            Navigator.pop(context);
                          }
                        }
                      },
                      child: Text(isEditMode
                          ? "Guardar Cambios"
                          : "Confirmar y Guardar Ejercicio"),
                    ),
                  ],
                ))),
      ),
    );
  }
}

// ----------- ExerciseDataDialog Widget (ÚNICA DEFINICIÓN - MÁS COMPLETA) -----------
class ExerciseDataDialog extends StatefulWidget {
  final Map<String, dynamic> exercise;
  final Map<String, dynamic>? lastLog;
  final Function(Map<String, dynamic> updatedExerciseData) onDataUpdated;
  final VoidCallback onExerciseDefinitionChanged;

  const ExerciseDataDialog({
    Key? key,
    required this.exercise,
    this.lastLog,
    required this.onDataUpdated,
    required this.onExerciseDefinitionChanged,
  }) : super(key: key);

  @override
  _ExerciseDataDialogState createState() => _ExerciseDataDialogState();
}

class _ExerciseDataDialogState extends State<ExerciseDataDialog>
    with SingleTickerProviderStateMixin {
  final _formKeyCurrentDataTab = GlobalKey<FormState>();
  late TabController _tabController;
  late TextEditingController seriesController;
  late TextEditingController weightController;
  late TextEditingController notesController;
  late String weightUnit;
  late List<TextEditingController> repControllers;
  late List<String> repWarnings;
  late int seriesCountFromInput;
  String seriesWarningText = '';

  late Map<String, dynamic> _currentExerciseData;

  @override
  void initState() {
    super.initState();
    _currentExerciseData = Map<String, dynamic>.from(widget.exercise);

    _tabController = TabController(length: 3, vsync: this);
    seriesController = TextEditingController(
        text: _currentExerciseData['series']?.toString() ??
            widget.exercise['series']?.toString() ??
            '');
    weightController = TextEditingController(
        text: _currentExerciseData['weight']?.toString() ??
            widget.exercise['weight']?.toString() ??
            '');
    notesController = TextEditingController(
        text: _currentExerciseData['notes']?.toString() ??
            widget.exercise['notes']?.toString() ??
            '');
    weightUnit = _currentExerciseData['weightUnit']?.toString() ??
        widget.exercise['weightUnit']?.toString() ??
        'kg';
    seriesCountFromInput = int.tryParse(seriesController.text) ?? 0;

    repControllers = [];
    repWarnings = [];
    _initializeRepControllersBasedOnSeriesCount();

    if (_currentExerciseData['reps'] is List ||
        widget.exercise['reps'] is List) {
      List<dynamic> repsList =
      (_currentExerciseData['reps'] ?? widget.exercise['reps']) as List;
      for (int i = 0; i < repControllers.length && i < repsList.length; i++) {
        repControllers[i].text = repsList[i]?.toString() ?? '';
      }
    }
  }

  void _initializeRepControllersBasedOnSeriesCount() {
    int targetSeriesForRepFields = seriesCountFromInput;
    if (seriesCountFromInput > 4) {
      seriesWarningText = "Se recomienda menos de 4 series para no sobrentrenar";
      targetSeriesForRepFields = 4;
    } else if (seriesCountFromInput < 0) {
      seriesWarningText = "Número de series inválido.";
      targetSeriesForRepFields = 0;
    } else {
      seriesWarningText = "";
    }

    List<TextEditingController> newRepControllers =
    List.generate(targetSeriesForRepFields, (i) {
      return (i < repControllers.length)
          ? repControllers[i]
          : TextEditingController();
    });
    List<String> newRepWarnings =
    List.generate(targetSeriesForRepFields, (i) {
      return (i < repWarnings.length) ? repWarnings[i] : '';
    });

    repControllers = newRepControllers;
    repWarnings = newRepWarnings;
  }

  void _validateRepValue(String value, int index) {
    if (index >= repControllers.length) {
      return;
    }
    String trimmedValue = value.trim();
    setState(() {
      if (trimmedValue.isEmpty) {
        repWarnings[index] = "Requerido";
      } else {
        int? reps = int.tryParse(trimmedValue);
        if (reps != null) {
          if (reps < 6) {
            repWarnings[index] =
            'Se recomienda bajar el peso para un mejor entrenamiento';
          } else if (reps > 12) {
            repWarnings[index] = "Te recomendamos subir el peso";
          } else {
            repWarnings[index] = "";
          }
          if (reps < 1) {
            repWarnings[index] = "Mínimo 1 repetición.";
          } else if (reps > 99) {
            repWarnings[index] = "Máximo 99 reps.";
          }
        } else {
          repWarnings[index] = "Valor inválido";
        }
      }
    });
  }

  // CORRECCIÓN 2: Eliminada la primera definición duplicada de _confirmAndSaveData
  // Esta es la versión completa y correcta.
  void _confirmAndSaveData() {
    bool hasBlockingErrors = false;
    if (!_formKeyCurrentDataTab.currentState!.validate()) {
      hasBlockingErrors = true;
    }
    setState(() {
      seriesCountFromInput = int.tryParse(seriesController.text.trim()) ?? 0;
      _initializeRepControllersBasedOnSeriesCount();
    });
    if (seriesWarningText == "Número de series inválido." ||
        seriesWarningText == "Máximo 6 series permitidas.") { // Ajusta si tu límite es otro
      hasBlockingErrors = true;
    }

    for (int i = 0; i < repControllers.length; i++) {
      // Es importante llamar a _validateRepValue SIN setState aquí,
      // porque ya estamos en un proceso de guardado y _validateRepValue llama a setState.
      // Para obtener el estado más reciente de repWarnings, lo recalculamos:
      String currentRepValue = repControllers[i].text;
      String tempWarning = "";
      if (currentRepValue.trim().isEmpty) {
        tempWarning = "Requerido";
      } else {
        int? reps = int.tryParse(currentRepValue.trim());
        if (reps != null) {
          if (reps < 1) tempWarning = "Mínimo 1 repetición.";
          else if (reps > 99) tempWarning = "Máximo 99 reps.";
        } else {
          tempWarning = "Valor inválido";
        }
      }
      // Ahora comprobamos tempWarning para errores bloqueantes
      if (tempWarning == "Requerido" ||
          tempWarning == "Valor inválido" ||
          tempWarning == "Mínimo 1 repetición." ||
          tempWarning == "Máximo 99 reps.") {
        hasBlockingErrors = true;
        if (mounted && i < repWarnings.length && repWarnings[i] != tempWarning) {
        }
      }
    }

    if (hasBlockingErrors) {
      if (mounted) { // Verificar mounted antes de usar context
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Corrige los errores marcados antes de guardar."),
            backgroundColor: Colors.redAccent));
      }
      return; // No continuar si hay errores
    }


    if (hasBlockingErrors) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Corrige los errores marcados en rojo antes de guardar."),
          backgroundColor: Colors.redAccent));
      return;
    }

    List<String> repsData =
    repControllers.map((c) => c.text.trim()).toList();

    // Usar _currentExerciseData para mantener la definición y actualizar solo los datos del log
    _currentExerciseData['series'] = seriesController.text.trim();
    _currentExerciseData['weight'] = weightController.text.trim();
    _currentExerciseData['weightUnit'] = weightUnit;
    _currentExerciseData['reps'] = repsData; // Esto es una lista de Strings
    _currentExerciseData['notes'] = notesController.text.trim();

    widget.onDataUpdated(_currentExerciseData); // Pasa el mapa completo
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _tabController.dispose();
    seriesController.dispose();
    weightController.dispose();
    notesController.dispose();
    for (var controller in repControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _openEditExerciseDialog(
      BuildContext parentDialogContext) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: parentDialogContext,
      barrierDismissible: false,
      builder: (dialogCtx) => NewExerciseDialog(
        exerciseToEdit: Map<String, dynamic>.from(_currentExerciseData),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _currentExerciseData = result;
      });
      widget.onExerciseDefinitionChanged();
      debugPrint(
          "Ejercicio actualizado en ExerciseDataDialog: ${_currentExerciseData['name']}");
    }
  }

  @override
  Widget build(BuildContext context) {
    final lastLogData = widget.lastLog;
    return Dialog(
        insetPadding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(alignment: Alignment.centerRight, children: [
              TabBar(
                controller: _tabController,
                labelColor: Theme.of(context).primaryColor,
                unselectedLabelColor: Colors.grey,
                tabs: const [
                  Tab(text: 'Actual'),
                  Tab(text: 'Historial'),
                  Tab(text: 'Info'),
                ],
              ),
              Positioned(
                right: 0, top: 0, bottom: 0,
                child: IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                    tooltip: "Cerrar"),
              )
            ]),
            Flexible(
                child: Container(
                  constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.7),
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildCurrentDataTab(),
                      _buildHistoryTab(lastLogData),
                      _buildDescriptionTab(),
                    ],
                  ),
                )),
          ],
        ));
  }

  Widget _buildCurrentDataTab() {
    return SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
    child: Form( // <--- 1. ENVOLVER CON WIDGET Form
    key: _formKeyCurrentDataTab, // <--- 2. ASIGNAR LA CLAVE
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
    // Campo de Número de Series
    TextFormField( // <--- 3. Considerar cambiar a TextFormField si quieres validación de Form
    controller: seriesController,
    keyboardType: TextInputType.number,
    decoration: InputDecoration(
    labelText: 'Número de Series',
    border: OutlineInputBorder(),
    errorText:
    seriesWarningText.isEmpty ? null : seriesWarningText),
    onChanged: (value) {
    setState(() {
    seriesCountFromInput = int.tryParse(value) ?? 0;
    _initializeRepControllersBasedOnSeriesCount();
    });
    },
      validator: (value) {
        // Ejemplo de validador si quisieras usar el Form para este campo:
        // if (value == null || value.trim().isEmpty) {
        //   return 'Las series son requeridas';
        // }
        // final n = int.tryParse(value.trim());
        // if (n == null) return 'Número inválido';
        // if (n < 0) return 'No puede ser negativo';
        return null; // Sin error desde la perspectiva del Form si la validación manual es suficiente
      },
    ),

          SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextFormField( // Tu TextFormField existente para Peso
                  controller: weightController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Peso *', // Ya lo tienes así, indica obligatorio
                    border: OutlineInputBorder(),
                    hintText: "Ej: 70.5",
                  ),
                  validator: (value) { // Tu validador existente
                    if (value == null || value.trim().isEmpty) {
                      return 'El peso es requerido';
                    }
                    final n = double.tryParse(value.trim().replaceAll(',', '.')); // Reemplaza coma por punto
                    if (n == null) {
                      return 'Ingresa un número válido';
                    }
                    if (n <= 0) {
                      return 'El peso debe ser mayor a 0';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(width: 8),
              SizedBox(
                width: 90,
                child: DropdownButtonFormField<String>(
                  value: weightUnit,
                  decoration: InputDecoration(border: OutlineInputBorder()),
                  items: ['kg', 'lb']
                      .map((unit) =>
                      DropdownMenuItem(value: unit, child: Text(unit)))
                      .toList(),
                  onChanged: (value) =>
                      setState(() => weightUnit = value ?? 'kg'),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text('Repeticiones por Serie:',
              style: Theme.of(context).textTheme.titleMedium),
          if (repControllers.isEmpty && seriesCountFromInput > 0)
            Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text("Ajusta el número de series.",
                    style: TextStyle(color: Colors.grey)))
          else
            ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: repControllers.length,
                itemBuilder: (context, index) {
                  return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
    child: TextFormField(
                        controller: repControllers[index],
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            labelText: 'Reps Serie ${index + 1}',
                            border: OutlineInputBorder(),
                            errorText: (repWarnings.length > index &&
                                repWarnings[index].isNotEmpty)
                                ? repWarnings[index]
                                : null),
                        onChanged: (value) => _validateRepValue(value, index),
                      ));
                }),
          SizedBox(height: 16),
    TextFormField(
              controller: notesController,
              decoration: InputDecoration(
                  labelText: 'Notas (opcional)',
                  border: OutlineInputBorder()),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences),
          SizedBox(height: 24),
          if (widget.lastLog != null) ...[
            Text("Último Registro:",
                style: Theme.of(context).textTheme.titleMedium),
            SizedBox(height: 4),
            Text(
                "  Series: ${widget.lastLog!['series'] ?? '-'}, Peso: ${widget.lastLog!['weight'] ?? '-'} ${widget.lastLog!['weightUnit'] ?? ''}"),
            Text("  Reps: ${widget.lastLog!['reps'] ?? '-'}"),
            if (widget.lastLog!['notes'] != null &&
                (widget.lastLog!['notes'] as String).isNotEmpty)
              Text("  Notas: ${widget.lastLog!['notes']}"),
            SizedBox(height: 24),
          ],
          ElevatedButton(
              onPressed: _confirmAndSaveData,
              child: Text('Actualizar Registro'),
              style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12))),
    ]
    ),
    ),
    );
  }

  // CORRECCIÓN 3: Añadidos itemCount, separatorBuilder, e itemBuilder
  Widget _buildHistoryTab(Map<String, dynamic>? currentLastLog) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future:
      DatabaseHelper.instance.getExerciseLogs(_currentExerciseData['name'] ?? ''),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
              child: Text("Error cargando historial: ${snapshot.error}"));
        }
        final logs = snapshot.data ?? [];
        if (logs.isEmpty) {
          return Center(
              child: Text(
                  "Sin registros anteriores para '${_currentExerciseData['name'] ?? 'ejercicio actual'}'"));
        }
        return ListView.separated(
          padding: EdgeInsets.all(16),
          itemCount: logs.length, // Parámetro itemCount
          separatorBuilder: (_, __) => Divider(height: 20), // Parámetro separatorBuilder
          itemBuilder: (context, index) { // Parámetro itemBuilder
            final log = logs[index];
            String formattedDate = "Fecha desconocida";
            if (log['dateTime'] != null) {
              try {
                DateTime dt = DateTime.parse(log['dateTime']);
                formattedDate =
                "${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
              } catch (_) {}
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(formattedDate,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColorDark)),
                SizedBox(height: 4),
                Text("  Series: ${log['series'] ?? '-'}"),
                Text(
                    "  Peso: ${log['weight'] ?? '-'} ${log['weightUnit'] ?? ''}"),
                Text("  Reps: ${log['reps'] ?? '-'}"),
                if (log['notes'] != null &&
                    (log['notes'] as String).isNotEmpty)
                  Text("  Notas: ${log['notes']}"),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildDescriptionTab() {
    final exerciseImage = _currentExerciseData['image'] as String?;
    final exerciseDescription = _currentExerciseData['description'] as String?;
    final exerciseName = _currentExerciseData['name']?.toString();
    final bool isManualExercise = _currentExerciseData['isManual'] == true;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (exerciseImage != null && exerciseImage.isNotEmpty)

            Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Container(
                  height: 150,
                  width: double.infinity,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: exerciseImage.startsWith('assets/')
                      ? Image.asset(
                    exerciseImage,
                    fit: BoxFit.contain, // Cambiado a contain para mejor visualización
                    errorBuilder: (_, __, ___) => Center(child: Text("No se pudo cargar imagen.", textAlign: TextAlign.center, style: TextStyle(color: Colors.orange))),
                  )
                      : Image.file(
                    File(exerciseImage),
                    fit: BoxFit.contain, // Cambiado a contain
                    errorBuilder: (_, __, ___) => Center(child: Text("No se pudo cargar imagen.", textAlign: TextAlign.center, style: TextStyle(color: Colors.red))),
                  ),
                ),
              ),
            )
          else
            Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Icon(Icons.image_search, size: 100, color: Colors.grey[400]),
                ),
              ),
            ),
          Center( // Widget para centrar
            child: Text(
              exerciseName ?? "Ejercicio",
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center, // Opcional: para centrar el texto si tiene múltiples líneas
            ),
          ),
          SizedBox(height: 8),
          Text(
            exerciseDescription != null && exerciseDescription.isNotEmpty
                ? exerciseDescription
                : "No hay descripción disponible.",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          SizedBox(height: 20),
          if (isManualExercise)
            Center(
              child: ElevatedButton.icon(
                icon: Icon(Icons.edit),
                label: Text('Editar Información del Ejercicio'),
                onPressed: () {
                  _openEditExerciseDialog(context);
                },
              ),
            ),
        ],
      ),
    );
  }
}