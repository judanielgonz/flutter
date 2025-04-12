import 'package:flutter/material.dart';
import 'login.dart';
import 'registro.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
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

//este codigo se llama main.dart