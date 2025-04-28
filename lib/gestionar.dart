import 'package:flutter/material.dart';
import 'api_service.dart';
import 'historial.dart';

class GestionarPage extends StatefulWidget {
  final String? medicoId;
  final String? medicoCorreo;

  const GestionarPage({Key? key, this.medicoId, this.medicoCorreo}) : super(key: key);

  @override
  _GestionarPageState createState() => _GestionarPageState();
}

class _GestionarPageState extends State<GestionarPage> {
  List<dynamic> pacientes = [];
  bool isLoading = true;
  final ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _fetchPacientes();
  }

  Future<void> _fetchPacientes() async {
    try {
      if (widget.medicoId == null) {
        throw Exception('ID del médico no proporcionado');
      }
      final pacientesData = await apiService.getPacientesAsignados(widget.medicoId!);
      setState(() {
        pacientes = pacientesData;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar los pacientes: $e'),
          backgroundColor: Colors.red.shade800,
        ),
      );
    }
  }

  void _verHistorial(String correoPaciente) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HistorialPage(
          correo: correoPaciente,
          tipoUsuario: 'medico',
          medicoCorreo: widget.medicoCorreo,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Gestionar Pacientes',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        color: const Color(0xFFD32F2F), // Deep red background matching the screenshot
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator(color: Colors.white))
                    : pacientes.isEmpty
                        ? const Center(
                            child: Text(
                              'No tienes pacientes asignados',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white70,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          )
                        : _buildPacientesList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFB71C1C), // Darker red for the header
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white.withOpacity(0.1),
            child: const Icon(
              Icons.person_add,
              size: 50,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 15),
          const Text(
            "Gestionar Pacientes",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Administra la información de tus pacientes",
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPacientesList() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: pacientes.length,
      itemBuilder: (context, index) {
        final paciente = pacientes[index];
        return _buildPacienteCard(paciente);
      },
    );
  }

  Widget _buildPacienteCard(Map<String, dynamic> paciente) {
    return GestureDetector(
      onTap: () => _verHistorial(paciente['correo']),
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFE57373), // Lighter red for cards
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: Colors.white.withOpacity(0.2),
              child: const Icon(
                Icons.person,
                color: Colors.white,
                size: 30,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    paciente['nombre_completo'] ?? 'Sin nombre',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    paciente['correo'] ?? 'Sin correo',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.white.withOpacity(0.5),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}