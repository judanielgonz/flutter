import 'package:flutter/material.dart';
import 'api_service.dart';
import 'historial.dart';
import 'chat.dart'; // Aseguramos que ChatPage esté importado

class SeleccionarPacientePage extends StatefulWidget {
  final String medicoId;
  final String medicoCorreo;
  final bool isForChat; // Nuevo parámetro para indicar si es para el chat

  const SeleccionarPacientePage({
    required this.medicoId,
    required this.medicoCorreo,
    this.isForChat = false, // Por defecto, es para historial
    Key? key,
  }) : super(key: key);

  @override
  _SeleccionarPacientePageState createState() => _SeleccionarPacientePageState();
}

class _SeleccionarPacientePageState extends State<SeleccionarPacientePage> {
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
      final pacientesData = await apiService.getPacientesAsignados(widget.medicoId);
      setState(() {
        pacientes = pacientesData;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar los pacientes: $e')),
      );
    }
  }

  void _verHistorial(String correoPaciente) {
    if (widget.isForChat) {
      // Si es para el chat, navegamos a ChatPage
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatPage(
            correo: widget.medicoCorreo,
            tipoUsuario: 'medico',
            pacienteCorreo: correoPaciente, // Correo del paciente seleccionado
          ),
        ),
      );
    } else {
      // Si no es para el chat, navegamos a HistorialPage (comportamiento original)
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Seleccionar Paciente',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
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
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : pacientes.isEmpty
                      ? const Center(child: Text('No tienes pacientes asignados'))
                      : _buildPacientesList(),
            ),
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
            Icons.person_search,
            size: 60,
            color: Colors.white,
          ),
          const SizedBox(height: 10),
          const Text(
            "Seleccionar Paciente",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
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
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal.shade200, Colors.teal.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            offset: Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(15),
        title: Text(
          paciente['nombre_completo'] ?? 'Sin nombre',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        subtitle: Text(
          paciente['correo'] ?? 'Sin correo',
          style: const TextStyle(color: Colors.white70),
        ),
        leading: const Icon(
          Icons.person,
          color: Colors.white,
          size: 30,
        ),
        onTap: () => _verHistorial(paciente['correo']),
      ),
    );
  }
}