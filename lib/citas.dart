import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:saludgest_app/api_service.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';

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
  List<dynamic> _historialCitas = [];
  bool _isLoading = true;
  String? _errorMessage;
  String? _nombreUsuario;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('es_ES', null);
    _fetchCitas();
    _fetchHistorialCitas();
    _fetchNombreUsuario();
  }

  Future<void> _fetchCitas() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final citas = await _apiService.getCitas(widget.correo, widget.tipoUsuario);
      setState(() {
        _citas = citas.where((cita) => cita['estado'] == 'Programada').toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchHistorialCitas() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final citas = await _apiService.getCitas(widget.correo, widget.tipoUsuario);
      setState(() {
        _historialCitas = citas.where((cita) => cita['estado'] == 'Realizada' || cita['estado'] == 'Cancelada').toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchNombreUsuario() async {
    try {
      final String endpoint = widget.tipoUsuario == 'paciente'
          ? 'http://10.0.2.2:3000/api/pacientes/obtener-por-correo?correo=${widget.correo}'
          : 'http://10.0.2.2:3000/api/medicos/obtener-por-correo?correo=${widget.correo}';
      final response = await http.get(Uri.parse(endpoint));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          setState(() {
            _nombreUsuario = data['persona']['nombre_completo'] ?? 'Usuario';
          });
        }
      }
    } catch (e) {
      print('Error al cargar el nombre del usuario: $e');
      setState(() {
        _nombreUsuario = 'Usuario';
      });
    }
  }

  Future<void> _cancelarCita(String citaId) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text('Confirmar Cancelación', style: TextStyle(color: Colors.red)),
        content: const Text('¿Estás seguro de que deseas cancelar esta cita?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sí', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _apiService.cancelarCita(citaId, widget.correo, widget.tipoUsuario);
      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Cita cancelada con éxito'),
            backgroundColor: Colors.red.shade500,
          ),
        );
        await _fetchCitas();
        await _fetchHistorialCitas();
      } else {
        throw Exception(response['error'] ?? 'Error al cancelar la cita');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cancelar la cita: $_errorMessage'),
          backgroundColor: Colors.red.shade500,
        ),
      );
    } finally {
      setState(() {
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

  Map<String, Color> _getColorsForRole() {
    switch (widget.tipoUsuario) {
      case 'medico':
        return {
          'header': Colors.red.shade600,
          'headerGradient': Colors.red.shade400,
          'accent': Colors.red.shade500,
          'calendarToday': Colors.red.shade100,
          'calendarSelected': Colors.red.shade400,
          'calendarMarker': Colors.red.shade300,
          'iconBackground': Colors.red.shade500,
        };
      case 'paciente':
        return {
          'header': Colors.blue.shade600,
          'headerGradient': Colors.blue.shade400,
          'accent': Colors.blue.shade500,
          'calendarToday': Colors.blue.shade100,
          'calendarSelected': Colors.blue.shade400,
          'calendarMarker': Colors.blue.shade300,
          'iconBackground': Colors.blue.shade500,
        };
      default:
        return {
          'header': Colors.teal.shade600,
          'headerGradient': Colors.teal.shade400,
          'accent': Colors.teal.shade500,
          'calendarToday': Colors.teal.shade100,
          'calendarSelected': Colors.teal.shade400,
          'calendarMarker': Colors.teal.shade300,
          'iconBackground': Colors.teal.shade500,
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = _getColorsForRole();
    final events = _getEventsForDay();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: colors['header'],
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            _buildHeader(colors),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCalendarSection(colors, events),
                      const SizedBox(height: 20),
                      _buildCitasSection(colors),
                      const SizedBox(height: 20),
                      _buildCitasLogSection(colors),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Map<String, Color> colors) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        bottom: 8,
        left: 16,
        right: 16,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colors['header']!, colors['headerGradient']!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black, size: 28),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: 12),
          CircleAvatar(
            radius: 35,
            backgroundColor: Colors.white,
            child: CircleAvatar(
              radius: 32,
              backgroundColor: colors['iconBackground'],
              child: Icon(
                widget.tipoUsuario == 'medico' ? Icons.medical_services : Icons.person,
                size: 44,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        _nombreUsuario ?? '',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        "${widget.correo} • Rol: ${widget.tipoUsuario == 'paciente' ? 'Paciente' : 'Médico'}",
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarSection(Map<String, Color> colors, Map<DateTime, List<dynamic>> events) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                color: colors['accent'],
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                "Calendario",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colors['accent'],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : TableCalendar(
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
                    todayDecoration: BoxDecoration(
                      color: colors['calendarToday'],
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: colors['calendarSelected'],
                      shape: BoxShape.circle,
                    ),
                    markerDecoration: BoxDecoration(
                      color: colors['calendarMarker'],
                      shape: BoxShape.circle,
                    ),
                    outsideTextStyle: TextStyle(color: Colors.grey.shade400),
                    defaultTextStyle: const TextStyle(color: Colors.black87),
                    weekendTextStyle: TextStyle(color: Colors.grey.shade600),
                    disabledTextStyle: TextStyle(color: Colors.grey.shade300),
                    holidayTextStyle: const TextStyle(color: Colors.black87),
                  ),
                  daysOfWeekStyle: DaysOfWeekStyle(
                    weekdayStyle: TextStyle(color: Colors.grey.shade700),
                    weekendStyle: TextStyle(color: Colors.grey.shade600),
                  ),
                  headerStyle: HeaderStyle(
                    titleTextStyle: const TextStyle(color: Colors.black87, fontSize: 18),
                    formatButtonTextStyle: const TextStyle(color: Colors.white),
                    formatButtonDecoration: BoxDecoration(
                      color: colors['accent'],
                      borderRadius: const BorderRadius.all(Radius.circular(12)),
                    ),
                    leftChevronIcon: Icon(Icons.chevron_left, color: colors['accent']),
                    rightChevronIcon: Icon(Icons.chevron_right, color: colors['accent']),
                  ),
                  eventLoader: (day) {
                    final eventDate = DateTime(day.year, day.month, day.day);
                    return events[eventDate] ?? [];
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildCitasSection(Map<String, Color> colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.event_note,
              color: colors['accent'],
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              "Mis Citas",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colors['accent'],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _errorMessage != null
            ? Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'Error al cargar las citas: $_errorMessage',
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            : _citas.isEmpty
                ? Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        "No hay citas programadas",
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _citas.length,
                    itemBuilder: (context, index) {
                      final cita = _citas[index];
                      String fecha;
                      try {
                        fecha = DateFormat('dd/MM/yyyy').format(
                          DateFormat('yyyy-MM-dd').parse(cita['fecha']),
                        );
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
                      final estado = cita['estado'] ?? 'Programada';
                      final consultorio = cita['consultorio'] ?? 'No especificado';
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: colors['accent']!),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: colors['accent']!.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.event,
                                color: colors['accent'],
                                size: 30,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Cita el $fecha",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Horario: ${cita['hora_inicio'] ?? 'N/A'} - ${cita['hora_fin'] ?? 'N/A'}",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.tipoUsuario == 'paciente'
                                        ? "Médico: $nombre"
                                        : "Paciente: $nombre",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Consultorio: $consultorio",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Estado: $estado",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.cancel, color: Colors.red.shade500),
                              onPressed: () => _cancelarCita(cita['_id']),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
      ],
    );
  }

  Widget _buildCitasLogSection(Map<String, Color> colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.history,
              color: colors['accent'],
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              "Historial de Citas",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colors['accent'],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _errorMessage != null
            ? Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'Error al cargar el historial de citas: $_errorMessage',
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            : _historialCitas.isEmpty
                ? Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        "No hay historial de citas",
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _historialCitas.length,
                    itemBuilder: (context, index) {
                      final cita = _historialCitas[index];
                      String fecha;
                      try {
                        fecha = DateFormat('dd/MM/yyyy').format(
                          DateFormat('yyyy-MM-dd').parse(cita['fecha']),
                        );
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
                      final estado = cita['estado'] ?? 'Desconocido';
                      final consultorio = cita['consultorio'] ?? 'No especificado';
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: colors['accent']!),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: colors['accent']!.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.history,
                                color: colors['accent'],
                                size: 30,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Cita el $fecha",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Horario: ${cita['hora_inicio'] ?? 'N/A'} - ${cita['hora_fin'] ?? 'N/A'}",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.tipoUsuario == 'paciente'
                                        ? "Médico: $nombre"
                                        : "Paciente: $nombre",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Consultorio: $consultorio",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Estado: $estado",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: estado == 'Cancelada' ? Colors.red : Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (cita['cancelado_por'] != null)
                                    Text(
                                      "Cancelado por: ${cita['cancelado_por']}",
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black54,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
      ],
    );
  }
}