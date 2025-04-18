import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'api_service.dart';

class RegistrarDisponibilidadPage extends StatefulWidget {
  final String correo;

  const RegistrarDisponibilidadPage({super.key, required this.correo});

  @override
  _RegistrarDisponibilidadPageState createState() => _RegistrarDisponibilidadPageState();
}

class _RegistrarDisponibilidadPageState extends State<RegistrarDisponibilidadPage> {
  final TextEditingController _fechaController = TextEditingController();
  final TextEditingController _horaInicioController = TextEditingController();
  final TextEditingController _horaFinController = TextEditingController();
  final TextEditingController _consultorioController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedHoraInicio;
  TimeOfDay? _selectedHoraFin;
  bool _isLoading = false;
  String? _errorMessage;
  List<dynamic> _disponibilidades = [];
  final ApiService _apiService = ApiService();
  bool _isEditing = false;
  Map<String, dynamic>? _editingDisponibilidad;

  @override
  void initState() {
    super.initState();
    _cargarDisponibilidades();
  }

  Future<void> _cargarDisponibilidades() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final disponibilidades = await _apiService.getDisponibilidades(widget.correo);
      setState(() {
        _disponibilidades = disponibilidades;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar disponibilidades: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _seleccionarFecha() async {
    DateTime? fechaSeleccionada = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.red.shade500,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
    if (fechaSeleccionada != null) {
      setState(() {
        _selectedDate = fechaSeleccionada;
        _fechaController.text = DateFormat('yyyy-MM-dd').format(fechaSeleccionada);
      });
    }
  }

  Future<void> _seleccionarHora(TextEditingController controller, bool isHoraInicio) async {
    TimeOfDay? horaSeleccionada = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.red.shade500,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
    if (horaSeleccionada != null) {
      setState(() {
        if (isHoraInicio) {
          _selectedHoraInicio = horaSeleccionada;
          _horaInicioController.text = horaSeleccionada.format(context);
        } else {
          _selectedHoraFin = horaSeleccionada;
          _horaFinController.text = horaSeleccionada.format(context);
        }
      });
    }
  }

  Future<void> _registrarDisponibilidad() async {
    if (_fechaController.text.isEmpty ||
        _horaInicioController.text.isEmpty ||
        _horaFinController.text.isEmpty ||
        _consultorioController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Por favor, completa todos los campos.';
      });
      return;
    }

    if (_selectedHoraInicio != null && _selectedHoraFin != null) {
      final now = DateTime.now();
      final inicio = DateTime(now.year, now.month, now.day, _selectedHoraInicio!.hour, _selectedHoraInicio!.minute);
      final fin = DateTime(now.year, now.month, now.day, _selectedHoraFin!.hour, _selectedHoraFin!.minute);
      if (fin.isBefore(inicio) || fin.isAtSameMomentAs(inicio)) {
        setState(() {
          _errorMessage = 'La hora de fin debe ser posterior a la hora de inicio.';
        });
        return;
      }
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final horario = '${_horaInicioController.text} - ${_horaFinController.text}';
      Map<String, dynamic> response;
      if (_isEditing && _editingDisponibilidad != null) {
        response = await _apiService.actualizarDisponibilidad({
          'correo': widget.correo,
          'diaAntiguo': _editingDisponibilidad!['dia'],
          'horarioAntiguo': _editingDisponibilidad!['horario'],
          'diaNuevo': _fechaController.text,
          'horarioNuevo': horario,
          'consultorio': _consultorioController.text,
        });
      } else {
        response = await _apiService.registrarDisponibilidad({
          'correo': widget.correo,
          'dia': _fechaController.text,
          'horario': horario,
          'consultorio': _consultorioController.text,
        });
      }

      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? 'Disponibilidad actualizada con éxito' : 'Disponibilidad registrada con éxito'),
            backgroundColor: Colors.red.shade500,
          ),
        );
        await _cargarDisponibilidades();
        _cancelarEdicion();
      } else {
        throw Exception('No se pudo ${_isEditing ? 'actualizar' : 'registrar'} la disponibilidad: ${response['error'] ?? 'Error desconocido'}');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _eliminarDisponibilidad(Map<String, dynamic> disponibilidad) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text('Confirmar Eliminación', style: TextStyle(color: Colors.red)),
        content: Text('¿Estás seguro de que deseas eliminar la disponibilidad del día ${disponibilidad['dia']} (${disponibilidad['horario']})?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
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
      final response = await _apiService.eliminarDisponibilidad({
        'correo': widget.correo,
        'dia': disponibilidad['dia'],
        'horario': disponibilidad['horario'],
      });

      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Disponibilidad eliminada con éxito'),
            backgroundColor: Colors.red.shade500,
          ),
        );
        await _cargarDisponibilidades();
      } else {
        throw Exception('No se pudo eliminar la disponibilidad: ${response['error'] ?? 'Error desconocido'}');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _editarDisponibilidad(Map<String, dynamic> disponibilidad) {
    setState(() {
      _isEditing = true;
      _editingDisponibilidad = disponibilidad;
      _fechaController.text = disponibilidad['dia'];
      final horario = disponibilidad['horario'].split(' - ');
      _horaInicioController.text = horario[0];
      _horaFinController.text = horario[1];
      _consultorioController.text = disponibilidad['consultorio'] ?? '';
      _selectedDate = DateFormat('yyyy-MM-dd').parse(disponibilidad['dia']);
      _selectedHoraInicio = _parseTimeOfDay(horario[0]);
      _selectedHoraFin = _parseTimeOfDay(horario[1]);
    });
  }

  void _cancelarEdicion() {
    setState(() {
      _isEditing = false;
      _editingDisponibilidad = null;
      _fechaController.clear();
      _horaInicioController.clear();
      _horaFinController.clear();
      _consultorioController.clear();
      _selectedDate = null;
      _selectedHoraInicio = null;
      _selectedHoraFin = null;
    });
  }

  TimeOfDay _parseTimeOfDay(String time) {
    final format = DateFormat.jm();
    final dateTime = format.parse(time);
    return TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isEditing ? 'Editar Disponibilidad' : 'Nueva Disponibilidad',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.red.shade500,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          controller: _fechaController,
                          label: 'Fecha',
                          hint: 'Selecciona una fecha',
                          icon: Icons.calendar_today,
                          onTap: _seleccionarFecha,
                        ),
                        const SizedBox(height: 15),
                        _buildTextField(
                          controller: _horaInicioController,
                          label: 'Hora Inicio',
                          hint: 'Selecciona una hora',
                          icon: Icons.access_time,
                          onTap: () => _seleccionarHora(_horaInicioController, true),
                        ),
                        const SizedBox(height: 15),
                        _buildTextField(
                          controller: _horaFinController,
                          label: 'Hora Fin',
                          hint: 'Selecciona una hora',
                          icon: Icons.access_time,
                          onTap: () => _seleccionarHora(_horaFinController, false),
                        ),
                        const SizedBox(height: 15),
                        _buildTextField(
                          controller: _consultorioController,
                          label: 'Consultorio',
                          hint: 'Ej: Consultorio 301, Edificio Salud',
                          icon: Icons.location_on,
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _registrarDisponibilidad,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red.shade500,
                                  padding: const EdgeInsets.symmetric(vertical: 15),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  elevation: 5,
                                ),
                                child: _isLoading
                                    ? const CircularProgressIndicator(color: Colors.white)
                                    : Text(
                                        _isEditing ? 'Actualizar' : 'Registrar',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),
                            if (_isEditing) ...[
                              const SizedBox(width: 10),
                              ElevatedButton(
                                onPressed: _cancelarEdicion,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey.shade400,
                                  padding: const EdgeInsets.symmetric(vertical: 15),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  elevation: 5,
                                ),
                                child: const Text(
                                  'Cancelar',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    'Disponibilidades Registradas',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _isLoading
                      ? Center(child: CircularProgressIndicator(color: Colors.red.shade500))
                      : _disponibilidades.isEmpty
                          ? Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Text(
                                  'No hay disponibilidades registradas.',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _disponibilidades.length,
                              itemBuilder: (context, index) {
                                final disp = _disponibilidades[index];
                                return AnimatedOpacity(
                                  opacity: 1.0,
                                  duration: const Duration(milliseconds: 300),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(vertical: 8),
                                    child: Card(
                                      elevation: 3,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                        side: BorderSide(color: Colors.red.shade500),
                                      ),
                                      child: ListTile(
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                        leading: Icon(
                                          Icons.event_available,
                                          color: Colors.red.shade500,
                                          size: 30,
                                        ),
                                        title: Text(
                                          'Día: ${disp['dia']}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Colors.red.shade500,
                                          ),
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(height: 5),
                                            Text(
                                              'Horario: ${disp['horario']}',
                                              style: const TextStyle(fontSize: 14, color: Colors.black87),
                                            ),
                                            if (disp['consultorio'] != null)
                                              Text(
                                                'Consultorio: ${disp['consultorio']}',
                                                style: const TextStyle(fontSize: 14, color: Colors.black87),
                                              ),
                                          ],
                                        ),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: Icon(Icons.edit, color: Colors.red.shade500),
                                              onPressed: () => _editarDisponibilidad(disp),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete, color: Colors.red),
                                              onPressed: () => _eliminarDisponibilidad(disp),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.red.shade600, Colors.red.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.white,
              child: CircleAvatar(
                radius: 18,
                backgroundColor: Colors.red.shade500,
                child: const Icon(
                  Icons.medical_services,
                  size: 24,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Registrar Disponibilidad',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: onTap != null,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.red.shade500),
        hintText: hint,
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.red.shade500, width: 2),
        ),
        suffixIcon: Icon(
          icon,
          color: Colors.red.shade500,
        ),
      ),
      style: const TextStyle(color: Colors.black87),
    );
  }

  @override
  void dispose() {
    _fechaController.dispose();
    _horaInicioController.dispose();
    _horaFinController.dispose();
    _consultorioController.dispose();
    super.dispose();
  }
}