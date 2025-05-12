import 'package:flutter/material.dart';

class SeleccionarPacienteStyles {
  // Colores principales (tonos rojos para médicos)
  static Color gradientStart = Colors.red.shade800;
  static Color gradientEnd = Colors.red.shade600;
  static Color headerColor = Colors.red.shade900;
  static Color buttonBase = Colors.red.shade700;
  static Color buttonHoverStart = Colors.red.shade600;
  static Color buttonHoverEnd = Colors.red.shade400;

  // Fondo de la pantalla
  static BoxDecoration backgroundDecoration() {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [gradientStart, gradientEnd],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    );
  }

  // Decoración del encabezado
  static BoxDecoration headerDecoration() {
    return BoxDecoration(
      color: headerColor,
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(50),
        bottomRight: Radius.circular(50),
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

  // Estilo del ícono de retroceso
  static const Color backIconColor = Colors.white;
  static const double backIconSize = 28;

  // Estilo del CircleAvatar del encabezado
  static const Color avatarBackgroundColor = Colors.white;
  static const Color avatarIconColor = Colors.grey;
  static const double avatarIconSize = 40;
  static const double avatarRadius = 30;

  // Estilo del título del encabezado
  static const TextStyle headerTitleStyle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  // Estilo del CircularProgressIndicator
  static Color loadingIndicatorColor = Colors.red.shade900;

  // Decoración del contenedor de "No hay pacientes"
  static BoxDecoration noPacientesContainerDecoration() {
    return BoxDecoration(
      color: headerColor.withOpacity(0.1),
      borderRadius: BorderRadius.circular(15),
    );
  }

  // Estilo del texto de "No hay pacientes"
  static const TextStyle noPacientesTextStyle = TextStyle(
    fontSize: 16,
    color: Colors.white,
  );

  // Decoración de la tarjeta de paciente
  static BoxDecoration pacienteCardDecoration() {
    return BoxDecoration(
      color: buttonBase,
      borderRadius: BorderRadius.circular(15),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          blurRadius: 10,
          offset: const Offset(0, 5),
        ),
      ],
    );
  }

  // Decoración del InkWell (restaurado como BoxDecoration)
  static BoxDecoration pacienteInkWellDecoration() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(15),
    );
  }

  // Borde de InkWell como BorderRadius (método auxiliar)
  static BorderRadius pacienteInkWellBorderRadius() {
    return BorderRadius.circular(15);
  }

  // Color del efecto splash
  static Color splashColor(Color buttonHoverStart) {
    return buttonHoverStart.withOpacity(0.3);
  }

  // Estilo del ícono de la tarjeta
  static const Color pacienteIconColor = Colors.white;
  static const double pacienteIconSize = 40;

  // Estilo del texto del nombre en la tarjeta
  static const TextStyle pacienteNameTextStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  // Estilo del texto del correo en la tarjeta
  static const TextStyle pacienteEmailTextStyle = TextStyle(
    fontSize: 12,
    color: Colors.white70,
  );

  // Estilo del SnackBar
  static const Color snackBarBackgroundColor = Colors.red;
}