import 'package:flutter/material.dart';
import 'package:saludgest_app/api_service.dart';
import 'login.dart';

class RegistroPage extends StatefulWidget {
  @override
  _RegistroPageState createState() => _RegistroPageState();
}

class _RegistroPageState extends State<RegistroPage> {
  final TextEditingController _nombreCompletoController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _contrasenaController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _registrarUsuario() async {
    final nombreCompleto = _nombreCompletoController.text;
    final correo = _correoController.text;
    final contrasena = _contrasenaController.text;
    final telefono = _telefonoController.text;

    // Validación de contraseña segura (RNF-001)
    RegExp passwordRegExp = RegExp(r'^(?=.*[A-Z])(?=.*\d)(?=.*[!@#\$&*~]).{8,}$');
    if (!passwordRegExp.hasMatch(contrasena)) {
      setState(() {
        _errorMessage = "La contraseña debe tener al menos 8 caracteres, una mayúscula, un número y un carácter especial.";
      });
      return;
    }

    if (nombreCompleto.isEmpty || correo.isEmpty || contrasena.isEmpty || telefono.isEmpty) {
      setState(() {
        _errorMessage = "Por favor, complete todos los campos.";
      });
      return;
    }

    final data = {
      'nombre_completo': nombreCompleto,
      'correo': correo,
      'contrasena': contrasena,
      'telefono': telefono,
      'tipoUsuario': 'paciente',
    };

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final apiService = ApiService();
      await apiService.savePaciente(data);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hubo un error al crear el usuario: $_errorMessage')),
      );
    }
  }

  void _irALogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registrar Paciente'),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Formulario de Registro - Paciente',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            SizedBox(height: 30),
            _buildTextField(_nombreCompletoController, 'Nombre Completo', Icons.person),
            _buildTextField(_correoController, 'Correo', Icons.email, keyboardType: TextInputType.emailAddress),
            _buildTextField(_contrasenaController, 'Contraseña', Icons.lock, obscureText: true),
            _buildTextField(_telefonoController, 'Teléfono', Icons.phone, keyboardType: TextInputType.phone),
            SizedBox(height: 20),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _registrarUsuario,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      padding: EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Registrar',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _irALogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
                padding: EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Volver a Login',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String labelText,
    IconData icon, {
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: labelText,
          prefixIcon: Icon(icon, color: Colors.teal),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.teal),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey),
          ),
        ),
      ),
    );
  }
}