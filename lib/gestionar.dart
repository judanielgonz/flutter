import 'package:flutter/material.dart';
import 'package:saludgest_app/api_service.dart';

class GestionarPage extends StatefulWidget {
  const GestionarPage({Key? key}) : super(key: key); // Añadido key

  @override
  _GestionarPageState createState() => _GestionarPageState();
}

class _GestionarPageState extends State<GestionarPage> {
  List<dynamic> _pacientes = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchPacientes();
  }

  Future<void> _fetchPacientes() async {
    try {
      final apiService = ApiService();
      final pacientes = await apiService.getPacientes();
      setState(() {
        _pacientes = pacientes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Gestionar Paciente"),
        backgroundColor: Colors.teal.shade700,
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!, style: TextStyle(color: Colors.red)))
              : Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Seleccione un paciente para gestionar su tratamiento:",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 20),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _pacientes.length,
                          itemBuilder: (context, index) {
                            final paciente = _pacientes[index];
                            return Card(
                              child: ListTile(
                                leading: Icon(Icons.person, color: Colors.teal.shade700),
                                title: Text(paciente['nombre_completo']),
                                subtitle: Text("Correo: ${paciente['correo']}"),
                                trailing: Icon(Icons.arrow_forward_ios),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => RecetarPage(pacienteCorreo: paciente['correo']),
                                    ),
                                  );
                                },
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

class RecetarPage extends StatefulWidget {
  final String pacienteCorreo;

  const RecetarPage({Key? key, required this.pacienteCorreo}) : super(key: key); // Añadido key

  @override
  _RecetarPageState createState() => _RecetarPageState();
}

class _RecetarPageState extends State<RecetarPage> {
  final _medicamentoController = TextEditingController();
  final _dosisController = TextEditingController();
  final _frecuenciaController = TextEditingController();
  final _duracionController = TextEditingController();
  final _horaController = TextEditingController();

  Future<void> _guardarTratamiento() async {
    final data = {
      'medicamentos': [{
        'nombre': _medicamentoController.text,
        'dosis': _dosisController.text,
        'frecuencia': _frecuenciaController.text,
        'fecha_inicio': DateTime.now().toIso8601String(),
        'fecha_fin': DateTime.now().add(Duration(days: int.parse(_duracionController.text))).toIso8601String(),
        'registrado_por': 'Médico',
      }],
    };
    final alarma = {
      'tipo': 'Medicamento',
      'actividad': {'medicamento_id': _medicamentoController.text, 'dosis': _dosisController.text},
      'hora': _horaController.text,
      'frecuencia': _frecuenciaController.text,
      'mensaje': 'Tomar ${_medicamentoController.text} - ${_dosisController.text}',
    };

    try {
      final apiService = ApiService();
      await apiService.registrarHistorialMedico(widget.pacienteCorreo, data);
      await apiService.registrarAlarma(widget.pacienteCorreo, alarma);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Tratamiento y alarma guardados')));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Recetar Tratamiento")),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Asignar Tratamiento", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            TextField(controller: _medicamentoController, decoration: InputDecoration(labelText: "Medicamento")),
            TextField(controller: _dosisController, decoration: InputDecoration(labelText: "Dosis")),
            TextField(controller: _frecuenciaController, decoration: InputDecoration(labelText: "Frecuencia (Ej: Cada 8 horas)")),
            TextField(
              controller: _duracionController,
              decoration: InputDecoration(labelText: "Duración (días)"),
              keyboardType: TextInputType.number, // Añadido aquí
            ),
            SizedBox(height: 20),
            Text("Configurar Recordatorio", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextField(controller: _horaController, decoration: InputDecoration(labelText: "Hora del Recordatorio")),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _guardarTratamiento,
              child: Text("Guardar Tratamiento y Recordatorio"),
            ),
          ],
        ),
      ),
    );
  }
}