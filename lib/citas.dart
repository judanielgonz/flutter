import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:saludgest_app/api_service.dart';
import 'package:intl/intl.dart';

class CitasPage extends StatefulWidget {
  final String correo;
  final String tipoUsuario;

  const CitasPage({super.key, required this.correo, required this.tipoUsuario});

  @override
  _CitasPageState createState() => _CitasPageState();
}

class _CitasPageState extends State<CitasPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<dynamic> _citas = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('es_ES', null);
    _fetchCitas();
  }

  Future<void> _fetchCitas() async {
    try {
      final apiService = ApiService();
      final citas = await apiService.getCitas(widget.correo, widget.tipoUsuario);
      setState(() {
        _citas = citas;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Map<DateTime, List<dynamic>> _getEventsForDay() {
    final events = <DateTime, List<dynamic>>{};
    for (var cita in _citas) {
      try {
        final date = DateFormat('yyyy-MM-dd').parse(cita['fecha']);
        final eventDate = DateTime(date.year, date.month, date.day);
        events[eventDate] ??= [];
        events[eventDate]!.add(cita);
      } catch (e) {
        print('Error al parsear la fecha de la cita: $e');
      }
    }
    return events;
  }

  @override
  Widget build(BuildContext context) {
    final events = _getEventsForDay();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tipoUsuario == 'paciente' ? "Mis Citas" : "Citas Agendadas"),
        backgroundColor: Colors.teal,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text('Error al cargar las citas: $_errorMessage', style: const TextStyle(color: Colors.red)))
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TableCalendar(
                        locale: 'es_ES',
                        firstDay: DateTime.utc(2020, 1, 1),
                        lastDay: DateTime.utc(2030, 12, 31),
                        focusedDay: _focusedDay,
                        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                        calendarFormat: _calendarFormat,
                        onDaySelected: (selectedDay, focusedDay) {
                          setState(() {
                            _selectedDay = selectedDay;
                            _focusedDay = focusedDay;
                          });
                        },
                        onFormatChanged: (format) {
                          setState(() {
                            _calendarFormat = format;
                          });
                        },
                        calendarStyle: CalendarStyle(
                          todayDecoration: BoxDecoration(color: Colors.teal.shade200, shape: BoxShape.circle),
                          selectedDecoration: BoxDecoration(color: Colors.teal, shape: BoxShape.circle),
                          markerDecoration: const BoxDecoration(
                            color: Colors.redAccent,
                            shape: BoxShape.circle,
                          ),
                        ),
                        eventLoader: (day) {
                          final eventDate = DateTime(day.year, day.month, day.day);
                          return events[eventDate] ?? [];
                        },
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: _citas.isEmpty
                            ? const Center(child: Text("No hay citas programadas", style: TextStyle(fontSize: 16)))
                            : ListView.builder(
                                itemCount: _citas.length,
                                itemBuilder: (context, index) {
                                  final cita = _citas[index];
                                  String fecha;
                                  try {
                                    fecha = DateFormat('dd/MM/yyyy')
                                        .format(DateFormat('yyyy-MM-dd').parse(cita['fecha']));
                                  } catch (e) {
                                    fecha = 'Fecha no válida';
                                  }
                                  final nombre = widget.tipoUsuario == 'paciente'
                                      ? (cita['persona_medico_id'] != null
                                          ? cita['persona_medico_id']['nombre_completo']
                                          : 'Médico desconocido')
                                      : (cita['persona_paciente_id'] != null
                                          ? cita['persona_paciente_id']['nombre_completo']
                                          : 'Paciente desconocido');
                                  return Card(
                                    margin: const EdgeInsets.symmetric(vertical: 8),
                                    child: ListTile(
                                      leading: const Icon(Icons.event, color: Colors.teal),
                                      title: Text(
                                        "Cita el $fecha de ${cita['hora_inicio'] ?? 'N/A'} a ${cita['hora_fin'] ?? 'N/A'}",
                                      ),
                                      subtitle: Text(widget.tipoUsuario == 'paciente' ? "Médico: $nombre" : "Paciente: $nombre"),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
    );
  }
}