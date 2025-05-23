import 'package:flutter/material.dart';
import 'dart:async';
import '../database/database_helper.dart'; // Asegúrate que la ruta sea correcta

// Clase principal de la pantalla de Entrenamiento
class TrainingScreen extends StatefulWidget {
  final List<Map<String, dynamic>>? initialExercises;
  const TrainingScreen({Key? key, this.initialExercises}) : super(key: key);

  @override
  State<TrainingScreen> createState() => _TrainingScreenState();
}

class _TrainingScreenState extends State<TrainingScreen> {
  String trainingTitle = "Entrenamiento de hoy";
  List<Map<String, dynamic>> selectedExercises = []; // Ejercicios en la sesión actual
  List<Map<String, dynamic>> availableExercises = []; // Todos los ejercicios disponibles (plantillas + manuales)

  @override
  void _removeExerciseFromTraining(int index) {
    if (mounted) { // Asegura que el widget todavía está en el árbol de widgets
      // Verificación adicional para la validez del índice
      if (index >= 0 && index < selectedExercises.length) {
        final String exerciseNameToRemove = selectedExercises[index]['name']?.toString() ?? 'Ejercicio';

        setState(() {
          selectedExercises.removeAt(index);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("'$exerciseNameToRemove' quitado del entrenamiento")),
        );
      } else {
        // Esto no debería ocurrir si ListView.builder está funcionando correctamente,
        // pero es una salvaguarda y ayuda a depurar si sucede.
        debugPrint("Error en _removeExerciseFromTraining: Índice $index está fuera de los límites para selectedExercises de tamaño ${selectedExercises.length}.");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al quitar el ejercicio. Índice inválido."), backgroundColor: Colors.red),
        );
      }
    }
  }
  void initState() {
    super.initState();
    // Si se pasan ejercicios iniciales (ej. desde una plantilla), se cargan
    if (widget.initialExercises != null) {
      selectedExercises = widget.initialExercises!.map((ex) {
        var newEx = Map<String, dynamic>.from(ex);
        // Asegurar formato correcto para 'reps'
        if (newEx['reps'] is String) {
          newEx['reps'] = (newEx['reps'] as String).split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
        } else if (newEx['reps'] == null || newEx['reps'] is! List) {
          newEx['reps'] = <String>[];
        }
        // Asegurar valores por defecto para otros campos
        newEx['series'] = newEx['series']?.toString() ?? '';
        newEx['weight'] = newEx['weight']?.toString() ?? '';
        newEx['weightUnit'] = newEx['weightUnit']?.toString() ?? 'kg';
        newEx['notes'] = newEx['notes']?.toString() ?? '';
        return newEx;
      }).toList();
    }
    _loadAvailableExercises(); // Carga todos los ejercicios disponibles de la DB
  }

  // Carga todos los ejercicios (plantillas y manuales) de la base de datos
  Future<List<Map<String, dynamic>>> _loadAvailableExercises() async {
    final db = DatabaseHelper.instance;
    debugPrint("Cargando ejercicios disponibles desde DB...");
    List<Map<String, dynamic>> templateExercises = [];
    List<Map<String, dynamic>> customExercises = [];

    try {
      // Asumiendo ID 1 para plantillas generales (ajusta si es necesario)
      templateExercises = await db.getTemplateExercises(1);
      customExercises = await db.getCategories(); // Ejercicios manuales se guardan en 'categories'
    } catch (e) {
      debugPrint("Error cargando ejercicios de la DB: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al cargar ejercicios: $e"), backgroundColor: Colors.red),
        );
      }
      return availableExercises; // Devuelve la lista actual para evitar romper la UI
    }

    // Mapea ejercicios de plantilla a un formato común
    final templateMapped = templateExercises.map((ex) {
      final name = ex['name']?.toString() ?? ex['exercise_name']?.toString(); // Consistencia en el nombre
      return { ...ex, 'name': name, 'isManual': false };
    }).toList();

    // Mapea ejercicios manuales (categorías) a un formato común
    final customExercisesMapped = customExercises.map((ex) {
      final name = ex['name']?.toString();
      return {
        'name': name,
        'image': ex['image']?.toString() ?? '',
        'category': ex['muscle_group']?.toString() ?? '', // 'muscle_group' de la DB es 'category' en la UI
        'description': ex['description']?.toString() ?? '',
        'id': ex['id'],
        'isManual': true,
      };
    }).toList();

    // Combina ambas listas
    final allAvailableExercises = [...templateMapped, ...customExercisesMapped];

    if (mounted) {
      setState(() {
        availableExercises = allAvailableExercises;
      });
    }
    debugPrint("Total de ejercicios cargados para el overlay: ${allAvailableExercises.length}");
    if (allAvailableExercises.isEmpty) {
      debugPrint("Advertencia: La lista de 'availableExercises' está vacía después de cargar.");
    }
    return allAvailableExercises; // Devuelve la lista fresca para el ExerciseOverlay
  }

  // Callback: se ejecuta cuando se marca un ejercicio en ExerciseOverlay
  void _onExerciseCheckedInOverlay(Map<String, dynamic> exercise) {
    setState(() {
      // Añade el ejercicio a la sesión actual si no está ya
      if (!selectedExercises.any((ex) => ex['name'] == exercise['name'])) {
        selectedExercises.add({
          'name': exercise['name'],
          'series': '', 'weight': '', 'weightUnit': 'kg',
          'reps': <String>[], 'notes': '',
          'image': exercise['image'], 'category': exercise['category'],
        });
      }
    });
  }

  // Callback: se ejecuta cuando se desmarca un ejercicio en ExerciseOverlay
  void _onExerciseUncheckedInOverlay(Map<String, dynamic> exercise) {
    setState(() {
      selectedExercises.removeWhere((ex) => ex['name'] == exercise['name']);
    });
  }

  // Abre el diálogo ExerciseOverlay para seleccionar ejercicios
  void _openExerciseOverlay() {
    showDialog(
      context: context,
      barrierDismissible: false, // Evita que se cierre al tocar fuera
      builder: (BuildContext dialogContext) {
        // StatefulBuilder permite actualizar la UI del diálogo (checkboxes)
        // cuando cambia el estado en _TrainingScreenState (ej. selectedExercises)
        return StatefulBuilder(
          builder: (BuildContext sbfContext, StateSetter setDialogState) {
            return Dialog(
              insetPadding: EdgeInsets.all(MediaQuery.of(sbfContext).size.width * 0.05), // Padding del diálogo
              child: ExerciseOverlay(
                getAvailableExercises: _loadAvailableExercises,
                availableExercises: availableExercises, // Pasa la lista completa
                selectedExercisesForCheckboxes: selectedExercises, // Pasa los ya seleccionados

                onNewExercise: (newExerciseMap) async {
                  // Este callback se llama desde NewExerciseDialog después de crear un ejercicio
                  await _loadAvailableExercises(); // Recarga la lista de todos los ejercicios
                  setDialogState(() {}); // Refresca la UI de ExerciseOverlay
                  if (mounted) {
                    ScaffoldMessenger.of(sbfContext).showSnackBar(
                      SnackBar(content: Text("Ejercicio '${newExerciseMap['name']}' creado.")),
                    );
                  }
                },
                onExerciseChecked: (exercise) {
                  _onExerciseCheckedInOverlay(exercise);
                  setDialogState(() {}); // Actualiza los checkboxes en el diálogo
                },
                onExerciseUnchecked: (exercise) {
                  _onExerciseUncheckedInOverlay(exercise);
                  setDialogState(() {}); // Actualiza los checkboxes en el diálogo
                },
              ),
            );
          },
        );
      },
    );
  }

  // --- Métodos para manejo del entrenamiento (guardar, editar título, etc.) ---
  // Estos métodos se mantienen como estaban en tu última versión completa,
  // ya que parecían funcionar bien y no estaban directamente relacionados
  // con los problemas de nombres o la ventana vacía del overlay.
  // Se incluyen aquí para que el archivo esté completo.

  Future<bool> _onWillPop() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Cancelar Entrenamiento"),
        content: Text("¿Seguro? Se perderán los datos no guardados."),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text("No")),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: Text("Sí")),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _saveTemplate(String name, List<Map<String, dynamic>> exercisesToSave) async {
    final db = DatabaseHelper.instance;
    final templateId = await db.insertTemplate(name);
    final exercisesForTemplateDb = exercisesToSave.map((ex) {
      return {
        'template_id': templateId,
        'name': ex['name'],
        'exercise_name': ex['name'], // Por compatibilidad o si usas ambos
        'image': ex['image'],
        'category_id': ex['category_id'], // Asegúrate que este ID exista si lo usas
      };
    }).toList();
    await db.insertTemplateExercises(templateId, exercisesForTemplateDb);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Plantilla '$name' guardada")),
      );
    }
  }

  void _openExerciseDataDialog(Map<String, dynamic> exercise, int index) {
    final db = DatabaseHelper.instance;
    showDialog(
      context: context,
      builder: (context) {
        return FutureBuilder<Map<String, dynamic>?>(
          future: db.getLastExerciseLog(exercise['name']?.toString() ?? ''), // Manejo de nombre nulo
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
                  });
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
          onSubmitted: (newTitle) { // Guardar al presionar Enter en el teclado
            if (mounted && newTitle.trim().isNotEmpty) {
              setState(() { trainingTitle = newTitle.trim(); });
            }
            Navigator.of(context).pop();
          },
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: Text("Cancelar")),
          TextButton(
            onPressed: () {
              if (mounted && controller.text.trim().isNotEmpty) {
                setState(() { trainingTitle = controller.text.trim(); });
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
      final now = DateTime.now().toIso8601String();
      try {
        for (final exercise in selectedExercises) {
          await db.insertExerciseLog({
            'exercise_name': exercise['name'],
            'dateTime': now,
            'series': exercise['series']?.toString() ?? '',
            'reps': (exercise['reps'] is List) ? (exercise['reps'] as List).join(',') : (exercise['reps']?.toString() ?? ''),
            'weight': exercise['weight']?.toString() ?? '',
            'weightUnit': exercise['weightUnit']?.toString() ?? 'kg',
            'notes': exercise['notes']?.toString() ?? '',
          });
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Entrenamiento guardado con éxito")));
          Navigator.pop(context, true); // Vuelve a HomeScreen, indicando que algo se guardó
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error al guardar entrenamiento: $e"), backgroundColor: Colors.red));
        }
      }
    }
  }

  void _confirmSaveTemplate() async {
    if (selectedExercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Añade ejercicios al entrenamiento para guardarlo como plantilla.")),
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
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancelar")),
          TextButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                Navigator.pop(context, nameController.text.trim());
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("El nombre de la plantilla no puede estar vacío.")),
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
      // Considera si quieres volver a HomeScreen después de guardar plantilla.
      // Navigator.pop(context, true); // 'true' podría indicar a HomeScreen que recargue plantillas.
    }
  }

  void _confirmCancelTraining() { // Confirmación para el botón "Cancelar" del AppBar
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Cancelar Entrenamiento"),
        content: Text("¿Seguro? Se perderán los datos agregados."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("No")), // Cierra solo el diálogo
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Cierra el diálogo de confirmación
              Navigator.pop(context); // Cierra la pantalla de TrainingScreen
            },
            child: Text("Sí, Salir"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop, // Maneja el botón de retroceso del dispositivo
      child: Scaffold(
        appBar: AppBar(
          title: Text("Entrenamiento"),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () async {
              if (await _onWillPop()) { // Confirma antes de salir
                Navigator.pop(context);
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: _confirmCancelTraining, // Botón de cancelar en AppBar
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
                Expanded(child: Text(trainingTitle, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
                IconButton(icon: Icon(Icons.edit), onPressed: _editTrainingTitle)
              ]),
              SizedBox(height: 10),
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                Expanded(child: ElevatedButton.icon(icon: Icon(Icons.add), onPressed: _openExerciseOverlay, label: Text("Añadir"))),
                SizedBox(width: 10),
                Expanded(child: ElevatedButton.icon(icon: Icon(Icons.save_alt), onPressed: _confirmSaveTemplate, label: Text("Plantilla"), style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent))),
              ]),
              SizedBox(height: 10),
              if (selectedExercises.isEmpty)
                Expanded(child: Center(child: Text("Añade ejercicios a tu entrenamiento.", style: TextStyle(fontSize: 16, color: Colors.grey))))
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: selectedExercises.length,
                    itemBuilder: (context, index) {
                      final exercise = selectedExercises[index];
                      final exerciseName = exercise['name']?.toString() ?? "Ejercicio";
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Dismissible(
                          key: UniqueKey(), // Clave única para cada elemento
                          direction: DismissDirection.endToStart,
                          background: Container(
                            color: Colors.red.shade400, alignment: Alignment.centerRight,
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Icon(Icons.delete_sweep, color: Colors.white),
                          ),
                          confirmDismiss: (direction) async {
                            return await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: Text("Quitar Ejercicio"),
                                content: Text("¿Quitar '$exerciseName' del entrenamiento?"),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text("No")),
                                  TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text("Sí, Quitar"), style: TextButton.styleFrom(foregroundColor: Colors.red)),
                                ],
                              ),
                            ) ?? false; // Si el diálogo se cierra sin seleccionar, devuelve false
                          },
                          onDismissed: (direction) {
                            if (mounted) {
                              _removeExerciseFromTraining(index); // Usa la función centralizada
                            }
                          },
                          child: ListTile(
                            title: Text(exerciseName, style: TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(
                              'Series: ${exercise['series']?.toString() ?? "-"} | Peso: ${exercise['weight']?.toString() ?? "-"} ${exercise['weightUnit']?.toString() ?? "kg"} | Reps: ${(exercise['reps'] as List?)?.join(", ") ?? "-"}',
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.edit_note, color: Theme.of(context).primaryColor),
                              onPressed: () => _openExerciseDataDialog(exercise, index),
                            ),
                            onTap: () => _openExerciseDataDialog(exercise, index), // También abre al tocar
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
                  backgroundColor: Colors.green.shade600, foregroundColor: Colors.white,
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
      debugPrint("ExerciseOverlay initState: La lista inicial 'availableExercises' está vacía. Intentando refrescar...");
      refreshExercises(); // Intenta cargar si la lista inicial está vacía
    }
  }

  Future<void> refreshExercises() async {
    debugPrint("ExerciseOverlay: Refrescando ejercicios...");
    final freshList = await widget.getAvailableExercises();
    if (mounted) {
      setState(() { exercises = freshList; });
      debugPrint("ExerciseOverlay refreshExercises: ${freshList.length} ejercicios cargados. Lista vacía: ${freshList.isEmpty}");
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredExercises = exercises.where((exercise) {
      final name = exercise['name']?.toString() ?? '';
      final nameMatch = name.toLowerCase().contains(searchQuery.toLowerCase());
      final categoryOfExercise = exercise['category']?.toString() ?? exercise['muscle_group']?.toString() ?? '';
      final categoryMatch = filterCategory.isEmpty || categoryOfExercise == filterCategory;
      return nameMatch && categoryMatch;
    }).toList();
    filteredExercises.sort((a, b) => (a['name']?.toString() ?? '').compareTo(b['name']?.toString() ?? ''));

    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Expanded(child: TextField(decoration: InputDecoration(labelText: "Buscar ejercicio", prefixIcon: Icon(Icons.search)), onChanged: (value) => setState(() => searchQuery = value))),
            IconButton(icon: Icon(Icons.close), onPressed: () => Navigator.pop(context))
          ]),
          Padding(padding: const EdgeInsets.symmetric(vertical: 8.0), child: Row(children: [
            Text("Categoría: "), SizedBox(width: 10),
            Expanded(child: DropdownButton<String>(
              isExpanded: true, value: filterCategory.isEmpty ? null : filterCategory, hint: Text("Todas"),
              items: <String>['', 'Pecho', 'Pierna', 'Espalda', 'Brazos', 'Cardio', 'Hombros', 'Abdomen', 'Otro']
                  .map((cat) => DropdownMenuItem(value: cat, child: Text(cat.isEmpty ? "Todas" : cat))).toList(),
              onChanged: (value) => setState(() => filterCategory = value ?? ''),
            )),
          ])),
          Flexible(child: filteredExercises.isEmpty
              ? Center(child: Padding(padding: const EdgeInsets.all(16.0), child: Text(exercises.isEmpty ? "Cargando o no hay ejercicios..." : "No se encontraron ejercicios.", textAlign: TextAlign.center)))
              : ListView.builder(
            shrinkWrap: true, itemCount: filteredExercises.length,
            itemBuilder: (context, index) {
              final exercise = filteredExercises[index];
              final bool isSelected = widget.selectedExercisesForCheckboxes.any((selectedEx) => selectedEx['name'] == exercise['name']);
              List<Widget> trailingItems = [];
              if (exercise['isManual'] == true) {
                trailingItems.add(SizedBox(width: iconButtonWidth, child: IconButton(
                  padding: EdgeInsets.zero, icon: Icon(Icons.delete_forever, color: Colors.red.shade700), tooltip: "Borrar permanentemente",
                  onPressed: () async {
                    final String exerciseNameForDialog = exercise['name']?.toString() ?? 'Ejercicio sin nombre';
                    final confirmed = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
                      title: Text("¿Borrar Ejercicio?"), content: Text("'$exerciseNameForDialog' se eliminará permanentemente."),
                      actions: [ TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text("Cancelar")), TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text("Borrar"), style: TextButton.styleFrom(foregroundColor: Colors.red))],
                    ));
                    if (confirmed == true) {
                      bool wasSelected = widget.selectedExercisesForCheckboxes.any((ex) => ex['name'] == exercise['name']);
                      await DatabaseHelper.instance.deleteCategory(exercise['id']);
                      if (wasSelected) widget.onExerciseUnchecked(exercise);
                      await refreshExercises();
                      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Ejercicio '$exerciseNameForDialog' eliminado.")));
                    }
                  },
                )));
              } else { trailingItems.add(SizedBox(width: iconButtonWidth)); }
              trailingItems.add(Checkbox(value: isSelected, onChanged: (bool? newValue) {
                if (newValue == true) widget.onExerciseChecked(exercise); else widget.onExerciseUnchecked(exercise);
              }));
              final exerciseName = exercise['name']?.toString();
              final exerciseImage = exercise['image'] as String?;

              return Card(
                margin: EdgeInsets.symmetric(vertical: 4.0),
                child: ListTile(
                  leading: (exerciseImage != null && exerciseImage.isNotEmpty && exerciseImage.startsWith('assets/'))
                      ? ClipRRect( // Si hay una imagen de asset válida
                    borderRadius: BorderRadius.circular(8.0), // Tu radio de borde anterior
                    child: Image.asset(
                      exerciseImage,
                      width: 32, // Tu ancho anterior
                      height: 32, // Tu alto anterior
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container( // Tu errorBuilder anterior
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: const Icon(Icons.fitness_center, color: Colors.grey, size: 20),
                      ),
                    ),
                  )
                      : Container( // Tu placeholder por defecto anterior
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: const Icon(Icons.fitness_center, color: Colors.grey, size: 20),
                  ),
                  title: Text(exerciseName ?? "Ejercicio sin nombre"), // Mantenemos el fallback
                  trailing: Row(mainAxisSize: MainAxisSize.min, children: trailingItems),
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
          Padding(padding: const EdgeInsets.only(top: 8.0), child: ElevatedButton.icon(
            icon: Icon(Icons.add_circle_outline), label: Text('Crear Nuevo Ejercicio Manual'),
            style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 40)),
            onPressed: () async {
              await showDialog(context: context, barrierDismissible: false, builder: (dialogCtx) => NewExerciseDialog(
                onExerciseCreated: (newExerciseData) { widget.onNewExercise(newExerciseData); },
              ));
              await refreshExercises(); // Siempre refresca después de cerrar el diálogo de creación
            },
          )),
        ],
      ),
    );
  }
}

// ----------- NewExerciseDialog Widget -----------
class NewExerciseDialog extends StatefulWidget {
  final Function(Map<String, dynamic> newExerciseData) onExerciseCreated;
  const NewExerciseDialog({Key? key, required this.onExerciseCreated}) : super(key: key);

  @override
  _NewExerciseDialogState createState() => _NewExerciseDialogState();
}

class _NewExerciseDialogState extends State<NewExerciseDialog> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  String? selectedMuscleGroup;
  String? imagePath;

  final List<String> muscleGroups = ['Pecho', 'Pierna', 'Espalda', 'Brazos', 'Hombros', 'Abdomen', 'Cardio', 'Otro'];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(key: _formKey, child: SingleChildScrollView(child: Column(
          mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text("Crear Nuevo Ejercicio", style: Theme.of(context).textTheme.titleLarge), // Usar titleLarge
              IconButton(icon: Icon(Icons.close), onPressed: () => Navigator.pop(context))
            ]),
            SizedBox(height: 16),
            TextFormField(controller: nameController, textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(labelText: "Nombre del ejercicio *", border: OutlineInputBorder(), hintText: "Ej: Press de Banca"),
              validator: (value) => (value == null || value.trim().isEmpty) ? 'El nombre es requerido' : null,
            ),
            SizedBox(height: 12),
            DropdownButtonFormField<String>(value: selectedMuscleGroup,
              decoration: InputDecoration(labelText: "Grupo Muscular *", border: OutlineInputBorder()),
              hint: Text("Selecciona un grupo"),
              items: muscleGroups.map((group) => DropdownMenuItem(value: group, child: Text(group))).toList(),
              onChanged: (value) => setState(() => selectedMuscleGroup = value),
              validator: (value) => value == null ? 'Selecciona un grupo muscular' : null,
            ),
            SizedBox(height: 12),
            TextFormField(controller: descriptionController, textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(labelText: "Descripción (opcional)", border: OutlineInputBorder(), hintText: "Ej: Movimiento principal..."),
              maxLines: 3,
            ),
            SizedBox(height: 12),
            TextButton.icon(icon: Icon(Icons.image_search),
              label: Text(imagePath == null ? "Simular Selección de Imagen" : "Quitar Imagen Simulada"),
              onPressed: () {
                setState(() => imagePath = imagePath == null ? 'assets/ejercicio_placeholder.png' : null);
                if (imagePath != null) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Imagen simulada: ${imagePath!}. El asset debe existir.")));
              },
            ),
            if (imagePath != null && imagePath!.startsWith('assets/'))
              Padding(padding: const EdgeInsets.only(top: 8.0),
                child: Image.asset(imagePath!, height: 60, errorBuilder: (_,__,___) => Text("Error al cargar imagen placeholder.", style: TextStyle(color: Colors.red))),
              ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 40)),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  String trimmedName = nameController.text.trim();
                  Map<String, dynamic> newExerciseDataForDb = {
                    'name': trimmedName, 'muscle_group': selectedMuscleGroup,
                    'image': imagePath, 'description': descriptionController.text.trim(),
                    'date': null, 'workout_id': null, 'category_id': null, 'weight': null,
                    'weightUnit': null, 'reps': null, 'sets': null, 'notes': null, 'dateTime': null,
                  };
                  final id = await DatabaseHelper.instance.insertCategory(newExerciseDataForDb);
                  Map<String, dynamic> exerciseForCallback = {
                    ...newExerciseDataForDb, 'id': id, 'isManual': true,
                    'category': selectedMuscleGroup,
                  };
                  widget.onExerciseCreated(exerciseForCallback);
                  Navigator.pop(context);
                }
              },
              child: Text("Confirmar y Guardar Ejercicio"),
            ),
          ],
        ))),
      ),
    );
  }
}

// ----------- ExerciseDataDialog Widget -----------
class ExerciseDataDialog extends StatefulWidget {
  final Map<String, dynamic> exercise;
  final Map<String, dynamic>? lastLog;
  final Function(Map<String, dynamic> updatedExerciseData) onDataUpdated;

  const ExerciseDataDialog({ Key? key, required this.exercise, this.lastLog, required this.onDataUpdated }) : super(key: key);

  @override
  _ExerciseDataDialogState createState() => _ExerciseDataDialogState();
}

class _ExerciseDataDialogState extends State<ExerciseDataDialog> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController seriesController;
  late TextEditingController weightController;
  late TextEditingController notesController;
  late String weightUnit;
  late List<TextEditingController> repControllers;
  late List<String> repWarnings;
  late int seriesCountFromInput;
  String seriesWarningText = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    seriesController = TextEditingController(text: widget.exercise['series']?.toString() ?? '');
    weightController = TextEditingController(text: widget.exercise['weight']?.toString() ?? '');
    notesController = TextEditingController(text: widget.exercise['notes']?.toString() ?? '');
    weightUnit = widget.exercise['weightUnit']?.toString() ?? 'kg';
    seriesCountFromInput = int.tryParse(seriesController.text) ?? 0;

    // Inicializa repControllers y repWarnings como listas vacías antes de llamar a _initializeRepControllersBasedOnSeriesCount
    repControllers = [];
    repWarnings = [];

    _initializeRepControllersBasedOnSeriesCount();

    if (widget.exercise['reps'] is List) {
      List<dynamic> repsList = widget.exercise['reps'];
      for (int i = 0; i < repControllers.length && i < repsList.length; i++) {
        repControllers[i].text = repsList[i]?.toString() ?? '';
      }
    }
  }

  void _initializeRepControllersBasedOnSeriesCount() {
    int targetSeriesForRepFields = seriesCountFromInput; // Número de series que el usuario ingresó

    // Aplicar lógica de advertencia y límite según tu especificación
    if (seriesCountFromInput > 4) {
      seriesWarningText =
      "Se recomienda menos de 4 series para no sobrentrenar"; // ADVISORY
      targetSeriesForRepFields =
      4; // Limita la cantidad de campos de repeticiones a 4
    } else if (seriesCountFromInput < 0) {
      seriesWarningText = "Número de series inválido."; // BLOCKING ERROR
      targetSeriesForRepFields = 0;
    } else { // 0 a 4 series
      seriesWarningText = ""; // Sin advertencia ni error
    }

    List<TextEditingController> newRepControllers = List.generate(
        targetSeriesForRepFields, (i) {
      return (i < repControllers.length)
          ? repControllers[i]
          : TextEditingController();
    });
    List<String> newRepWarnings = List.generate(targetSeriesForRepFields, (i) {
      // Conserva las advertencias de repeticiones existentes si el índice aún es válido
      return (i < repWarnings.length) ? repWarnings[i] : '';
    });

    repControllers = newRepControllers;
    repWarnings = newRepWarnings;


    // Solo llama a setState si las listas han cambiado de tamaño o contenido para evitar bucles innecesarios
    // Esta comparación es superficial, para una profunda necesitarías comparar cada elemento.
    bool changed = repControllers.length != newRepControllers.length;
    if (!changed) {
      for(int i=0; i< repControllers.length; i++) {
        if(repControllers[i].text != newRepControllers[i].text) { // Ejemplo de comparación más profunda
          changed = true;
          break;
        }
      }
    }

    // Actualiza las listas principales
    repControllers = newRepControllers;
    repWarnings = newRepWarnings;

    // Si se llama desde onChanged, el setState de allí se encargará.
    // Si se llama desde initState, no es necesario setState.
    // Si se necesita un setState explícito aquí, debe ser condicional.
    // Por ahora, el setState en onChanged de seriesController maneja la reconstrucción.
  }

  void _validateRepValue(String value, int index) {
    if (index >= repControllers.length) {
      return;
    }

    String trimmedValue = value.trim();
    setState(() {
      if (trimmedValue.isEmpty) {
        // Si el campo de repetición está vacío, es un error "Requerido"
        repWarnings[index] = "Requerido"; // Esto será un error BLOQUEANTE
      } else {
        int? reps = int.tryParse(trimmedValue);
        if (reps != null) { // Si es un número válido
          // --- LÓGICA DE ADVERTENCIA DE REPETICIONES RESTAURADA ---
          if (reps < 6) {
            repWarnings[index] = 'Se recomienda bajar el peso para un mejor entrenamiento'; // ADVISORY
          } else if (reps > 12) {
            repWarnings[index] = "Te recomendamos subir el peso"; // ADVISORY
          } else {
            repWarnings[index] = ""; // Reps válidas y sin consejo
          }
          // --- FIN LÓGICA DE ADVERTENCIA DE REPETICIONES ---

          // Adicionalmente, podrías querer errores bloqueantes para rangos imposibles
          if (reps < 1) { // Ejemplo de error bloqueante
            repWarnings[index] = "Mínimo 1 repetición."; // ERROR BLOQUEANTE
          } else if (reps > 99) { // Ejemplo de límite superior práctico
            repWarnings[index] = "Máximo 99 reps."; // ERROR BLOQUEANTE
          }
          // Nota: Si una condición de error bloqueante se cumple, sobrescribirá la advertencia advisory.
          // Prioriza los errores bloqueantes.

        } else { // No es un número
          repWarnings[index] = "Valor inválido"; // ERROR BLOQUEANTE
        }
      }
    });
  }

  void _confirmAndSaveData() {
    bool hasBlockingErrors = false;
    // Valida número de series
    // Llama a setState dentro de _initialize para que se actualice el warning si es necesario
    setState(() {
    seriesCountFromInput = int.tryParse(seriesController.text.trim()) ?? 0;
    _initializeRepControllersBasedOnSeriesCount();
  });
    if (seriesWarningText == "Número de series inválido." ||
        seriesWarningText == "Máximo 6 series permitidas." /* o tu límite máximo real */) {
      hasBlockingErrors = true;
    }
    // Valida repeticiones
    for (int i = 0; i < repControllers.length; i++) {
      _validateRepValue(repControllers[i].text, i); // Esto llamará a setState internamente

      // Verifica si la advertencia actual para esta repetición es un error bloqueante
      if (repWarnings[i] == "Requerido" ||
          repWarnings[i] == "Valor inválido" ||
          repWarnings[i] == "Mínimo 1 repetición." || // Asegúrate que coincida con el texto exacto del error
          repWarnings[i] == "Máximo 99 reps."  // Asegúrate que coincida con el texto exacto del error
      /* Añade aquí otros textos de error de repeticiones que consideres bloqueantes */
      ) {
        hasBlockingErrors = true;
      }
    }

    if (hasBlockingErrors) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Corrige los errores marcados en rojo antes de guardar."), backgroundColor: Colors.redAccent)
      );
      return; // No guardar si hay errores bloqueantes
    }

    List<String> repsData = repControllers.map((c) => c.text.trim()).toList();
    Map<String, dynamic> updatedExerciseData = {
      ...widget.exercise,
      'series': seriesController.text.trim(),
      'weight': weightController.text.trim(),
      'weightUnit': weightUnit,
      'reps': repsData,
      'notes': notesController.text.trim(),
    };

    widget.onDataUpdated(updatedExerciseData);
    Navigator.pop(context);
  }

  @override
  void dispose() {
    // ... (dispose de controladores) ...
    _tabController.dispose();
    seriesController.dispose();
    weightController.dispose();
    notesController.dispose();
    for (var controller in repControllers) { controller.dispose(); }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ... (Build principal de ExerciseDataDialog sin cambios, ya es complejo) ...
    final lastLogData = widget.lastLog;
    return Dialog( /* ... */ child: Column(mainAxisSize: MainAxisSize.min, children: [
      Stack(alignment: Alignment.centerRight, children: [
        TabBar(controller: _tabController, labelColor: Theme.of(context).primaryColor, unselectedLabelColor: Colors.grey, tabs: const [Tab(text: 'Actual'), Tab(text: 'Historial'), Tab(text: 'Info')]),
        IconButton(icon: Icon(Icons.close), onPressed: () => Navigator.pop(context), tooltip: "Cerrar")
      ]),
      Flexible(child: Container(constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.65), child: TabBarView(controller: _tabController, children: [
        _buildCurrentDataTab(), _buildHistoryTab(lastLogData), _buildDescriptionTab(),
      ]))),
    ]));
  }

  Widget _buildCurrentDataTab() {
    return SingleChildScrollView(padding: const EdgeInsets.all(16.0), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      TextField(controller: seriesController, keyboardType: TextInputType.number,
        decoration: InputDecoration(labelText: 'Número de Series', border: OutlineInputBorder(), errorText: seriesWarningText.isEmpty ? null : seriesWarningText),
        onChanged: (value) { setState(() { seriesCountFromInput = int.tryParse(value) ?? 0; _initializeRepControllersBasedOnSeriesCount(); }); },
      ),
      SizedBox(height: 12),
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: TextField(controller: weightController, keyboardType: TextInputType.numberWithOptions(decimal: true), decoration: InputDecoration(labelText: 'Peso', border: OutlineInputBorder()))),
        SizedBox(width: 8),
        SizedBox(width: 90, child: DropdownButtonFormField<String>(value: weightUnit, decoration: InputDecoration(border: OutlineInputBorder()),
          items: ['kg', 'lb'].map((unit) => DropdownMenuItem(value: unit, child: Text(unit))).toList(),
          onChanged: (value) => setState(() => weightUnit = value ?? 'kg'),
        )),
      ]),
      SizedBox(height: 16),
      Text('Repeticiones por Serie:', style: Theme.of(context).textTheme.bodyLarge), // Usar bodyLarge
      if (repControllers.isEmpty && seriesCountFromInput > 0) Padding(padding: const EdgeInsets.symmetric(vertical: 8.0), child: Text("Ajusta el número de series.", style: TextStyle(color: Colors.grey)))
      else ListView.builder(shrinkWrap: true, physics: NeverScrollableScrollPhysics(), itemCount: repControllers.length, itemBuilder: (context, index) {
        return Padding(padding: const EdgeInsets.only(top: 8.0), child: TextField(controller: repControllers[index], keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: 'Reps Serie ${index + 1}', border: OutlineInputBorder(), errorText: (repWarnings.length > index && repWarnings[index].isNotEmpty) ? repWarnings[index] : null),
          onChanged: (value) => _validateRepValue(value, index),
        ));
      }),
      SizedBox(height: 16),
      TextField(controller: notesController, decoration: InputDecoration(labelText: 'Notas (opcional)', border: OutlineInputBorder()), maxLines: 3, textCapitalization: TextCapitalization.sentences),
      SizedBox(height: 24),
      if (widget.lastLog != null) ...[
        Text("Último Registro:", style: Theme.of(context).textTheme.bodyLarge), SizedBox(height: 4),
        Text("  Series: ${widget.lastLog!['series'] ?? '-'}, Peso: ${widget.lastLog!['weight'] ?? '-'} ${widget.lastLog!['weightUnit'] ?? ''}"),
        Text("  Reps: ${widget.lastLog!['reps'] ?? '-'}"),
        if (widget.lastLog!['notes'] != null && (widget.lastLog!['notes'] as String).isNotEmpty) Text("  Notas: ${widget.lastLog!['notes']}"),
        SizedBox(height: 24),
      ],
      ElevatedButton(onPressed: _confirmAndSaveData, child: Text('Guardar Cambios'), style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 12))),
    ]));
  }

  Widget _buildHistoryTab(Map<String, dynamic>? currentLastLog) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: DatabaseHelper.instance.getExerciseLogs(widget.exercise['name'] ?? ''),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("Error cargando historial: ${snapshot.error}"));
        }

        final logs = snapshot.data ?? [];

        // --- INICIO DE LÓGICA RESTAURADA ---
        if (logs.isEmpty) {
          return Center(child: Text("Sin registros anteriores")); // Tu mensaje específico
        }
        // --- FIN DE LÓGICA RESTAURADA ---

        // El resto del método para mostrar la lista de logs se mantiene igual:
        return ListView.separated(
          padding: EdgeInsets.all(16),
          itemCount: logs.length,
          separatorBuilder: (_, __) => Divider(height: 20),
          itemBuilder: (context, index) {
            final log = logs[index];
            String formattedDate = "Fecha desconocida";
            if (log['dateTime'] != null) {
              try {
                DateTime dt = DateTime.parse(log['dateTime']);
                formattedDate = "${dt.day.toString().padLeft(2,'0')}/${dt.month.toString().padLeft(2,'0')}/${dt.year} ${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2, '0')}";
              } catch (_) {}
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(formattedDate, style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColorDark)),
                SizedBox(height: 4),
                Text("  Series: ${log['series'] ?? '-'}"),
                Text("  Peso: ${log['weight'] ?? '-'} ${log['weightUnit'] ?? ''}"),
                Text("  Reps: ${log['reps'] ?? '-'}"),
                if (log['notes'] != null && (log['notes'] as String).isNotEmpty)
                  Text("  Notas: ${log['notes']}"),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildDescriptionTab() {
    final exerciseImage = widget.exercise['image'] as String?;
    final exerciseDescription = widget.exercise['description'] as String?;
    final exerciseName = widget.exercise['name']?.toString();
    return SingleChildScrollView(padding: const EdgeInsets.all(16.0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (exerciseImage != null && exerciseImage.isNotEmpty && exerciseImage.startsWith('assets/'))
        Center(child: Padding(padding: const EdgeInsets.only(bottom: 16.0),
          child: Image.asset(exerciseImage, height: 150, fit: BoxFit.contain, errorBuilder: (_,__,___) => Text("No se pudo cargar imagen.", textAlign: TextAlign.center, style: TextStyle(color: Colors.orange))),
        ))
      else if (exerciseImage != null && exerciseImage.isNotEmpty) Center(child: Padding(padding: const EdgeInsets.only(bottom: 16.0), child: Icon(Icons.image_search, size: 100, color: Colors.grey))),
      Text(exerciseName ?? "Ejercicio", style: Theme.of(context).textTheme.headlineSmall), // Usar headlineSmall
      SizedBox(height: 8),
      Text(exerciseDescription != null && exerciseDescription.isNotEmpty ? exerciseDescription : "No hay descripción disponible.", style: Theme.of(context).textTheme.bodyMedium), // Usar bodyMedium
    ]));
  }
}