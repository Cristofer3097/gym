import 'package:flutter/material.dart';
import 'dart:async';
import '../database/database_helper.dart';

class TrainingScreen extends StatefulWidget {
  final List<Map<String, dynamic>>? initialExercises;
  const TrainingScreen({Key? key, this.initialExercises}) : super(key: key);

  @override
  State<TrainingScreen> createState() => _TrainingScreenState();
}

class _TrainingScreenState extends State<TrainingScreen> {
  String trainingTitle = "Entrenamiento de hoy";
  List<Map<String, dynamic>> selectedExercises = [];
  List<Map<String, dynamic>> availableExercises = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialExercises != null) {
      selectedExercises = List<Map<String, dynamic>>.from(widget.initialExercises!);
    }
    _loadAvailableExercises();
  }

  Future<void> _loadAvailableExercises() async {
    final db = DatabaseHelper.instance;
    final exercises = await db.getTemplateExercises(1); // assuming templateId = 1 for demo
    setState(() {
      availableExercises = exercises;
    });
  }

  Future<bool> _onWillPop() async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Cancelar Entrenamiento"),
        content: Text("¿Seguro? Se perderán los datos agregados."),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text("No"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: Text("Sí"),
          ),
        ],
      ),
    ) ?? false;
  }
  void _saveTemplate(String name, List<Map<String, dynamic>> selectedExercises) async {
    final db = DatabaseHelper.instance;
    final templateId = await db.insertTemplate(name);
    await db.insertTemplateExercises(templateId, selectedExercises);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Plantilla '$name' guardada")),
    );
  }
  void _openExerciseOverlay() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          insetPadding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.1),
          child: ExerciseOverlay(
            availableExercises: availableExercises,
            onExerciseSelected: (exercise) {
              setState(() {
                selectedExercises.add({
                  'name': exercise['name'],
                  'series': '',
                  'weight': '',
                  'weightUnit': 'kg',
                  'reps': <String>[],
                  'notes': ''
                });
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Se agregó ${exercise['name']}"),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            onNewExercise: (newExercise) {
              setState(() {
                availableExercises.add(newExercise);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Se guardó el ejercicio"),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _openExerciseDataDialog(Map<String, dynamic> exercise, int index) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return ExerciseDataDialog(
          exercise: exercise,
          onDataUpdated: (updatedData) {
            setState(() {
              selectedExercises[index] = updatedData;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("¡Porcentaje mejorado: 10%!"),
                duration: Duration(seconds: 5),
              ),
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
        title: Text("Editar Título"),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(labelText: "Título"),
          onSubmitted: (newTitle) {
            setState(() {
              trainingTitle = newTitle;
            });
            Navigator.of(context).pop();
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("Cancelar"),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                trainingTitle = controller.text;
              });
              Navigator.of(context).pop();
            },
            child: Text("Guardar"),
          ),
        ],
      ),
    );
  }

  void _removeExercise(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("¿Quieres quitar el ejercicio del entrenamiento?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("No"),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                selectedExercises.removeAt(index);
              });
              Navigator.of(context).pop();
            },
            child: Text("Sí"),
          ),
        ],
      ),
    );
  }

  void _confirmFinishTraining() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Terminar Entrenamiento"),
        content: Text("¿Terminar entrenamiento?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("No"),
          ),
          TextButton(
            onPressed: () {
              // Aquí guardarías el entrenamiento en la BD
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text("Sí"),
          ),
        ],
      ),
    );
  }

  void _confirmSaveTemplate() async {
    final nameController = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Guardar como nueva plantilla"),
        content: TextField(
          controller: nameController,
          decoration: InputDecoration(labelText: "Nombre de la plantilla"),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancelar"),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                Navigator.pop(context, nameController.text.trim());
              }
            },
            child: Text("Guardar"),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      // Aquí debes guardar la plantilla (en base de datos, archivo, etc.)
      // Por ejemplo, si usas un método externo: await saveTemplate(result, selectedExercises);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Plantilla '$result' guardada")),
      );
      // ¡NO hagas Navigator.pop(context, true); aquí!
    }
  }

  void _deleteTraining(int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Confirmar borrado"),
        content: Text("¿Seguro que quieres borrar este entrenamiento?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Cancelar"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text("Borrar", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      setState(() {
        selectedExercises.removeAt(index);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Entrenamiento borrado")),
      );
      // Si tienes el entrenamiento en la base de datos, aquí lo eliminas:
      // await DatabaseHelper.instance.deleteWorkout(workoutId);
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
              bool exit = await _onWillPop();
              if (exit) Navigator.pop(context);
            },
          ),
          actions: [
            TextButton(
              onPressed: () => _confirmCancelTraining(),
              child: Text("cancelar entrenamiento", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Título editable
              Row(
                children: [
                  Expanded(
                    child: Text(
                      trainingTitle,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: _editTrainingTitle,
                  )
                ],
              ),
              SizedBox(height: 10),
              // Botones principales
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _openExerciseOverlay,
                    child: Text("Añadir ejercicio"),
                  ),
                  ElevatedButton(
                    onPressed: _confirmFinishTraining,
                    child: Text("Terminar entrenamiento"),
                  ),
                ],
              ),
              SizedBox(height: 10),
              // Lista de ejercicios agregados
              Expanded(
                child: ListView.builder(
                  itemCount: selectedExercises.length,
                  itemBuilder: (context, index) {
                    final exercise = selectedExercises[index];
                    return Dismissible(
                      key: UniqueKey(),
                      direction: DismissDirection.startToEnd,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.only(left: 16),
                        child: Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (direction) {
                        setState(() {
                          selectedExercises.removeAt(index);
                        });
                      },
                      child: ListTile(
                        title: Text(exercise['name']),
                        subtitle: Text(
                          'Series: ${exercise['series'] ?? "-"} | Peso: ${exercise['weight']} ${exercise['weightUnit']} | Reps: ${exercise['reps'] is List ? (exercise['reps'] as List).join(", ") : "-"}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () => _openExerciseDataDialog(exercise, index),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              color: Colors.red,
                              onPressed: () => _deleteTraining(index),
                            ),
                          ],
                        ),
                        onLongPress: () => _openExerciseDataDialog(exercise, index),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 10),
              // Botón para guardar como plantilla
              ElevatedButton(
                onPressed: _confirmSaveTemplate,
                child: Text("Agregar como nueva plantilla"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmCancelTraining() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Cancelar Entrenamiento"),
        content: Text("¿Seguro? Se perderán los datos agregados."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("No"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text("Sí"),
          ),
        ],
      ),
    );
  }
}

/// Widget para el overlay de selección de ejercicios
class ExerciseOverlay extends StatefulWidget {
  final List<Map<String, dynamic>> availableExercises;
  final Function(Map<String, dynamic>) onExerciseSelected;
  final Function(Map<String, dynamic>) onNewExercise;

  ExerciseOverlay({required this.availableExercises, required this.onExerciseSelected, required this.onNewExercise});

  @override
  _ExerciseOverlayState createState() => _ExerciseOverlayState();
}

class _ExerciseOverlayState extends State<ExerciseOverlay> {
  String searchQuery = '';
  String filterCategory = '';

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredExercises = widget.availableExercises.where((exercise) {
      bool matchesSearch = exercise['name'].toLowerCase().contains(searchQuery.toLowerCase());
      bool matchesCategory = filterCategory.isEmpty || exercise['category'] == filterCategory;
      return matchesSearch && matchesCategory;
    }).toList();
    filteredExercises.sort((a, b) => a['name'].compareTo(b['name']));

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // Barra superior con búsqueda y botón cerrar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(labelText: "Buscar ejercicio"),
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                ),
              ),
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              )
            ],
          ),
          // Filtro por categoría (simplificado)
          Row(
            children: [
              Text("Filtrar por categoría: "),
              DropdownButton<String>(
                value: filterCategory.isEmpty ? null : filterCategory,
                hint: Text("Seleccionar"),
                items: <String>['Pecho', 'Pierna', 'Espalda', 'Brazos', 'Cardio']
                    .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    filterCategory = value ?? '';
                  });
                },
              ),
            ],
          ),
          SizedBox(height: 10),
          // Lista de ejercicios disponibles con imagen pequeña
          Expanded(
            child: ListView.builder(
              itemCount: filteredExercises.length,
              itemBuilder: (context, index) {
                final exercise = filteredExercises[index];
                return ListTile(
                  leading: (exercise['image'] != null && (exercise['image'] as String).isNotEmpty)
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      exercise['image'],
                      width: 32,
                      height: 32,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.fitness_center, color: Colors.grey, size: 20),
                      ),
                    ),
                  )
                      : Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.fitness_center, color: Colors.grey, size: 20),
                  ),
                  title: Text(exercise['name']),
                  onTap: () {
                    widget.onExerciseSelected(exercise);
                  },
                );
              },
            ),
          ),
          // Botón para agregar nuevo ejercicio (abre pantalla flotante "Nuevo Ejercicio")
          ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => NewExerciseDialog(
                  onExerciseCreated: (newExercise) {
                    widget.onNewExercise(newExercise);
                    Navigator.pop(context); // Cierra el dialog "Nuevo Ejercicio"
                  },
                ),
              );
            },
            child: Text('+ Agregar ejercicio'),
          ),
        ],
      ),
    );
  }
}

/// Diálogo para crear un nuevo ejercicio
class NewExerciseDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onExerciseCreated;

  NewExerciseDialog({required this.onExerciseCreated});

  @override
  _NewExerciseDialogState createState() => _NewExerciseDialogState();
}

class _NewExerciseDialogState extends State<NewExerciseDialog> {
  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  String selectedCategory = '';
  String? imagePath; // Simula la ruta de la imagen

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Cabecera con botón "X"
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Nuevo Ejercicio", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  )
                ],
              ),
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: "Nombre del ejercicio"),
              ),
              DropdownButtonFormField<String>(
                value: selectedCategory.isEmpty ? null : selectedCategory,
                decoration: InputDecoration(labelText: "Categoría"),
                items: <String>['Pecho', 'Pierna', 'Espalda', 'Brazos', 'Cardio']
                    .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value ?? '';
                  });
                },
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: "Descripción (opcional)"),
              ),
              SizedBox(height: 10),
              // Botón simulado para seleccionar imagen
              ElevatedButton(
                onPressed: () {
                  // Aquí integrarías el image_picker para seleccionar imagen
                  setState(() {
                    imagePath = 'assets/placeholder.png';
                  });
                },
                child: Text("Seleccionar imagen"),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("Cancelar"),
                  ),
                  TextButton(
                    onPressed: () {
                      if (nameController.text.isNotEmpty && selectedCategory.isNotEmpty) {
                        Map<String, dynamic> newExercise = {
                          'name': nameController.text,
                          'image': imagePath,
                          'category': selectedCategory,
                          'description': descriptionController.text,
                        };
                        widget.onExerciseCreated(newExercise);
                      }
                    },
                    child: Text("Confirmar"),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

/// Diálogo para editar datos de un ejercicio con 3 pestañas
class ExerciseDataDialog extends StatefulWidget {
  final Map<String, dynamic> exercise;
  final Function(Map<String, dynamic>) onDataUpdated;

  ExerciseDataDialog({required this.exercise, required this.onDataUpdated});

  @override
  _ExerciseDataDialogState createState() => _ExerciseDataDialogState();
}

class _ExerciseDataDialogState extends State<ExerciseDataDialog> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  TextEditingController seriesController = TextEditingController();
  TextEditingController weightController = TextEditingController();
  TextEditingController notesController = TextEditingController();

  // Controladores para cuadros de repeticiones y sus advertencias
  List<TextEditingController> repControllers = [];
  List<String> repWarnings = [];
  int seriesCount = 0;
  String seriesWarning = ''; // Advertencia para series

  // Unidad de peso
  String weightUnit = 'kg';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    seriesController.text = widget.exercise['series']?.toString() ?? '';
    weightController.text = widget.exercise['weight']?.toString() ?? '';
    notesController.text = widget.exercise['notes'] ?? '';
    weightUnit = widget.exercise['weightUnit'] ?? 'kg';

    // Cargar repeticiones previas si existen
    if (widget.exercise['reps'] is List && (widget.exercise['reps'] as List).isNotEmpty) {
      repControllers = (widget.exercise['reps'] as List)
          .map((e) => TextEditingController(text: e.toString()))
          .toList();
      repWarnings = List.filled(repControllers.length, '');
      seriesCount = repControllers.length;
    } else {
      seriesCount = int.tryParse(seriesController.text) ?? 0;
      _initRepControllers();
    }
  }

  void _initRepControllers() {
    repControllers = [];
    repWarnings = [];
    if (seriesCount > 4) {
      seriesWarning = "Se recomienda menos de 4 series para no sobrentrenar";
      seriesCount = 4; // Limitar a 4 series
    } else {
      seriesWarning = "";
    }
    for (int i = 0; i < seriesCount; i++) {
      repControllers.add(TextEditingController());
      repWarnings.add('');
    }
    setState(() {});
  }

  // Función de validación al presionar "Aceptar"
  void _validateAndConfirm() {
    // Reiniciar advertencias
    for (int i = 0; i < repWarnings.length; i++) {
      repWarnings[i] = '';
    }
    // Validar cada cuadro de repeticiones



    // Mostrar las advertencias durante 5 segundos y luego borrarlas
    Timer(Duration(seconds: 5), () {
      setState(() {
        for (int i = 0; i < repWarnings.length; i++) {
          repWarnings[i] = '';
        }
        seriesWarning = '';
      });
    });

    // Recopilar los datos y enviarlos
    List<String> reps = repControllers.map((c) => c.text).toList();
    Map<String, dynamic> updatedData = {
      'name': widget.exercise['name'],
      'series': seriesController.text,
      'weight': weightController.text,
      'weightUnit': weightUnit,
      'reps': reps,
      'notes': notesController.text,
    };
    widget.onDataUpdated(updatedData);
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _tabController.dispose();
    seriesController.dispose();
    weightController.dispose();
    notesController.dispose();
    repControllers.forEach((c) => c.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.1),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.8,
        child: Column(
          children: [
            // Cabecera con pestañas y botón "X"
            Stack(
              children: [
                TabBar(
                  controller: _tabController,
                  tabs: [
                    Tab(text: 'Datos'),
                    Tab(text: 'Registros'),
                    Tab(text: 'Descripción'),
                  ],
                ),
                Positioned(
                  right: 0,
                  child: IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                )
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Pestaña Datos
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Campo de series y advertencia de series
                          TextField(
                            controller: seriesController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(labelText: 'Series'),
                            onChanged: (value) {
                              int count = int.tryParse(value) ?? 0;
                              if (count != seriesCount) {
                                seriesCount = count;
                                _initRepControllers();
                              }
                            },
                          ),
                          if (seriesWarning.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0, top: 2),
                              child: Text(
                                seriesWarning,
                                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                              ),
                            ),
                          // Campo de peso con dropdown
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: weightController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(labelText: 'Peso'),
                                ),
                              ),
                              SizedBox(width: 8),
                              DropdownButton<String>(
                                value: weightUnit,
                                items: <String>['kg', 'lb']
                                    .map((unit) => DropdownMenuItem(value: unit, child: Text(unit)))
                                    .toList(),
                                onChanged: (value) {
                                  setState(() {
                                    weightUnit = value ?? 'kg';
                                  });
                                },
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          // Cuadros para repeticiones y sus advertencias individuales
                          Text('Repeticiones por serie:'),
                          Column(
                            children: List.generate(repControllers.length, (index) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextField(
                                    controller: repControllers[index],
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(labelText: 'Serie ${index + 1}'),
                                    onChanged: (value) {
                                      int? reps = int.tryParse(value);
                                      setState(() {
                                        if (reps != null) {
                                          if (reps < 6) {
                                            repWarnings[index] = 'Se recomienda bajar el peso para un mejor entrenamiento';
                                          } else if (reps > 12) {
                                            repWarnings[index] = "Te recomendamos subir el peso";
                                          } else {
                                            repWarnings[index] = "";
                                          }
                                        } else {
                                          repWarnings[index] = "";
                                        }
                                      });
                                    },
                                  ),
                                  if (repWarnings[index].isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8.0, top: 2),
                                      child: Text(
                                        repWarnings[index],
                                        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                ],
                              );
                            }),
                          ),
                          SizedBox(height: 10),
                          // Campo de notas
                          TextField(
                            controller: notesController,
                            decoration: InputDecoration(labelText: 'Notas'),
                          ),
                          SizedBox(height: 20),
                          // Mostrar último registro (si existe)
                          Text('Último registro: ...'),
                          SizedBox(height: 20),
                          Center(
                            child: ElevatedButton(
                              onPressed: _validateAndConfirm,
                              child: Text('Aceptar'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Pestaña Registros
                  Center(child: Text('Registros de entrenamiento')),
                  // Pestaña Descripción
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        widget.exercise.containsKey('image')
                            ? Image.asset(widget.exercise['image'], height: 100)
                            : Container(height: 100, color: Colors.grey),
                        SizedBox(height: 10),
                        Text('Descripción del ejercicio: ...'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
