import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'citas.dart';
import 'chat.dart';
import 'historial.dart';
import 'notificaciones.dart';
import 'configuracion.dart';
import 'gestionar.dart';
import 'login.dart';
import 'registro_medico.dart';
import 'registrar_disponibilidad.dart';
import 'agendar_cita.dart' as agendarCita;
import 'asignar_medico.dart';
import 'seleccionar_paciente.dart';
import 'screens/alarmas_page.dart';
import 'confirmar_alarma.dart';

class InterfazPage extends StatefulWidget {
  final String correo;
  final String tipoUsuario;
  final String? medicoAsignado;
  final String? usuarioId;

  const InterfazPage({
    required this.correo,
    required this.tipoUsuario,
    this.medicoAsignado,
    this.usuarioId,
    Key? key,
  }) : super(key: key);

  @override
  _InterfazPageState createState() => _InterfazPageState();
}

class _InterfazPageState extends State<InterfazPage> {
  String? _medicoAsignado;
  int _selectedIndex = 0;
  bool _hasPendingAlarm = false;

  @override
  void initState() {
    super.initState();
    _medicoAsignado = widget.medicoAsignado;
    if (widget.tipoUsuario == 'paciente') {
      _fetchUsuarioData();
      _checkPendingAlarmsWithRetry();
      // Verificar alarmas periódicamente cada 30 segundos
      Future.doWhile(() async {
        await Future.delayed(Duration(seconds: 30));
        if (mounted) {
          await _checkPendingAlarms();
          return true;
        }
        return false;
      });
    }
    print('Tipo de usuario: ${widget.tipoUsuario}, _hasPendingAlarm: $_hasPendingAlarm');
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
      print('Error al cargar los datos del usuario: $e');
    }
  }

  Future<void> _checkPendingAlarmsWithRetry() async {
    const maxRetries = 3;
    int retryCount = 0;
    bool success = false;

    while (retryCount < maxRetries && !success) {
      try {
        await _checkPendingAlarms();
        success = true;
      } catch (e) {
        retryCount++;
        print('Intento $retryCount fallido al verificar alarmas: $e');
        if (retryCount < maxRetries) {
          await Future.delayed(Duration(seconds: 2));
        } else {
          print('Fallo al verificar alarmas después de $maxRetries intentos');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al verificar alarmas: $e')),
          );
        }
      }
    }
  }

  Future<void> _checkPendingAlarms() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:3000/api/alarmas?correo=${widget.correo}'),
      );
      print('Respuesta del servidor (checkPendingAlarms): ${response.body}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final alarmas = data['alarmas'] ?? [];
          print('Alarmas encontradas (checkPendingAlarms): $alarmas');
          setState(() {
            _hasPendingAlarm = alarmas.any((alarma) =>
                alarma['estadoNotificacion'] == 'pendiente' ||
                alarma['estadoNotificacion'] == 'no tomado');
          });
          print('Actualizado _hasPendingAlarm a: $_hasPendingAlarm');
        } else {
          print('Error en la respuesta del servidor: ${data['error']}');
        }
      } else {
        print('Error en la solicitud HTTP: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al verificar alarmas pendientes: $e');
      rethrow; // Para que el mecanismo de reintentos lo capture
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
      await _fetchUsuarioData();
      return _medicoAsignado != null;
    }
    return false;
  }

  Map<String, Color> _getColorsForRole() {
    switch (widget.tipoUsuario) {
      case 'medico':
        return {
          'gradientStart': Colors.red.shade800,
          'gradientEnd': Colors.red.shade600,
          'header': Colors.red.shade900,
          'buttonBase': Colors.red.shade700,
          'buttonHoverStart': Colors.red.shade600,
          'buttonHoverEnd': Colors.red.shade400,
          'bottomNav': Colors.red.shade800,
        };
      case 'paciente':
        return {
          'gradientStart': Colors.blue.shade800,
          'gradientEnd': Colors.blue.shade600,
          'header': Colors.blue.shade900,
          'buttonBase': Colors.blue.shade700,
          'buttonHoverStart': Colors.blue.shade600,
          'buttonHoverEnd': Colors.blue.shade400,
          'bottomNav': Colors.blue.shade800,
        };
      default:
        return {
          'gradientStart': Colors.teal.shade600,
          'gradientEnd': Colors.teal.shade400,
          'header': Colors.teal.shade700,
          'buttonBase': Colors.teal.shade500,
          'buttonHoverStart': Colors.teal.shade400,
          'buttonHoverEnd': Colors.teal.shade200,
          'bottomNav': Colors.teal.shade600,
        };
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        break;
      case 1:
        if (widget.usuarioId != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NotificacionesPage(
                usuarioId: widget.usuarioId!,
                correo: widget.correo,
                tipoUsuario: widget.tipoUsuario,
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error: No se encontró el ID del usuario. Por favor, inicia sesión nuevamente.')),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        }
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ConfiguracionPage()),
        );
        break;
      case 3:
        // Limpiar datos almacenados al cerrar sesión
        _logout();
        break;
      case 4:
        if (_hasPendingAlarm && widget.tipoUsuario == 'paciente') {
          print('Navegando a ConfirmarAlarmaPage - _hasPendingAlarm: $_hasPendingAlarm, tipoUsuario: ${widget.tipoUsuario}');
          try {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ConfirmarAlarmaPage(correo: widget.correo),
              ),
            ).then((_) {
              _checkPendingAlarms();
            });
          } catch (e) {
            print('Error al navegar a ConfirmarAlarmaPage: $e');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error al abrir la página de alarmas: $e')),
            );
          }
        } else {
          print('No se navega - _hasPendingAlarm: $_hasPendingAlarm, tipoUsuario: ${widget.tipoUsuario}');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No hay alarmas pendientes o no eres paciente.')),
          );
        }
        break;
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Limpiar todos los datos almacenados
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = _getColorsForRole();

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
              _buildOptionsGrid(context, colors),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: colors['bottomNav'],
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: widget.tipoUsuario == 'paciente'
            ? [
                const BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Inicio',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.notifications),
                  label: 'Notificaciones',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.settings),
                  label: 'Configuración',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.logout),
                  label: 'Cerrar Sesión',
                ),
                BottomNavigationBarItem(
                  icon: _hasPendingAlarm
                      ? Icon(Icons.alarm, color: Colors.red)
                      : Icon(Icons.alarm, color: Colors.white70),
                  label: 'Alarma',
                ),
              ]
            : const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Inicio',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.notifications),
                  label: 'Notificaciones',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings),
                  label: 'Configuración',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.logout),
                  label: 'Cerrar Sesión',
                ),
              ],
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
          const CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.person,
              size: 50,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 15),
          const Text(
            "Bienvenido a SaludGest",
            style: TextStyle(
              fontSize: 28,
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
          Text(
            "Rol: ${widget.tipoUsuario}",
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white60,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionsGrid(BuildContext context, Map<String, Color> colors) {
    List<Map<String, dynamic>> options = [];

    if (widget.tipoUsuario == 'paciente') {
      options = [
        if (_medicoAsignado == null)
          {
            'title': 'Asignar Médico',
            'icon': Icons.person_add_alt_1,
            'onTap': () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AsignarMedicoPage(pacienteCorreo: widget.correo),
                ),
              );
              if (result == true) {
                await _fetchUsuarioData();
              }
            },
          },
        {
          'title': 'Agendar Cita',
          'icon': Icons.calendar_today,
          'onTap': () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => agendarCita.AgendarCitaPage(pacienteCorreo: widget.correo),
              ),
            );
          },
        },
        {
          'title': 'Mis Citas',
          'icon': Icons.event,
          'onTap': () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CitasPage(correo: widget.correo, tipoUsuario: widget.tipoUsuario),
              ),
            );
          },
        },
        {
          'title': 'Chat',
          'icon': Icons.chat,
          'onTap': () async {
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
        },
        {
          'title': 'Historial',
          'icon': Icons.history,
          'onTap': () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HistorialPage(
                  correo: widget.correo,
                  tipoUsuario: widget.tipoUsuario,
                  medicoCorreo: null,
                ),
              ),
            );
          },
        },
        {
          'title': 'Alarmas',
          'icon': Icons.alarm,
          'onTap': () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AlarmasPage(correo: widget.correo),
              ),
            );
          },
        },
      ];
    }

    if (widget.tipoUsuario == 'medico') {
      options = [
        {
          'title': 'Mis Citas',
          'icon': Icons.event,
          'onTap': () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CitasPage(correo: widget.correo, tipoUsuario: widget.tipoUsuario),
              ),
            );
          },
        },
        {
          'title': 'Registrar Disponibilidad',
          'icon': Icons.schedule,
          'onTap': () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RegistrarDisponibilidadPage(correo: widget.correo),
              ),
            );
          },
        },
        {
          'title': 'Gestionar Paciente',
          'icon': Icons.person_add,
          'onTap': () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GestionarPage(
                  medicoId: widget.usuarioId,
                  medicoCorreo: widget.correo,
                ),
              ),
            );
          },
        },
        {
          'title': 'Historial de Paciente',
          'icon': Icons.history,
          'onTap': () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SeleccionarPacientePage(
                  medicoId: widget.usuarioId!,
                  medicoCorreo: widget.correo,
                ),
              ),
            );
          },
        },
        {
          'title': 'Chat',
          'icon': Icons.chat,
          'onTap': () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SeleccionarPacientePage(
                  medicoId: widget.usuarioId!,
                  medicoCorreo: widget.correo,
                  isForChat: true,
                ),
              ),
            );
          },
        },
      ];
    }

    if (widget.tipoUsuario == 'admin' || widget.tipoUsuario == 'secretario') {
      options = [
        {
          'title': 'Gestionar Paciente',
          'icon': Icons.person_add,
          'onTap': () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GestionarPage(
                  medicoId: widget.usuarioId,
                  medicoCorreo: widget.correo,
                ),
              ),
            );
          },
        },
      ];
      if (widget.tipoUsuario == 'admin') {
        options.add({
          'title': 'Registrar Médico',
          'icon': Icons.medical_services,
          'onTap': () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => RegistroMedicoPage()),
            );
          },
        });
      }
    }

    return Expanded(
      child: GridView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          childAspectRatio: 1,
        ),
        itemCount: options.length,
        itemBuilder: (context, index) {
          final option = options[index];
          return _buildModernButton(
            title: option['title'],
            icon: option['icon'],
            onTap: option['onTap'],
            colors: colors,
          );
        },
      ),
    );
  }

  Widget _buildModernButton({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    required Map<String, Color> colors,
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
                  Icon(
                    icon,
                    size: 40,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
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