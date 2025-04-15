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
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF00695C),
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
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF00695C),
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
      final response = await _apiService.registrarDisponibilidad({
        'correo': widget.correo,
        'dia': _fechaController.text,
        'horario': horario,
        'consultorio': _consultorioController.text,
      });

      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Disponibilidad registrada con éxito'),
            backgroundColor: Colors.teal,
          ),
        );
        await _cargarDisponibilidades();
        setState(() {
          _fechaController.clear();
          _horaInicioController.clear();
          _horaFinController.clear();
          _consultorioController.clear();
          _selectedDate = null;
          _selectedHoraInicio = null;
          _selectedHoraFin = null;
        });
      } else {
        throw Exception('No se pudo registrar la disponibilidad: ${response['error'] ?? 'Error desconocido'}');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Registrar Disponibilidad",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF00695C),
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF00695C).withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Mensaje de error
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                  ),
                ),

              // Sección de registro
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
                    const Text(
                      'Nueva Disponibilidad',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00695C),
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
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _registrarDisponibilidad,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00695C),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 5,
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                'Registrar',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),

              // Sección de disponibilidades registradas
              const SizedBox(height: 30),
              const Text(
                'Disponibilidades Registradas',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00695C),
                ),
              ),
              const SizedBox(height: 10),
              _disponibilidades.isEmpty
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
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            child: Card(
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                leading: const Icon(
                                  Icons.event_available,
                                  color: Color(0xFF00695C),
                                  size: 30,
                                ),
                                title: Text(
                                  'Día: ${disp['dia']}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Color(0xFF00695C),
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 5),
                                    Text(
                                      'Horario: ${disp['horario']}',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    if (disp['consultorio'] != null)
                                      Text(
                                        'Consultorio: ${disp['consultorio']}',
                                        style: const TextStyle(fontSize: 14),
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
        labelStyle: const TextStyle(color: Color(0xFF00695C)),
        hintText: hint,
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF00695C)),
        ),
        suffixIcon: Icon(
          icon,
          color: const Color(0xFF00695C),
        ),
      ),
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