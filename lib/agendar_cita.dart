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
  String? _medicoNombre;
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
        _medicoCorreo = pacienteData['medico_asignado'];
      });

      if (_medicoCorreo != null) {
        print('Médico asignado encontrado. Obteniendo datos del médico...');
        final medicoData = await _apiService.obtenerPorId(_medicoCorreo!);
        print('Datos del médico: $medicoData');
        setState(() {
          _medicoCorreo = medicoData['correo'];
          _medicoNombre = medicoData['nombre_completo']; // Guardamos el nombre del médico
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
          SnackBar(
            content: const Text('Cita agendada con éxito'),
            backgroundColor: const Color(0xFF00695C),
          ),
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
        title: const Text(
          'Agendar Cita',
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
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF00695C)))
            : _errorMessage != null
                ? Center(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Información del médico
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                        child: Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.person,
                                color: Color(0xFF00695C),
                                size: 30,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Médico Asignado',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      _medicoNombre ?? 'Cargando...',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF00695C),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Lista de disponibilidades
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: const Text(
                          'Disponibilidades Disponibles',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF00695C),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: _disponibilidades.isEmpty
                            ? Center(
                                child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 20),
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(15),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 10,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: const Text(
                                    'No hay disponibilidades para este médico.',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(20),
                                itemCount: _disponibilidades.length,
                                itemBuilder: (context, index) {
                                  final disponibilidad = _disponibilidades[index];
                                  return AnimatedOpacity(
                                    opacity: 1.0,
                                    duration: const Duration(milliseconds: 300),
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
                                          'Día: ${disponibilidad['dia']}',
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
                                              'Horario: ${disponibilidad['horario'].split(', ')[0]}',
                                              style: const TextStyle(fontSize: 14),
                                            ),
                                            if (disponibilidad['consultorio'] != null)
                                              Text(
                                                'Consultorio: ${disponibilidad['consultorio']}',
                                                style: const TextStyle(fontSize: 14),
                                              ),
                                          ],
                                        ),
                                        trailing: ElevatedButton(
                                          onPressed: () => _agendarCita(disponibilidad),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF00695C),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                                          ),
                                          child: const Text(
                                            'Agendar',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
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