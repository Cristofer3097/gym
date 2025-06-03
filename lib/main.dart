import 'package:flutter/material.dart';
import 'training_screen.dart'; //
import 'calendar.dart'; //
import '../database/database_helper.dart'; //
import 'package:intl/date_symbol_data_local.dart';
import 'extras.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // Importa esto
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../utils/localization_utils.dart';



// Define los colores principales basados en la imagen y tus preferencias
const Color amarilloPrincipal = Color(0xFFFFC107); // Un tono de amarillo vibrante (Ámbar)
const Color fondoOscuro = Color(0xFF121212); // Un gris muy oscuro, casi negro para el fondo
const Color colorAppBar = Color(0xFF000000); // Negro para la AppBar
const Color negroBoton = Color(0xFF121212); //Colors.black; // Fondo de los botones principales
const Color grisContenedor = Color(0xFF1E1E1E); // Un gris oscuro para tarjetas y diálogos
const Color grisTextField = Color(0xFF2C2C2C); // Un gris para el fondo de campos de texto

Future<void> main() async { // Hacerla async y retornar Future<void>
  WidgetsFlutterBinding.ensureInitialized(); // Asegurar que los bindings estén inicializados
  await initializeDateFormatting('es_ES', null); // Inicializar datos para español
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  static void setLocale(BuildContext context, Locale newLocale) {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.setLocale(newLocale);
  }
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('en');

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        onGenerateTitle: (BuildContext context) {
        return AppLocalizations.of(context)?.appTitle ?? 'Gym Diary';
        },
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: fondoOscuro,
        primaryColor: amarilloPrincipal, // Color primario para acentos
        colorScheme: ColorScheme.dark(
          primary: amarilloPrincipal,
          secondary: amarilloPrincipal, // Usado para elementos como el color del cursor, etc.
          surface: grisContenedor, // Color de superficie para Cards, Dialogs
          onPrimary: negroBoton, // Color del texto/iconos sobre el color primario
          onSecondary: negroBoton,
          onSurface: Colors.white, // Color del texto/iconos sobre el color de superficie
          background: fondoOscuro,
          onBackground: Colors.white,
          error: Colors.redAccent,
          onError: Colors.white,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: colorAppBar,
          foregroundColor: Colors.white, // Color para el título e iconos en la AppBar
          elevation: 0, // La AppBar en la imagen no tiene sombra
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold, // El título "Post" en la imagen se ve en negrita
          ),
          iconTheme: IconThemeData(color: Colors.white), // Para iconos como la flecha de retroceso
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: negroBoton, // Fondo negro para los botones
            foregroundColor: amarilloPrincipal, // Texto e iconos en amarillo
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14), // Padding generoso
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0), // Esquinas redondeadas
              side: BorderSide(color: amarilloPrincipal, width: 1.5), // Borde amarillo
            ),
            textStyle: TextStyle(
              fontWeight: FontWeight.w500, // Un peso de fuente medio para los botones
              fontSize: 15,
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: amarilloPrincipal, // Texto amarillo para TextButtons
            textStyle: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        cardTheme: CardTheme(
          color: grisContenedor, // Color de fondo para las Cards
          elevation: 1, // Una elevación sutil
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          margin: EdgeInsets.symmetric(vertical: 6.0, horizontal: 4.0),
        ),
        dialogTheme: DialogTheme(
          backgroundColor: grisContenedor, // Fondo oscuro para diálogos
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.bold),
          contentTextStyle: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 15),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: grisTextField, // Fondo oscuro para campos de texto
          hintStyle: TextStyle(color: Colors.grey[500]),
          labelStyle: TextStyle(color: amarilloPrincipal.withOpacity(0.9)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide.none, // Sin borde por defecto cuando está relleno
          ),
          enabledBorder: OutlineInputBorder( // Borde cuando el campo no está enfocado pero está habilitado
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Colors.grey[700]!, width: 0.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: amarilloPrincipal, width: 1.5), // Borde amarillo cuando está enfocado
          ),
          prefixIconColor: Colors.grey[400], // Color para iconos de prefijo
        ),
        listTileTheme: ListTileThemeData(
          iconColor: amarilloPrincipal, // Color de iconos en ListTiles
          textColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
          // tileColor: grisContenedor.withOpacity(0.5), // Opcional: si quieres un fondo para todos los ListTiles
        ),
        dividerTheme: DividerThemeData(
          color: Colors.grey[700],
          thickness: 0.5,
        ),
      ),


      // ...
      localizationsDelegates: AppLocalizations.localizationsDelegates, // Usar el generado
      supportedLocales: AppLocalizations.supportedLocales,       // Usar el generado
      locale: _locale, // El locale actual del estado
      home: HomeScreen(onLocaleChange: setLocale),
        // pásale la función

    );
  }
}

class HomeScreen extends StatefulWidget {
  final void Function(Locale) onLocaleChange;
  const HomeScreen({Key? key, required this.onLocaleChange}) : super(key: key);


  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> templates = []; //

  @override
  void initState() {
    super.initState();
    _loadTemplates(); //
  }

  void _loadTemplates() async {
    final db = DatabaseHelper.instance; //
    final tpls = await db.getAllTemplates(); //
    if (mounted) {
      setState(() {
        templates = tpls; //
      });
    }
  }
  void _showLanguageSelectionDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(l10n.changeLanguageDialogTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                title: Text(l10n.languageEnglish),
                onTap: () {
                  widget.onLocaleChange(const Locale('en'));
                  Navigator.of(dialogContext).pop();
                },
              ),
              ListTile(
                title: Text(l10n.languageSpanish),
                onTap: () {
                  widget.onLocaleChange(const Locale('es'));
                  Navigator.of(dialogContext).pop();
                },
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text(l10n.close),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // _showSelectTemplateToDeleteDialog no necesita cambios lógicos aquí.

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        //title: const Text('Gym Diary'), // Título de la AppBar
        title: Text(l10n.appTitle),
        centerTitle: true, //
        // Puedes añadir un menú lateral (Drawer) o acciones si lo deseas:
        // leading: IconButton(icon: Icon(Icons.menu), onPressed: () { /* Lógica del menú */ }),
        // actions: [
        //   IconButton(icon: Icon(Icons.search), onPressed: () { /* Lógica de búsqueda */ }),
        //   IconButton(icon: Icon(Icons.more_vert), onPressed: () { /* Lógica de más opciones */ }),
        // ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), //
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch, // Para que los botones ocupen el ancho
          children: [
            // Considera si la imagen del logo es necesaria o cómo se ve en tema oscuro
            // Image.asset('assets/logo.png', height: 80, color: amarilloPrincipal), //
            // const SizedBox(height: 24),

            ElevatedButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TrainingScreen()), //
                );
                if (result == true) {
                  _loadTemplates(); //
                }
              },
              // El estilo del botón se toma del tema global.
              // Si necesitas un tamaño específico, puedes usar style.merge.
              // style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
              //   minimumSize: MaterialStateProperty.all(const Size(double.infinity, 50)),
              // ),
              //child: const Text('Iniciar Entrenamiento'), //
              child: Text(l10n.startTraining),
            ),
            const SizedBox(height: 24),
      Expanded( // Para que esta sección tome el espacio disponible
        child: Container(
          padding: const EdgeInsets.all(12.0), // Padding interno para el contenido
          decoration: BoxDecoration(
            color: grisContenedor, // Color de fondo gris
            borderRadius: BorderRadius.circular(10.0), // Bordes redondeados como las cards
          ),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
            Text(
              l10n.templates,
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: Colors.white.withOpacity(0.9),
              ), //
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: templates.isEmpty
                  ? Center(child: Text(l10n.noTemplatesSaved, //
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[500], fontSize: 15),
                  ))
                  : GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, //
                    crossAxisSpacing: 12, //
                    mainAxisSpacing: 12, //
                    childAspectRatio: 2.2, // Ajusta según el padding del botón
                  ),
                  itemCount: templates.length, //
                  itemBuilder: (context, index) {
                    final template = templates[index]; //
                    final String displayTemplateName = getLocalizedTemplateName(context, template); // NUEVO
                    final templateId = template['id']; //

                    if (templateId == null) {
                      return Card(
                          child: Center(
                              child: Text("Error: Plantilla sin ID", //
                                  style: TextStyle(color: Theme.of(context).colorScheme.error))));
                    }

                    return GestureDetector( //
                      onLongPress: () async { //
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('¿Borrar plantilla?'), //
                            content: Text(
                                '¿Quieres eliminar la plantilla "$displayTemplateName"? Esta acción no se puede deshacer.'), //
                            actions: [
                              TextButton( //
                                onPressed: () => Navigator.pop(ctx, false), //
                                child: const Text('Cancelar'), //
                              ),
                              TextButton( //
                                onPressed: () => Navigator.pop(ctx, true), //
                                child: Text('Borrar', //
                                    style: TextStyle(color: Theme.of(context).colorScheme.error)),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) { //
                          final db = DatabaseHelper.instance; //
                          await db.deleteTemplate(templateId); //
                          _loadTemplates(); //
                          if (mounted) { //
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Plantilla "$displayTemplateName" eliminada.'), //
                                backgroundColor: Theme.of(context).cardTheme.color,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            );
                          }
                        }
                      },
                      child: ElevatedButton(
                        onPressed: () async { //
                          final db = DatabaseHelper.instance; //
                          final exercises = await db.getTemplateExercises(templateId); //

                          final dynamic dialogResult = await showDialog(
                            context: context,
                            builder: (BuildContext dialogContext) {
                              return TemplatePreviewDialog( //
                                templateId: templateId, //
                                templateName: displayTemplateName, //
                                exercises: exercises, //
                              );
                            },
                          );
                          if (dialogResult == true && mounted) { //
                            _loadTemplates(); //
                          }
                        },
                        child: Text(displayTemplateName, textAlign: TextAlign.center),
                      ),
                    );
                  }),
            ),
    ],
    ),
        ),
      ),
            const SizedBox(height: 20), // Un poco más de espacio antes de la fila de botones

            // --- FILA PARA BOTONES DE CALENDARIO Y CONSEJOS ---
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.calendar_month),
                    label: Text(l10n.calendar),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CalendarScreen()),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12), // Espacio entre los botones
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.lightbulb_outline_rounded), // Icono para consejos
                    label:
                    Text(l10n.tipsAndExtras), // Etiqueta más corta para mejor ajuste

                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const TipsExtrasScreen()), // Navegar a la nueva pantalla
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 40, // Ajusta la altura según tu diseño
              child: Stack(
                children: [
                  // Texto de versión centrado
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      l10n.version("1.0.1"),
                      style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
                    ),
                  ),
                  // Botón de idioma a la derecha
                  Align(
                    alignment: Alignment.centerRight,
                    child: OutlinedButton(
                      onPressed: () => _showLanguageSelectionDialog(context),
                      style: OutlinedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(10),
                        side: BorderSide(color: theme.primaryColor.withOpacity(0.7)),
                        minimumSize: const Size(40, 40),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.localeName.toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          color: theme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
      // --- FIN DE NUEVA FILA ---

      const SizedBox(height: 10), // Espacio antes del crédito del creador
          ],
        ),
      ),
    );
  }
}

class TemplatePreviewDialog extends StatelessWidget {
  final int templateId; //
  final String templateName; //
  final List<Map<String, dynamic>> exercises; //

  const TemplatePreviewDialog({
    Key? key, //
    required this.templateId, //
    required this.templateName, //
    required this.exercises, //
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog( // Se aplica DialogTheme
      title: Text(templateName, textAlign: TextAlign.center), // Se aplica DialogTheme.titleTextStyle
      content: Container( // Se aplica DialogTheme.contentTextStyle para el texto dentro
        width: double.maxFinite, //
        child: exercises.isEmpty
            ? Center( //
            child: Padding( //
              padding: EdgeInsets.symmetric(vertical: 20.0), //
              child: Text("Esta plantilla no tiene ejercicios."), //
            ))
            : ListView.builder( //
          shrinkWrap: true, //
          itemCount: exercises.length, //
          itemBuilder: (context, index) {
            final exercise = exercises[index]; //
            final exerciseName = getLocalizedExerciseName(context, exercise);
            return ListTile( // Se aplica ListTileTheme
              title: Text('${index + 1}. $exerciseName'), //
              contentPadding: EdgeInsets.symmetric(vertical: 2, horizontal: 8),
            );
          },
        ),
      ),
      actionsAlignment: MainAxisAlignment.spaceBetween, //
      actionsPadding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0), //
      actions: <Widget>[
        ElevatedButton( // Usa TextButtonTheme
          child: const Text('Regresar'), //
          onPressed: () { //
            Navigator.of(context).pop(); //
          },
        ),
        ElevatedButton( // Botón de Borrar
          style: Theme.of(context).elevatedButtonTheme.style?.copyWith( // Hereda del tema pero cambia colores
            backgroundColor: MaterialStateProperty.all(Colors.red.shade700),
            foregroundColor: MaterialStateProperty.all(Colors.white),
            side: MaterialStateProperty.all(BorderSide(color: amarilloPrincipal, width: 1.5)), // Mantiene borde amarillo
          ),
          child: const Text('Borrar'), //
          onPressed: () async { //
            final bool? confirmedDelete = await showDialog<bool>(
              context: context,
              builder: (BuildContext confirmDialogContext) {
                return ConfirmDeleteDialog( //
                  templateId: templateId, //
                  templateName: templateName, //
                );
              },
            );
            if (confirmedDelete == true) { //
              if (Navigator.of(context).canPop()) { //
                Navigator.of(context).pop(true); //
              }
            }
          },
        ),
        ElevatedButton( // Botón Iniciar, usa ElevatedButtonTheme global
          child: const Text('Iniciar'), //
          onPressed: () async { //
            final dynamic trainingScreenResult = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TrainingScreen( //
                  initialExercises: exercises, //
                  templateName: templateName, //
                ),
              ),
            );
            if (Navigator.of(context).canPop()) { //
              Navigator.of(context).pop(trainingScreenResult); //
            }
          },
        ),
      ],
    );
  }
}

class SelectTemplateToDeleteDialog extends StatelessWidget {
  final List<Map<String, dynamic>> templates; //

  const SelectTemplateToDeleteDialog({
    Key? key, //
    required this.templates, //
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog( // Aplicará DialogTheme
      title: const Text("Selecciona Plantilla a Borrar"), //
      content: Container( //
        width: double.maxFinite, //
        child: templates.isEmpty
            ? Center( //
            child: Padding( //
              padding: EdgeInsets.all(8.0), //
              child: Text("No hay plantillas para borrar."), //
            ))
            : ListView.builder( //
          shrinkWrap: true, //
          itemCount: templates.length, //
          itemBuilder: (BuildContext context, int index) {
            final template = templates[index]; //
            final String templateName = template['name']?.toString() ?? 'Plantilla'; //
            final int templateId = template['id']; //

            return ListTile( // Aplicará ListTileTheme
              title: Text(templateName), //
              onTap: () async { //
                final bool? confirmedDelete = await showDialog<bool>(
                  context: context,
                  builder: (BuildContext confirmDialogContext) {
                    return ConfirmDeleteDialog( //
                      templateId: templateId, //
                      templateName: templateName, //
                    );
                  },
                );
                if (confirmedDelete == true) { //
                  Navigator.of(context).pop(true); //
                }
              },
            );
          },
        ),
      ),
      actions: <Widget>[
        TextButton( // Aplicará TextButtonTheme
          child: const Text('Cancelar'), //
          onPressed: () { //
            Navigator.of(context).pop(false); //
          },
        ),
      ],
    );
  }
}

class ConfirmDeleteDialog extends StatelessWidget {
  final int templateId; //
  final String templateName; //

  const ConfirmDeleteDialog({
    Key? key, //
    required this.templateId, //
    required this.templateName, //
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog( // Aplicará DialogTheme
      title: const Text("Confirmar Borrado"), //
      content: Text("¿Seguro que quieres borrar la plantilla \"$templateName\" permanentemente? Esta acción no se puede deshacer."), //
      actionsAlignment: MainAxisAlignment.spaceAround, //
      actions: <Widget>[
        TextButton( // Aplicará TextButtonTheme
          child: const Text("Cancelar"), //
          onPressed: () { //
            Navigator.of(context).pop(false); //
          },
        ),
        ElevatedButton( // Botón de confirmación de borrado
          style: Theme.of(context).elevatedButtonTheme.style?.copyWith( // Hereda del tema pero cambia colores
            backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.error), // Usa el color de error del tema
            foregroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.onError),
            side: MaterialStateProperty.all(BorderSide(color: amarilloPrincipal, width: 1.5)), // Mantiene borde amarillo
          ),
          child: const Text("Sí, Borrar"), //
          onPressed: () async { //
            final db = DatabaseHelper.instance; //
            await db.deleteTemplate(templateId); //
            Navigator.of(context).pop(true); //
          },
        ),
      ],
    );
  }
}