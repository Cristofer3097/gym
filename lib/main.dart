import 'package:flutter/material.dart';
import 'training_screen.dart';
import 'dart:io';
import 'calendar.dart';
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
  }

  void _loadTemplates() async {
    final db = DatabaseHelper.instance;
    final tpls = await db.getAllTemplates(); //
    if (mounted) {
      setState(() {
        templates = tpls;
      });
    }
  }


  // NUEVO MÉTODO para mostrar el diálogo de selección de plantilla a borrar
  void _showSelectTemplateToDeleteDialog() async {
    if (templates.isEmpty) {
      if (mounted) { // Verificar mounted antes de usar context
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No hay plantillas para borrar.")),
        );
      }
      return;
    }

    final bool? deletionOccurred = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return SelectTemplateToDeleteDialog(
          templates: templates, // Pasa la lista actual de plantillas
        );
      },
    );

    if (deletionOccurred == true && mounted) {
      _loadTemplates(); // Recarga la lista de plantillas en HomeScreen
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Plantilla eliminada con éxito.')),
      );
    }
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
            Image.asset('assets/logo.png', height: 100),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TrainingScreen()),
                );
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
                  ? const Center(child: Text("No hay plantillas. ¡Crea una o guarda un entrenamiento!"))
                  : GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 2.5,
                  ),
                  itemCount: templates.length,
                  itemBuilder: (context, index) {
                    final template = templates[index];
                    final templateName = template['name']?.toString() ?? 'Plantilla sin nombre';
                    final templateId = template['id'];

                    if (templateId == null) {
                      return const Card(child: Center(child: Text("Error: Plantilla sin ID")));
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
                          await db.deleteTemplate(templateId); //
                          _loadTemplates();
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
                          // Cargar los ejercicios ANTES de mostrar el diálogo
                          final exercises = await db.getTemplateExercises(templateId); //

                          // Mostrar el nuevo diálogo de vista previa y esperar su resultado
                          final dynamic dialogResult = await showDialog(
                            context: context,
                            builder: (BuildContext dialogContext) {
                              return TemplatePreviewDialog(
                                templateId: templateId,
                                templateName: templateName,
                                exercises: exercises, // Pasar los ejercicios cargados
                              );
                            },
                          );

                          // Si el diálogo se cerró y devolvió 'true' (porque TrainingScreen devolvió 'true'),
                          // entonces recargamos las plantillas.
                          if (dialogResult == true && mounted) {
                            _loadTemplates();
                          }
                        },
                        child: Text(templateName, textAlign: TextAlign.center),
                      ),
                    );
                  }),
            ),

            const SizedBox(height: 10),
            ElevatedButton.icon(
              icon: const Icon(Icons.calendar_month),
              label: const Text('Calendario'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CalendarScreen()),
                );
              },

            )
          ],
        ),
      ),
    );
  }
}

class TemplatePreviewDialog extends StatelessWidget {
  final int templateId;
  final String templateName;
  final List<Map<String, dynamic>> exercises;

  const TemplatePreviewDialog({
    Key? key,
    required this.templateId,
    required this.templateName,
    required this.exercises,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Estilo base común para los botones con borde negro y esquinas redondeadas
    final ButtonStyle baseButtonStyle = ElevatedButton.styleFrom(
      side: const BorderSide(color: Colors.black, width: 1.0),
      elevation: 1, // Menor elevación para un look más plano si se desea
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), // Ajusta el padding
    );

    // Estilo para el botón "Regresar" e "Iniciar Entrenamiento" (fondo blanco)
    final ButtonStyle whiteBackgroundButtonStyle = baseButtonStyle.copyWith(
      backgroundColor: MaterialStateProperty.all(Colors.white),
    );

    return AlertDialog(
      title: Text(
        templateName,
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Container(
        width: double.maxFinite,
        child: exercises.isEmpty
            ? const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 20.0),
            child: Text("Esta plantilla no tiene ejercicios."),
          ),
        )
            : ListView.builder(
          shrinkWrap: true,
          itemCount: exercises.length,
          itemBuilder: (context, index) {
            final exercise = exercises[index];
            final exerciseName = exercise['name']?.toString() ?? 'Ejercicio sin nombre';
            return ListTile(
              title: Text('${index + 1}. $exerciseName'),
            );
          },
        ),
      ),
      actionsAlignment: MainAxisAlignment.spaceBetween, // Distribuye el espacio entre los grupos de acciones
      actionsPadding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
      actions: <Widget>[
        // Botón Regresar
        ElevatedButton(

          child: const Text('Regresar'),
          onPressed: () {
            Navigator.of(context).pop(); // Simplemente cierra este diálogo
          },
        ),
        // Botón Borrar (Nuevo)
        ElevatedButton(
          style: baseButtonStyle.copyWith(
            backgroundColor: MaterialStateProperty.all(Colors.red.shade600),
            foregroundColor: MaterialStateProperty.all(Colors.white),
          ),
          child: const Text('Borrar'),
          onPressed: () async {
            // Muestra el diálogo de confirmación para borrar
            final bool? confirmedDelete = await showDialog<bool>(
              context: context, // Usa el contexto del TemplatePreviewDialog
              builder: (BuildContext confirmDialogContext) {
                return ConfirmDeleteDialog( // Reutiliza el ConfirmDeleteDialog
                  templateId: templateId,   // Pasa el ID de la plantilla actual
                  templateName: templateName, // Pasa el nombre de la plantilla actual
                );
              },
            );

            if (confirmedDelete == true) {
              // Si la eliminación fue confirmada y realizada,
              // cierra TemplatePreviewDialog y devuelve 'true' a HomeScreen.
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop(true);
              }
            }
            // Si confirmedDelete es false o null, no hacemos nada aquí,
            // TemplatePreviewDialog permanece abierto.
          },
        ),
        // Botón Iniciar Entrenamiento
        ElevatedButton(

          child: const Text('Iniciar'), // Texto más corto para mejor ajuste si es necesario
          onPressed: () async {
            final dynamic trainingScreenResult = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TrainingScreen(
                  initialExercises: exercises,
                  templateName: templateName,
                ),
              ),
            );
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop(trainingScreenResult);
            }
          },
        ),
      ],
    );
  }
}

class SelectTemplateToDeleteDialog extends StatelessWidget {
  final List<Map<String, dynamic>> templates;

  const SelectTemplateToDeleteDialog({
    Key? key,
    required this.templates,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Selecciona Plantilla a Borrar"),
      content: Container(
        width: double.maxFinite, // Para que el diálogo tenga un ancho razonable
        child: templates.isEmpty
            ? const Center(child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Text("No hay plantillas para borrar."),
        ))
            : ListView.builder(
          shrinkWrap: true,
          itemCount: templates.length,
          itemBuilder: (BuildContext context, int index) {
            final template = templates[index];
            final String templateName = template['name']?.toString() ?? 'Plantilla Desconocida';
            final int templateId = template['id'];

            return ListTile(
              title: Text(templateName),
              onTap: () async {
                // Muestra el diálogo de confirmación para esta plantilla específica
                final bool? confirmedDelete = await showDialog<bool>(
                  context: context, // Usa el contexto del diálogo actual para mostrar otro encima
                  builder: (BuildContext confirmDialogContext) {
                    return ConfirmDeleteDialog(
                      templateId: templateId,
                      templateName: templateName,
                    );
                  },
                );

                if (confirmedDelete == true) {
                  // Si la eliminación fue confirmada y realizada,
                  // cierra este diálogo de selección (SelectTemplateToDeleteDialog)
                  // y devuelve 'true' para que HomeScreen sepa que debe recargar.
                  Navigator.of(context).pop(true);
                }
                // Si confirmedDelete es false o null (el usuario canceló la eliminación),
                // no hacemos nada aquí; SelectTemplateToDeleteDialog permanece abierto.
                // El usuario puede elegir otra plantilla o presionar "Cancelar" abajo.
              },
            );
          },
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancelar'),
          onPressed: () {
            // El usuario canceló el proceso de selección de plantilla a borrar
            Navigator.of(context).pop(false); // Devuelve false o null
          },
        ),
      ],
    );
  }
}

class ConfirmDeleteDialog extends StatelessWidget {
  final int templateId;
  final String templateName;

  const ConfirmDeleteDialog({
    Key? key,
    required this.templateId,
    required this.templateName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Confirmar Borrado"),
      content: Text("¿Seguro que quieres borrar la plantilla \"$templateName\" permanentemente? Esta acción no se puede deshacer."),
      actionsAlignment: MainAxisAlignment.spaceAround, // Para espaciar los botones
      actions: <Widget>[
        TextButton(
          child: const Text("Cancelar"),
          onPressed: () {
            Navigator.of(context).pop(false); // Borrado no confirmado
          },
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red, // Color distintivo para la acción de borrar
            foregroundColor: Colors.white,
          ),
          child: const Text("Sí, Borrar"),
          onPressed: () async {
            final db = DatabaseHelper.instance;
            await db.deleteTemplate(templateId);
            Navigator.of(context).pop(true); // Borrado confirmado y realizado
          },
        ),
      ],
    );
  }
}