import 'package:flutter/material.dart';

class GestionarStyles {
  // Colores principales
  static const Color backgroundColor = Color(0xFFD32F2F); // Deep red
  static const Color headerBackgroundColor = Color(0xFFB71C1C); // Darker red
  static const Color cardBackgroundColor = Color(0xFFE57373); // Lighter red

  // Decoración del encabezado
  static BoxDecoration headerDecoration() {
    return BoxDecoration(
      color: headerBackgroundColor,
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
    );
  }

  // Decoración del CircleAvatar del encabezado
  static BoxDecoration headerAvatarDecoration() {
    return BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.white.withOpacity(0.1),
    );
  }

  // Estilo del ícono del encabezado
  static const Color headerIconColor = Colors.white;
  static const double headerIconSize = 50;

  // Estilo del título del encabezado
  static const TextStyle headerTitleTextStyle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    letterSpacing: 1.2,
  );

  // Estilo del subtítulo del encabezado
  static TextStyle headerSubtitleTextStyle = TextStyle(
    fontSize: 16,
    color: Colors.white.withOpacity(0.7),
  );

  // Estilo del AppBar
  static const TextStyle appBarTitleTextStyle = TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
    fontSize: 22,
  );

  static const Color appBarIconColor = Colors.white;

  // Decoración de la tarjeta de paciente
  static BoxDecoration pacienteCardDecoration() {
    return BoxDecoration(
      color: cardBackgroundColor,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  // Decoración del CircleAvatar de la tarjeta
  static BoxDecoration pacienteAvatarDecoration() {
    return BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.white.withOpacity(0.2),
    );
  }

  // Estilo del ícono de la tarjeta
  static const Color pacienteIconColor = Colors.white;
  static const double pacienteIconSize = 30;

  // Estilo del texto del nombre en la tarjeta
  static const TextStyle pacienteNameTextStyle = TextStyle(
    fontWeight: FontWeight.bold,
    color: Colors.white,
    fontSize: 18,
  );

  // Estilo del texto del correo en la tarjeta
  static TextStyle pacienteEmailTextStyle = TextStyle(
    color: Colors.white.withOpacity(0.7),
    fontSize: 14,
  );

  // Estilo del ícono de flecha en la tarjeta
  static const Color arrowIconColor = Colors.white;
  static const double arrowIconSize = 20;

  // Estilo del texto cuando no hay pacientes
  static const TextStyle noPacientesTextStyle = TextStyle(
    fontSize: 18,
    color: Colors.white70,
    fontWeight: FontWeight.w500,
  );

  // Estilo del CircularProgressIndicator
  static const Color loadingIndicatorColor = Colors.white;
}