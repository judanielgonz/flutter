import 'package:flutter/material.dart';

class AppStyles {
  // Colores por rol (médico, paciente, admin/secretario)
  static Map<String, Color> getColorsForRole(String tipoUsuario) {
    switch (tipoUsuario) {
      case 'medico':
        return {
          'header': Colors.red.shade600,
          'headerGradient': Colors.red.shade400,
          'accent': Colors.red.shade500,
          'iconBackground': Colors.red.shade500,
        };
      case 'paciente':
        return {
          'header': Colors.blue.shade600,
          'headerGradient': Colors.blue.shade400,
          'accent': Colors.blue.shade500,
          'iconBackground': Colors.blue.shade500,
        };
      default:
        return {
          'header': Colors.teal.shade600,
          'headerGradient': Colors.teal.shade400,
          'accent': Colors.teal.shade500,
          'iconBackground': Colors.teal.shade500,
        };
    }
  }

  // Colores para SnackBar
  static const Color successSnackBarBackgroundColor = Colors.green;
  static const Color errorSnackBarBackgroundColor = Colors.redAccent;
  static const Color warningSnackBarBackgroundColor = Colors.orange;
}