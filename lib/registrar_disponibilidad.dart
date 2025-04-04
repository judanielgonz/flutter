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
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    print('Correo del médico en RegistrarDisponibilidadPage: ${widget.correo}');
  }

  Future<void> _seleccionarFecha() async {
    DateTime? fechaSeleccionada = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (fechaSeleccionada != null) {
      setState(() {
        _fechaController.text = DateFormat('yyyy-MM-dd').format(fechaSeleccionada);
      });
    }
  }

  Future<void> _seleccionarHora(TextEditingController controller) async {
    TimeOfDay? horaSeleccionada = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (horaSeleccionada != null) {
      setState(() {
        controller.text = horaSeleccionada.format(context);
      });
    }
  }

  Future<void> _registrarDisponibilidad() async {
    try {
      final apiService = ApiService();
      final response = await apiService.registrarDisponibilidad({
        'medicoCorreo': widget.correo,
        'fecha': _fechaController.text,
        'hora_inicio': _horaInicioController.text,
        'hora_fin': _horaFinController.text,
      });
      if (response['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Disponibilidad registrada con éxito")),
          );
          Navigator.pop(context);
        }
      } else {
        setState(() {
          _errorMessage = response['error'] ?? 'Error al registrar disponibilidad';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
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
            TextFormField(
              controller: _fechaController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: "Fecha",
                hintText: "Selecciona una fecha",
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
                labelText: "Hora Inicio",
                hintText: "Selecciona una hora",
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.access_time),
                  onPressed: () => _seleccionarHora(_horaInicioController),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _horaFinController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: "Hora Fin",
                hintText: "Selecciona una hora",
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.access_time),
                  onPressed: () => _seleccionarHora(_horaFinController),
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (_errorMessage != null)
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _registrarDisponibilidad,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00695C),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: const Text(
                  "Registrar",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}