import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'login.dart';
import 'registro.dart';

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
  // Mostrar notificación en segundo plano
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
  @override
  void initState() {
    super.initState();

    // Manejar notificaciones en primer plano
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Notificación en primer plano recibida: ${message.notification?.title}');
      _showNotification(message);
    });

    // Manejar notificaciones cuando la app se abre desde una notificación
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('App abierta desde notificación: ${message.notification?.title}');
      // Aquí puedes navegar a una pantalla específica, como ChatPage
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mi App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(),
      routes: {
        '/registro': (context) => RegistroPage(),
        '/login': (context) => LoginPage(),
      },
    );
  }
}