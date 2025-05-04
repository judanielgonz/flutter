import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificacionesService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Inicializar las notificaciones
  Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _notificationsPlugin.initialize(initializationSettings);
    await _requestNotificationPermissions();
  }

  // Solicitar permisos para notificaciones
  Future<void> _requestNotificationPermissions() async {
    final status = await Permission.notification.request();
    if (status.isDenied) {
      print('Permiso de notificaciones denegado');
    }
  }

  // Enviar una notificación
  Future<void> showNotification({
    Map<String, dynamic>? notificacion,
    String? title,
    String? body,
  }) async {
    // Determinar el título y el cuerpo según los parámetros proporcionados
    final String notificationTitle = notificacion != null
        ? (notificacion['tipo']?.toString().capitalize() ?? 'Notificación')
        : (title ?? 'Notificación');
    final String notificationBody = notificacion != null
        ? (notificacion['contenido'] ?? 'Sin contenido')
        : (body ?? 'Sin contenido');

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'channel_id',
      'Canal de Notificaciones',
      channelDescription: 'Canal para notificaciones de SaludGest',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      0,
      notificationTitle,
      notificationBody,
      notificationDetails,
    );
  }
}

// Extensión para capitalizar cadenas
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}