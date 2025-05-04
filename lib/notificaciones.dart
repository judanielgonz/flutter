import 'package:flutter/material.dart';
import 'package:saludgest_app/api_service.dart';
import 'package:intl/intl.dart';
import 'package:saludgest_app/historial.dart';

class NotificacionesPage extends StatefulWidget {
  final String usuarioId;
  final String correo;
  final String tipoUsuario;
  final String? nombre; // Hacer 'nombre' opcional

  const NotificacionesPage({
    required this.usuarioId,
    required this.correo,
    required this.tipoUsuario,
    this.nombre, // Cambiado a opcional
    Key? key,
  }) : super(key: key);

  @override
  _NotificacionesPageState createState() => _NotificacionesPageState();
}

class _NotificacionesPageState extends State<NotificacionesPage> {
  List<dynamic> notificaciones = [];
  bool isLoading = true;
  final ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _fetchNotificaciones();
  }

  Future<void> _fetchNotificaciones() async {
    try {
      final data = await apiService.getNotificaciones(widget.usuarioId);
      setState(() {
        notificaciones = data.where((notif) => !(notif['deletedBy']?.contains(widget.usuarioId) ?? false)).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar notificaciones: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _marcarTodasBorradas() async {
    try {
      await apiService.marcarTodasNotificacionesBorradas(widget.usuarioId);
      setState(() {
        notificaciones = [];
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Todas las notificaciones han sido marcadas como borradas'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al marcar notificaciones como borradas: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Map<String, Color> _getColorsForRole() {
    switch (widget.tipoUsuario) {
      case 'paciente':
        return {
          'header': Colors.blue.shade600,
          'headerGradient': Colors.blue.shade400,
          'accent': Colors.blue.shade500,
          'iconBackground': Colors.blue.shade500,
          'cardBorder': Colors.blue.shade300,
          'cardBackground': Colors.blue.shade50,
        };
      case 'medico':
        return {
          'header': Colors.red.shade600,
          'headerGradient': Colors.red.shade400,
          'accent': Colors.red.shade500,
          'iconBackground': Colors.red.shade500,
          'cardBorder': Colors.red.shade300,
          'cardBackground': Colors.red.shade50,
        };
      default:
        return {
          'header': Colors.teal.shade600,
          'headerGradient': Colors.teal.shade400,
          'accent': Colors.teal.shade500,
          'iconBackground': Colors.teal.shade500,
          'cardBorder': Colors.teal.shade300,
          'cardBackground': Colors.teal.shade50,
        };
    }
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = _getColorsForRole();
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Column(
        children: [
          _buildHeader(colors),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator(color: colors['accent']))
                : notificaciones.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.notifications_off,
                              color: Colors.grey.shade400,
                              size: 60,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'No hay notificaciones',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: notificaciones.length,
                        itemBuilder: (context, index) {
                          final notificacion = notificaciones[index];
                          final String contenido = notificacion['contenido'] ?? 'Sin contenido';
                          final String fecha = notificacion['fecha'] ?? 'Sin fecha';
                          final String pacienteCorreo = notificacion['pacienteCorreo'] ?? widget.correo;
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 5,
                            shadowColor: colors['accent']!.withOpacity(0.2),
                            child: Container(
                              decoration: BoxDecoration(
                                color: colors['cardBackground'],
                                border: Border.all(color: colors['cardBorder']!),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                leading: CircleAvatar(
                                  backgroundColor: colors['accent']!.withOpacity(0.1),
                                  child: Icon(
                                    Icons.notifications_active,
                                    color: colors['accent'],
                                    size: 30,
                                  ),
                                ),
                                title: Text(
                                  contenido,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Text(
                                  'Fecha: ${_formatDate(fecha)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                onTap: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => HistorialPage(
                                        correo: pacienteCorreo,
                                        tipoUsuario: widget.tipoUsuario,
                                        medicoCorreo: widget.tipoUsuario == 'medico' ? widget.correo : null,
                                        nombre: widget.nombre, // Puede ser null
                                      ),
                                    ),
                                  );
                                },
                                trailing: Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                  color: colors['accent'],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _marcarTodasBorradas,
        backgroundColor: colors['accent'],
        elevation: 6,
        child: const Icon(Icons.delete_sweep, color: Colors.white, size: 30),
        tooltip: 'Marcar todas como borradas',
      ),
    );
  }

  Widget _buildHeader(Map<String, Color> colors) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colors['header']!, colors['headerGradient']!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: colors['accent']!.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.white,
              child: CircleAvatar(
                radius: 18,
                backgroundColor: colors['iconBackground'],
                child: const Icon(
                  Icons.notifications,
                  size: 24,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Notificaciones',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.2),
                          offset: const Offset(1, 1),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'Tus actualizaciones recientes',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}