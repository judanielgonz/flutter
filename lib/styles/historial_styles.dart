import 'package:flutter/material.dart';

class HistorialStyles {
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

  // Estilo del texto del título "Historial Médico"
  static const headerTitleStyle = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  // Estilo del texto del nombre del paciente
  static const patientNameStyle = TextStyle(
    fontSize: 14,
    color: Colors.white70,
  );

  // Decoración del encabezado
  static BoxDecoration headerDecoration(Map<String, Color> colors) {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [colors['header']!, colors['headerGradient']!],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(20),
        bottomRight: Radius.circular(20),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  // Estilo de los tabs
  static TabBar tabBarStyle(Map<String, Color> colors) {
    return TabBar(
      isScrollable: true,
      indicatorColor: colors['accent'],
      labelColor: colors['accent'],
      unselectedLabelColor: Colors.grey,
      tabs: const [
        Tab(text: 'Síntomas'),
        Tab(text: 'Órdenes de Análisis'),
        Tab(text: 'Análisis'),
        Tab(text: 'Diagnósticos'),
        Tab(text: 'Tratamiento'),
        Tab(text: 'Medicamentos'),
        Tab(text: 'Documentos'),
      ],
    );
  }

  // Estilo del texto para "No hay registros"
  static const noRecordsTextStyle = TextStyle(
    fontSize: 18,
    color: Colors.grey,
  );

  // Decoración de las Cards
  static BoxDecoration cardDecoration(Map<String, Color> colors) {
    return BoxDecoration(
      color: Colors.white,
      border: Border.all(color: colors['accent']!),
      borderRadius: BorderRadius.circular(15),
    );
  }

  // Estilo del título de las entradas
  static const entryTitleStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.black87,
  );

  // Estilo del texto de la fecha
  static const dateTextStyle = TextStyle(
    fontSize: 12,
    color: Colors.grey,
  );

  // Decoración del contenedor de elementos relacionados
  static const relatedContainerDecoration = BoxDecoration(
    color: Colors.greenAccent,
    borderRadius: BorderRadius.all(Radius.circular(8)),
    border: Border(
      left: BorderSide(color: Colors.green),
      top: BorderSide(color: Colors.green),
      right: BorderSide(color: Colors.green),
      bottom: BorderSide(color: Colors.green),
    ),
  );

  // Estilo del texto de elementos relacionados
  static const relatedTextStyle = TextStyle(
    fontSize: 12,
    color: Colors.green,
    fontStyle: FontStyle.italic,
  );

  // Estilo del FloatingActionButton
  static FloatingActionButton floatingActionButton(
      Map<String, Color> colors, VoidCallback onPressed) {
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: colors['accent'],
      child: const Icon(Icons.add, color: Colors.white, size: 30),
      elevation: 6,
      tooltip: 'Agregar entrada',
    );
  }

  // Estilo del título del diálogo de contenido completo
  static TextStyle dialogTitleStyle(Map<String, Color> colors) {
    return TextStyle(
      fontWeight: FontWeight.bold,
      color: colors['accent'],
    );
  }

  // Estilo del contenido del diálogo
  static const dialogContentStyle = TextStyle(
    fontSize: 16,
    color: Colors.black87,
  );

  // Estilo del botón "Cerrar" del diálogo
  static const dialogCloseButtonStyle = TextStyle(color: Colors.grey);

  // Estilo del botón "Copiar" del diálogo
  static const dialogCopyButtonStyle = TextStyle(color: Colors.blue);

  // Estilo del SnackBar de error
  static const errorSnackBarBackgroundColor = Colors.redAccent;

  // Estilo del SnackBar de copia exitosa
  static const successSnackBarBackgroundColor = Colors.green;
}