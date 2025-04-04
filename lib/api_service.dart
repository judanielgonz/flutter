import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = 'http://10.0.2.2:3000'; // Ajustar según entorno (localhost para emulador Android)

  // Login
  Future<Map<String, dynamic>> login(Map<String, String> credentials) async {
    final url = Uri.parse('$baseUrl/api/pacientes/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(credentials),
    );
    print('Respuesta del servidor al hacer login: ${response.body}');
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return json.decode(response.body);
    }
  }

  // Registrar paciente
  Future<Map<String, dynamic>> savePaciente(Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/api/pacientes/save-data');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al guardar el paciente: ${response.body}');
    }
  }

  // Registrar médico
  Future<Map<String, dynamic>> registrarMedico(Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/api/pacientes/registrar-medico');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
    print('Respuesta del servidor al registrar médico: ${response.statusCode} - ${response.body}'); // Depuración
    if (response.statusCode == 201 || response.statusCode == 200) { // Aceptar 200 y 201 como éxito
      final responseBody = json.decode(response.body);
      return {
        'success': responseBody['success'] ?? true, // Asegurar que siempre haya un success
        'error': responseBody['error'] ?? null,
      };
    } else {
      final responseBody = json.decode(response.body);
      return {
        'success': false,
        'error': responseBody['error'] ?? 'Error al registrar el médico: ${response.body}',
      };
    }
  }

  // Asignar médico a paciente
  Future<Map<String, dynamic>> asignarMedico(String pacienteCorreo, String medicoCorreo) async {
    final url = Uri.parse('$baseUrl/api/pacientes/asignar-medico');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'pacienteCorreo': pacienteCorreo,
        'medicoCorreo': medicoCorreo,
      }),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al asignar el médico: ${response.body}');
    }
  }

  // Obtener médicos disponibles
  Future<List<dynamic>> getMedicosDisponibles() async {
    final url = Uri.parse('$baseUrl/api/pacientes/medicos-disponibles');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return data['medicos'];
      } else {
        throw Exception(data['error'] ?? 'Error al obtener médicos disponibles');
      }
    } else {
      throw Exception('Error al obtener médicos disponibles: ${response.body}');
    }
  }

  // Registrar disponibilidad de médico
  Future<Map<String, dynamic>> registrarDisponibilidad(Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/api/pacientes/registrar-disponibilidad');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'correo': data['medicoCorreo'],
        'dia': data['fecha'],
        'horario': '${data['hora_inicio']} - ${data['hora_fin']}',
      }),
    );
    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al registrar la disponibilidad: ${response.body}');
    }
  }

  // Obtener disponibilidad de médicos
  Future<List<dynamic>> getDisponibilidad() async {
    final url = Uri.parse('$baseUrl/api/pacientes/disponibilidad');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al obtener la disponibilidad: ${response.body}');
    }
  }

  // Agendar cita
  Future<Map<String, dynamic>> agendarCita(Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/api/pacientes/agendar-cita');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
    final responseBody = json.decode(response.body);
    if (response.statusCode == 201) {
      return responseBody;
    } else {
      throw Exception(responseBody['error'] ?? 'Error al agendar la cita');
    }
  }

  // Obtener citas
  Future<List<dynamic>> getCitas(String correo, String tipoUsuario) async {
    final url = Uri.parse('$baseUrl/api/pacientes/citas?correo=$correo&tipoUsuario=$tipoUsuario');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return data['citas'] ?? [];
      } else {
        throw Exception(data['error'] ?? 'Error al obtener las citas');
      }
    } else {
      throw Exception('Error al obtener las citas: ${response.body}');
    }
  }

  // Obtener datos de un paciente por correo
  Future<Map<String, dynamic>> getPacienteByCorreo(String correo) async {
    final url = Uri.parse('$baseUrl/api/pacientes/datos?correo=$correo');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> pacientes = json.decode(response.body);
      if (pacientes.isNotEmpty) {
        return pacientes[0] as Map<String, dynamic>;
      } else {
        throw Exception('Paciente no encontrado');
      }
    } else {
      throw Exception('Error al obtener el paciente: ${response.body}');
    }
  }

  // Obtener mensajes
  Future<List<Map<String, String>>> getMessages(String userId) async {
    final url = Uri.parse('$baseUrl/api/mensajes/$userId');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return List<Map<String, String>>.from(json.decode(response.body));
    } else {
      throw Exception('Error al obtener mensajes: ${response.body}');
    }
  }

  // Enviar mensaje
  Future<void> sendMessage(String userId, String message) async {
    final url = Uri.parse('$baseUrl/api/mensajes/enviar');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'to': userId, 'message': message}),
    );
    if (response.statusCode != 200) {
      throw Exception('Error al enviar mensaje: ${response.body}');
    }
  }

  // Registrar historial médico
  Future<void> registrarHistorialMedico(String correo, Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/api/pacientes/registrar-historial');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'correo': correo, 'historial': data}),
    );
    if (response.statusCode != 200) {
      throw Exception('Error al registrar historial: ${response.body}');
    }
  }

  // Obtener lista de pacientes
  Future<List<dynamic>> getPacientes() async {
    final url = Uri.parse('$baseUrl/api/pacientes?rol=Paciente');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al obtener pacientes: ${response.body}');
    }
  }

  // Obtener notificaciones
  Future<List<dynamic>> getNotificaciones() async {
    final url = Uri.parse('$baseUrl/api/notificaciones');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al obtener notificaciones: ${response.body}');
    }
  }

  // Registrar alarma
  Future<void> registrarAlarma(String correo, Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/api/alarmas');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'correo': correo, ...data}),
    );
    if (response.statusCode != 201) {
      throw Exception('Error al registrar alarma: ${response.body}');
    }
  }

  // Actualizar datos de persona (para Configuración)
  Future<Map<String, dynamic>> updatePersona(String correo, Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/api/pacientes/update');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'correo': correo, ...data}),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al actualizar persona: ${response.body}');
    }
  }
}