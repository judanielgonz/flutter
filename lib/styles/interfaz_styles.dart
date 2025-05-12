import 'package:flutter/material.dart';

class InterfazStyles {
  // Colores por rol
  static Map<String, Color> getColorsForRole(String tipoUsuario) {
    switch (tipoUsuario) {
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

  // Decoración de gradiente para el fondo
  static BoxDecoration backgroundGradientDecoration(Map<String, Color> colors) {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [colors['gradientStart']!, colors['gradientEnd']!],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    );
  }

  // Decoración del encabezado
  static BoxDecoration headerDecoration(Color headerColor) {
    return BoxDecoration(
      color: headerColor,
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(50),
        bottomRight: Radius.circular(50),
      ),
    );
  }

  // Estilo del título del encabezado
  static const TextStyle headerTitleStyle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  // Estilo del texto del correo
  static const TextStyle emailTextStyle = TextStyle(
    fontSize: 16,
    color: Colors.white70,
  );

  // Estilo del texto del rol
  static const TextStyle roleTextStyle = TextStyle(
    fontSize: 14,
    color: Colors.white60,
  );

  // Decoración del botón moderno
  static BoxDecoration modernButtonDecoration(Map<String, Color> colors) {
    return BoxDecoration(
      color: colors['buttonBase'],
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

  // Propiedades del ícono del botón moderno
  static const Color buttonIconColor = Colors.white;
  static const double buttonIconSize = 40;

  // Estilo del texto del botón moderno
  static const TextStyle buttonTextStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  // Propiedades de la barra de navegación inferior
  static Map<String, dynamic> bottomNavStyles(Map<String, Color> colors) {
    return {
      'backgroundColor': colors['bottomNav'],
      'selectedItemColor': Colors.white,
      'unselectedItemColor': Colors.white70,
      'type': BottomNavigationBarType.fixed,
    };
  }
}