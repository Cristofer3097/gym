// En calendar_screen.dart

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<dynamic>> _events = {};
  List<Map<String, dynamic>> _selectedDaySessions = []; // Almacenará las sesiones del día



  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadDatesWithTrainingSessions();
    _loadSessionsForSelectedDay(_focusedDay);
  }

  Future<void> _loadDatesWithTrainingSessions() async {
    final db = DatabaseHelper.instance;
    final dates = await db.getDatesWithTrainingSessions(); // Usa el método actualizado
    final Map<DateTime, List<dynamic>> eventsMap = {};
    for (var date in dates) {
      final utcDate = DateTime.utc(date.year, date.month, date.day);
      eventsMap[utcDate] = ['Sesión']; // Marcador
    }
    if (mounted) {
      setState(() {
        _events = eventsMap;
      });
    }
  }

  Future<void> _loadSessionsForSelectedDay(DateTime day) async {
    final db = DatabaseHelper.instance;
    final sessions = await db.getTrainingSessionsForDate(day); // Obtiene las sesiones
    if (mounted) {
      setState(() {
        _selectedDaySessions = sessions;
      });
    }
  }

  List<dynamic> _getEventsForDay(DateTime day) {
    final utcDay = DateTime.utc(day.year, day.month, day.day);
    return _events[utcDay] ?? [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });
      _loadSessionsForSelectedDay(selectedDay);
    }
  }

  // Diálogo para confirmar borrado de una SESIÓN COMPLETA
  Future<bool?> _showConfirmDeleteSessionDialog(BuildContext parentContext, Map<String, dynamic> session) async {
    return showDialog<bool>(
      context: parentContext,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text("Confirmar Borrado de Sesión"),
          content: Text(
              "¿Seguro que quieres borrar la sesión '${session['session_title']}' y todos sus ejercicios? Esta acción no se puede deshacer."),
          actionsAlignment: MainAxisAlignment.spaceAround,
          actions: <Widget>[
            TextButton(
              child: Text("Cancelar"),
              onPressed: () => Navigator.of(dialogContext).pop(false),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, foregroundColor: Colors.white),
              child: Text("Sí, Borrar Sesión"),
              onPressed: () async {
                final db = DatabaseHelper.instance;
                await db.deleteTrainingSessionAndLogs(session['id'] as int); // Borra la sesión y sus logs
                Navigator.of(dialogContext).pop(true);
              },
            ),
          ],
        );
      },
    );
  }


  // Diálogo de acciones para una SESIÓN COMPLETA
  void _showSessionActionsDialog(BuildContext screenContext, Map<String, dynamic> session) {
    final String sessionTitle = session['session_title']?.toString() ?? 'Entrenamiento';

    showDialog(
      context: screenContext,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text("Acciones para: '$sessionTitle'",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          // El contenido podría mostrar un resumen rápido o simplemente las acciones
          content: Text("Selecciona una acción para esta sesión de entrenamiento."),
          actionsAlignment: MainAxisAlignment.spaceAround,
          actions: <Widget>[
            TextButton(
              child: const Text('Cerrar'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            ElevatedButton.icon(
              icon: Icon(Icons.delete_forever_outlined),
              label: Text('Borrar Sesión'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                Navigator.of(dialogContext).pop(); // Cierra diálogo de acciones
                final bool? deletionConfirmed = await _showConfirmDeleteSessionDialog(screenContext, session);

                if (deletionConfirmed == true) {
                  if (mounted && _selectedDay != null) {
                    await _loadSessionsForSelectedDay(_selectedDay!);
                    await _loadDatesWithTrainingSessions(); // Actualiza marcadores del calendario
                    ScaffoldMessenger.of(screenContext).showSnackBar(
                      SnackBar(content: Text("Sesión '$sessionTitle' eliminada.")),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildExerciseTableForCalendar(Map<String, dynamic> log, BuildContext context) {
    final theme = Theme.of(context);
    final int seriesCount = int.tryParse(log['series']?.toString() ?? '0') ?? 0;
    final List<String> reps = (log['reps']?.toString() ?? '').split(',');
    final List<String> weights = (log['weight']?.toString() ?? '').split(',');
    final List<String> units = (log['weightUnit']?.toString() ?? '').split(',');
    final String logUnit = (log['weightUnit']?.toString() ?? 'lb').split(',')[0].trim(); // Tomar la primera unidad o la unidad única
    final String notes = log['notes']?.toString() ?? '';

    List<TableRow> rows = [
      TableRow(
        decoration: BoxDecoration(color: theme.colorScheme.onSurface.withOpacity(0.08)),
        children: [
          Padding(padding: const EdgeInsets.symmetric(vertical: 7.0, horizontal: 5.0), child: Text('Serie', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5), textAlign: TextAlign.center)),
          Padding(padding: const EdgeInsets.symmetric(vertical: 7.0, horizontal: 5.0), child: Text('Reps', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5), textAlign: TextAlign.center)),
          Padding(padding: const EdgeInsets.symmetric(vertical: 7.0, horizontal: 5.0), child: Text('Peso', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5), textAlign: TextAlign.center)),
        ],
      ),
    ];

    for (int i = 0; i < seriesCount; i++) {
      rows.add(TableRow(
        children: [
          Padding(padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 5.0), child: Text('${i + 1}', textAlign: TextAlign.center, style: TextStyle(fontSize: 12.5))),
          Padding(padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 5.0), child: Text(i < reps.length ? reps[i].trim() : '-', textAlign: TextAlign.center, style: TextStyle(fontSize: 12.5))),
          Padding(padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 5.0), child: Text(
              (i < weights.length ? weights[i].trim() : '-') + " " + (i < units.length ? units[i].trim() : (units.isNotEmpty ? units[0].trim() : 'lb')),
              textAlign: TextAlign.center, style: TextStyle(fontSize: 12.5)
          )),
        ],
      ));
    }
    if (seriesCount == 0) {
      rows.add(TableRow(children: [
        Padding(padding: const EdgeInsets.all(6.0), child: Text('-', textAlign: TextAlign.center, style: TextStyle(fontSize: 12.5))),
        Padding(padding: const EdgeInsets.all(6.0), child: Text('-', textAlign: TextAlign.center, style: TextStyle(fontSize: 12.5))),
        Padding(padding: const EdgeInsets.all(6.0), child: Text('-', textAlign: TextAlign.center, style: TextStyle(fontSize: 12.5))),
      ]));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Table(
          // Asegurar que todos los bordes (internos y externos) sean visibles y amarillos.
          // Cambiamos el width a 1.0 para mayor consistencia en el renderizado.
          border: TableBorder.all(color: theme.primaryColor, width: 1.0), // Borde amarillo y más grueso
          columnWidths: const {
            0: FlexColumnWidth(0.8), // Serie
            1: FlexColumnWidth(1.2), // Reps
            2: FlexColumnWidth(1.8), // Peso
          },
          children: rows,
        ),
        if (notes.isNotEmpty) ...[
          SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 4.0, right: 4.0),
            child: Text(
              "Notas: $notes",
              style: TextStyle(fontSize: 11.5, fontStyle: FontStyle.italic, color: Colors.grey.shade400),
            ),
          )
        ]
      ],
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendario de Entrenamientos'),
      ),
      body: Column(
        children: [
          TableCalendar(
            // ... (configuración del TableCalendar sin cambios respecto a la respuesta anterior) ...
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: _onDaySelected,
            eventLoader: _getEventsForDay,
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                if (events.isNotEmpty) {
                  return Positioned(
                    right: 1, bottom: 1,
                    child: Container(
                      decoration: BoxDecoration(shape: BoxShape.circle, color: Theme.of(context).primaryColor.withOpacity(0.8)),
                      width: 6.0, height: 6.0,
                    ),
                  );
                }
                return null;
              },
            ),
            headerStyle: HeaderStyle(formatButtonVisible: true, titleCentered: true, formatButtonShowsNext: false),
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(color: Theme.of(context).colorScheme.secondary.withOpacity(0.5), shape: BoxShape.circle),
              selectedDecoration: BoxDecoration(color: Theme.of(context).primaryColor, shape: BoxShape.circle),
            ),
            onFormatChanged: (format) {
              if (_calendarFormat != format) { setState(() { _calendarFormat = format; });}
            },
            onPageChanged: (focusedDay) { _focusedDay = focusedDay;},
          ),
          const Divider(height: 1, thickness: 1),
          const SizedBox(height: 12.0),
          if (_selectedDay != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                "Entrenamientos del ${DateFormat.yMMMMd().format(_selectedDay!)}:",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          const SizedBox(height: 8.0),
          Expanded(
            child: _selectedDaySessions.isEmpty
                ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                    _selectedDay != null
                        ? "No hay sesiones de entrenamiento registradas para este día."
                        : "Selecciona un día para ver las sesiones.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              itemCount: _selectedDaySessions.length,
              itemBuilder: (context, sessionIndex) {
                final session = _selectedDaySessions[sessionIndex];
                final String sessionTitle = session['session_title']?.toString() ?? 'Entrenamiento Sin Título';
                String sessionTime = "Hora desconocida";
                try { DateTime dt = DateTime.parse(session['session_dateTime']); sessionTime = DateFormat.Hm('es_ES').format(dt); } catch (_) {}

                return Card(
                  // ... card properties ...
                  child: InkWell(
                    onTap: () { _showSessionActionsDialog(context, session); },
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          // ... Row para título de sesión y hora ...
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  "${sessionIndex + 1}. $sessionTitle",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ),
                              Text(
                                sessionTime,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12.0),
                          FutureBuilder<List<Map<String, dynamic>>>(
                            future: DatabaseHelper.instance.getExerciseLogsForSession(session['id'] as int),
                            builder: (context, exerciseSnapshot) {
                              if (exerciseSnapshot.connectionState == ConnectionState.waiting) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0, left: 16.0),
                                  child: Text("Cargando ejercicios...", style: TextStyle(fontStyle: FontStyle.italic)),
                                );
                              }
                              if (exerciseSnapshot.hasError || !exerciseSnapshot.hasData || exerciseSnapshot.data!.isEmpty) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0, left: 16.0),
                                  child: Text("No hay ejercicios en esta sesión.", style: TextStyle(fontStyle: FontStyle.italic)),
                                );
                              }
                              final exercisesInSession = exerciseSnapshot.data!;
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: exercisesInSession.asMap().entries.map((entry) {
                                  int exerciseIdx = entry.key;
                                  Map<String, dynamic> log = entry.value;
                                  return Padding(
                                    padding: const EdgeInsets.only(top:10.0, bottom: 4.0),
                                    child: Column( // Columna para nombre de ejercicio y luego la tabla
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Nombre del ejercicio (como en la imagen de referencia)
                                        Padding(
                                          padding: const EdgeInsets.only(left: 8.0, bottom: 6.0), // Indentación y espacio
                                          child: Text(
                                            "${exerciseIdx + 1}. ${log['exercise_name']}",
                                            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16.5), // Tamaño consistente
                                          ),
                                        ),
                                        // Tabla de detalles del ejercicio
                                        Padding(
                                          padding: const EdgeInsets.only(left: 8.0, right: 4.0), // Indentación para la tabla
                                          child: _buildExerciseTableForCalendar(log, context),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}