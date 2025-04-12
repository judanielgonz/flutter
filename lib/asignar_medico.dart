import 'package:flutter/material.dart';
import 'package:saludgest_app/api_service.dart';

class AsignarMedicoPage extends StatefulWidget {
  final String pacienteCorreo;

  AsignarMedicoPage({required this.pacienteCorreo});

  @override
  _AsignarMedicoPageState createState() => _AsignarMedicoPageState();
}

class _AsignarMedicoPageState extends State<AsignarMedicoPage> {
  List<dynamic> _medicos = [];
  bool _isLoading = true;
  String? _errorMessage;
  String? _selectedMedicoCorreo;

  @override
  void initState() {
    super.initState();
    _fetchMedicos();
  }

  Future<void> _fetchMedicos() async {
    try {
      final apiService = ApiService();
      final medicos = await apiService.getMedicosDisponibles();
      setState(() {
        _medicos = medicos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _asignarMedico() async {
    if (_selectedMedicoCorreo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, selecciona un médico')),
      );
      return;
    }

    try {
      final apiService = ApiService();
      final response = await apiService.asignarMedico(widget.pacienteCorreo, _selectedMedicoCorreo!);
      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Médico asignado exitosamente')),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['error'] ?? 'Error al asignar el médico')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString().replaceFirst('Exception: ', '')}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Asignar Médico de Confianza"),
        backgroundColor: Colors.teal,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!, style: TextStyle(color: Colors.red)))
              : Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        "Selecciona tu médico de confianza",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 20),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _medicos.length,
                          itemBuilder: (context, index) {
                            final medico = _medicos[index];
                            return Card(
                              margin: EdgeInsets.symmetric(vertical: 8),
                              child: RadioListTile<String>(
                                title: Text(medico['nombre_completo']),
                                subtitle: Text("Especialidad: ${medico['especialidad'] ?? 'No especificada'}"),
                                value: medico['correo'],
                                groupValue: _selectedMedicoCorreo,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedMedicoCorreo = value;
                                  });
                                },
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _asignarMedico,
                        child: Text("Asignar Médico"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
} 
//este codigo se llama asignar_medico.dart