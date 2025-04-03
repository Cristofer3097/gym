// Archivo: training_screen.dart

import 'package:flutter/material.dart';
import 'dart:async';

class TrainingScreen extends StatefulWidget {
  @override
  _TrainingScreenState createState() => _TrainingScreenState();
}

class _TrainingScreenState extends State<TrainingScreen> {
  String trainingTitle = "Entrenamiento de hoy";
  List<Map<String, dynamic>> selectedExercises = [];

  // Ejemplo de ejercicios disponibles; en la versión real se obtendrían desde la BD
  List<Map<String, dynamic>> availableExercises = [
    {'name': 'Press de banca', 'image': 'assets/press.png', 'category': 'Pecho'},
    {'name': 'Sentadilla', 'image': 'assets/sentadilla.png', 'category': 'Pierna'},
    {'name': 'Remo en T', 'image': 'assets/remo.png', 'category': 'Espalda'},
  ];

  void _showCancelConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Cancelar Entrenamiento"),
        content: Text("¿Seguro? Se perderán los datos agregados."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Cierra el diálogo
            },
            child: Text("No"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Cierra el diálogo
              Navigator.pop(context); // Regresa al menú principal
            },
            child: Text("Sí"),
          ),
        ],
      ),
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
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancelar"),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                trainingTitle = controller.text;
              });
              Navigator.pop(context);
            },
            child: Text("Guardar"),
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

  void _confirmSaveTemplate() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Guardar Plantilla"),
        content: Text("¿Guardar esta sesión como plantilla?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("No"),
          ),
          TextButton(
            onPressed: () {
              // Aquí guardarías la plantilla en la BD o almacenamiento local
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Plantilla guardada")),
              );
            },
            child: Text("Sí"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Entrenamiento"),
        actions: [
          IconButton(
            icon: Icon(Icons.cancel),
            onPressed: _showCancelConfirmation,
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
                        'Series: ${exercise['series'] ?? "-"} | Peso: ${exercise['weight'] ?? "-"} | Reps: ${exercise['reps'] is List ? (exercise['reps'] as List).join(", ") : "-"}',
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => _openExerciseDataDialog(exercise, index),
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
              child: Text("Agregar plantilla"),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget para el overlay de selección de ejercicios
class ExerciseOverlay extends StatefulWidget {
  final List<Map<String, dynamic>> availableExercises;
  final Function(Map<String, dynamic>) onExerciseSelected;

  ExerciseOverlay({required this.availableExercises, required this.onExerciseSelected});

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
          // Lista de ejercicios disponibles
          Expanded(
            child: ListView.builder(
              itemCount: filteredExercises.length,
              itemBuilder: (context, index) {
                final exercise = filteredExercises[index];
                return ListTile(
                  leading: exercise['image'] != null
                      ? Image.asset(exercise['image'], width: 40, height: 40)
                      : Container(width: 40, height: 40, color: Colors.grey),
                  title: Text(exercise['name']),
                  onTap: () {
                    widget.onExerciseSelected(exercise);
                  },
                );
              },
            ),
          ),
          // Botón para agregar nuevo ejercicio (simplificado)
          ElevatedButton(
            onPressed: () {
              // Aquí podrías abrir un formulario para crear un ejercicio nuevo
            },
            child: Text('+ Agregar ejercicio'),
          ),
        ],
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

  // Lista de controladores para los cuadros de repeticiones
  List<TextEditingController> repControllers = [];
  int seriesCount = 0;

  // Variables para mostrar mensajes de advertencia
  String warningMessage = '';
  Timer? warningTimer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    seriesController.text = widget.exercise['series']?.toString() ?? '';
    weightController.text = widget.exercise['weight']?.toString() ?? '';
    notesController.text = widget.exercise['notes'] ?? '';

    // Inicialmente se carga la cantidad de series si ya existe
    seriesCount = int.tryParse(seriesController.text) ?? 0;
    _initRepControllers();
  }

  void _initRepControllers() {
    repControllers = [];
    // Si seriesCount es mayor a 4, limitar a 4 y mostrar advertencia
    if (seriesCount > 4) {
      seriesCount = 4;
      _showWarning("Se recomienda menos de 4 series para no sobrentrenar");
    }
    for (int i = 0; i < seriesCount; i++) {
      repControllers.add(TextEditingController());
    }
    setState(() {});
  }

  void _showWarning(String message) {
    setState(() {
      warningMessage = message;
    });
    warningTimer?.cancel();
    warningTimer = Timer(Duration(seconds: 5), () {
      setState(() {
        warningMessage = '';
      });
    });
  }

  // Verificar repeticiones para cada cuadro
  void _checkReps() {
    for (var controller in repControllers) {
      int? reps = int.tryParse(controller.text);
      if (reps != null) {
        if (reps < 6) {
          _showWarning("Se recomienda bajar el peso para un mejor entrenamiento");
        } else if (reps > 12) {
          _showWarning("Te recomendamos subir el peso");
        }
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    seriesController.dispose();
    weightController.dispose();
    notesController.dispose();
    repControllers.forEach((c) => c.dispose());
    warningTimer?.cancel();
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
            TabBar(
              controller: _tabController,
              tabs: [
                Tab(text: 'Datos'),
                Tab(text: 'Registros'),
                Tab(text: 'Descripción'),
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
                          // Campo de series
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
                          // Campo de peso
                          TextField(
                            controller: weightController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(labelText: 'Peso (kg/lb)'),
                          ),
                          // Generar cuadros para repeticiones según series
                          SizedBox(height: 10),
                          Text('Repeticiones por serie:'),
                          Column(
                            children: List.generate(repControllers.length, (index) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: TextField(
                                  controller: repControllers[index],
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(labelText: 'Serie ${index + 1}'),
                                  onChanged: (_) => _checkReps(),
                                ),
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
                              onPressed: () {
                                _checkReps();
                                // Recopilar repeticiones de cada cuadro
                                List<String> reps = repControllers.map((c) => c.text).toList();
                                Map<String, dynamic> updatedData = {
                                  'name': widget.exercise['name'],
                                  'series': seriesController.text,
                                  'weight': weightController.text,
                                  'reps': reps,
                                  'notes': notesController.text,
                                };
                                widget.onDataUpdated(updatedData);
                                Navigator.pop(context);
                              },
                              child: Text('Aceptar'),
                            ),
                          ),
                          // Mostrar mensaje de advertencia si corresponde
                          if (warningMessage.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(
                                child: Text(
                                  warningMessage,
                                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                                ),
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
