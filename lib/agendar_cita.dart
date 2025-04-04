import 'package:flutter/material.dart';
import 'package:saludgest_app/api_service.dart';

class AgendarCitaPage extends StatefulWidget {
  final String pacienteCorreo;

  const AgendarCitaPage({super.key, required this.pacienteCorreo});

  @override
  _AgendarCitaPageState createState() => _AgendarCitaPageState();
}

class _AgendarCitaPageState extends State<AgendarCitaPage> {
  List<dynamic> _disponibilidad = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchDisponibilidad();
  }

  Future<void> _fetchDisponibilidad() async {
    try {
      final apiService = ApiService();
      final response = await apiService.getDisponibilidad();
      setState(() {
        _disponibilidad = response;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _agendarCita(String medicoCorreo, String dia, String horario, String medicoNombre) async {
    // Mostrar un diálogo de confirmación antes de agendar la cita
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Cita'),
        content: Text(
          '¿Estás seguro de que deseas agendar una cita con $medicoNombre el $dia a las $horario?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final data = {
      'pacienteCorreo': widget.pacienteCorreo,
      'medicoCorreo': medicoCorreo,
      'dia': dia,
      'horario': horario,
    };

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final apiService = ApiService();
      final response = await apiService.agendarCita(data);
      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cita agendada exitosamente')),
        );
        // Refrescar la disponibilidad después de agendar
        await _fetchDisponibilidad();
      } else {
        setState(() {
          _errorMessage = response['error'] ?? "Error desconocido.";
        });
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
        backgroundColor: Colors.teal.shade700,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text('Error al cargar la disponibilidad: $_errorMessage', style: const TextStyle(color: Colors.red)))
              : _disponibilidad.isEmpty
                  ? const Center(child: Text('No hay médicos disponibles'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: _disponibilidad.length,
                      itemBuilder: (context, index) {
                        final medico = _disponibilidad[index];
                        return Card(
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ExpansionTile(
                            title: Text(
                              medico['nombre'],
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text('Especialidad: ${medico['especialidad'] ?? 'No especificada'}'),
                            children: medico['disponibilidad'].map<Widget>((disp) {
                              return ListTile(
                                title: Text('Día: ${disp['dia']}'),
                                subtitle: Text('Horario: ${disp['horario']}'),
                                trailing: ElevatedButton(
                                  onPressed: () => _agendarCita(
                                    medico['correo'],
                                    disp['dia'],
                                    disp['horario'],
                                    medico['nombre'],
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.teal.shade700,
                                  ),
                                  child: const Text('Agendar'),
                                ),
                              );
                            }).toList(),
                          ),
                        );
                      },
                    ),
    );
  }
}