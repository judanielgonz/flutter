import 'package:flutter/material.dart';
import 'package:saludgest_app/login.dart';

class ConfiguracionPage extends StatefulWidget {
  @override
  _ConfiguracionPageState createState() => _ConfiguracionPageState();
}

class _ConfiguracionPageState extends State<ConfiguracionPage> {
  void _logout(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Configuración"),
        backgroundColor: Colors.teal,
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade50, Colors.teal.shade200],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            _buildConfigTile(Icons.person, "Editar Perfil", () {
              // Lógica para editar perfil (falta implementar)
            }),
            _buildConfigTile(Icons.notifications, "Notificaciones", () {
              // Lógica para configurar notificaciones (falta Firebase)
            }),
            _buildConfigTile(Icons.lock, "Privacidad y Seguridad", () {
              // Lógica para ajustes de privacidad
            }),
            _buildConfigTile(Icons.info, "Acerca de la App", () {
              // Mostrar información de la app
              showAboutDialog(context: context, applicationName: "SaludGest", applicationVersion: "1.0");
            }),
            Divider(),
            _buildLogoutButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildConfigTile(IconData icon, String title, VoidCallback onTap) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: ListTile(
        leading: Icon(icon, color: Colors.teal),
        title: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        trailing: Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.redAccent,
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: () => _logout(context),
        icon: Icon(Icons.logout, color: Colors.white),
        label: Text("Cerrar Sesión", style: TextStyle(color: Colors.white, fontSize: 16)),
      ),
    );
  }
}