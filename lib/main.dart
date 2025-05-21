import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login.dart';
import 'registro.dart';
import 'interfaz.dart';

// Configuración del canal de notificaciones para Android
const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel', // ID del canal
  'High Importance Notifications', // Nombre del canal
  description: 'Este canal se usa para notificaciones importantes.',
  importance: Importance.high,
);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

// Manejador de notificaciones en segundo plano
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Notificación en segundo plano recibida: ${message.notification?.title}');
  _showNotification(message);
}

Future<void> _showNotification(RemoteMessage message) async {
  final RemoteNotification? notification = message.notification;
  if (notification != null) {
    await flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Configurar manejador de notificaciones en segundo plano
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Configurar flutter_local_notifications
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // Crear el canal de notificaciones para Android
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  // Configurar notificaciones en primer plano
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Widget? _initialScreen;

  @override
  void initState() {
    super.initState();
    _determineInitialScreen();

    // Manejar notificaciones en primer plano
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Notificación en primer plano recibida: ${message.notification?.title}');
      _showNotification(message);
      if (message.data['type'] == 'alarm') {
        print('Notificación de alarma recibida: ${message.data}');
        // Nota: Para actualizar _hasPendingAlarm, necesitarías un sistema de estado global (e.g., Provider)
      }
    });

    // Manejar notificaciones cuando la app se abre desde una notificación
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('App abierta desde notificación: ${message.notification?.title}');
      if (message.data['type'] == 'alarm') {
        print('Notificación de alarma al abrir app: ${message.data}');
        // Navegar a InterfazPage si ya está autenticado
        _navigateIfAuthenticated();
      }
    });

    // Obtener el token FCM inicial y imprimirlo para pruebas
    FirebaseMessaging.instance.getToken().then((token) {
      print('Token FCM: $token');
    });

    // Manejar la actualización del token FCM
    FirebaseMessaging.instance.onTokenRefresh.listen((token) {
      print('Token FCM actualizado: $token');
      // Enviar el token actualizado al backend si es necesario
    });
  }

  Future<void> _determineInitialScreen() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final correo = prefs.getString('correo');
      final tipoUsuario = prefs.getString('tipoUsuario');
      final usuarioId = prefs.getString('usuarioId');
      final medicoAsignado = prefs.getString('medicoAsignado');

      if (correo != null && tipoUsuario != null && usuarioId != null) {
        print('Sesión encontrada - Navegando a InterfazPage para $correo');
        setState(() {
          _initialScreen = InterfazPage(
            correo: correo,
            tipoUsuario: tipoUsuario,
            usuarioId: usuarioId,
            medicoAsignado: medicoAsignado,
          );
        });
      } else {
        print('No hay sesión activa - Navegando a LoginPage');
        setState(() {
          _initialScreen = const LoginPage();
        });
      }
    } catch (e) {
      print('Error al determinar pantalla inicial: $e');
      setState(() {
        _initialScreen = const LoginPage();
      });
    }
  }

  Future<void> _navigateIfAuthenticated() async {
    final prefs = await SharedPreferences.getInstance();
    final correo = prefs.getString('correo');
    final tipoUsuario = prefs.getString('tipoUsuario');
    final usuarioId = prefs.getString('usuarioId');
    final medicoAsignado = prefs.getString('medicoAsignado');

    if (correo != null && tipoUsuario != null && usuarioId != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => InterfazPage(
            correo: correo,
            tipoUsuario: tipoUsuario,
            usuarioId: usuarioId,
            medicoAsignado: medicoAsignado,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mi App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: _initialScreen ?? const Center(child: CircularProgressIndicator()),
      routes: {
        '/registro': (context) => RegistroPage(),
        '/login': (context) => LoginPage(),
      },
    );
  }
}