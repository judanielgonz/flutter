import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:saludgest_app/api_service.dart';

class ConfirmarAlarmaPage extends StatefulWidget {
  final String correo;

  const ConfirmarAlarmaPage({super.key, required this.correo});

  @override
  _ConfirmarAlarmaPageState createState() => _ConfirmarAlarmaPageState();
}

class _ConfirmarAlarmaPageState extends State<ConfirmarAlarmaPage> {
  List<dynamic> pendingAlarms = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPendingAlarms();
  }

  Future<void> _loadPendingAlarms() async {
    try {
      final apiService = ApiService();
      final alarmas = await apiService.getAlarmas(widget.correo);
      print('Respuesta del servidor (alarmas): $alarmas'); // Depuración
      setState(() {
        pendingAlarms = alarmas
            .where((alarma) =>
                (alarma is Map && (alarma['estadoNotificacion'] == 'pendiente' || alarma['estadoNotificacion'] == 'no tomado')))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Excepción al cargar alarmas: $e'); // Depuración
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar alarmas: $e')),
      );
    }
  }

  Future<void> _confirmAlarma(String id, String accion) async {
    try {
      final apiService = ApiService();
      await apiService.confirmarAlarma(id, accion);
      await _loadPendingAlarms(); // Recargar alarmas después de confirmar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Acción registrada exitosamente')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al confirmar alarma: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirmar Alarma'),
        backgroundColor: Colors.blue.shade600,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : pendingAlarms.isEmpty
              ? const Center(child: Text('No hay alarmas pendientes'))
              : ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: pendingAlarms.length,
                  itemBuilder: (context, index) {
                    final alarma = pendingAlarms[index] as Map<String, dynamic>;
                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        title: Text(
                          alarma['nombreMedicamento'] ?? 'Sin nombre',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle: Text('Hora: ${alarma['hora'] ?? 'Sin hora'}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.check, color: Colors.green),
                              onPressed: () => _confirmAlarma(alarma['_id'].toString(), 'tomado'),
                              tooltip: 'Tomado',
                            ),
                            IconButton(
                              icon: const Icon(Icons.clear, color: Colors.red),
                              onPressed: () => _confirmAlarma(alarma['_id'].toString(), 'no tomado'),
                              tooltip: 'No tomado',
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

extension ApiServiceExtension on ApiService {
  Future<void> confirmarAlarma(String id, String accion) async {
    final url = Uri.parse('$baseUrl/api/alarmas/$id/confirmar');
    print('Enviando confirmación para alarma $id con acción $accion'); // Depuración
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'accion': accion}),
    );
    print('Respuesta del servidor: ${response.body}'); // Depuración
    if (response.statusCode != 200) {
      throw Exception('Error al confirmar alarma: ${json.decode(response.body)['error']}');
    }
  }
}