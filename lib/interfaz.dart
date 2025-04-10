import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'citas.dart';
import 'chat.dart';
import 'historial.dart';
import 'notificaciones.dart';
import 'configuracion.dart';
import 'gestionar.dart';
import 'login.dart';
import 'registro_medico.dart';
import 'registrar_disponibilidad.dart';
import 'agendar_cita.dart';
import 'asignar_medico.dart';

class InterfazPage extends StatefulWidget {
  final String correo;
  final String tipoUsuario;
  final String? medicoAsignado;

  const InterfazPage({
    required this.correo,
    required this.tipoUsuario,
    this.medicoAsignado,
  });

  @override
  _InterfazPageState createState() => _InterfazPageState();
}

class _InterfazPageState extends State<InterfazPage> {
  String? _medicoAsignado;

  @override
  void initState() {
    super.initState();
    _medicoAsignado = widget.medicoAsignado;
    _fetchUsuarioData(); // Cargar los datos del usuario al iniciar
  }

  Future<void> _fetchUsuarioData() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:3000/api/pacientes/obtener-por-correo?correo=${widget.correo}'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          setState(() {
            _medicoAsignado = data['persona']['medico_asignado'];
          });
        }
      }
    } catch (e) {
      // Manejar el error si es necesario
      print('Error al cargar los datos del usuario: $e');
    }
  }

  Future<bool> _checkMedicoAsignado(BuildContext context) async {
    if (widget.tipoUsuario != 'paciente' || _medicoAsignado != null) {
      return true;
    }
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AsignarMedicoPage(pacienteCorreo: widget.correo),
      ),
    );
    if (result == true) {
      // Recargar los datos del usuario después de asignar un médico
      await _fetchUsuarioData();
      return _medicoAsignado != null;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade50, Colors.teal.shade200],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            _buildHeader(),
            _buildGrid(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.teal.shade700,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.health_and_safety,
            size: 80,
            color: Colors.white,
          ),
          const SizedBox(height: 10),
          const Text(
            "Bienvenido a SaludGest",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Usuario: ${widget.correo}",
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          children: [
            if (widget.tipoUsuario == 'paciente' && _medicoAsignado == null)
              _buildGridButton(
                context,
                "Asignar Médico",
                AsignarMedicoPage(pacienteCorreo: widget.correo),
                Icons.person_add_alt_1,
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AsignarMedicoPage(pacienteCorreo: widget.correo),
                    ),
                  );
                  if (result == true) {
                    await _fetchUsuarioData(); // Recargar los datos después de asignar
                  }
                },
              ),
            if (widget.tipoUsuario == 'paciente')
              _buildGridButton(
                context,
                "Agendar Cita",
                AgendarCitaPage(pacienteCorreo: widget.correo),
                Icons.calendar_today,
              ),
            if (widget.tipoUsuario == 'paciente' || widget.tipoUsuario == 'medico' || widget.tipoUsuario == 'secretario')
              _buildGridButton(
                context,
                "Mis Citas",
                CitasPage(correo: widget.correo, tipoUsuario: widget.tipoUsuario),
                Icons.event,
              ),
            if (widget.tipoUsuario == 'medico')
              _buildGridButton(
                context,
                "Registrar Disponibilidad",
                RegistrarDisponibilidadPage(correo: widget.correo),
                Icons.schedule,
              ),
            _buildGridButton(
              context,
              "Chat",
              ChatPage(correo: widget.correo, tipoUsuario: widget.tipoUsuario, medicoAsignado: _medicoAsignado),
              Icons.chat,
              onTap: () async {
                if (await _checkMedicoAsignado(context)) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatPage(
                        correo: widget.correo,
                        tipoUsuario: widget.tipoUsuario,
                        medicoAsignado: _medicoAsignado,
                      ),
                    ),
                  );
                }
              },
            ),
            _buildGridButton(context, "Historial", HistorialPage(correo: widget.correo), Icons.history),
            _buildGridButton(context, "Notificaciones", NotificacionesPage(), Icons.notifications),
            _buildGridButton(context, "Configuración", ConfiguracionPage(), Icons.settings),
            if (widget.tipoUsuario == 'admin' || widget.tipoUsuario == 'secretario')
              _buildGridButton(context, "Gestionar Paciente", GestionarPage(), Icons.person_add),
            if (widget.tipoUsuario == 'admin')
              _buildGridButton(context, "Registrar Médico", RegistroMedicoPage(), Icons.medical_services),
          ],
        ),
      ),
    );
  }

  Widget _buildGridButton(BuildContext context, String text, Widget page, IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap ?? () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade200, Colors.teal.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              offset: Offset(0, 4),
              blurRadius: 10,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(25),
                child: Icon(icon, size: 50, color: Colors.white),
              ),
              Positioned(
                bottom: 25,
                child: Text(
                  text,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}