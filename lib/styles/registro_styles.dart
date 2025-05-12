import 'package:flutter/material.dart';

class RegistroStyles {
  // Colores principales (tonos teal para pacientes)
  static const Color primaryColor = Colors.teal;
  static Color accentColor = Colors.teal.shade500;
  static Color gradientStart = Colors.teal.shade700;
  static Color gradientEnd = Colors.teal.shade300;

  // Fondo de la pantalla
  static BoxDecoration backgroundDecoration() {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [gradientStart, gradientEnd],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    );
  }

  // Decoración del encabezado
  static BoxDecoration headerDecoration() {
    return BoxDecoration(
      color: accentColor.withOpacity(0.9),
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(30),
        bottomRight: Radius.circular(30),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  // Estilo del título del encabezado
  static const TextStyle headerTitleStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  // Estilo del ícono de retroceso
  static const Color backIconColor = Colors.white;
  static const double backIconSize = 28;

  // Decoración del contenedor del formulario
  static BoxDecoration formContainerDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 10,
          offset: const Offset(0, 5),
        ),
      ],
    );
  }

  // Estilo del título del formulario
  static TextStyle formTitleStyle() {
    return TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: accentColor,
    );
  }

  // Estilo del TextField
  static InputDecoration textFieldDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: accentColor),
      hintText: 'Ingresa tu $label',
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: accentColor, width: 2),
      ),
      prefixIcon: Icon(
        icon,
        color: accentColor,
      ),
    );
  }

  // Estilo del texto del TextField
  static const TextStyle textFieldTextStyle = TextStyle(color: Colors.black87);

  // Estilo del botón de registrar
  static ButtonStyle primaryButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: accentColor,
      padding: const EdgeInsets.symmetric(vertical: 15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 5,
    );
  }

  // Estilo del botón de volver a login
  static ButtonStyle secondaryButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.grey.shade400,
      padding: const EdgeInsets.symmetric(vertical: 15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 5,
    );
  }

  // Estilo del texto de los botones
  static const TextStyle buttonTextStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  // Estilo del texto de error
  static const TextStyle errorTextStyle = TextStyle(
    color: Colors.red,
    fontSize: 16,
  );

  // Estilo del CircularProgressIndicator
  static Color loadingIndicatorColor = Colors.teal.shade500;

  // Estilo del SnackBar
  static Color snackBarBackgroundColor = Colors.red.shade500;
}