import 'package:flutter/material.dart';

class RegistrarDisponibilidadStyles {
  // Colores principales
  static const Color primaryColor = Colors.red;
  static Color accentColor = Colors.red.shade500;
  static Color headerGradientStart = Colors.red.shade600;
  static Color headerGradientEnd = Colors.red.shade400;

  // Fondo de la pantalla
  static const Color backgroundColor = Colors.white;

  // Decoración del encabezado
  static BoxDecoration headerDecoration() {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [headerGradientStart, headerGradientEnd],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(20),
        bottomRight: Radius.circular(20),
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

  // Estilo del ícono de retroceso
  static const Color backIconColor = Colors.white;
  static const double backIconSize = 28;

  // Decoración del CircleAvatar del encabezado
  static const Color avatarOuterBackgroundColor = Colors.white;
  static Color avatarInnerBackgroundColor = Colors.red.shade500;

  // Estilo del ícono del CircleAvatar
  static const Color avatarIconColor = Colors.white;
  static const double avatarIconSize = 24;

  // Estilo del título del encabezado
  static const TextStyle headerTitleStyle = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  // Estilo del contenedor de error
  static BoxDecoration errorContainerDecoration() {
    return BoxDecoration(
      color: Colors.red.shade100,
      borderRadius: BorderRadius.circular(10),
    );
  }

  // Estilo del texto de error
  static const TextStyle errorTextStyle = TextStyle(
    color: Colors.white,
    fontSize: 16,
  );

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
      fontSize: 22,
      fontWeight: FontWeight.bold,
      color: accentColor,
    );
  }

  // Estilo del TextFormField
  static InputDecoration textFieldDecoration(String label, String hint, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: accentColor),
      hintText: hint,
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
      suffixIcon: Icon(
        icon,
        color: accentColor,
      ),
    );
  }

  // Estilo del texto del TextFormField
  static const TextStyle textFieldTextStyle = TextStyle(color: Colors.black87);

  // Estilo del botón de registrar/actualizar
  static ButtonStyle primaryButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: accentColor,
      padding: const EdgeInsets.symmetric(vertical: 15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 5,
    );
  }

  // Estilo del botón de cancelar edición
  static ButtonStyle cancelButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.grey.shade400,
      padding: const EdgeInsets.symmetric(vertical: 15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
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

  // Estilo del CircularProgressIndicator
  static Color loadingIndicatorColor = Colors.red.shade500;

  // Estilo del título de la sección de disponibilidades
  static TextStyle sectionTitleStyle() {
    return TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.bold,
      color: accentColor,
    );
  }

  // Decoración del contenedor cuando no hay disponibilidades
  static BoxDecoration noDisponibilidadesContainerDecoration() {
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

  // Estilo del texto cuando no hay disponibilidades
  static const TextStyle noDisponibilidadesTextStyle = TextStyle(
    fontSize: 16,
    color: Colors.grey,
  );

  // Decoración de la tarjeta de disponibilidad
  static ShapeBorder disponibilidadCardDecoration() {
    return RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15),
      side: BorderSide(color: accentColor),
    );
  }

  // Estilo del ícono de la tarjeta
  static Color cardIconColor = Colors.red.shade500;
  static const double cardIconSize = 30;

  // Estilo del título de la tarjeta
  static TextStyle cardTitleStyle() {
    return TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 16,
      color: accentColor,
    );
  }

  // Estilo del subtítulo de la tarjeta
  static const TextStyle cardSubtitleStyle = TextStyle(
    fontSize: 14,
    color: Colors.black87,
  );

  // Estilo de los botones de acción (editar/eliminar)
  static Color editIconColor = Colors.red.shade500;
  static const Color deleteIconColor = Colors.red;
  static const double actionIconSize = 24;

  // Estilo del diálogo de eliminación
  static ShapeBorder dialogDecoration() {
    return RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15),
    );
  }

  static const TextStyle dialogTitleStyle = TextStyle(color: Colors.red);
  static const TextStyle dialogContentStyle = TextStyle(color: Colors.black);
  static const TextStyle dialogCancelTextStyle = TextStyle(color: Colors.grey);
  static const TextStyle dialogConfirmTextStyle = TextStyle(color: Colors.red);

  // Estilo del SnackBar
  static Color snackBarBackgroundColor = Colors.red.shade500;

  // Estilo del DatePicker y TimePicker
  static ThemeData pickerTheme(BuildContext context) {
    return ThemeData.light().copyWith(
      colorScheme: ColorScheme.light(
        primary: accentColor,
        onPrimary: Colors.white,
        surface: Colors.white,
        onSurface: Colors.black,
      ),
      dialogBackgroundColor: Colors.white,
    );
  }
}