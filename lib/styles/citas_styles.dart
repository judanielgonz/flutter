import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:table_calendar/table_calendar.dart';

class CitasStyles {
  // Colores por rol
  static Map<String, Color> getColorsForRole(String tipoUsuario) {
    switch (tipoUsuario) {
      case 'medico':
        return {
          'header': Colors.red.shade600,
          'headerGradient': Colors.red.shade400,
          'accent': Colors.red.shade500,
          'calendarToday': Colors.red.shade100,
          'calendarSelected': Colors.red.shade400,
          'calendarMarker': Colors.red.shade300,
          'iconBackground': Colors.red.shade500,
        };
      case 'paciente':
        return {
          'header': Colors.blue.shade600,
          'headerGradient': Colors.blue.shade400,
          'accent': Colors.blue.shade500,
          'calendarToday': Colors.blue.shade100,
          'calendarSelected': Colors.blue.shade400,
          'calendarMarker': Colors.blue.shade300,
          'iconBackground': Colors.blue.shade500,
        };
      default:
        return {
          'header': Colors.teal.shade600,
          'headerGradient': Colors.teal.shade400,
          'accent': Colors.teal.shade500,
          'calendarToday': Colors.teal.shade100,
          'calendarSelected': Colors.teal.shade400,
          'calendarMarker': Colors.teal.shade300,
          'iconBackground': Colors.teal.shade500,
        };
    }
  }

  // Estilo de la barra de estado
  static SystemUiOverlayStyle statusBarStyle(Map<String, Color> colors) {
    return SystemUiOverlayStyle(
      statusBarColor: colors['header'],
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    );
  }

  // Decoración del encabezado
  static BoxDecoration headerDecoration(Map<String, Color> colors) {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [colors['header']!, colors['headerGradient']!],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
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

  // Decoración del botón de retroceso
  static BoxDecoration backButtonDecoration() {
    return BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  // Estilo del ícono del botón de retroceso
  static const Color backButtonIconColor = Colors.black;
  static const double backButtonIconSize = 28;

  // Decoración del CircleAvatar del usuario
  static BoxDecoration userAvatarOuterDecoration() {
    return const BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.white,
    );
  }

  static BoxDecoration userAvatarInnerDecoration(Map<String, Color> colors) {
    return BoxDecoration(
      shape: BoxShape.circle,
      color: colors['iconBackground'],
    );
  }

  // Estilo del ícono del usuario
  static const Color userIconColor = Colors.white;
  static const double userIconSize = 44;

  // Estilo del texto del nombre del usuario
  static const TextStyle userNameTextStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  // Estilo del texto del correo y rol
  static const TextStyle userDetailsTextStyle = TextStyle(
    fontSize: 14,
    color: Colors.white70,
  );

  // Estilo del ícono de persona en el encabezado
  static const Color personIconColor = Colors.white;
  static const double personIconSize = 20;

  // Decoración del contenedor del calendario y citas
  static BoxDecoration sectionContainerDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  // Estilo del título de la sección (Calendario y Citas)
  static TextStyle sectionTitleStyle(Map<String, Color> colors) {
    return TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: colors['accent'],
    );
  }

  // Estilo del ícono de la sección (Calendario y Citas)
  static double sectionIconSize = 24;
  static Color sectionIconColor(Map<String, Color> colors) => colors['accent']!;

  // Estilo del calendario
  static CalendarStyle calendarStyle(Map<String, Color> colors) {
    return CalendarStyle(
      todayDecoration: BoxDecoration(
        color: colors['calendarToday'],
        shape: BoxShape.circle,
      ),
      selectedDecoration: BoxDecoration(
        color: colors['calendarSelected'],
        shape: BoxShape.circle,
      ),
      markerDecoration: BoxDecoration(
        color: colors['calendarMarker'],
        shape: BoxShape.circle,
      ),
      outsideTextStyle: TextStyle(color: Colors.grey.shade400),
      defaultTextStyle: const TextStyle(color: Colors.black87),
      weekendTextStyle: TextStyle(color: Colors.grey.shade600),
      disabledTextStyle: TextStyle(color: Colors.grey.shade300),
      holidayTextStyle: const TextStyle(color: Colors.black87),
    );
  }

  static DaysOfWeekStyle daysOfWeekStyle() {
    return DaysOfWeekStyle(
      weekdayStyle: TextStyle(color: Colors.grey.shade700),
      weekendStyle: TextStyle(color: Colors.grey.shade600),
    );
  }

  static HeaderStyle calendarHeaderStyle(Map<String, Color> colors) {
    return HeaderStyle(
      titleTextStyle: const TextStyle(color: Colors.black87, fontSize: 18),
      formatButtonTextStyle: const TextStyle(color: Colors.white),
      formatButtonDecoration: BoxDecoration(
        color: colors['accent'],
        borderRadius: const BorderRadius.all(Radius.circular(12)),
      ),
      leftChevronIcon: Icon(Icons.chevron_left, color: colors['accent']),
      rightChevronIcon: Icon(Icons.chevron_right, color: colors['accent']),
    );
  }

  // Estilo del texto de error
  static const TextStyle errorTextStyle = TextStyle(
    color: Colors.red,
    fontSize: 16,
  );

  // Estilo del texto cuando no hay citas
  static const TextStyle noCitasTextStyle = TextStyle(
    fontSize: 16,
    color: Colors.black54,
  );

  // Decoración de la tarjeta de cita
  static BoxDecoration citaCardDecoration(Map<String, Color> colors) {
    return BoxDecoration(
      color: Colors.white,
      border: Border.all(color: colors['accent']!),
      borderRadius: BorderRadius.circular(15),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  // Decoración del ícono de la cita
  static BoxDecoration citaIconDecoration(Map<String, Color> colors) {
    return BoxDecoration(
      color: colors['accent']!.withOpacity(0.1),
      borderRadius: BorderRadius.circular(10),
    );
  }

  // Estilo del ícono de la cita
  static Color citaIconColor(Map<String, Color> colors) => colors['accent']!;
  static const double citaIconSize = 30;

  // Estilo del texto de la fecha de la cita
  static const TextStyle citaDateTextStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  );

  // Estilo del texto de detalles de la cita (horario, médico/paciente)
  static const TextStyle citaDetailsTextStyle = TextStyle(
    fontSize: 14,
    color: Colors.black54,
  );

  // Estilo del botón de cancelar
  static const Color cancelButtonColor = Colors.red;
  static const double cancelButtonIconSize = 24;

  // Estilo del diálogo de confirmación
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
  static Color snackBarBackgroundColor(Map<String, Color> colors) => colors['accent']!;
}