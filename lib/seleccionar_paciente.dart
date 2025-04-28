import 'package:flutter/material.dart';
import 'package:saludgest_app/api_service.dart';
import 'historial.dart';
import 'chat.dart';

class SeleccionarPacientePage extends StatefulWidget {
  final String medicoId;
  final String medicoCorreo;
  final bool isForChat;

  const SeleccionarPacientePage({
    required this.medicoId,
    required this.medicoCorreo,
    this.isForChat = false,
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
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatPage(
            correo: widget.medicoCorreo,
            tipoUsuario: 'medico',
            pacienteCorreo: correoPaciente,
          ),
        ),
      );
    } else {
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
    final colors = {
      'gradientStart': Colors.red.shade800,
      'gradientEnd': Colors.red.shade600,
      'header': Colors.red.shade900,
      'buttonBase': Colors.red.shade700,
      'buttonHoverStart': Colors.red.shade600,
      'buttonHoverEnd': Colors.red.shade400,
    };

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [colors['gradientStart']!, colors['gradientEnd']!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(colors['header']!),
              Expanded(
                child: isLoading
                    ? Center(child: CircularProgressIndicator(color: colors['header']!))
                    : pacientes.isEmpty
                        ? Center(
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              margin: const EdgeInsets.symmetric(horizontal: 20),
                              decoration: BoxDecoration(
                                color: colors['header']!.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: const Text(
                                'No tienes pacientes asignados',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                        : _buildPacientesGrid(colors),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Color headerColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: headerColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(50),
          bottomRight: Radius.circular(50),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              const CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.person_search,
                  size: 40,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(width: 40),
            ],
          ),
          const SizedBox(height: 15),
          const Text(
            "Seleccionar Paciente",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPacientesGrid(Map<String, Color> colors) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 1,
      ),
      itemCount: pacientes.length,
      itemBuilder: (context, index) {
        final paciente = pacientes[index];
        return _buildPacienteButton(
          nombre: paciente['nombre_completo'] ?? 'Sin nombre',
          correo: paciente['correo'] ?? 'Sin correo',
          colors: colors,
          onTap: () => _verHistorial(paciente['correo']),
        );
      },
    );
  }

  Widget _buildPacienteButton({
    required String nombre,
    required String correo,
    required Map<String, Color> colors,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: colors['buttonBase'],
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(15),
            onTap: onTap,
            splashColor: colors['buttonHoverStart']!.withOpacity(0.3),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.person,
                    size: 40,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    nombre,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    correo,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}