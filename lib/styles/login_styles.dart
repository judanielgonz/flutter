import 'package:flutter/material.dart';

class LoginStyles {
  // Gradiente del fondo
  static const backgroundGradient = LinearGradient(
    colors: [Colors.blueAccent, Colors.redAccent],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Estilo del texto del título "SaludGest"
  static const titleTextStyle = TextStyle(
    fontSize: 40,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  // Estilo del texto "Iniciar Sesión"
  static const loginHeaderTextStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.blue,
  );

  // Decoración para el TextField de correo
  static InputDecoration correoInputDecoration(TextEditingController controller) {
    return InputDecoration(
      labelText: "Correo",
      labelStyle: const TextStyle(color: Colors.blue),
      border: const OutlineInputBorder(),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.blue),
      ),
      prefixIcon: const Icon(Icons.email, color: Colors.red),
    );
  }

  // Decoración para el TextField de contraseña
  static InputDecoration contrasenaInputDecoration(TextEditingController controller) {
    return InputDecoration(
      labelText: "Contraseña",
      labelStyle: const TextStyle(color: Colors.blue),
      border: const OutlineInputBorder(),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.blue),
      ),
      prefixIcon: const Icon(Icons.lock, color: Colors.red),
    );
  }

  // Estilo del mensaje de error
  static const errorTextStyle = TextStyle(color: Colors.red);

  // Estilo del botón de "Iniciar Sesión"
  static final loginButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: Colors.blue,
    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
  );

  // Estilo del texto del botón de "Iniciar Sesión"
  static const loginButtonTextStyle = TextStyle(
    fontSize: 18,
    color: Colors.white,
  );

  // Estilo del TextButton para "Regístrate"
  static const registerTextStyle = TextStyle(color: Colors.red);

  // Estilo de la Card
  static const cardDecoration = BoxDecoration(
    borderRadius: BorderRadius.all(Radius.circular(15)),
    boxShadow: [
      BoxShadow(
        color: Colors.black26,
        blurRadius: 8,
        offset: Offset(0, 2),
      ),
    ],
  );
}