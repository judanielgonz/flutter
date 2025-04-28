import 'package:flutter/material.dart';
import 'package:saludgest_app/api_service.dart';
import 'package:http/http.dart' as http;

class NotificacionesPage extends StatefulWidget {
  @override
  _NotificacionesPageState createState() => _NotificacionesPageState();
}

class _NotificacionesPageState extends State<NotificacionesPage> {
  List<dynamic> _notificaciones = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchNotificaciones();
  }

  Future<void> _fetchNotificaciones() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final apiService = ApiService();
      final notificaciones = await apiService.getNotificaciones();
      setState(() {
        _notificaciones = notificaciones;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
      print('Error al obtener notificaciones: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notificaciones"),
        backgroundColor: Colors.teal.shade700,
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Error al obtener notificaciones: $_errorMessage',
                        style: TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _fetchNotificaciones,
                        child: Text('Reintentar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal.shade700,
                        ),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Notificaciones",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 10),
                      Expanded(
                        child: _notificaciones.isEmpty
                            ? Center(child: Text("No hay notificaciones"))
                            : ListView.builder(
                                itemCount: _notificaciones.length,
                                itemBuilder: (context, index) {
                                  final notificacion = _notificaciones[index];
                                  return Card(
                                    child: ListTile(
                                      leading: Icon(Icons.notification_important,
                                          color: Colors.teal.shade700),
                                      title: Text(notificacion['tipo'] ?? 'Sin tipo'),
                                      subtitle: Text(notificacion['contenido'] ?? 'Sin contenido'),
                                      trailing: Icon(
                                        notificacion['estado'] == 'Entregada'
                                            ? Icons.check_circle
                                            : Icons.circle,
                                        color: Colors.green,
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