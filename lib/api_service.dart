import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http_parser/http_parser.dart';

class ApiService {
  final String baseUrl = 'http://10.0.2.2:3000';

  Future<Map<String, dynamic>> login(Map<String, String> credentials) async {
    final url = Uri.parse('$baseUrl/api/pacientes/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(credentials),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return {
        'success': data['success'],
        'tipoUsuario': data['tipoUsuario'],
        'medicoAsignado': data['medicoAsignado'],
        'usuarioId': data['usuarioId'],
        'nombre': data['nombre'],
      };
    } else {
      return json.decode(response.body);
    }
  }

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

  Future<Map<String, dynamic>> registrarMedico(Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/api/pacientes/registrar-medico');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      final responseBody = json.decode(response.body);
      return {
        'success': responseBody['success'] ?? true,
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

  Future<Map<String, dynamic>> forgotPassword(String correo) async {
    final url = Uri.parse('$baseUrl/api/pacientes/forgot-password');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'correo': correo}),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception(json.decode(response.body)['error'] ?? 'Error al solicitar restablecimiento');
    }
  }

  Future<Map<String, dynamic>> resetPassword(String correo, String token, String newPassword) async {
    final url = Uri.parse('$baseUrl/api/pacientes/reset-password');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'correo': correo,
        'token': token,
        'newPassword': newPassword,
      }),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception(json.decode(response.body)['error'] ?? 'Error al restablecer contraseña');
    }
  }

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

  Future<Map<String, dynamic>> registrarDisponibilidad(Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/api/pacientes/registrar-disponibilidad');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'correo': data['correo'],
        'dia': data['dia'],
        'horario': data['horario'],
        'consultorio': data['consultorio'],
      }),
    );
    final responseBody = json.decode(response.body);
    if (response.statusCode == 201) {
      return responseBody;
    } else {
      throw Exception(responseBody['error'] ?? 'Error al registrar la disponibilidad: ${response.body}');
    }
  }

  Future<List<dynamic>> getDisponibilidades(String medicoCorreo) async {
    final url = Uri.parse('$baseUrl/api/pacientes/disponibilidad');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final disponibilidades = json.decode(response.body);
      final filteredDisponibilidades = disponibilidades.where((disp) => disp['correo'] == medicoCorreo).toList();
      return filteredDisponibilidades;
    } else {
      throw Exception('Error al obtener las disponibilidades: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> agendarCita(Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/api/pacientes/agendar-cita');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'pacienteCorreo': data['pacienteCorreo'],
        'medicoCorreo': data['medicoCorreo'],
        'dia': data['dia'],
        'horario': data['horario'],
      }),
    );
    final responseBody = json.decode(response.body);
    if (response.statusCode == 201) {
      return responseBody;
    } else {
      throw Exception(responseBody['error'] ?? 'Error al agendar la cita: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> cancelarCita(String citaId, String usuarioCorreo, String tipoUsuario) async {
    final url = Uri.parse('$baseUrl/api/citas/cancelar-cita');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'citaId': citaId,
        'usuarioCorreo': usuarioCorreo,
        'tipoUsuario': tipoUsuario,
      }),
    );
    final responseBody = json.decode(response.body);
    if (response.statusCode == 200) {
      return responseBody;
    } else {
      throw Exception(responseBody['error'] ?? 'Error al cancelar la cita: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> editarCita(
      String citaId, String usuarioCorreo, String tipoUsuario, Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/api/citas/editar-cita');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'citaId': citaId,
        'usuarioCorreo': usuarioCorreo,
        'tipoUsuario': tipoUsuario,
        'fecha': data['fecha'],
        'hora_inicio': data['hora_inicio'],
        'hora_fin': data['hora_fin'],
        'consultorio': data['consultorio'],
      }),
    );
    final responseBody = json.decode(response.body);
    if (response.statusCode == 200) {
      return responseBody;
    } else {
      throw Exception(responseBody['error'] ?? 'Error al editar la cita: ${response.body}');
    }
  }

  Future<List<dynamic>> getCitas(String correo, String tipoUsuario) async {
    final url = Uri.parse('$baseUrl/api/citas/citas?correo=$correo&tipoUsuario=$tipoUsuario');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return data['citas'] ?? [];
      } else {
        throw Exception(data['message'] ?? 'Error al obtener las citas');
      }
    } else {
      throw Exception('Error al obtener las citas: ${response.body}');
    }
  }

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

  Future<Map<String, dynamic>> obtenerPorId(String id) async {
    final url = Uri.parse('$baseUrl/api/pacientes/obtener-por-id?id=$id');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return data['persona'];
      } else {
        throw Exception(data['message'] ?? 'Persona no encontrada');
      }
    } else {
      throw Exception('Error al obtener la persona por ID: ${response.body}');
    }
  }

  Future<List<Map<String, String>>> getMessages(String userId) async {
    final url = Uri.parse('$baseUrl/api/mensajes/$userId');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return List<Map<String, String>>.from(json.decode(response.body));
    } else {
      throw Exception('Error al obtener mensajes: ${response.body}');
    }
  }

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

  Future<Map<String, dynamic>> eliminarDisponibilidad(Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/api/pacientes/eliminar-disponibilidad');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'correo': data['correo'],
        'dia': data['dia'],
        'horario': data['horario'],
      }),
    );
    final responseBody = json.decode(response.body);
    if (response.statusCode == 200) {
      return responseBody;
    } else {
      throw Exception(responseBody['error'] ?? 'Error al eliminar la disponibilidad: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> actualizarDisponibilidad(Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/api/pacientes/actualizar-disponibilidad');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'correo': data['correo'],
        'diaAntiguo': data['diaAntiguo'],
        'horarioAntiguo': data['horarioAntiguo'],
        'diaNuevo': data['diaNuevo'],
        'horarioNuevo': data['horarioNuevo'],
        'consultorio': data['consultorio'],
      }),
    );
    final responseBody = json.decode(response.body);
    if (response.statusCode == 200) {
      return responseBody;
    } else {
      throw Exception(responseBody['error'] ?? 'Error al actualizar la disponibilidad: ${response.body}');
    }
  }

  Future<List<dynamic>> getHistorialMedico(String correo) async {
    final url = Uri.parse('$baseUrl/api/historial/obtener-por-correo?correo=$correo');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return data['historial'] ?? [];
      } else {
        throw Exception(data['error'] ?? 'Error al obtener el historial médico');
      }
    } else {
      throw Exception('Error al obtener el historial médico: ${response.statusCode} - ${response.body}');
    }
  }

  Future<Map<String, dynamic>> guardarEntradaHistorial(
      String correoRegistrador, String tipo, String pacienteCorreo, Map<String, dynamic> datos, String nombrePaciente) async {
    final url = Uri.parse('$baseUrl/api/historial/guardar-entrada');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'correo': correoRegistrador,
        'tipo': tipo,
        'pacienteCorreo': pacienteCorreo,
        'datos': datos,
        'nombrePaciente': nombrePaciente,
      }),
    );

    final responseBody = json.decode(response.body);

    if (response.statusCode == 200 && responseBody['success'] == true) {
      return responseBody;
    } else {
      String errorMessage = responseBody['error'] ?? 'Error al guardar la entrada en el historial';
      if (responseBody['error']?.contains('diagnóstico especificado no existe') ?? false) {
        errorMessage = 'El diagnóstico seleccionado no existe en el historial del paciente.';
      } else if (responseBody['error']?.contains('tratamiento especificado no existe') ?? false) {
        errorMessage = 'El tratamiento seleccionado no existe en el historial del paciente.';
      }
      throw Exception(errorMessage);
    }
  }

  Future<Map<String, dynamic>> subirDocumento(
      String correoRegistrador, String pacienteCorreo, File file, String nombrePaciente) async {
    final url = Uri.parse('$baseUrl/api/historial/subir-documento');
    final request = http.MultipartRequest('POST', url);
    request.fields['correo'] = correoRegistrador;
    request.fields['pacienteCorreo'] = pacienteCorreo;
    request.fields['nombrePaciente'] = nombrePaciente;
    request.files.add(
      await http.MultipartFile.fromPath(
        'documento',
        file.path,
        contentType: MediaType('application', 'pdf'),
      ),
    );
    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      final decoded = jsonDecode(responseBody);
      if (decoded['success'] == true) {
        return decoded;
      } else {
        throw Exception(decoded['error'] ?? 'Error al subir el documento');
      }
    } else {
      throw Exception('Error al subir el documento: ${response.statusCode} - $responseBody');
    }
  }

  Future<Map<String, dynamic>> subirResultadoAnalisis(
      String correoRegistrador, String pacienteCorreo, String ordenId, File file, String nombrePaciente) async {
    final url = Uri.parse('$baseUrl/api/historial/subir-resultado-analisis');
    final request = http.MultipartRequest('POST', url);
    request.fields['correo'] = correoRegistrador;
    request.fields['pacienteCorreo'] = pacienteCorreo;
    request.fields['orden_id'] = ordenId;
    request.fields['nombrePaciente'] = nombrePaciente;
    request.files.add(
      await http.MultipartFile.fromPath(
        'documento',
        file.path,
        contentType: MediaType('application', 'pdf'),
      ),
    );
    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      final decoded = jsonDecode(responseBody);
      if (decoded['success'] == true) {
        return decoded;
      } else {
        throw Exception(decoded['error'] ?? 'Error al subir el resultado de análisis');
      }
    } else {
      throw Exception('Error al subir el resultado de análisis: ${response.statusCode} - $responseBody');
    }
  }

  Future<String> descargarDocumento(String historialId, String documentoId) async {
    final url = Uri.parse('$baseUrl/api/historial/descargar-documento/$historialId/$documentoId');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final bytes = response.bodyBytes;
      final dir = await getTemporaryDirectory();
      final filePath = '${dir.path}/documento-$documentoId.pdf';
      final file = File(filePath);
      await file.writeAsBytes(bytes);
      return filePath;
    } else {
      throw Exception('Error al descargar el documento: ${response.statusCode} - ${response.body}');
    }
  }

  Future<Map<String, dynamic>> generarDiagnostico(String symptomsText) async {
    final url = Uri.parse('$baseUrl/api/historial/generar-diagnostico');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'symptomsText': symptomsText,
      }),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data;
    } else {
      throw Exception('Error al generar diagnóstico: ${response.statusCode} - ${response.body}');
    }
  }

  Future<List<dynamic>> getPacientesAsignados(String medicoId) async {
    final url = Uri.parse('$baseUrl/api/pacientes/obtener-pacientes-asignados?medicoId=$medicoId');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return data['pacientes'] ?? [];
      } else {
        throw Exception(data['error'] ?? 'Error al obtener los pacientes asignados');
      }
    } else {
      throw Exception('Error al obtener los pacientes asignados: ${response.body}');
    }
  }

  Future<List<dynamic>> getPacientes() async {
    final url = Uri.parse('$baseUrl/api/pacientes?rol=Paciente');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al obtener pacientes: ${response.body}');
    }
  }

  Future<List<dynamic>> getNotificaciones(String usuarioId) async {
    final url = Uri.parse('$baseUrl/api/notificaciones?usuarioId=$usuarioId');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al obtener notificaciones: ${response.body}');
    }
  }

  Future<void> marcarTodasNotificacionesBorradas(String usuarioId) async {
    final url = Uri.parse('$baseUrl/api/notificaciones/marcar-todas-borradas');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'usuarioId': usuarioId}),
    );
    if (response.statusCode != 200) {
      try {
        final errorBody = json.decode(response.body);
        throw Exception(errorBody['error'] ?? 'Error al marcar las notificaciones como borradas: ${response.body}');
      } catch (e) {
        throw Exception('Error al marcar las notificaciones como borradas: ${response.body}');
      }
    }
  }

  Future<Map<String, dynamic>> crearNotificacion(Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/api/notificaciones/crear');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      final responseBody = json.decode(response.body);
      throw Exception(responseBody['error'] ?? 'Error al crear la notificación: ${response.body}');
    }
  }

  Future<void> registrarAlarma(String correo, Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/api/alarmas');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'pacienteCorreo': correo, ...data}),
      );
      if (response.statusCode != 201) {
        final errorBody = json.decode(response.body);
        throw Exception(errorBody['error'] ?? 'Error al registrar alarma: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error al registrar alarma: $e');
    }
  }

  Future<void> editarAlarma(String id, Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/api/alarmas/$id');
    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );
      if (response.statusCode != 200) {
        final errorBody = json.decode(response.body);
        throw Exception(errorBody['error'] ?? 'Error al editar alarma: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error al editar alarma: $e');
    }
  }

  Future<void> eliminarAlarma(String id) async {
    final url = Uri.parse('$baseUrl/api/alarmas/$id');
    try {
      final response = await http.delete(url);
      if (response.statusCode != 200) {
        final errorBody = json.decode(response.body);
        throw Exception(errorBody['error'] ?? 'Error al eliminar alarma: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error al eliminar alarma: $e');
    }
  }

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

  Future<Map<String, dynamic>> otorgarPermisoHistorial(String pacienteCorreo, String medicoCorreo) async {
    final url = Uri.parse('$baseUrl/api/pacientes/otorgar-permiso');
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
      throw Exception('Error al otorgar permiso: ${response.body}');
    }
  }

  Future<List<String>> getMedicosConAcceso(String pacienteCorreo) async {
    final url = Uri.parse('$baseUrl/api/pacientes/medicos-con-acceso?pacienteCorreo=$pacienteCorreo');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        List<dynamic> medicos = data['medicos'] ?? [];
        return medicos.map((medico) => medico['usuarioId'].toString()).toList();
      } else {
        throw Exception(data['error'] ?? 'Error al obtener médicos con acceso');
      }
    } else {
      throw Exception('Error al obtener médicos con acceso: ${response.body}');
    }
  }

  Future<List<dynamic>> getAlarmas(String correo) async {
    final url = Uri.parse('$baseUrl/api/alarmas?correo=$correo');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data['alarmas'] ?? [];
        } else {
          throw Exception(data['error'] ?? 'Error al obtener las alarmas');
        }
      } else {
        throw Exception('Error al obtener las alarmas: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error al obtener las alarmas: $e');
    }
  }

  Future<void> enviarNotificaciones(List<String> usuarioIds, String contenido) async {
    final url = Uri.parse('$baseUrl/api/notificaciones/enviar');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'usuarioIds': usuarioIds,
        'contenido': contenido,
        'fecha': DateTime.now().toIso8601String(),
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('Error al enviar notificaciones: ${response.body}');
    }
  }
}