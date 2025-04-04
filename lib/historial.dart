import 'package:flutter/material.dart';
import 'package:saludgest_app/api_service.dart';

class HistorialPage extends StatefulWidget {
  final String correo;

  const HistorialPage({Key? key, required this.correo}) : super(key: key); // Añadido key

  @override
  _HistorialPageState createState() => _HistorialPageState();
}

class _HistorialPageState extends State<HistorialPage> {
  Map<String, dynamic>? paciente;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchPaciente();
  }

  Future<void> _fetchPaciente() async {
    try {
      final apiService = ApiService();
      final response = await apiService.getPacienteByCorreo(widget.correo);
      setState(() {
        paciente = response;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _errorMessage = error.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Historial Médico"),
        backgroundColor: Colors.teal.shade700,
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : _errorMessage != null
                ? Center(child: Text(_errorMessage!, style: TextStyle(color: Colors.red)))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Información del Paciente",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Text("Nombre: ${paciente!['nombre_completo']}"),
                      Text("Correo: ${paciente!['correo']}"),
                      Text("Teléfono: ${paciente!['telefono']}"),
                      SizedBox(height: 20),
                      Text(
                        "Historial Clínico",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Expanded(
                        child: paciente!['historial_medico'] == null ||
                                (paciente!['historial_medico']['diagnosticos'].isEmpty &&
                                    paciente!['historial_medico']['tratamientos'].isEmpty &&
                                    paciente!['historial_medico']['medicamentos'].isEmpty &&
                                    paciente!['historial_medico']['ordenes_analisis'].isEmpty &&
                                    paciente!['historial_medico']['resultados_analisis'].isEmpty)
                            ? Center(child: Text("No hay datos de historial médico disponibles"))
                            : ListView.builder(
                                itemCount: (paciente!['historial_medico']['diagnosticos'] as List).length +
                                    (paciente!['historial_medico']['ordenes_analisis'] as List).length,
                                itemBuilder: (context, index) {
                                  if (index < (paciente!['historial_medico']['diagnosticos'] as List).length) {
                                    return Card(
                                      child: ListTile(
                                        title: Text("Consulta Médica ${index + 1}"),
                                        subtitle: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            if ((paciente!['historial_medico']['diagnosticos'] as List).isNotEmpty)
                                              Text("Diagnóstico: ${paciente!['historial_medico']['diagnosticos'][index]['descripcion']}"),
                                            if ((paciente!['historial_medico']['tratamientos'] as List).isNotEmpty)
                                              Text("Tratamiento: ${paciente!['historial_medico']['tratamientos'][index]['descripcion']}"),
                                            if ((paciente!['historial_medico']['medicamentos'] as List).isNotEmpty)
                                              Text("Medicamento: ${paciente!['historial_medico']['medicamentos'][index]['nombre']} - ${paciente!['historial_medico']['medicamentos'][index]['dosis']}"),
                                            if ((paciente!['historial_medico']['sintomas'] as List).isNotEmpty)
                                              Text("Síntomas: ${paciente!['historial_medico']['sintomas'][index]['descripcion']}"),
                                          ],
                                        ),
                                      ),
                                    );
                                  } else {
                                    int analisisIndex = (index - (paciente!['historial_medico']['diagnosticos'] as List).length).toInt();
                                    return Card(
                                      child: ListTile(
                                        title: Text("Análisis ${analisisIndex + 1}"),
                                        subtitle: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text("Orden: ${paciente!['historial_medico']['ordenes_analisis'][analisisIndex]['tipo']}"),
                                            if ((paciente!['historial_medico']['resultados_analisis'] as List).length > analisisIndex)
                                              Text("Resultado: ${paciente!['historial_medico']['resultados_analisis'][analisisIndex]['resultados'].toString()}"),
                                          ],
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ),
                      ),
                    ],
                  ),
      ),
    );
  }
}