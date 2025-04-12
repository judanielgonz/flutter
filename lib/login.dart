import 'package:flutter/material.dart';
import 'package:saludgest_app/api_service.dart';
import 'package:saludgest_app/interfaz.dart';
import 'package:saludgest_app/notificaciones_service.dart';
import 'package:saludgest_app/registro.dart';
import 'package:saludgest_app/registro_medico.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _correoController = TextEditingController();
  final _contrasenaController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  final NotificacionesService _notificacionesService = NotificacionesService();

  @override
  void initState() {
    super.initState();
    _notificacionesService.initialize(); // Inicializar las notificaciones
  }

  // Función para normalizar texto (eliminar acentos)
  String _normalize(String text) {
    return text
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .toLowerCase();
  }

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final apiService = ApiService();
      final response = await apiService.login({
        'correo': _correoController.text,
        'contrasena': _contrasenaController.text,
      });

      if (response['success'] == true) {
        // Normalizamos el tipoUsuario para manejar acentos
        final tipoUsuario = _normalize(response['tipoUsuario']);
        
        // Enviar notificación de inicio de sesión exitoso
        await _notificacionesService.showNotification(
          '¡Bienvenido a SaludGest!',
          'Has iniciado sesión como $tipoUsuario.',
        );

        if (tipoUsuario == 'paciente' || tipoUsuario == 'medico') {
          // Redirigimos a InterfazPage para pacientes y médicos, pasando el usuarioId
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => InterfazPage(
                correo: _correoController.text,
                tipoUsuario: tipoUsuario,
                medicoAsignado: response['medicoAsignado'],
                usuarioId: response['usuarioId'],
              ),
            ),
          );
        } else if (tipoUsuario == 'admin') {
          // Redirigimos a RegistroMedicoPage para admin
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => RegistroMedicoPage(),
            ),
          );
        } else {
          setState(() {
            _errorMessage = 'Rol no reconocido: ${response['tipoUsuario']}';
          });
        }
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Error al iniciar sesión';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade200, Colors.teal.shade600],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "SaludGest",
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 30),
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Text(
                          "Iniciar Sesión",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _correoController,
                          decoration: const InputDecoration(
                            labelText: "Correo",
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.email),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _contrasenaController,
                          decoration: const InputDecoration(
                            labelText: "Contraseña",
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.lock),
                          ),
                          obscureText: true,
                        ),
                        const SizedBox(height: 20),
                        if (_errorMessage != null)
                          Text(
                            _errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        const SizedBox(height: 20),
                        _isLoading
                            ? const CircularProgressIndicator()
                            : ElevatedButton(
                                onPressed: _login,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.teal.shade700,
                                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text(
                                  "Iniciar Sesión",
                                  style: TextStyle(fontSize: 18, color: Colors.white),
                                ),
                              ),
                        const SizedBox(height: 20),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => RegistroPage()),
                            );
                          },
                          child: const Text(
                            "¿No tienes cuenta? Regístrate",
                            style: TextStyle(color: Colors.teal),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _correoController.dispose();
    _contrasenaController.dispose();
    super.dispose();
  }
}