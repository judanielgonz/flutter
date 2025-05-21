import 'package:flutter/material.dart';
import 'package:saludgest_app/api_service.dart';
import 'package:saludgest_app/interfaz.dart';
import 'package:saludgest_app/notificaciones_service.dart';
import 'package:saludgest_app/registro.dart';
import 'package:saludgest_app/registro_medico.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _correoController = TextEditingController();
  final _contrasenaController = TextEditingController();
  final _resetCorreoController = TextEditingController();
  final _tokenController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _showForgotPassword = false;
  bool _showResetPassword = false;
  final NotificacionesService _notificacionesService = NotificacionesService();

  @override
  void initState() {
    super.initState();
    _notificacionesService.initialize();
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      if (_correoController.text.isNotEmpty) {
        _sendFcmTokenToBackend(_correoController.text, newToken);
      }
    });
    _checkExistingSession(); // Verificar si ya hay una sesión activa
  }

  Future<void> _checkExistingSession() async {
    final prefs = await SharedPreferences.getInstance();
    final correo = prefs.getString('correo');
    final tipoUsuario = prefs.getString('tipoUsuario');
    final usuarioId = prefs.getString('usuarioId');
    final medicoAsignado = prefs.getString('medicoAsignado');

    if (correo != null && tipoUsuario != null && usuarioId != null) {
      print('Sesión encontrada - Navegando a InterfazPage para $correo');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => InterfazPage(
            correo: correo,
            tipoUsuario: tipoUsuario,
            usuarioId: usuarioId,
            medicoAsignado: medicoAsignado,
          ),
        ),
      );
    } else {
      print('No hay sesión activa - Permaneciendo en LoginPage');
    }
  }

  String _normalize(String text) {
    return text
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .toLowerCase();
  }

  Future<void> _sendFcmTokenToBackend(String correo, String? newToken) async {
    if (newToken == null || correo.isEmpty) {
      print('No se puede enviar el token FCM: token o correo vacío (token: $newToken, correo: $correo)');
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:3000/api/pacientes/update-fcm-token'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'correo': correo, 'fcmToken': newToken}),
      );
      if (response.statusCode == 200) {
        print('Token FCM enviado al backend con éxito para $correo: $newToken');
      } else {
        print('Error al enviar token FCM para $correo: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error al enviar token FCM para $correo: $e');
    }
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
        final tipoUsuario = _normalize(response['tipoUsuario']);

        // Guardar datos en SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('correo', _correoController.text);
        await prefs.setString('tipoUsuario', tipoUsuario);
        await prefs.setString('usuarioId', response['usuarioId'].toString());
        await prefs.setString('medicoAsignado', response['medicoAsignado'] ?? '');

        String? fcmToken = await FirebaseMessaging.instance.getToken();
        if (fcmToken != null) {
          await _sendFcmTokenToBackend(_correoController.text, fcmToken);
        } else {
          print('No se pudo obtener un token FCM para ${_correoController.text}');
        }

        await _notificacionesService.showNotification(
          title: '¡Bienvenido a SaludGest!',
          body: 'Has iniciado sesión como $tipoUsuario.',
        );

        if (tipoUsuario == 'paciente' || tipoUsuario == 'medico') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => InterfazPage(
                correo: _correoController.text,
                tipoUsuario: tipoUsuario,
                medicoAsignado: response['medicoAsignado'],
                usuarioId: response['usuarioId'].toString(),
              ),
            ),
          );
        } else if (tipoUsuario == 'admin') {
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

  Future<void> _forgotPassword() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final apiService = ApiService();
      final response = await apiService.forgotPassword(_resetCorreoController.text);
      if (response['success'] == true) {
        setState(() {
          _showForgotPassword = false;
          _showResetPassword = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Correo de restablecimiento enviado')),
        );
      } else {
        setState(() {
          _errorMessage = response['error'] ?? 'Error al solicitar restablecimiento';
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

  Future<void> _resetPassword() async {
    if (_newPasswordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = 'Las contraseñas no coinciden';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final apiService = ApiService();
      final response = await apiService.resetPassword(
        _resetCorreoController.text,
        _tokenController.text,
        _newPasswordController.text,
      );
      if (response['success'] == true) {
        setState(() {
          _showResetPassword = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Contraseña actualizada correctamente')),
        );
        _resetCorreoController.clear();
        _tokenController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
      } else {
        setState(() {
          _errorMessage = response['error'] ?? 'Error al restablecer contraseña';
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
            colors: [Colors.blue.shade600, Colors.red.shade600],
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
                    child: _showForgotPassword
                        ? _buildForgotPasswordForm()
                        : _showResetPassword
                            ? _buildResetPasswordForm()
                            : _buildLoginForm(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Column(
      children: [
        Text(
          "Iniciar Sesión",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade500,
          ),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _correoController,
          decoration: InputDecoration(
            labelText: "Correo",
            labelStyle: TextStyle(color: Colors.blue.shade500),
            border: const OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue.shade500),
            ),
            prefixIcon: Icon(Icons.email, color: Colors.red.shade500),
          ),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _contrasenaController,
          decoration: InputDecoration(
            labelText: "Contraseña",
            labelStyle: TextStyle(color: Colors.blue.shade500),
            border: const OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue.shade500),
            ),
            prefixIcon: Icon(Icons.lock, color: Colors.red.shade500),
          ),
          obscureText: true,
        ),
        const SizedBox(height: 20),
        if (_errorMessage != null)
          Text(
            _errorMessage!,
            style: TextStyle(color: Colors.red.shade500),
          ),
        const SizedBox(height: 20),
        _isLoading
            ? CircularProgressIndicator(color: Colors.red.shade500)
            : ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
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
            setState(() {
              _showForgotPassword = true;
              _errorMessage = null;
            });
          },
          child: Text(
            "¿Olvidaste tu contraseña?",
            style: TextStyle(color: Colors.red.shade500),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => RegistroPage()),
            );
          },
          child: Text(
            "¿No tienes cuenta? Regístrate",
            style: TextStyle(color: Colors.red.shade500),
          ),
        ),
      ],
    );
  }

  Widget _buildForgotPasswordForm() {
    return Column(
      children: [
        Text(
          "Recuperar Contraseña",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade500,
          ),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _resetCorreoController,
          decoration: InputDecoration(
            labelText: "Correo",
            labelStyle: TextStyle(color: Colors.blue.shade500),
            border: const OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue.shade500),
            ),
            prefixIcon: Icon(Icons.email, color: Colors.red.shade500),
          ),
        ),
        const SizedBox(height: 20),
        if (_errorMessage != null)
          Text(
            _errorMessage!,
            style: TextStyle(color: Colors.red.shade500),
          ),
        const SizedBox(height: 20),
        _isLoading
            ? CircularProgressIndicator(color: Colors.red.shade500)
            : ElevatedButton(
                onPressed: _forgotPassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Enviar Correo",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
        const SizedBox(height: 20),
        TextButton(
          onPressed: () {
            setState(() {
              _showForgotPassword = false;
              _errorMessage = null;
            });
          },
          child: Text(
            "Volver al inicio de sesión",
            style: TextStyle(color: Colors.red.shade500),
          ),
        ),
      ],
    );
  }

  Widget _buildResetPasswordForm() {
    return Column(
      children: [
        Text(
          "Restablecer Contraseña",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade500,
          ),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _tokenController,
          decoration: InputDecoration(
            labelText: "Token",
            labelStyle: TextStyle(color: Colors.blue.shade500),
            border: const OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue.shade500),
            ),
            prefixIcon: Icon(Icons.vpn_key, color: Colors.red.shade500),
          ),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _newPasswordController,
          decoration: InputDecoration(
            labelText: "Nueva Contraseña",
            labelStyle: TextStyle(color: Colors.blue.shade500),
            border: const OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue.shade500),
            ),
            prefixIcon: Icon(Icons.lock, color: Colors.red.shade500),
          ),
          obscureText: true,
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _confirmPasswordController,
          decoration: InputDecoration(
            labelText: "Confirmar Contraseña",
            labelStyle: TextStyle(color: Colors.blue.shade500),
            border: const OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue.shade500),
            ),
            prefixIcon: Icon(Icons.lock, color: Colors.red.shade500),
          ),
          obscureText: true,
        ),
        const SizedBox(height: 20),
        if (_errorMessage != null)
          Text(
            _errorMessage!,
            style: TextStyle(color: Colors.red.shade500),
          ),
        const SizedBox(height: 20),
        _isLoading
            ? CircularProgressIndicator(color: Colors.red.shade500)
            : ElevatedButton(
                onPressed: _resetPassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Restablecer Contraseña",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
        const SizedBox(height: 20),
        TextButton(
          onPressed: () {
            setState(() {
              _showResetPassword = false;
              _errorMessage = null;
            });
          },
          child: Text(
            "Volver al inicio de sesión",
            style: TextStyle(color: Colors.red.shade500),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _correoController.dispose();
    _contrasenaController.dispose();
    _resetCorreoController.dispose();
    _tokenController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}