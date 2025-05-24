import 'package:flutter/material.dart';
import 'training_screen.dart';
import '../database/database_helper.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Gym Diary App',
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> templates = [];



  @override
  void initState() {
    super.initState();
    _loadTemplates();
    // Limpia plantillas de ejemplo si existen (solo una vez)
  }


  void _loadTemplates() async {
    final db = DatabaseHelper.instance;
    final tpls = await db.getAllTemplates(); // Obtiene plantillas de SQLite
    if (mounted) {
      setState(() {
        templates = tpls;
      });
    }
  }
  void _addTemplate(String name) async {
    final db = DatabaseHelper.instance;
    await db.insertTemplate(name);
    _loadTemplates(); // Recarga la lista desde la base de datos para reflejar el cambio
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diario de Entrenamiento'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Image.asset('assets/logo.png', height: 100), // Asegúrate que 'assets/logo.png' exista en tu pubspec.yaml y en la carpeta assets
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // Al iniciar un nuevo entrenamiento, no pasamos initialExercises ni templateName
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TrainingScreen()),
                );
                // Si TrainingScreen devuelve true (ej. al guardar un entrenamiento como nueva plantilla), recargamos.
                if (result == true) {
                  _loadTemplates();
                }
              },
              child: const Text('Iniciar Entrenamiento'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            const SizedBox(height: 10),
            const Text('Plantillas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(
              child: templates.isEmpty
                  ? Center(child: Text("No hay plantillas. ¡Crea una o guarda un entrenamiento!"))
                  : GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 2.5,
                  ),
                  itemCount: templates.length,
                  itemBuilder: (context, index) {
                    final template = templates[index];
                    final templateName = template['name']?.toString() ?? 'Plantilla sin nombre';
                    final templateId = template['id'];

                    if (templateId == null) {
                      // Esto no debería ocurrir si las plantillas siempre vienen de la DB
                      return Card(child: Center(child: Text("Error: Plantilla sin ID")));
                    }

                    return GestureDetector(
                      onLongPress: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('¿Borrar plantilla?'),
                            content: Text('¿Quieres eliminar la plantilla "$templateName"? Esta acción no se puede deshacer.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text('Cancelar'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                child: const Text('Borrar', style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          final db = DatabaseHelper.instance;
                          await db.deleteTemplate(templateId);
                          _loadTemplates(); // recarga la lista
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Plantilla "$templateName" eliminada')),
                            );
                          }
                        }
                      },
                      child: ElevatedButton(
                        onPressed: () async {
                          final db = DatabaseHelper.instance;
                          final exercises = await db.getTemplateExercises(templateId);

                          // Pasa el nombre de la plantilla y sus ejercicios a TrainingScreen
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TrainingScreen(
                                initialExercises: exercises,
                                templateName: templateName, // <--- PASAR EL NOMBRE
                              ),
                            ),
                          );
                          // Si TrainingScreen devuelve true, podría significar que se guardó algo (aunque el SnackBar ya lo dice TrainingScreen)
                          if (result == true && mounted) {
                            _loadTemplates(); // Recarga las plantillas
                          }
                        },
                        child: Text(templateName, textAlign: TextAlign.center),
                      ),
                    );
                  }
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Lógica para pedir nombre de plantilla y luego llamar a _addTemplate
                final nameController = TextEditingController();
                showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text("Nueva Plantilla"),
                      content: TextField(
                        controller: nameController,
                        decoration: InputDecoration(hintText: "Nombre de la plantilla"),
                        autofocus: true,
                      ),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text("Cancelar")),
                        TextButton(
                            onPressed: () {
                              if (nameController.text.trim().isNotEmpty) {
                                _addTemplate(nameController.text.trim());
                                Navigator.pop(context);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("El nombre no puede estar vacío.")),
                                );
                              }
                            },
                            child: Text("Crear"))
                      ],
                    ));
              },
              child: const Text('+ Plantilla'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Futura funcionalidad de calendario
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Funcionalidad de Calendario próximamente.")),
                );
              },
              child: const Text('Calendario'),
            ),
          ],
        ),
      ),
    );
  }
}