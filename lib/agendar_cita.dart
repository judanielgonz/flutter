import 'package:flutter/material.dart';
import 'api_service.dart';

class AgendarCitaPage extends StatefulWidget {
  final String pacienteCorreo;

  const AgendarCitaPage({required this.pacienteCorreo, Key? key}) : super(key: key);

  @override
  _AgendarCitaPageState createState() => _AgendarCitaPageState();
}

class _AgendarCitaPageState extends State<AgendarCitaPage> {
  List<dynamic> _disponibilidades = [];
  bool _isLoading = true;
  String? _errorMessage;
  String? _medicoCorreo;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _fetchPacienteData();
  }

  Future<void> _fetchPacienteData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final pacienteData = await _apiService.getPacienteByCorreo(widget.pacienteCorreo);
      print('Datos del paciente: $pacienteData');
      setState(() {
        // El backend devuelve medico_asignado como un ID, necesitamos obtener el correo del médico
        _medicoCorreo = pacienteData['medico_asignado'];
      });

      if (_medicoCorreo != null) {
        print('Médico asignado encontrado. Obteniendo correo del médico...');
        // Obtener los datos del médico para extraer su correo
        final medicoData = await _apiService.obtenerPorId(_medicoCorreo!);
        print('Datos del médico: $medicoData');
        setState(() {
          _medicoCorreo = medicoData['correo'];
        });
        print('Correo del médico asignado: $_medicoCorreo');
        await _fetchDisponibilidades();
      } else {
        throw Exception('No tienes un médico asignado.');
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

  Future<void> _fetchDisponibilidades() async {
    try {
      final disponibilidades = await _apiService.getDisponibilidades(_medicoCorreo!);
      print('Disponibilidades obtenidas: $disponibilidades');
      setState(() {
        _disponibilidades = disponibilidades;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _agendarCita(Map<String, dynamic> disponibilidad) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _apiService.agendarCita({
        'pacienteCorreo': widget.pacienteCorreo,
        'medicoCorreo': _medicoCorreo,
        'dia': disponibilidad['dia'],
        'horario': disponibilidad['horario'].split(', ')[0], // Tomar solo el primer horario si hay múltiples
      });

      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cita agendada con éxito')),
        );
        Navigator.pop(context);
      } else {
        throw Exception('No se pudo agendar la cita: ${response['error'] ?? 'Error desconocido'}');
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
        title: const Text('Agendar Cita'),
        backgroundColor: Colors.teal,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)))
              : _disponibilidades.isEmpty
                  ? const Center(child: Text('No hay disponibilidades para este médico.'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(10),
                      itemCount: _disponibilidades.length,
                      itemBuilder: (context, index) {
                        final disponibilidad = _disponibilidades[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          child: ListTile(
                            title: Text('${disponibilidad['dia']}'),
                            subtitle: Text('Horario: ${disponibilidad['horario']}'),
                            trailing: const Icon(Icons.calendar_today, color: Colors.teal),
                            onTap: () => _agendarCita(disponibilidad),
                          ),
                        );
                      },
                    ),
    );
  }
}