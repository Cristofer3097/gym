// lib/calendar_screen.dart

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart'; // Para formatear fechas
import 'database/database_helper.dart'; // Ajusta la ruta si es diferente

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;


  // Mapa para almacenar los días que tienen entrenamientos.
  // Usamos DateTime normalizado a UTC para las claves para evitar problemas con zonas horarias en table_calendar.
  Map<DateTime, List<dynamic>> _events = {};
  List<Map<String, dynamic>> _selectedDayTrainings = [];

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay; // Selecciona el día actual al inicio
    _loadDatesWithTrainings(); // Carga los marcadores para el calendario
    _loadTrainingsForSelectedDay(_focusedDay); // Carga los entrenamientos para el día actual
  }

  Future<void> _loadDatesWithTrainings() async {
    final db = DatabaseHelper.instance;
    final datesWithTrainings = await db.getDatesWithTrainings();
    final Map<DateTime, List<dynamic>> eventsMap = {};
    for (var date in datesWithTrainings) {
      // Normaliza la fecha a UTC para usarla como clave en el mapa de eventos
      final utcDate = DateTime.utc(date.year, date.month, date.day);
      eventsMap[utcDate] = ['Entrenamiento']; // Añade un evento marcador
    }
    if (mounted) {
      setState(() {
        _events = eventsMap;
      });
    }
  }

  Future<void> _loadTrainingsForSelectedDay(DateTime day) async {
    final db = DatabaseHelper.instance;
    // La consulta a la DB se hace con la fecha local (getTrainingsForDate la formatea)
    final trainings = await db.getTrainingsForDate(day);
    if (mounted) {
      setState(() {
        _selectedDayTrainings = trainings;
      });
    }
  }

  // Función que table_calendar usa para obtener los eventos de un día
  List<dynamic> _getEventsForDay(DateTime day) {
    final utcDay = DateTime.utc(day.year, day.month, day.day); // Normalizar a UTC
    return _events[utcDay] ?? [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        // Opcional: si quieres que el calendario vuelva a formato mes al seleccionar un día.
        // _calendarFormat = CalendarFormat.month;
      });
      _loadTrainingsForSelectedDay(selectedDay);
    }
  }
  Future<bool?> _showConfirmDeleteLogDialog(BuildContext parentContext, Map<String, dynamic> logEntry) async {
    return showDialog<bool>(
      context: parentContext, // Usar el contexto que abrió este diálogo
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text("Confirmar Borrado"),
          content: Text(
              "¿Seguro que quieres borrar este registro de '${logEntry['exercise_name']}'? Esta acción no se puede deshacer."),
          actionsAlignment: MainAxisAlignment.spaceAround,
          actions: <Widget>[
            TextButton(
              child: Text("Cancelar"),
              onPressed: () => Navigator.of(dialogContext).pop(false), // No confirmado
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, foregroundColor: Colors.white),
              child: Text("Sí, Borrar"),
              onPressed: () async {
                final db = DatabaseHelper.instance;
                await db.deleteExerciseLog(logEntry['id'] as int);
                Navigator.of(dialogContext).pop(true); // Borrado confirmado
              },
            ),
          ],
        );
      },
    );
  }
  void _showLogItemActionsDialog(BuildContext screenContext, Map<String, dynamic> logEntry) {
    final String exerciseName = logEntry['exercise_name']?.toString() ?? 'este registro';

    showDialog(
      context: screenContext, // Contexto de la pantalla CalendarScreen
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text("Acciones para '$exerciseName'",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          content: Text("¿Qué deseas hacer con este registro de entrenamiento?"),
          actionsAlignment: MainAxisAlignment.spaceAround, // O MainAxisAlignment.end
          actions: <Widget>[
            TextButton(
              child: const Text('Cerrar'),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Cierra este diálogo de acciones
              },
            ),
            ElevatedButton.icon( // Cambiado a ElevatedButton.icon para más énfasis
              icon: Icon(Icons.delete_outline),
              label: Text('Borrar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                Navigator.of(dialogContext).pop(); // Cierra el diálogo de acciones primero

                // Muestra el diálogo de confirmación de borrado
                final bool? deletionConfirmed = await _showConfirmDeleteLogDialog(screenContext, logEntry);

                if (deletionConfirmed == true) {
                  // Si se confirmó el borrado, actualiza la UI
                  if (mounted && _selectedDay != null) {
                    await _loadTrainingsForSelectedDay(_selectedDay!);
                    await _loadDatesWithTrainings(); // Para actualizar los marcadores del calendario
                    ScaffoldMessenger.of(screenContext).showSnackBar(
                      SnackBar(content: Text("Registro de '$exerciseName' eliminado.")),
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
  void _showLogItemDetailsDialog(BuildContext screenContext, Map<String, dynamic> logEntry) {
    String formattedLogDateTime = "Fecha/Hora desconocida";
    if (logEntry['dateTime'] != null) {
      try {
        DateTime dt = DateTime.parse(logEntry['dateTime'] as String);
        formattedLogDateTime = DateFormat.yMMMMEEEEd().add_Hms().format(dt); // Formato más detallado con hora
      } catch (_) {
        // Mantener el valor por defecto si hay error de parseo
      }
    }
    showDialog(
      context: screenContext, // Contexto de la pantalla CalendarScreen
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(logEntry['exercise_name']?.toString() ?? 'Detalle del Registro',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text("Realizado: $formattedLogDateTime"),
                Divider(height: 16),
                Text("Series: ${logEntry['series'] ?? '-'}"),
                Text("Repeticiones: ${logEntry['reps'] ?? '-'}"),
                Text("Peso: ${logEntry['weight'] ?? '-'} ${logEntry['weightUnit'] ?? ''}"),
                if (logEntry['notes'] != null && (logEntry['notes'] as String).isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text("Notas: ${logEntry['notes']}"),
                  ),
              ],
            ),
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: <Widget>[
            TextButton(
              child: const Text('Cerrar'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton.icon(
              icon: Icon(Icons.delete_outline, color: Colors.red.shade700),
              label: Text('Borrar Reg.', style: TextStyle(color: Colors.red.shade700)),
              onPressed: () async {
                Navigator.of(dialogContext).pop(); // Cierra el diálogo de detalles primero

                // Muestra el diálogo de confirmación de borrado
                final bool? deletionConfirmed = await _showConfirmDeleteLogDialog(screenContext, logEntry);

                if (deletionConfirmed == true) {
                  // Si se confirmó el borrado, actualiza la UI
                  if (mounted && _selectedDay != null) {
                    await _loadTrainingsForSelectedDay(_selectedDay!);
                    await _loadDatesWithTrainings(); // Para actualizar los marcadores del calendario
                    ScaffoldMessenger.of(screenContext).showSnackBar(
                      SnackBar(content: Text("Registro de '${logEntry['exercise_name']}' eliminado.")),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendario de Entrenamientos'),
      ),
      body: Column(
        children: [
          TableCalendar(
            // locale: 'es_ES', // Comentado según tu preferencia
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
                    right: 1,
                    bottom: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).primaryColor.withOpacity(0.8),
                      ),
                      width: 6.0,
                      height: 6.0,
                    ),
                  );
                }
                return null;
              },
            ),
            headerStyle: HeaderStyle(
              formatButtonVisible: true,
              titleCentered: true,
              formatButtonShowsNext: false,
            ),
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
              ),
            ),
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
          ),
          const Divider(height: 1, thickness: 1),
          const SizedBox(height: 12.0),
          if (_selectedDay != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                // Título en negritas para la sección de entrenamientos
                "Entrenamientos del ${DateFormat.yMMMMd().format(_selectedDay!)}:", // Formato sin locale específico
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold, // <--- ASEGURAR NEGRITAS
                ),
              ),
            ),
          const SizedBox(height: 8.0),
          Expanded(
            child: _selectedDayTrainings.isEmpty
                ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                    _selectedDay != null
                        ? "No hay entrenamientos registrados para este día."
                        : "Selecciona un día para ver los detalles.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              itemCount: _selectedDayTrainings.length,
              itemBuilder: (context, index) { // 'index' aquí es el índice del ejercicio en la lista del día
                final log = _selectedDayTrainings[index];
                final String exerciseName = log['exercise_name']?.toString() ?? 'Ejercicio Desconocido';
                final String series = log['series']?.toString() ?? '-';
                final String reps = log['reps']?.toString() ?? '-';
                final String weight = log['weight']?.toString() ?? '-';
                final String weightUnit = log['weightUnit']?.toString() ?? '';
                final String notes = log['notes']?.toString() ?? '';

                return Card(
                  elevation: 2.5, // Puedes ajustar la elevación
                  margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 8.0),
                  clipBehavior: Clip.antiAlias, // Para que el InkWell respete los bordes redondeados del Card
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)), // Bordes redondeados para el Card
                  child: InkWell(
                    onTap: () {
                      // Llama al diálogo de acciones que ya tienes (Borrar/Cerrar)
                      _showLogItemActionsDialog(context, log);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "${index + 1}. $exerciseName", // <--- EJERCICIO ENUMERADO Y NOMBRE COMO TÍTULO
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16, // Ajusta el tamaño según tu preferencia
                            ),
                          ),
                          SizedBox(height: 8.0), // Espacio entre el título del ejercicio y sus detalles
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0), // Una ligera indentación para los detalles
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Series: $series"), // Ya no es necesario el "1. " aquí si el ejercicio está numerado
                                SizedBox(height: 2.0),
                                Text("Repeticiones: $reps"),
                                SizedBox(height: 2.0),
                                Text("Peso: $weight $weightUnit"),
                                if (notes.isNotEmpty) ...[
                                  SizedBox(height: 2.0),
                                  Text("Notas: $notes"),
                                ],
                              ],
                            ),
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