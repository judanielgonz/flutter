import 'package:flutter/material.dart';

class AsignarMedicoStyles {
  // Color principal (usado en AppBar y botón)
  static const Color primaryColor = Colors.teal;

  // Estilo del título del AppBar
  static const TextStyle appBarTitleStyle = TextStyle(
    color: Colors.white,
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  // Estilo del título de la pantalla
  static const TextStyle titleStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  );

  // Estilo del texto de error
  static const TextStyle errorTextStyle = TextStyle(
    color: Colors.red,
    fontSize: 16,
  );

  // Estilo del título en las tarjetas de médicos
  static const TextStyle medicoCardTitleStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.black87,
  );

  // Estilo del subtítulo en las tarjetas de médicos
  static const TextStyle medicoCardSubtitleStyle = TextStyle(
    fontSize: 14,
    color: Colors.grey,
  );

  // Estilo del botón elevado
  static ButtonStyle elevatedButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: primaryColor,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  // Estilo del texto del botón
  static const TextStyle buttonTextStyle = TextStyle(
    color: Colors.white,
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  // Estilo de la tarjeta de médico
  static BoxDecoration medicoCardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  // Estilo del CircularProgressIndicator
  static Color get progressIndicatorColor => primaryColor;
}