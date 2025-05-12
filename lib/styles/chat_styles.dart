import 'package:flutter/material.dart';

class ChatStyles {
  // Color principal (usado en AppBar, CircularProgressIndicator, etc.)
  static const Color primaryColor = Colors.teal;

  // Fondo del cuerpo del chat
  static const Color chatBackgroundColor = Color(0xFFF5F5F5); // Equivalente a Colors.grey.shade100

  // Estilo del título del AppBar
  static const TextStyle appBarTitleStyle = TextStyle(
    fontWeight: FontWeight.bold,
    color: Colors.white,
    fontSize: 20,
  );

  // Estilo del texto de error
  static const TextStyle errorTextStyle = TextStyle(
    color: Colors.red,
    fontSize: 16,
  );

  // Estilo del texto cuando no hay mensajes
  static TextStyle noMessagesTextStyle = TextStyle(
    color: Colors.grey.shade600,
    fontSize: 16,
  );

  // Decoración del contenedor de mensajes (enviados por el usuario)
  static BoxDecoration messageSentDecoration() {
    return BoxDecoration(
      color: Colors.teal.shade400,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  // Decoración del contenedor de mensajes (recibidos)
  static BoxDecoration messageReceivedDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  // Estilo del texto del contenido del mensaje (enviado)
  static const TextStyle messageSentTextStyle = TextStyle(
    fontSize: 16,
    color: Colors.white,
  );

  // Estilo del texto del contenido del mensaje (recibido)
  static const TextStyle messageReceivedTextStyle = TextStyle(
    fontSize: 16,
    color: Colors.black87,
  );

  // Estilo del texto de la hora (enviado)
  static const TextStyle messageSentTimeStyle = TextStyle(
    fontSize: 12,
    color: Colors.white70,
  );

  // Estilo del texto de la hora (recibido)
  static TextStyle messageReceivedTimeStyle = TextStyle(
    fontSize: 12,
    color: Colors.grey.shade600,
  );

  // Decoración del contenedor de la barra de entrada
  static BoxDecoration inputBarDecoration() {
    return BoxDecoration(
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 4,
          offset: const Offset(0, -2),
        ),
      ],
    );
  }

  // Estilo del TextField de entrada
  static InputDecoration messageInputDecoration() {
    return InputDecoration(
      hintText: "Escribe un mensaje...",
      hintStyle: TextStyle(color: Colors.grey.shade500),
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    );
  }

  // Estilo del botón de enviar
  static const Color sendButtonBackgroundColor = Colors.teal;
  static const Color sendButtonIconColor = Colors.white;
  static const double sendButtonRadius = 24;
}