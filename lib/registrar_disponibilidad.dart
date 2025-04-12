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
  DateTime? _selectedDate;
  TimeOfDay? _selectedHoraInicio;
  TimeOfDay? _selectedHoraFin;
  bool _isLoading = false;
  String? _errorMessage;
  final ApiService _apiService = ApiService();

  Future<void> _seleccionarFecha() async {
    DateTime? fechaSeleccionada = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
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
        _horaFinController.text.isEmpty) {
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
      });

      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Disponibilidad registrada con éxito')),
        );
        Navigator.pop(context);
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
        title: const Text("Registrar Disponibilidad"),
        backgroundColor: const Color(0xFF00695C),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            TextFormField(
              controller: _fechaController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Fecha',
                hintText: 'Selecciona una fecha',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: _seleccionarFecha,
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _horaInicioController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Hora Inicio',
                hintText: 'Selecciona una hora',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.access_time),
                  onPressed: () => _seleccionarHora(_horaInicioController, true),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _horaFinController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Hora Fin',
                hintText: 'Selecciona una hora',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.access_time),
                  onPressed: () => _seleccionarHora(_horaFinController, false),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _registrarDisponibilidad,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Registrar Disponibilidad',
                        style: TextStyle(fontSize: 18),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _fechaController.dispose();
    _horaInicioController.dispose();
    _horaFinController.dispose();
    super.dispose();
  }
}