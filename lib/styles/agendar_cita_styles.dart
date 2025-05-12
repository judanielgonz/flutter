import 'package:flutter/material.dart';

class AgendarCitaStyles {
  // Color principal usado en la pantalla
  static const primaryColor = Color(0xFF00695C);

  // Estilo del título de la AppBar
  static const appBarTitleStyle = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 24,
    color: Colors.white,
  );

  // Fondo de la AppBar
  static const appBarBackgroundColor = primaryColor;

  // Gradiente del fondo del body
  static const bodyGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color.fromRGBO(0, 105, 92, 0.1), // primaryColor con opacidad 0.1
      Colors.white,
    ],
  );

  // Estilo del texto de error
  static const errorTextStyle = TextStyle(
    color: Colors.red,
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );

  // Decoración del contenedor de error
  static final errorContainerDecoration = BoxDecoration(
    color: Colors.red.withOpacity(0.1),
    borderRadius: BorderRadius.circular(15),
  );

  // Decoración del contenedor de información del médico
  static const medicoContainerDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.all(Radius.circular(15)),
    boxShadow: [
      BoxShadow(
        color: Colors.black12,
        blurRadius: 10,
        offset: Offset(0, 5),
      ),
    ],
  );

  // Estilo del texto "Médico Asignado"
  static const medicoLabelStyle = TextStyle(
    fontSize: 16,
    color: Colors.grey,
  );

  // Estilo del nombre del médico
  static const medicoNameStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: primaryColor,
  );

  // Estilo del texto "Disponibilidades Disponibles"
  static const disponibilidadesTitleStyle = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: primaryColor,
  );

  // Decoración del contenedor de "No hay disponibilidades"
  static const noDisponibilidadesContainerDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.all(Radius.circular(15)),
    boxShadow: [
      BoxShadow(
        color: Colors.black12,
        blurRadius: 10,
        offset: Offset(0, 5),
      ),
    ],
  );

  // Estilo del texto de "No hay disponibilidades"
  static const noDisponibilidadesTextStyle = TextStyle(
    fontSize: 16,
    color: Colors.grey,
  );

  // Estilo del ListTile para disponibilidades
  static const disponibilidadTitleStyle = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 16,
    color: primaryColor,
  );

  // Estilo del subtítulo de disponibilidades (horario, consultorio)
  static const disponibilidadSubtitleStyle = TextStyle(fontSize: 14);

  // Estilo del botón "Agendar"
  static final agendarButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: primaryColor,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
  );

  // Estilo del texto del botón "Agendar"
  static const agendarButtonTextStyle = TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
  );

  // Decoración de la Card de disponibilidades
  static final disponibilidadCardDecoration = BoxDecoration(
    borderRadius: BorderRadius.all(Radius.circular(15)),
    boxShadow: [
      BoxShadow(
        color: Colors.black12,
        blurRadius: 3,
        offset: Offset(0, 1),
      ),
    ],
  );

  // Estilo del SnackBar
  static const snackBarBackgroundColor = primaryColor;
}