import 'package:flutter/material.dart';

class HistorialDialogsStyles {
  // Estilo del título de los diálogos
  static TextStyle dialogTitleStyle(Map<String, Color> colors) {
    return TextStyle(
      fontWeight: FontWeight.bold,
      color: colors['accent'],
      fontSize: 20,
    );
  }

  // Estilo del título de los diálogos con gradiente
  static TextStyle dialogGradientTitleStyle() {
    return const TextStyle(
      fontWeight: FontWeight.bold,
      color: Colors.white,
      fontSize: 20,
    );
  }

  // Estilo del contenido del diálogo de diagnóstico
  static TextStyle diagnosisContentStyle(Map<String, Color> colors) {
    return TextStyle(
      fontWeight: FontWeight.bold,
      color: colors['accent'],
    );
  }

  // Estilo del botón "Cancelar" de los diálogos
  static TextStyle cancelButtonStyle() {
    return TextStyle(
      color: Colors.grey.shade600,
      fontWeight: FontWeight.w600,
    );
  }

  // Estilo del botón "Cerrar" de los diálogos
  static const closeButtonStyle = TextStyle(color: Colors.grey);

  // Estilo del botón "Copiar" de los diálogos
  static const copyButtonStyle = TextStyle(color: Colors.blue);

  // Estilo del botón "Usar Diagnóstico"
  static TextStyle useDiagnosisButtonStyle(Map<String, Color> colors) {
    return TextStyle(color: colors['accent']);
  }

  // Estilo del botón elevado (Guardar, Generar Diagnóstico, etc.)
  static ButtonStyle elevatedButtonStyle(Map<String, Color> colors) {
    return ElevatedButton.styleFrom(
      backgroundColor: colors['accent'],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  // Decoración del contenedor del título con gradiente
  static BoxDecoration gradientTitleDecoration(Map<String, Color> colors) {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [colors['header']!, colors['headerGradient']!],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
    );
  }

  // Decoración de las opciones del diálogo
  static BoxDecoration dialogOptionDecoration() {
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

  // Estilo del texto de las opciones del diálogo
  static TextStyle dialogOptionTextStyle(Map<String, Color> colors) {
    return TextStyle(
      color: colors['accent'],
      fontWeight: FontWeight.w600,
      fontSize: 16,
    );
  }

  // Decoración del ícono de las opciones del diálogo
  static BoxDecoration dialogOptionIconDecoration(Map<String, Color> colors) {
    return BoxDecoration(
      color: colors['iconBackground']!.withOpacity(0.1),
      shape: BoxShape.circle,
    );
  }

  // Estilo del ícono de avance en las opciones del diálogo
  static Icon dialogOptionForwardIcon(Map<String, Color> colors) {
    return Icon(
      Icons.arrow_forward_ios,
      color: colors['accent']!.withOpacity(0.5),
      size: 16,
    );
  }

  // Decoración de los campos de texto
  static InputDecoration textFieldDecoration(Map<String, Color> colors, String labelText, IconData icon) {
    return InputDecoration(
      labelText: labelText,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      prefixIcon: Icon(icon, color: colors['accent']),
      filled: true,
      fillColor: Colors.grey.shade50,
    );
  }

  // Decoración de los DropdownButton
  static BoxDecoration dropdownDecoration() {
    return BoxDecoration(
      border: Border.all(color: Colors.grey.shade300),
      borderRadius: BorderRadius.circular(12),
      color: Colors.grey.shade50,
    );
  }

  // Estilo del texto de las etiquetas de enlazar (síntoma, diagnóstico, etc.)
  static TextStyle linkLabelStyle(Map<String, Color> colors) {
    return TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: colors['accent'],
    );
  }

  // Estilo del texto de "No hay registros"
  static const noRecordsTextStyle = TextStyle(color: Colors.grey);

  // Estilo de los ToggleButtons
  static ButtonStyle toggleButtonStyle(Map<String, Color> colors) {
    return ButtonStyle(
      shape: WidgetStateProperty.all(RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      )),
      foregroundColor: WidgetStateProperty.resolveWith((states) => Colors.black),
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return colors['accent'];
        }
        return null;
      }),
      side: WidgetStateProperty.all(BorderSide(color: Colors.grey.shade300)),
      textStyle: WidgetStateProperty.all(const TextStyle(color: Colors.white)),
    );
  }

  // Estilo del texto de los elementos en los DropdownButton
  static const dropdownItemTextStyle = TextStyle(
    fontSize: 14,
    color: Colors.black87,
  );

  // Estilo del SnackBar de éxito
  static const successSnackBarBackgroundColor = Colors.green;

  // Estilo del SnackBar de error
  static const errorSnackBarBackgroundColor = Colors.redAccent;

  // Estilo del SnackBar de advertencia
  static const warningSnackBarBackgroundColor = Colors.orange;

  // Estilo del CheckboxListTile
  static TextStyle checkboxListTileTextStyle(Map<String, Color> colors) {
    return TextStyle(color: colors['accent']);
  }
}